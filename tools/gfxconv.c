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

/* Some headers for dealing with IFF files */
#define FORM 0x464f524d
#define ILBM 0x494c424d
#define PBM 0x50424d20
#define BMHD 0x424d4844
#define CMAP 0x434d4150
#define BODY 0x424f4459

int main(int argc, char **argv);
void countcolors(void);
int process(void);
Uint32 read_header(FILE *fd);
Uint32 find_chunk(FILE *fd, Uint32 type);
int load_pic(char *name);

/* Needed for ILBM loading (ugly "packed pixels") */
int poweroftwo[] = {1, 2, 4, 8, 16, 32, 64, 128, 256};
SCREEN sc;

int coloruse[16];

int useheight = 0;
int usewidth = 0;
int forcebgcol = -1;
int bgcol = 0;
int cbefore = 0;
int optimalsave = 0;
FILE *handle;
int rows = 0;
int columns = 0;
int x,y,c;
int startadr = 0xa000;
int rawsave = 0;

int main(int argc, char **argv)
{
  char *srcname = NULL;
  char *destname = NULL;

  if (argc < 2)
  {
    printf("Usage: gfxconv <lbm> <prg> + switches\n\n"
           "Switches are:\n"
           "/hXX Clip picture height to XX\n"
           "/wXX Clip picture width to XX\n"
           "/bXX Set background ($D021) color to XX\n"
           "     By default it's the most used color.\n"
           "/sXX Set picture start address in hex (default a000)\n"
           "/r   Raw save (no .PRG start address included)\n"
           "/o   Optimal save (do not align bitmap & screen data to page boundary)\n"
           "/c   Save color data before bitmap\n");
    return 1;
  }

  printf("* PROCESSING COMMAND LINE\n");
  for (c = 1; c < argc; c++)
  {
    if ((argv[c][0] == '-') || (argv[c][0] == '/'))
    {
      char cmd = tolower(argv[c][1]);
      switch (cmd)
      {
        case 'h':
        sscanf(&argv[c][2], "%d", &useheight);
        break;

        case 'w':
        sscanf(&argv[c][2], "%d", &usewidth);
        break;

        case 'b':
        sscanf(&argv[c][2], "%d", &forcebgcol);
        break;

        case 's':
        sscanf(&argv[c][2], "%x", &startadr);
        break;

        case 'r':
        rawsave = 1;
        break;

        case 'c':
        cbefore = 1;
        break;

        case 'o':
        optimalsave = 1;
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
    printf("  Source & destination filenames needed!\n");
    return 1;
  }

  printf("* LOADING PICTURE\n");
  if (!load_pic(srcname))
  {
    printf("Could not open input!\n");
    return 1;
  }
  if ((useheight > 0) && (useheight < sc.sizey)) sc.sizey = useheight;
  if ((usewidth > 0) && (usewidth < sc.sizex))
  {
    for (y = 0; y < sc.sizey; y++)
    {
      memmove(sc.data+usewidth*y,sc.data+sc.sizex*y,usewidth);
    }
    sc.sizex = usewidth;
  }

  if (sc.sizey & 7)
  {
    printf("Picture height must be multiple of 8!\n");
    return 1;
  }
  if (sc.sizex & 7)
  {
    printf("Picture width must be multiple of 8!\n");
    return 1;
  }
  if (sc.sizey > 200)
  {
    printf("Picture height must not exceed 200!\n");
  }
  if (sc.sizex > 320)
  {
    printf("Picture width must not exceed 320!\n");
    return 1;
  }
  rows = (sc.sizey)/8;
  columns = (sc.sizex)/8;
  countcolors();
  printf("Columns %d rows %d\n", columns, rows);

  printf("* CREATING DESTINATION FILE\n");
  handle = fopen(destname, "wb");
  if (!handle)
  {
    printf("cmd happened!\n");
    return 1;
  }
  if (process())
  {
    printf("Out of memory while processing!\n");
    fclose(handle);
    return 1;
  }
  printf("* CLOSING DESTINATION & EXITING\n");
  fclose(handle);
  return 0;
}

void countcolors(void)
{
  int biggest = 0;

  for (c = 0; c < 16; c++) coloruse[c] = 0;

  for (y = 0; y < sc.sizey; y++)
  {
    for (x = 0; x < sc.sizex; x += 2)
    {
      sc.data[y*sc.sizex+x] &= 15;
      coloruse[sc.data[y*sc.sizex+x]]++;
    }
  }
  for (c = 0; c < 16; c++)
  {
    if (coloruse[c] > biggest)
    {
      bgcol = c;
      biggest = coloruse[c];
    }
  }
  if (forcebgcol != -1) bgcol = forcebgcol & 15;
}

int process(void)
{
  int row, col;
  unsigned char *pixptr;
  unsigned char *screenbuf = malloc(1024);
  unsigned char *colorbuf = malloc(1024);
  unsigned char *pixelbuf = malloc(8192);

  if ((!screenbuf) || (!colorbuf) || (!pixelbuf))
  {
    return 1;
  }

  memset(screenbuf, 0, 1024);
  memset(colorbuf, 0, 1024);
  memset(pixelbuf, 0, 8192);
  pixptr = pixelbuf;

  for (row = 0; row < rows; row++)
  {
    for (col = 0; col < columns; col++)
    {
      int color[3], t = 0;

      color[0]=-1;
      color[1]=-1;
      color[2]=-1;

      for (c = 0; c < 16; c++) coloruse[c] = 0;
      for (y = row*8; y < row*8+8; y++)
      {
        for (x = col*8; x < col*8+8; x += 2)
        {
          if (sc.data[y*sc.sizex+x] != bgcol) coloruse[sc.data[y*sc.sizex+x]]++;
        }
      }

      for (c = 0; c < 16; c++)
      {
        if (coloruse[c] > 0)
        {
          if (color[0]==-1)
          {
            color[0] = c;
          }
          else
          {
            if (color[1]==-1)
            {
              color[1] = c;
            }
            else
            {
              if (color[2]==-1)
              {
                color[2] = c;
              }
            }
          }

          t++;
          if (t==3) break;
        }
      }

      for (c = 0; c<3; c++)
      {
        if (color[c]==-1) color[c]=0;
      }

      screenbuf[row*columns+col] = (color[0] << 4) | color[1];
      colorbuf[row*columns+col] = color[2];

      for (y = 0; y < 8; y++)
      {
        int value = 0;

        for (x = 0; x < 4; x++)
        {
          unsigned char pixel = sc.data[(y+row*8)*sc.sizex+col*8+x*2];

          value <<= 2;
          if (pixel != bgcol)
          {
            if (pixel == color[0]) value |= 1;
            else
            {
              if (pixel == color[1]) value |= 2;
              else value |= 3;
            }
          }
        }
        *pixptr++ = value;
      }
    }
  }

  if (!rawsave)
  {
    fwritele16(handle, startadr);
  }
  if (optimalsave)
  {
  if (!cbefore)
  {
    fwrite(pixelbuf, rows*columns*8, 1, handle);
    fwrite(screenbuf, rows*columns, 1, handle);
    fwrite(colorbuf, rows*columns, 1, handle);
  }
  else
  {
    fwrite(screenbuf, rows*columns, 1, handle);
    fwrite(colorbuf, rows*columns, 1, handle);
    fwrite(pixelbuf, rows*columns*8, 1, handle);
  }
  }
  else
  {
  if (!cbefore)
  {
    fwrite(pixelbuf, ((rows*columns*8+255)/256)*256, 1, handle);
    fwrite(screenbuf, ((rows*columns+255)/256)*256, 1, handle);
    fwrite(colorbuf, ((rows*columns+255)/256)*256, 1, handle);
  }
  else
  {
    fwrite(screenbuf, ((rows*columns+255)/256)*256, 1, handle);
    fwrite(colorbuf, ((rows*columns+255)/256)*256, 1, handle);
    fwrite(pixelbuf, ((rows*columns*8+255)/256)*256, 1, handle);
  }
  }
  return 0;
}

Uint32 read_header(FILE *fd)
{
  Uint32 type;

  /* Go to the beginning */
  fseek(fd, 0, SEEK_SET);

  /* Is it a FORM-type IFF file? */
  type = freadhe32(fd);
  if (type != FORM) return 0;

  /* Go to the identifier */
  fseek(fd, 8, SEEK_SET);
  type = freadhe32(fd);
  return type;
}

Uint32 find_chunk(FILE *fd, Uint32 type)
{
  Uint32 length, thischunk, thislength, pos;

  /* Get file length so we know how much data to go thru */
  fseek(fd, 4, SEEK_SET);
  length = freadhe32(fd) + 8;

  /* Now go to the first chunk */
  fseek(fd, 12, SEEK_SET);

  for (;;)
  {
    /* Read type & length, check for match */
    thischunk = freadhe32(fd);
    thislength = freadhe32(fd);
    if (thischunk == type)
    {
      return thislength;
    }

    /* No match, skip over this chunk (pad byte if odd size) */
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

    /* Quit if gone to the end */
    if (pos >= length) break;
  }
  return 0;
}

int load_pic(char *name)
{
  FILE *fd = fopen(name, "rb");
  Uint32 type;

  /* Couldn't open */
  if (!fd) return 0;

  type = read_header(fd);

  /* Not an IFF file */
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
        Uint8 compression;
        int colors = 256;
        Uint32 bodylength;

        /*
         * Hop over the "hotspot", planes & masking (stencil pictures are
         * always saved as ILBMs!
         */
        fseek(fd, 6, SEEK_CUR);
        compression = fread8(fd);
        fread8(fd);
        fread8(fd);
        fread8(fd);
        /*
         * That was all we needed of the BMHD, now the CMAP (optional hehe!)
         */
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
        /*
         * Now the BODY chunk, this is important!
         */
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

            /* Run-length encoding */
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
        Uint8 compression;
        Uint8 planes;
        Uint8 mask;
        int colors;
        Uint32 bodylength;

        /*
         * Hop over the "hotspot"
         */
        fseek(fd, 4, SEEK_CUR);
        planes = fread8(fd);
        mask = fread8(fd);
        compression = fread8(fd);
        fread8(fd);
        fread8(fd);
        fread8(fd);
        colors = poweroftwo[planes];
        if (mask > 1) mask = 0;
        /*
         * That was all we needed of the BMHD, now the CMAP (optional hehe!)
         */
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
        /*
         * Now the BODY chunk, this is important!
         */
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



