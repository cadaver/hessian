//
// Graphics convertor
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <SDL/SDL_types.h>
#include "fileio.h"

typedef struct
{
    int sizex;
    int sizey;
    unsigned char *data;
    int red[256];
    int green[256];
    int blue[256];
} SCREEN;

typedef struct
{
    Uint16 xsize;
    Uint16 ysize;
    Sint16 xhot;
    Sint16 yhot;
    Uint32 offset;
} SPRITEHEADER;

typedef struct
{
    Uint32 type;
    Uint32 offset;
} BLOCKHEADER;

// Modes 
#define NORMAL 1
#define PALETTE 2
#define BLOCK 3
#define SPRITE 4

// Block types 
#define BLOCK_NORMAL 0
#define BLOCK_SOLID 1

// Some headers for dealing with IFF files 
#define FORM 0x464f524d
#define ILBM 0x494c424d
#define PBM 0x50424d20
#define BMHD 0x424d4844
#define CMAP 0x434d4150
#define BODY 0x424f4459

int main(int argc, char **argv);
Uint32 read_header(FILE *fd);
Uint32 find_chunk(FILE *fd, Uint32 type);
int load_pic(char *name);
void convert_sprite(int x, int y, int xsize, int ysize);
int convert_block(int x, int y, int xsize, int ysize);
int checkedge(int x, int y);

// Needed for ILBM loading (ugly "packed pixels")
int poweroftwo[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
SCREEN sc;
BLOCKHEADER bh;
SPRITEHEADER sprh;

int blockxsize = 16;
int blockysize = 16;
int tcolor = 252;
int rcolor = 254;
int hcolor = 253;
int mode = NORMAL;
int useheight = 0;
int optimize = 0;
FILE *handle;

int main(int argc, char **argv)
{
    char *srcname = NULL;
    char *destname = NULL;
    int c;

    if (argc < 2)
    {
        printf("Converts LBM pictures for use with BME library\nUsage: bmeconv <source> <dest> + switches anywhere\n\n"
               "Switches are:\n"
               "/n   Normal (rawdata) conversion\n"
               "/p   Palette save\n"
               "/b   Block conversion\n"
               "/s   Sprite conversion\n"
               "/o   Optimize sprite sizes\n"
               "/xXX Set block X size to XX (default 16)\n"
               "/yXX Set block Y size to XX (default 16)\n"
               "/cXX Clip picture height to XX\n"
               "/tXX Set transparent color to XX (default 252)\n"
               "/rXX Set sprite rectangle color to XX (default 254)\n"
               "/hXX Set hotspot color to XX (default 253)\n");
        return 1;
    }

    for (c = 1; c < argc; c++)
    {
        if ((argv[c][0] == '-') || (argv[c][0] == '/'))
        {
            char temp = tolower(argv[c][1]);
            switch (temp)
            {
                case 'n':
                mode = NORMAL;
                break;

                case 'p':
                mode = PALETTE;
                break;

                case 'b':
                mode = BLOCK;
                break;

                case 's':
                mode = SPRITE;
                break;

                case 'x':
                sscanf(&argv[c][2], "%d", &blockxsize);
                break;

                case 'y':
                sscanf(&argv[c][2], "%d", &blockysize);
                break;

                case 'c':
                sscanf(&argv[c][2], "%d", &useheight);
                break;

                case 't':
                sscanf(&argv[c][2], "%d", &tcolor);
                break;

                case 'h':
                sscanf(&argv[c][2], "%d", &hcolor);
                break;

                case 'r':
                sscanf(&argv[c][2], "%d", &rcolor);
                break;

                case 'o':
                optimize = 1;
                break;
            }
        }
        else
        {
            if (srcname == NULL)
            {
                srcname = argv[c];
            }
            else
            {
                if (destname == NULL)
                {
                    destname = argv[c];
                }
            }
        }
    }
    if ((!srcname) || (!destname))
    {
        printf("Source & destination filenames needed!\n");
        return 1;
    }

    if (!load_pic(srcname))
    {
        printf("Unable to load source file!\n");
        return 1;
    }
    if ((useheight > 0) && (useheight < sc.sizey)) sc.sizey = useheight;

    handle = fopen(destname, "wb");
    if (!handle)
    {
        printf("Unable to create destination file!\n");
        return 1;
    }

    switch(mode)
    {
        case NORMAL:
        fwrite(sc.data, sc.sizex * sc.sizey, 1, handle);
        break;

        case PALETTE:
        {
            int c;

            for (c = 0; c < 256; c++)
            {
                fwrite8(handle, sc.red[c]);
                fwrite8(handle, sc.green[c]);
                fwrite8(handle, sc.blue[c]);
            }
        }
        break;

        case BLOCK:
        {
            int xb = sc.sizex / blockxsize;
            int yb = sc.sizey / blockysize;
            int n = xb * yb;
            int xc, yc;
            int datastart;

            // Write amount of blocks & blocksize
            fwritele32(handle, n);
            fwritele32(handle, blockxsize);
            fwritele32(handle, blockysize);
            // Now jump over header (not written yet)
            fseek(handle, n * sizeof(BLOCKHEADER), SEEK_CUR);
            n = 0;

            datastart = ftell(handle);

            for (yc = 0; yc < yb; yc++)
            {
                for (xc = 0; xc < xb; xc++)
                {
                    int offset = ftell(handle);
                    bh.offset = offset - datastart;
                    bh.type = convert_block(xc * blockxsize, yc * blockysize,blockxsize, blockysize);
                    offset = ftell(handle);
                    // Now fwrite header
                    fseek(handle, 12 + n * sizeof(BLOCKHEADER), SEEK_SET);
                    fwritele32(handle, bh.type);
                    fwritele32(handle, bh.offset);
                    // Go back to blockdatas
                    fseek(handle, offset, SEEK_SET);
                    n++;
                }
            }
        }
        break;

        case SPRITE:
        {
            int datastart;
            int xc, yc;
            int n=0;
            int xsize, ysize;
            int xhot, yhot;
            int offset;
            for (yc = 0; yc < sc.sizey-2; yc++)
            {
                for (xc = 0; xc < sc.sizex-2; xc++)
                {
                    if (checkedge(xc, yc))
                    {
                        n++;
                    }
                }
            }

            // Write amount of sprites
            fwritele32(handle, n);
            // Now jump over header (not written yet)
            fseek(handle, n * sizeof(SPRITEHEADER), SEEK_CUR);

            datastart = ftell(handle);

            n = 0;
            for (yc = 0; yc < sc.sizey-2; yc++)
            {
                for (xc = 0; xc < sc.sizex-2; xc++)
                {
                    if (checkedge(xc, yc))
                    {
                        int xs,ys;
                        int txc = xc+1;
                        int tyc = yc+1;
                        xsize=0;ysize=0;
                        ys=yc+1;
                        for(xs=xc+1;xs<sc.sizex;xs++)
                        {
                            if ((sc.data[xs+ys*sc.sizex]==rcolor) || (sc.data[xs+ys*sc.sizex]==hcolor)) break;
                            xsize++;
                        }
                        xs=xc+1;
                        for(ys=yc+1;ys<sc.sizey;ys++)
                        {
                            if ((sc.data[xs+ys*sc.sizex]==rcolor) || (sc.data[xs+ys*sc.sizex]==hcolor)) break;
                            ysize++;
                        }
                        xhot=0;yhot=0;
                        for (xs=xc+1;xs<(xc+xsize+1);xs++)
                        {
                            ys=yc;
                            if(sc.data[xs+ys*sc.sizex]==hcolor) xhot=xs-xc-1;
                            ys=yc+ysize+1;
                            if(sc.data[xs+ys*sc.sizex]==hcolor) xhot=xs-xc-1;
                        }
                        for (ys=yc+1;ys<(yc+ysize+1);ys++)
                        {
                            xs=xc;
                            if(sc.data[xs+ys*sc.sizex]==hcolor) yhot=ys-yc-1;
                            xs=xc+xsize+1;
                            if(sc.data[xs+ys*sc.sizex]==hcolor) yhot=ys-yc-1;
                        }

                        if (optimize)
                        {
                            int sizechange = 0;

                            for (ys=tyc;ys<tyc+ysize;ys++)
                            {
                                int t = 0;
                                for (xs=txc;xs<txc+xsize;xs++)
                                {
                                    if(sc.data[xs+ys*sc.sizex]==tcolor) t++;
                                }
                                if (t < xsize)
                                {
                                    sizechange = ys-tyc;
                                    break;
                                }
                            }
                            tyc += sizechange;
                            ysize -= sizechange;
                            yhot -= sizechange;

                            sizechange = 0;
                            for (ys=tyc+ysize-1;ys>=tyc;ys--)
                            {
                                int t = 0;
                                for (xs=txc;xs<txc+xsize;xs++)
                                {
                                    if(sc.data[xs+ys*sc.sizex]==tcolor) t++;
                                }
                                if (t < xsize)
                                {
                                    sizechange = tyc+ysize-(ys+1);
                                    break;
                                }
                            }
                            ysize -= sizechange;

                            sizechange = 0;

                            for (xs=txc;xs<txc+xsize;xs++)
                            {
                                int t = 0;
                                for (ys=tyc;ys<tyc+ysize;ys++)
                                {
                                    if(sc.data[xs+ys*sc.sizex]==tcolor) t++;
                                }
                                if (t < ysize)
                                {
                                    sizechange = xs-txc;
                                    break;
                                }
                            }
                            txc += sizechange;
                            xsize -= sizechange;
                            xhot -= sizechange;

                            sizechange = 0;
                            for (xs=txc+xsize-1;xs>=txc;xs--)
                            {
                                int t = 0;
                                for (ys=tyc;ys<tyc+ysize;ys++)
                                {
                                    if(sc.data[xs+ys*sc.sizex]==tcolor) t++;
                                }
                                if (t < ysize)
                                {
                                    sizechange = txc+xsize-(xs+1);
                                    break;
                                }
                            }
                            xsize -= sizechange;
                        }

                        offset = ftell(handle);
                        sprh.offset = offset - datastart;
                        sprh.xsize=xsize;
                        sprh.ysize=ysize;
                        sprh.xhot=xhot;
                        sprh.yhot=yhot;
                        // Now write header
                        fseek(handle, 4 + n * sizeof(SPRITEHEADER), SEEK_SET);
                        fwritele16(handle, sprh.xsize);
                        fwritele16(handle, sprh.ysize);
                        fwritele16(handle, sprh.xhot);
                        fwritele16(handle, sprh.yhot);
                        fwritele32(handle, sprh.offset);
                        fseek(handle, offset, SEEK_SET);
                        // Write spritedata
                        convert_sprite(txc,tyc,xsize,ysize);
                        n++;
                    }
                }
            }
            break;
        }
    }
    fclose(handle);
    return 0;
}

int checkedge(int x, int y)
{
    if (sc.data[x+y*sc.sizex]==rcolor)
    {
        if ((sc.data[x+1+y*sc.sizex]==rcolor) || (sc.data[x+1+y*sc.sizex]==hcolor))
        {
            if ((sc.data[x+(y+1)*sc.sizex]==rcolor) || (sc.data[x+(y+1)*sc.sizex]==hcolor))
            {
                if ((sc.data[x+1+(y+1)*sc.sizex]!=rcolor) && (sc.data[x+1+(y+1)*sc.sizex]!=hcolor)) return 1;
            }
        }
    }
    return 0;
}

int convert_block(int x, int y, int xsize, int ysize)
{
    int t;
    int tslice;
    int xc;
    int yc;
    int rowendmark = 255;
    int blockendmark = 0;
    int slicelength;
    int slicestartx;

    t = 0;
    for (yc = 0; yc < ysize; yc++)
    {
        for (xc = 0; xc < xsize; xc++)
        {
            if (sc.data[x+xc + (y+yc)*sc.sizex] == tcolor) t++;
        }
    }
    if (!t) // Solid block 
    {
        for (yc = 0; yc < ysize; yc++)
        {
            fwrite(&sc.data[x + (y+yc)*sc.sizex], xsize, 1, handle);
        }
        return BLOCK_SOLID;
    }

    for (yc = 0; yc < ysize; yc++)
    {
        t = 0;
        for (xc = 0; xc < xsize; xc++)
        {
            if (sc.data[x+xc + (y+yc)*sc.sizex] == tcolor) t++;
        }
        if (t < xsize) // Nonempty row
        {
            // Init empty/nonempty slice state machine
            if (sc.data[x + (y+yc)*sc.sizex] == tcolor) tslice = 1;
            else tslice = 0;
            xc = 0;
            slicelength = 0;
            slicestartx = xc;

            while (xc < xsize)
            {
                if (tslice)
                {
                    if (sc.data[x+xc + (y+yc)*sc.sizex] == tcolor)
                    {
                        slicelength++;
                    }
                    else
                    {
                        tslice = 0;
                        if (slicelength)
                        {
                            slicelength += 128;
                            fwrite8(handle, slicelength);
                            slicelength = 1;
                            slicestartx = xc;
                        }
                    }
                    if (slicelength == 126)
                    {
                        slicelength += 128;
                        fwrite8(handle, slicelength);
                        slicelength = 0;
                        slicestartx = xc+1;
                    }
                }
                else
                {
                    if (sc.data[x+xc + (y+yc)*sc.sizex] != tcolor)
                    {
                        slicelength++;
                    }
                    else
                    {
                        tslice = 1;
                        if (slicelength)
                        {
                            fwrite8(handle, slicelength);
                            fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
                            slicelength = 1;
                            slicestartx = xc;
                        }
                    }
                    if (slicelength == 127)
                    {
                        fwrite8(handle, slicelength);
                        fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
                        slicelength = 0;
                        slicestartx = xc+1;
                    }
                }
                xc++;
            }
            // Write last slice only if it's nonempty
            if ((!tslice) && (slicelength))
            {
                fwrite8(handle, slicelength);
                fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
            }
        }
        // Write row endmark
        fwrite(&rowendmark, 1, 1, handle);
    }
    fwrite(&blockendmark, 1, 1, handle);
    return BLOCK_NORMAL;
}

void convert_sprite(int x, int y, int xsize, int ysize)
{
    int t;
    int tslice;
    int xc;
    int yc;
    int rowendmark = 255;
    int blockendmark = 0;
    int slicelength;
    int slicestartx;

    for (yc = 0; yc < ysize; yc++)
    {
        t = 0;
        for (xc = 0; xc < xsize; xc++)
        {
            if (sc.data[x+xc + (y+yc)*sc.sizex] == tcolor) t++;
        }
        if (t < xsize) // Nonempty row
        {
            // Init empty/nonempty slice state machine
            if (sc.data[x + (y+yc)*sc.sizex] == tcolor) tslice = 1;
            else tslice = 0;
            xc = 0;
            slicelength = 0;
            slicestartx = xc;

            while (xc < xsize)
            {
                if (tslice)
                {
                    if (sc.data[x+xc + (y+yc)*sc.sizex] == tcolor)
                    {
                        slicelength++;
                    }
                    else
                    {
                        tslice = 0;
                        if (slicelength)
                        {
                            slicelength += 128;
                            fwrite8(handle, slicelength);
                            slicelength = 1;
                            slicestartx = xc;
                        }
                    }
                    if (slicelength == 126)
                    {
                        slicelength += 128;
                        fwrite8(handle, slicelength);
                        slicelength = 0;
                        slicestartx = xc+1;
                    }
                }
                else
                {
                    if (sc.data[x+xc + (y+yc)*sc.sizex] != tcolor)
                    {
                        slicelength++;
                    }
                    else
                    {
                        tslice = 1;
                        if (slicelength)
                        {
                            fwrite8(handle, slicelength);
                            fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
                            slicelength = 1;
                            slicestartx = xc;
                        }
                    }
                    if (slicelength == 127)
                    {
                        fwrite8(handle, slicelength);
                        fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
                        slicelength = 0;
                        slicestartx = xc+1;
                    }
                }
                xc++;
            }
            // Write last slice only if it's nonempty
            if ((!tslice) && (slicelength))
            {
                fwrite8(handle, slicelength);
                fwrite(&sc.data[x+slicestartx + (y+yc)*sc.sizex], slicelength, 1, handle);
            }
        }
        // Write row endmark
        fwrite(&rowendmark, 1, 1, handle);
    }
    fwrite(&blockendmark, 1, 1, handle);
}

Uint32 read_header(FILE *fd)
{
    Uint32 type;

    // Go to the beginning 
    fseek(fd, 0, SEEK_SET);

    // Is it a FORM-type IFF file? 
    type = freadhe32(fd);
    if (type != FORM) return 0;

    // Go to the identifier
    fseek(fd, 8, SEEK_SET);
    type = freadhe32(fd);
    return type;
}

Uint32 find_chunk(FILE *fd, Uint32 type)
{
    Uint32 length, thischunk, thislength, pos;

    // Get file length so we know how much data to go thru 
    fseek(fd, 4, SEEK_SET);
    length = freadhe32(fd) + 8;

    // Now go to the first chunk 
    fseek(fd, 12, SEEK_SET);

    for (;;)
    {
        // Read type & length, check for match 
        thischunk = freadhe32(fd);
        thislength = freadhe32(fd);
        if (thischunk == type)
        {
            return thislength;
        }

        // No match, skip over this chunk (pad byte if odd size) 
        if (thislength & 1)
        {
            fseek(fd, thislength + 1, SEEK_CUR);
            pos = ftell(fd);
        }
        else
        {
            fseek(fd, thislength, SEEK_CUR);
            pos = ftell(fd);
        }

        // Quit if gone to the end 
        if (pos >= length) break;
    }
    return 0;
}

int load_pic(char *name)
{
    FILE *fd = fopen(name, "rb");
    Uint32 type;

    // Couldn't open 
    if (!fd) return 0;

    type = read_header(fd);

    // Not an IFF file 
    if (!type)
    {
        fclose(fd);
        return 0;
    }

    switch(type)
    {
        case PBM:
        {
            if (find_chunk(fd, BMHD))
            {
                Uint16 sizex = freadhe16(fd);
                Uint16 sizey = freadhe16(fd);
                unsigned char compression;
                int colors = 256;
                Uint32 bodylength;

                //
                // Hop over the "hotspot", planes & masking (stencil pictures
                // are always saved as ILBMs!
                //

                fseek(fd, 6, SEEK_CUR);
                compression = fread8(fd);
                fread8(fd);
                fread8(fd);
                fread8(fd);

                // That was all we needed of the BMHD, now the CMAP

                if (find_chunk(fd, CMAP))
                {
                    int count;
                    for (count = 0; count < colors; count++)
                    {
                        sc.red[count] = fread8(fd) >> 2;
                        sc.green[count] = fread8(fd) >> 2;
                        sc.blue[count] = fread8(fd) >> 2;
                    }
                }

                // Now the BODY chunk
                 
                bodylength = find_chunk(fd, BODY);

                if (bodylength)
                {
                    sc.sizex = sizex;
                    sc.sizey = sizey;
                    sc.data = malloc(sc.sizex * sc.sizey);
                    if (!sc.data)
                    {
                        fclose(fd);
                        return 0;
                    }
                    if (!compression)
                    {
                        int ycount;
                        for (ycount = 0; ycount < sizey; ycount++)
                        {
                            fread(&sc.data[sc.sizex * ycount], sizex, 1, fd);
                        }
                    }
                    else
                    {
                        int ycount;

                        char *ptr = malloc(bodylength);
                        char *origptr = ptr;
                        if (!ptr)
                        {
                            fclose(fd);
                            return 0;
                        }

                        fread(ptr, bodylength, 1, fd);

                        // Run-length encoding 
                        for (ycount = 0; ycount < sizey; ycount++)
                        {
                            int total = 0;
                            while (total < sizex)
                            {
                                signed char decision = *ptr++;
                                if (decision >= 0)
                                {
                                    memcpy(&sc.data[sc.sizex * ycount + total], ptr, decision + 1);
                                    ptr += decision + 1;
                                    total += decision + 1;
                                }
                                if ((decision < 0) && (decision != -128))
                                {
                                    memset(&sc.data[sc.sizex * ycount + total], *ptr++, -decision + 1);
                                    total += -decision + 1;
                                }
                            }
                        }
                        free(origptr);
                    }
                }
            }
        }
        break;

        case ILBM:
        {
            if (find_chunk(fd, BMHD))
            {
                Uint16 sizex = freadhe16(fd);
                Uint16 sizey = freadhe16(fd);
                unsigned char compression;
                unsigned char planes;
                unsigned char mask;
                int colors;
                Uint32 bodylength;

                // Hop over the "hotspot"

                fseek(fd, 4, SEEK_CUR);
                planes = fread8(fd);
                mask = fread8(fd);
                compression = fread8(fd);
                fread8(fd);
                fread8(fd);
                fread8(fd);
                colors = poweroftwo[planes];
                if (mask > 1) mask = 0;

                // That was all we needed of the BMHD, now the CMAP

                if (find_chunk(fd, CMAP))
                {
                    int count;
                    for (count = 0; count < 256; count++)
                    {
                        sc.red[count] = 0;
                        sc.green[count] = 0;
                        sc.blue[count] = 0;
                    }
                    sc.red[255] = 255;
                    sc.green[255] = 255;
                    sc.blue[255] = 255;
                    for (count = 0; count < colors; count++)
                    {
                        sc.red[count] = fread8(fd) >> 2;
                        sc.green[count] = fread8(fd) >> 2;
                        sc.blue[count] = fread8(fd) >> 2;
                    }
                }

                // Now the BODY chunk
                 
                bodylength = find_chunk(fd, BODY);

                if (bodylength)
                {
                    char *ptr;
                    char *origptr;
                    char *unpackedptr;
                    char *workptr;
                    int ycount, plane;
                    int bytes, dbytes;

                    sc.sizex = sizex;
                    sc.sizey = sizey;
                    sc.data = malloc(sc.sizex * sc.sizey);
                    memset(sc.data, 0, sc.sizex * sc.sizey);
                    if (!sc.data)
                    {
                        fclose(fd);
                        return 0;
                    }
                    origptr = malloc(bodylength * 2);
                    ptr = origptr;
                    if (!origptr)
                    {
                        fclose(fd);
                        return 0;
                    }
                    fread(origptr, bodylength, 1, fd);
                    if (compression)
                    {
                        dbytes = sizey * (planes + mask) * ((sizex + 7) / 8);
                        unpackedptr = malloc(dbytes);
                        workptr = unpackedptr;
                        if (!unpackedptr)
                        {
                            fclose(fd);
                            return 0;
                        }
                        bytes = 0;
                        while (bytes < dbytes)
                        {
                            signed char decision = *ptr++;
                            if (decision >= 0)
                            {
                                memcpy(workptr, ptr, decision + 1);
                                workptr += decision + 1;
                                ptr += decision + 1;
                                bytes += decision + 1;
                            }
                            if ((decision < 0) && (decision != -128))
                            {
                                memset(workptr, *ptr++, -decision + 1);
                                workptr += -decision + 1;
                                bytes += -decision + 1;
                            }
                        }
                        free(origptr);
                        origptr = unpackedptr;
                        ptr = unpackedptr;
                    }
                    for (ycount = 0; ycount < sizey; ycount++)
                    {
                        for (plane = 0; plane < planes; plane++)
                        {
                            int xcount = (sizex + 7) / 8;
                            int xcoord = 0;
                            while (xcount)
                            {
                                if (*ptr & 128) sc.data[sc.sizex * ycount + xcoord + 0] |= poweroftwo[plane];
                                if (*ptr & 64 ) sc.data[sc.sizex * ycount + xcoord + 1] |= poweroftwo[plane];
                                if (*ptr & 32 ) sc.data[sc.sizex * ycount + xcoord + 2] |= poweroftwo[plane];
                                if (*ptr & 16 ) sc.data[sc.sizex * ycount + xcoord + 3] |= poweroftwo[plane];
                                if (*ptr & 8  ) sc.data[sc.sizex * ycount + xcoord + 4] |= poweroftwo[plane];
                                if (*ptr & 4  ) sc.data[sc.sizex * ycount + xcoord + 5] |= poweroftwo[plane];
                                if (*ptr & 2  ) sc.data[sc.sizex * ycount + xcoord + 6] |= poweroftwo[plane];
                                if (*ptr & 1  ) sc.data[sc.sizex * ycount + xcoord + 7] |= poweroftwo[plane];
                                ptr++;
                                xcoord += 8;
                                xcount--;
                            }
                        }
                        if (mask)
                        {
                            ptr += (sizex + 7) / 8;
                        }
                    }
                    free(origptr);
                }
            }
        }
        break;
    }
    fclose(fd);
    return 1;
}

