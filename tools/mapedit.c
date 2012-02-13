//
// MAP EDITOR
//

#ifndef __WIN32__
#include <sys/stat.h>
#include <sys/types.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "fileio.h"
#include "cfgfile.h"
#include "bme.h"

#define SPR_FONTS 0
#define SPR_EDITOR 1
#define MAX_LAYERS 4

#define LAYERMEMSIZE 512*1024

unsigned mousex = 160, mousey = 100;
int mouseb, prevmouseb;
int mark = 0;
int copybuffer = 0;
int speed;
int copybufferx, copybuffery;
int markx1, marky1, markx2, marky2;
int scrolllock = 0;
int layermenusel = 0;
int blockx, blocky;
int xpos = 0, ypos = 0;
int key;
int blk = 0;
int cl = 0;
int transparent = 255;
int screenmode = 0;
int layervisible[4] = {1,1,1,1};
char printbuffer[80];
char mapname[13] = {0,0,0,0,0,0,0,0,0,0,0,0,0};
MAPHEADER map;
LAYERHEADER layer[MAX_LAYERS];
Uint16 *layerdataptr[MAX_LAYERS];
Uint16 *temparea;
int minxsize = 20;
int minysize = 13;

extern unsigned char datafile[];

void mainloop(void);
void setscreenmode(void);
void loadmapname(void);
void loadconfig(void);
void saveconfig(void);
void enterfilename(char *text, char *buffer);
void help(void);
void printstatus(void);
void drawalllayers(void);
void drawlayer(int l);
void blockediting(void);
void scrollmap(void);
void generalcommands(void);
void resizelayer(int l, int newxsize, int newysize);
void layeroptions(void);
void loadmap(void);
void savemap(void);
void loadpalette(void);
void loadblocks(void);
void initstuff(void);
void initmap(void);
void handle_int(int a);
void getmousebuttons(void);
void getmousemove(void);

int main(int argc, char *argv[])
{
    io_openlinkeddatafile(datafile);

    initmap();
    loadconfig();
    initstuff();
    loadmap();
    mainloop();
    saveconfig();
    return 0;
}

void loadconfig(void)
{
    FILE *handle = cfgfile_open("mapedit.cfg", "rb");

    if (!handle) return;
    fread(&mapname, sizeof mapname, 1, handle);
    fread(&xpos, sizeof xpos, 1, handle);
    fread(&ypos, sizeof ypos, 1, handle);
    fread(&blk, sizeof blk, 1, handle);
    fread(&cl, sizeof cl, 1, handle);
    fread(&layervisible, sizeof layervisible, 1, handle);
    fread(&screenmode, sizeof screenmode, 1, handle);
    fread(&win_fullscreen, sizeof win_fullscreen, 1, handle);
    fclose(handle);
}

void saveconfig(void)
{
    FILE *handle = cfgfile_open("mapedit.cfg", "wb");

    if (!handle) return;
    fwrite(&mapname, sizeof mapname, 1, handle);
    fwrite(&xpos, sizeof xpos, 1, handle);
    fwrite(&ypos, sizeof ypos, 1, handle);
    fwrite(&blk, sizeof blk, 1, handle);
    fwrite(&cl, sizeof cl, 1, handle);
    fwrite(&layervisible, sizeof layervisible, 1, handle);
    fwrite(&screenmode, sizeof screenmode, 1, handle);
    fwrite(&win_fullscreen, sizeof win_fullscreen, 1, handle);
    fclose(handle);
}

void mainloop(void)
{
    gfx_calcpalette(64, 0, 0, 0);
    gfx_setpalette();

    win_getspeed(60);
    for (;;)
    {
        speed = win_getspeed(60);
        if (speed > 10) speed = 10;
        key = kbd_getkey();
        getmousemove();
        getmousebuttons();
        if ((key == KEY_ESC) || (win_quitted)) break;
        blockediting();
        scrollmap();
        generalcommands();
        gfx_fillscreen(transparent);
        drawalllayers();
        printstatus();
        if (mark)
        {
            int mx, my;
            if (layer[cl].xdivisor) mx = markx1*gfx_blockxsize-xpos/layer[cl].xdivisor;
            else mx = markx1*gfx_blockxsize;
            if (layer[cl].xsize)
            {
                while (mx < 0)
                {
                    mx += layer[cl].xsize*gfx_blockxsize;
                }
                mx %= (layer[cl].xsize*gfx_blockxsize);
            }
            if (layer[cl].ydivisor) my = marky1*gfx_blockysize-ypos/layer[cl].ydivisor;
            else my = marky1*gfx_blockysize;
            if (layer[cl].ysize)
            {
                while (my < 0)
                {
                    my += layer[cl].ysize*gfx_blockysize;
                }
                my %= (layer[cl].ysize*gfx_blockysize);
            }
            gfx_drawsprite(mx,my,0x00010002);
        }
        if (mark==2)
        {
            int mx, my;
            if (layer[cl].xdivisor) mx = markx2*gfx_blockxsize-xpos/layer[cl].xdivisor;
            else mx = markx2*gfx_blockxsize;
            if (layer[cl].xsize)
            {
                while (mx < 0)
                {
                    mx += layer[cl].xsize*gfx_blockxsize;
                }
                mx %= (layer[cl].xsize*gfx_blockxsize);
            }
            if (layer[cl].ydivisor) my = marky2*gfx_blockysize-ypos/layer[cl].ydivisor;
            else my = marky2*gfx_blockysize;
            if (layer[cl].ysize)
            {
                while (my < 0)
                {
                    my += layer[cl].ysize*gfx_blockysize;
                }
                my %= (layer[cl].ysize*gfx_blockysize);
            }
            gfx_drawsprite(mx,my,0x00010003);
        }
        gfx_drawsprite(mousex,mousey,0x00010001);
        gfx_updatepage();

    }
}

void generalcommands(void)
{
    /* Block selecting */
    if (key == KEY_Z) blk--;
    if (key == KEY_X) blk++;
    if (key == KEY_A) blk -= 10;
    if (key == KEY_S) blk += 10;
    if (blk < 0) blk = 0;
    if (blk > (int)gfx_nblocks) blk = gfx_nblocks;

    /* General commands */
    if (key == KEY_SCROLLLOCK) scrolllock ^= 1;
    if (key == KEY_1)
    {
        cl = 0;
        mark = 0;
    }
    if (key == KEY_2)
    {
        cl = 1;
        mark = 0;
    }
    if (key == KEY_3)
    {
        cl = 2;
        mark = 0;
    }
    if (key == KEY_4)
    {
        cl = 3;
        mark = 0;
    }
    if (key == KEY_5) layervisible[0] ^=1;
    if (key == KEY_6) layervisible[1] ^=1;
    if (key == KEY_7) layervisible[2] ^=1;
    if (key == KEY_8) layervisible[3] ^=1;
    if (key == KEY_L) layeroptions();
    if (key == KEY_F3) loadblocks();
    if (key == KEY_F4) loadpalette();
    if (key == KEY_F1) loadmapname();
    if (key == KEY_F2) savemap();
    if (key == KEY_F10) help();
    if (key == KEY_F12)
    {
        screenmode++;
        if (screenmode > GFX_DOUBLESIZE) screenmode = 0;
        setscreenmode();
    }
}

void blockediting(void)
{
    /* Block editing here. Only if layer exists */
    blockx = mousex / gfx_blockxsize;
    blocky = mousey / gfx_blockysize;
    if (layer[cl].xdivisor)
    {                
        blockx = (mousex + xpos/layer[cl].xdivisor) / gfx_blockxsize;
    }
    if (layer[cl].ydivisor)
    {
        blocky = (mousey + ypos/layer[cl].ydivisor) / gfx_blockysize;
    }
    if (layer[cl].xsize) blockx %= layer[cl].xsize;
    if (layer[cl].ysize) blocky %= layer[cl].ysize;
    if ((layer[cl].xsize) && (layer[cl].ysize))
    {
        if (mouseb & 1)
        {
            layerdataptr[cl][blocky*layer[cl].xsize+blockx] = blk;
        }
        if (key == KEY_G)
        {
            blk = layerdataptr[cl][blocky*layer[cl].xsize+blockx];
        }
        if (key == KEY_P)
        {
            int x,y;
            if (copybuffer)
            {
                int c = 0;
                /* Paste will perform differently if wrapping is in use */
                if (layer[cl].xwrap & layer[cl].ywrap)
                {
                    /* Wrap version */
                    for (y = blocky; y < blocky+copybuffery; y++)
                    {
                        for (x = blockx; x < blockx+copybufferx; x++)
                        {
                            int realx = x % layer[cl].xsize;
                            int realy = y % layer[cl].ysize;
                            layerdataptr[cl][realy*layer[cl].xsize+realx] = temparea[c];
                            c++;
                        }
                    }
                }
                else
                {
                    /* Nonwrap version */
                    for (y = blocky; y < blocky+copybuffery; y++)
                    {
                        for (x = blockx; x < blockx+copybufferx; x++)
                        {
                            if ((x < layer[cl].xsize) && (y < layer[cl].ysize))
                            {
                                layerdataptr[cl][y*layer[cl].xsize+x] = temparea[c];
                                c++;
                            }
                        }
                    }
                }
            }
        }

        if ((mouseb & 2) && (!(prevmouseb & 2)))
        {
            switch (mark)
            {
                case 0:
                markx1 = blockx;
                markx2 = blockx;
                marky1 = blocky;
                marky2 = blocky;
                mark = 1;
                break;

                case 1:
                markx2 = blockx;
                marky2 = blocky;
                if ((markx2 >= markx1) && (marky2 >= marky1)) mark = 2;
                else mark = 0;
                break;

                case 2:
                mark = 0;
                break;
            }
        }
        if (markx1 > layer[cl].xsize) mark = 0;
        if (markx2 > layer[cl].xsize) mark = 0;
        if (marky1 > layer[cl].ysize) mark = 0;
        if (marky2 > layer[cl].ysize) mark = 0;
        if (mark == 2)
        {
            int x,y;
            if (key == KEY_F)
            {
                for (y = marky1; y <= marky2; y++)
                {
                    for (x = markx1; x <= markx2; x++)
                    {
                        layerdataptr[cl][y*layer[cl].xsize+x] = blk;
                    }
                }
            }
            if (key == KEY_B)
            {
                int b = blk;
                for (x = markx1; x <= markx2; x++)
                {
                    layerdataptr[cl][marky1*layer[cl].xsize+x] = b;
                    b++;
                }
            }
            if (key == KEY_C)
            {
                int c = 0;
                copybuffer = 1;
                copybufferx = markx2-markx1+1;
                copybuffery = marky2-marky1+1;
                for (y = marky1; y <= marky2; y++)
                {
                    for (x = markx1; x <= markx2; x++)
                    {
                        temparea[c] = layerdataptr[cl][y*layer[cl].xsize+x];
                        c++;
                    }
                }
            }
        }
    }
}

void scrollmap(void)
{
    /* Map scrolling */
    /* Limit is according to the biggest layer */
    int limitx = 0;
    int limity = 0;
    int c;
    for (c = 0; c < MAX_LAYERS; c++)
    {
        if ((layer[c].xsize) && (layer[c].ysize))
        {
            int thislimitx, thislimity;
            thislimitx = (layer[c].xsize-minxsize)*gfx_blockxsize*layer[c].xdivisor;
            if (limitx < thislimitx) limitx = thislimitx;
            thislimity = (layer[c].ysize-minysize)*gfx_blockysize*layer[c].ydivisor;
            if (limity < thislimity) limity = thislimity;
        }
    }
    if (key == KEY_LEFT) xpos -= 32;
    if (key == KEY_RIGHT) xpos += 32;
    if (key == KEY_UP) ypos -= 32;
    if (key == KEY_DOWN) ypos += 32;
    for (c = 0; c < speed; c++)
    {
        if (!scrolllock)
        {
            if (mousex >= 320-16) xpos += 4;
            if (mousey >= 200-16) ypos += 4;
            if (mousex < 16) xpos -= 4;
            if (mousey < 16) ypos -= 4;
        }
    }
    if (xpos < 0) xpos = 0;
    if (ypos < 0) ypos = 0;
    if (xpos > limitx) xpos = limitx;
    if (ypos > limity) ypos = limity;
}

void printstatus(void)
{
    int c;
    gfx_drawblock(8, 8, blk);
    sprintf(printbuffer, "%04d", blk);
    txt_print(32, 8, SPR_FONTS, printbuffer);
    sprintf(printbuffer, "X:%04d", blockx);
    txt_print(8, 170, SPR_FONTS, printbuffer);
    sprintf(printbuffer, "Y:%04d", blocky);
    txt_print(8, 180, SPR_FONTS, printbuffer);
    if (mark==2)
    {
        sprintf(printbuffer, "XSIZE:%04d", markx2 - markx1 + 1);
        txt_print(240, 160, SPR_FONTS, printbuffer);
        sprintf(printbuffer, "YSIZE:%04d", marky2 - marky1 + 1);
        txt_print(240, 170, SPR_FONTS, printbuffer);
    }
    if (scrolllock) txt_print(240, 8, SPR_FONTS, "SCRLOCK");
    sprintf(printbuffer, "L:%1d", cl+1);
    txt_print(64,170, SPR_FONTS, printbuffer);
    sprintf(printbuffer, "V:");
    for (c = 0; c < MAX_LAYERS; c++)
    {
        char layerstring[2];
        layerstring[0] = '1'+c;
        layerstring[1] = 0;
        if (layervisible[c]) strcat(printbuffer,layerstring);
    }
    txt_print(64,180, SPR_FONTS, printbuffer);
    txt_print(240,180, SPR_FONTS, "F10 = HELP");
}

void loadblocks(void)
{
    char textbuffer[13];

    textbuffer[0] = 0;
    enterfilename("LOAD BLOCKS", textbuffer);

    if (gfx_loadblocks(textbuffer))
    {
        memcpy(map.blocksname, textbuffer, 13);
        minxsize = (gfx_virtualxsize + (gfx_blockxsize-1)) / gfx_blockxsize;
        minysize = (gfx_virtualysize + (gfx_blockysize-1)) / gfx_blockysize;
    }
}

void loadpalette(void)
{
    char textbuffer[13];

    textbuffer[0] = 0;
    enterfilename("LOAD PALETTE", textbuffer);

    if (gfx_loadpalette(textbuffer))
    {
        memcpy(map.palettename, textbuffer, 13);
    }
    gfx_calcpalette(64, 0, 0, 0);
    gfx_setpalette();
}

void loadmapname(void)
{
    enterfilename("LOAD MAP", mapname);
    loadmap();
}

void loadmap(void)
{
    FILE *handle;
    int c;

    if (!strlen(mapname)) return;
    handle = fopen(mapname, "rb");
    if (!handle) return;
    /* Load map header */
    fread(&map, sizeof(MAPHEADER), 1, handle);
    /* Load each layer */
    for (c = 0; c < MAX_LAYERS; c++)
    {
        layer[c].xsize = freadle32(handle);
        layer[c].ysize = freadle32(handle);
        layer[c].xdivisor = fread8(handle);
        layer[c].ydivisor = fread8(handle);
        layer[c].xwrap = fread8(handle);
        layer[c].ywrap = fread8(handle);
        if ((layer[c].xsize) && (layer[c].ysize))
        {
            int d;
            for (d = 0; d < layer[c].xsize * layer[c].ysize; d++)
            {
                layerdataptr[c][d] = freadle16(handle);
            }
        }
    }
    fclose(handle);
    /* Load correct blocks & palette */
    gfx_loadblocks((char *)map.blocksname);
    minxsize = (gfx_virtualxsize + (gfx_blockxsize-1)) / gfx_blockxsize;
    minysize = (gfx_virtualysize + (gfx_blockysize-1)) / gfx_blockysize;
    gfx_loadpalette((char *)map.palettename);
    gfx_calcpalette(64, 0, 0, 0);
    gfx_setpalette();
}

void savemap(void)
{
    FILE *handle;
    int c;

    enterfilename("SAVE MAP", mapname);
    if (!strlen(mapname)) return;
    handle = fopen(mapname, "wb");
    if (!handle) return;
    /* Write map header */
    fwrite(&map, sizeof(MAPHEADER), 1, handle);
    /* Write each layer */
    for (c = 0; c < MAX_LAYERS; c++)
    {
        fwritele32(handle, layer[c].xsize);
        fwritele32(handle, layer[c].ysize);
        fwrite8(handle, layer[c].xdivisor);
        fwrite8(handle, layer[c].ydivisor);
        fwrite8(handle, layer[c].xwrap);
        fwrite8(handle, layer[c].ywrap);
        if ((layer[c].xsize) && (layer[c].ysize))
        {
            int d;
            for (d = 0; d < layer[c].xsize * layer[c].ysize; d++)
            {
                fwritele16(handle, map_layerdataptr[c][d]);
            }
        }
    }
    fclose(handle);
}

void help(void)
{
    gfx_fillscreen(0);
    txt_printcenter(0, SPR_FONTS, "MAP EDITOR HELP");
    txt_printcenter(16, SPR_FONTS, "F1 - LOAD MAP");
    txt_printcenter(24, SPR_FONTS, "F2 - SAVE MAP");
    txt_printcenter(32, SPR_FONTS, "F3 - LOAD BLOCKS");
    txt_printcenter(40, SPR_FONTS, "F4 - LOAD PALETTE");
    txt_printcenter(48, SPR_FONTS, "F10 - THIS SCREEN");
    txt_printcenter(56, SPR_FONTS, "F12 - SWITCH SCREENMODE");
    txt_printcenter(64, SPR_FONTS, "ESC - EXIT PROGRAM");
    txt_printcenter(80, SPR_FONTS, "1,2,3,4 - SELECT LAYER TO WORK ON");
    txt_printcenter(88, SPR_FONTS, "5,6,7,8 - TOGGLE LAYER VISIBILITY");
    txt_printcenter(96, SPR_FONTS, "L - LAYER SIZE & OPTIONS");
    txt_printcenter(104, SPR_FONTS, "G - GRAB BLOCK UNDER CURSOR");
    txt_printcenter(112, SPR_FONTS, "C - COPY MARKED AREA");
    txt_printcenter(120, SPR_FONTS, "F,B - FILL MARKED AREA");
    txt_printcenter(128, SPR_FONTS, "P - PASTE MARKED AREA");
    txt_printcenter(136, SPR_FONTS, "Z,X - SELECT BLOCK");
    txt_printcenter(144, SPR_FONTS, "A,S - SELECT BLOCK FAST");
    txt_printcenter(152, SPR_FONTS, "SCROLLLOCK - TOGGLE MOUSE SCROLLING");
    txt_printcenter(160, SPR_FONTS, "I,J,K,M - CHANGE SIZE FAST IN LAYER OPT.");
    txt_printcenter(176, SPR_FONTS, "USE LEFT MOUSEBUTTON TO DRAW AND RIGHT");
    txt_printcenter(184, SPR_FONTS, "MOUSEBUTTON TO MARK AREAS.");
    gfx_updatepage();

    for (;;)
    {
        win_getspeed(60);
        key = kbd_getkey();
        getmousemove();
        getmousebuttons();
        if ((mouseb) || (key)) break;
    }
}



void initmap(void)
{
    int c;
    memset(map.blocksname, 0, sizeof(map.blocksname));
    memset(map.palettename, 0, sizeof(map.palettename));
    memset(mapname, 0, 13);
    for (c = 0; c < MAX_LAYERS; c++)
    {
        layer[c].xsize = 0;
        layer[c].ysize = 0;
        layer[c].xdivisor = 1;
        layer[c].ydivisor = 1;
        layer[c].xwrap = 0;
        layer[c].ywrap = 0;
        layerdataptr[c] = malloc(LAYERMEMSIZE*2);
        if (!layerdataptr[c])
        {
            printf("Out of memory when reserving map area!\n");
            exit(1);
        }
        memset(layerdataptr[c], 0, LAYERMEMSIZE*2);
    }
    layer[0].xsize = minxsize;
    layer[0].ysize = minysize;
    temparea = malloc(LAYERMEMSIZE*2);
    if (!temparea)
    {
        printf("Out of memory when reserving map work area!\n");
        exit(1);
    }
}

void enterfilename(char *text, char *buffer)
{
    int c;
    for (c = strlen(buffer); c < 13; c++) buffer[c] = 0;

    kbd_getascii();

    for (;;)
    {
        int ascii;
        int cursorpos;

        win_getspeed(60);
        key = kbd_getkey();
        ascii = kbd_getascii();
        getmousemove();
        getmousebuttons();

        cursorpos = strlen(buffer);
        if (ascii == 8)
        {
            if (cursorpos)
            {
                buffer[cursorpos-1] = 0;
            }
        }
        if (ascii == 27)
        {
            memset(buffer, 0, 13);
            return;
        }
        if (ascii == 13) return;
        if ((ascii >= 32) && (cursorpos < 12))
        {
            buffer[cursorpos] = ascii;
        }

        gfx_fillscreen(0);
        txt_printcenter(80, SPR_FONTS, text);
        txt_printcenter(90, SPR_FONTS, buffer);
        gfx_updatepage();
    }
}

void drawalllayers(void)
{
    int c;
    for (c = 0; c < MAX_LAYERS; c++)
    {
        if (layervisible[c]) drawlayer(c);
    }
}

void layeroptions(void)
{
    int newsizex = layer[cl].xsize;
    int newsizey = layer[cl].ysize;

    for (;;)
    {
        win_getspeed(60);
        key = kbd_getkey();

        if ((key == KEY_ESC) || (key == KEY_ENTER)) break;
        if (key == KEY_DOWN) layermenusel++;
        if (key == KEY_UP) layermenusel--;
        if (layermenusel < 0) layermenusel = 5;
        if (layermenusel > 5) layermenusel = 0;
        if (key == KEY_I)
        {
            newsizey -= 10;
            if (newsizey < minysize) newsizey = 0;
        }
        if (key == KEY_J)
        {
            newsizex -= 10;
            if (newsizex < minxsize) newsizex = 0;
        }
        if (key == KEY_M)
        {
            if (newsizey) newsizey += 10;
            else newsizey = minysize;
        }
        if (key == KEY_K)
        {
            if (newsizex) newsizex += 10;
            else newsizex = minxsize;
        }
        if (key == KEY_RIGHT)
        {
            switch(layermenusel)
            {
                case 0:
                if (newsizex) newsizex++;
                else newsizex = minxsize;
                break;

                case 1:
                if (newsizey) newsizey++;
                else newsizey = minysize;
                break;

                case 2:
                layer[cl].xdivisor++;
                break;

                case 3:
                layer[cl].ydivisor++;
                break;

                case 4:
                layer[cl].xwrap ^= 1;
                break;

                case 5:
                layer[cl].ywrap ^= 1;
                break;
            }
        }
        if (key == KEY_LEFT)
        {
            switch(layermenusel)
            {
                case 0:
                if (newsizex) newsizex--;
                if (newsizex < minxsize) newsizex = 0;
                break;

                case 1:
                if (newsizey) newsizey--;
                if (newsizey < minysize) newsizey = 0;
                break;

                case 2:
                if (layer[cl].xdivisor) layer[cl].xdivisor--;
                break;

                case 3:
                if (layer[cl].ydivisor) layer[cl].ydivisor--;
                break;

                case 4:
                layer[cl].xwrap ^= 1;
                break;

                case 5:
                layer[cl].ywrap ^= 1;
                break;
            }
        }

        gfx_fillscreen(0);
        sprintf(printbuffer, "LAYER %d OPTIONS", cl+1);
        txt_printcenter(40, SPR_FONTS, printbuffer);
        sprintf(printbuffer, "X SIZE %04d", newsizex);
        txt_printcenter(60, SPR_FONTS, printbuffer);
        sprintf(printbuffer, "Y SIZE %04d", newsizey);
        txt_printcenter(70, SPR_FONTS, printbuffer);
        sprintf(printbuffer, "X DIVISOR %03d", layer[cl].xdivisor);
        txt_printcenter(80, SPR_FONTS, printbuffer);
        sprintf(printbuffer, "Y DIVISOR %03d", layer[cl].ydivisor);
        txt_printcenter(90, SPR_FONTS, printbuffer);
        if (layer[cl].xwrap) txt_printcenter(100, SPR_FONTS, "X WRAP ON");
        else txt_printcenter(100, SPR_FONTS, "X WRAP OFF");
        if (layer[cl].ywrap) txt_printcenter(100, SPR_FONTS, "Y WRAP ON");
        else txt_printcenter(110, SPR_FONTS, "Y WRAP OFF");
        gfx_drawsprite(100, 60+layermenusel*10, 0x00010004);
        gfx_updatepage();

    }

    if ((newsizex != layer[cl].xsize) || (newsizey != layer[cl].ysize))
    {
        resizelayer(cl, newsizex, newsizey);
    }
    mark = 0;
    copybuffer = 0;
}




void drawlayer(int l)
{
    int x,y;
    int realxpos = 0, realypos = 0;
    int blockxpos, finexpos;
    int blockypos, fineypos;
    unsigned short *mapptr;

    /* Check for inactive layer */
    if ((!layer[l].xsize) || (!layer[l].ysize)) return;

    if (layer[l].xdivisor) realxpos = xpos / layer[l].xdivisor;
    if (layer[l].ydivisor) realypos = ypos / layer[l].ydivisor;

    finexpos = realxpos % gfx_blockxsize;
    fineypos = realypos % gfx_blockysize;
    blockxpos = realxpos / gfx_blockxsize;
    blockypos = realypos / gfx_blockysize;

    if (!layer[l].xwrap)
    {
        if ((blockxpos + minxsize) > layer[l].xsize)
        {
            blockxpos = layer[l].xsize - minxsize;
            finexpos = gfx_blockxsize - 1;
        }
    }

    if (!layer[l].ywrap)
    {
        if ((blockypos + minysize) > layer[l].ysize)
        {
            blockypos = layer[l].ysize - minysize;
            fineypos = gfx_blockysize - 1;
        }
    }

    blockxpos %= layer[l].xsize;
    blockypos %= layer[l].ysize;

    for (y = 0; y < minysize+1; y++)
    {
        if (blockypos >= layer[l].ysize) blockypos = 0;
        mapptr = &layerdataptr[l][layer[l].xsize*blockypos];
        for (x = 0; x < minxsize+1; x++)
        {
            int xpos = blockxpos + x;
            if (xpos >= layer[l].xsize) xpos %= layer[l].xsize;
            gfx_drawblock((x*gfx_blockxsize)-finexpos, (y*gfx_blockysize)-fineypos, mapptr[xpos]);
        }
        blockypos++;
    }
}

void resizelayer(int l, int newxsize, int newysize)
{
    int x,y;
    if (newxsize*newysize > LAYERMEMSIZE) return;
    memcpy(temparea, layerdataptr[l], layer[l].xsize*layer[l].ysize*2);
    for (y = 0; y < newysize; y++)
    {
        for (x = 0; x < newxsize; x++)
        {
            layerdataptr[l][y*newxsize+x] = blk;
        }
    }
    for (y = 0; y < layer[l].ysize; y++)
    {
        for (x = 0; x < layer[l].xsize; x++)
        {
            layerdataptr[l][y*newxsize+x] = temparea[y*layer[l].xsize+x];
        }
    }
    layer[l].xsize = newxsize;
    layer[l].ysize = newysize;
    mark = 0;
    copybuffer = 0;
}


void initstuff(void)
{
    win_openwindow("Map Editor V1.26", NULL);
    win_setmousemode(MOUSE_ALWAYS_HIDDEN);
    win_fullscreen = 1;
    setscreenmode();
    kbd_init();
    mou_init();
    if (!gfx_loadsprites(SPR_FONTS, "fonts.spr"))
    {
        win_messagebox("Sprite load error (FONTS.SPR)");
        exit(1);
    }
    if (!gfx_loadsprites(SPR_EDITOR, "editor.spr"))
    {
        win_messagebox("Sprite load error (FONTS.SPR)");
        exit(1);
    }
    io_setfilemode(0); /* Rest of file access happens without datafile */
}

void setscreenmode(void)
{
    if (!gfx_init(320,200,60,screenmode))
    {
        win_messagebox("Graphics init error!\n");
        saveconfig();
        exit(1);
    }
}

void handle_int(int a)
{
    exit(0); /* Atexit functions will be called! */
}

void getmousemove(void)
{
    mou_getpos(&mousex, &mousey);
}

void getmousebuttons(void)
{
    prevmouseb = mouseb;
    mouseb = mou_getbuttons();
}

