/*
 * Sprite Editor V3.0
 */

#define TESTSPR_X 200
#define TESTSPR_Y 48

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <ctype.h>
#include <string.h>
#include "fileio.h"
#include "bme.h"

#define LEFT_BUTTON 1
#define RIGHT_BUTTON 2
#define SINGLECOLOR 0
#define MULTICOLOR 1

#define SPR_C 0
#define SPR_FONTS 1

#define COL_WHITE 0
#define COL_HIGHLIGHT 1

#define COLOR_DELAY 10

typedef struct
{
  unsigned char slicemask;
  unsigned char color;
  signed char hotspotx;
  signed char connectspotx;
  signed char hotspoty;
  signed char connectspoty;
  unsigned char cacheframe;
} SPRHEADER;

typedef struct
{
  short slicemask;
  signed char hotspotx;
  signed char reversehotspotx;
  signed char hotspoty;
  signed char connectspotx;
  signed char reverseconnectspotx;
  signed char connectspoty;
} OLDSPRHEADER;

unsigned char magx[256];
int sliceoffset[] = {0,1,2,21,22,23,42,43,44};

unsigned char cwhite[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35};
unsigned char chl[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,35};
unsigned char *colxlattable[] = {cwhite, chl};
unsigned char textbuffer[80];
unsigned char ib1[80];
int k,l;
unsigned char ascii;
int colordelay = 0;

int mousex = 160;
int mousey = 100;
int mouseb;
int prevmouseb = 0;
int sprnum = 0;
unsigned char *spritedata;
unsigned char ccolor = 2;
int testspr = 0;
int hotspotflash = 0;

unsigned char testsprf[16];
int testsprx = TESTSPR_X;
int testspry = TESTSPR_Y;

unsigned char bgcol = 0;
unsigned char multicol1 = 15;
unsigned char multicol2 = 11;

unsigned char copyconnectx = 0, copyconnecty = 0, copyhotx = 0, copyhoty = 0;
unsigned char copymagx = 0;
unsigned char copybuffer[64] = {0};
signed char hotspotx[256];
signed char hotspoty[256];
signed char connectspotx[256];
signed char connectspoty[256];
unsigned char programname[256];

void handle_int(int a);
void mainloop(void);
void mouseupdate(void);
int initsprites(void);
void drawgrid(void);
void clearspr(void);
void loadspr(void);
void loadoldspr(void);
void savespr(void);
void flipsprx(void);
void flipspry(void);
void editspr(void);
void scrollsprleft(void);
void scrollsprright(void);
void scrollsprup(void);
void scrollsprdown(void);
void changecol(void);
void initstuff(void);
void drawcbar(int x, int y, unsigned char col);
void drawc64sprite(int bx, int by, int num);
void printtext_color(unsigned char *string, int x, int y, unsigned spritefile, int color);
void printtext_center_color(unsigned char *string, int y, unsigned spritefile, int color);
int inputtext(unsigned char *buffer, int maxlength);

extern unsigned char datafile[];

int main (int argc, char *argv[])
{
  FILE *handle;

  io_openlinkeddatafile(datafile);

  ib1[0] = 0; /* Initial filename=empty */
  if (!win_openwindow("Sprite editor", NULL)) return 1;

  handle = fopen("spredit.cfg", "rb");
  if (handle)
  {
    bgcol = fread8(handle);
    multicol1 = fread8(handle);
    multicol2 = fread8(handle);
    fclose(handle);
  }

  initstuff();
  gfx_calcpalette(63,0,0,0);
  gfx_setpalette();
  mainloop();

  handle = fopen("spredit.cfg", "wb");
  if (handle)
  {
    fwrite8(handle, bgcol);
    fwrite8(handle, multicol1);
    fwrite8(handle, multicol2);
    fclose(handle);
  }
  return 0;
}

void mainloop(void)
{
  for (;;)
  {
    win_getspeed(70);
    for (k = 0; k < MAX_KEYS; k++)
    {
      if (win_keytable[k])
      {
        if ((k != KEY_LEFTSHIFT) && (k != KEY_RIGHTSHIFT))
        {
          win_keytable[k] = 0;
          break;
        }
      }
    }
    if (k == 256) k = 0;
    ascii = kbd_getascii();
    if (ascii == 27) break;
    if (k == KEY_W)
    {
      magx[sprnum] ^= 1;
      if (magx[sprnum])
      {
        hotspotx[sprnum] *= 2;
        connectspotx[sprnum] *= 2;
      }
      else
      {
        hotspotx[sprnum] /= 2;
        connectspotx[sprnum] /= 2;
      }
    }
    if (k == KEY_C) clearspr();
    if (k == KEY_V)
    {
      int y,x,c;
      unsigned char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 21; y++)
      {
        for (c = 0; c < 3; c++)
        {
          for (x = 0; x < 4; x++)
          {
            unsigned char bit = (spritedata[sprnum*64+y*3+c] >> (x*2)) & 3;
            if (bit == 2) bit = 1;
            else if (bit == 1) bit = 2;
            spritedata[sprnum*64+y*3+c] &= andtable[x];
            spritedata[sprnum*64+y*3+c] |= (bit << (x*2));
          }
        }
      }
    }
    if (k == KEY_DEL)
    {
      int c;
      for (c = sprnum+1; c < 256; c++)
      {
        memcpy(&spritedata[(c-1)*64], &spritedata[c*64], 64);
        magx[c-1] = magx[c];
        hotspotx[c-1] = hotspotx[c];
        hotspoty[c-1] = hotspoty[c];
        connectspotx[c-1] = connectspotx[c];
        connectspoty[c-1] = connectspoty[c];
      }
    }

    if (k == KEY_B)
    {
      int y,x,c;
      unsigned char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 21; y++)
      {
        for (c = 0; c < 3; c++)
        {
          for (x = 0; x < 4; x++)
          {
            unsigned char bit = (spritedata[sprnum*64+y*3+c] >> (x*2)) & 3;
            if (bit == 3) bit = 1;
            else if (bit == 1) bit = 3;
            spritedata[sprnum*64+y*3+c] &= andtable[x];
            spritedata[sprnum*64+y*3+c] |= (bit << (x*2));
          }
        }
      }
    }
    if (k == KEY_N)
    {
      int y,x,c;
      unsigned char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 21; y++)
      {
        for (c = 0; c < 3; c++)
        {
          for (x = 0; x < 4; x++)
          {
            unsigned char bit = (spritedata[sprnum*64+y*3+c] >> (x*2)) & 3;
            if (bit == 3) bit = 2;
            else if (bit == 2) bit = 3;
            spritedata[sprnum*64+y*3+c] &= andtable[x];
            spritedata[sprnum*64+y*3+c] |= (bit << (x*2));
          }
        }
      }
    }

    if ((k == KEY_COMMA) && (sprnum > 0)) sprnum--;
    if ((k == KEY_COLON) && (sprnum < 255)) sprnum++;

    if (!(win_keytable[KEY_LEFTSHIFT]|win_keytable[KEY_RIGHTSHIFT]))
    {
      if (k == KEY_LEFT)
      {
        scrollsprleft();
        if (!magx[sprnum])
          hotspotx[sprnum] -= 2;
        else
          hotspotx[sprnum] -= 4;
      }
      if (k == KEY_RIGHT)
      {
        scrollsprright();
        if (!magx[sprnum])
          hotspotx[sprnum] += 2;
        else
          hotspotx[sprnum] += 4;
      }
      if (k == KEY_UP)
      {
        scrollsprup();
        hotspoty[sprnum] -= 1;
      }
      if (k == KEY_DOWN)
      {
        scrollsprdown();
        hotspoty[sprnum] += 1;
      }
    }
    if (k == KEY_LEFT)
    {
      if (!magx[sprnum])
        connectspotx[sprnum] -= 2;
      else
        connectspotx[sprnum] -= 4;
    }
    if (k == KEY_RIGHT)
    {
      if (!magx[sprnum])
        connectspotx[sprnum] += 2;
      else
        connectspotx[sprnum] += 4;
    }
    if (k == KEY_UP) connectspoty[sprnum]--;
    if (k == KEY_DOWN) connectspoty[sprnum]++;
    if (k == KEY_X) flipsprx();
    if (k == KEY_Y) flipspry();
    if (k == KEY_P)
    {
      memcpy(copybuffer, &spritedata[sprnum*64],64);
      copymagx     = magx[sprnum];
      copyhotx     = hotspotx[sprnum];
      copyhoty     = hotspoty[sprnum];
      copyconnectx = connectspotx[sprnum];
      copyconnecty = connectspoty[sprnum];
    }
    if (k == KEY_T)
    {
      memcpy(&spritedata[sprnum*64],copybuffer,64);
      magx[sprnum]         = copymagx;
      hotspotx[sprnum]     = copyhotx;
      hotspoty[sprnum]     = copyhoty;
      connectspotx[sprnum] = copyconnectx;
      connectspoty[sprnum] = copyconnecty;
    }

    if (k == KEY_F1) loadspr();
    if (k == KEY_F2) savespr();
    if (k == KEY_F3) loadoldspr();
    if ((k == KEY_2) && (testspr < 15))
    {
      testspr++;
    }
    if ((k == KEY_1) && (testspr > 0))
    {
      testspr--;
    }
    if (k == KEY_3) testsprx -= 4;
    if (k == KEY_4) testsprx += 4;
    if (k == KEY_5) testspry -= 4;
    if (k == KEY_6) testspry += 4;

    if (k == KEY_7)
    {
      testsprf[testspr]--;
      testsprf[testspr] &= 0xff;
    }
    if (k == KEY_8)
    {
      testsprf[testspr]++;
      testsprf[testspr] &= 0xff;
    }

    mouseupdate();
    editspr();
    changecol();
    gfx_fillscreen(254);
    drawgrid();
    {
      int cx = testsprx;
      int cy = testspry;
      for (l = 0; l < 16; l++)
      {
        if (testsprf[l] != 255)
        {
          cx -= hotspotx[testsprf[l]];
          cy -= hotspoty[testsprf[l]];
          if (l)
          {
            cx += connectspotx[testsprf[l-1]];
            cy += connectspoty[testsprf[l-1]];
          }
          drawc64sprite(cx, cy,testsprf[l]);
        }
        else break;
      }
    }

    sprintf(textbuffer, "TESTSPR %03d", testspr);
    printtext_color(textbuffer, 0,150,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "X-POS %03d", testsprx);
    printtext_color(textbuffer, 0,160,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "Y-POS %03d", testspry);
    printtext_color(textbuffer, 0,170,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "FRAME %03d", testsprf[testspr]);
    printtext_color(textbuffer, 0,180,SPR_FONTS,COL_WHITE);
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void clearspr(void)
{
  unsigned char *ptr = &spritedata[sprnum*64];
  memset(ptr, 0, 63);
}

void loadspr(void)
{
  unsigned char ib2[5];
  int phase = 1;
  ib2[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD SPRITEFILE:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("LOAD AT SPRITENUM:",95,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib2,105,SPR_FONTS,COL_HIGHLIGHT);
    }
    gfx_updatepage();
    if (phase == 1)
    {
      int r = inputtext(ib1, 80);
      if (r == -1) return;
      if (r == 1) phase = 2;
    }
    if (phase == 2)
    {
      int r = inputtext(ib2, 5);
      if (r == -1) return;
      if (r == 1)
      {
        int frameindex = 0;
        int oldformat = 0;
        int length;
        int frame;
        FILE *handle;
        sscanf(ib2, "%d", &frame);
        if (frame < 0) frame = 0;
        if (frame > 255) frame = 255;
        handle = fopen(ib1, "rb");
        if (!handle) return;
        fseek(handle, 0, SEEK_END);
        length = ftell(handle);

        // Detect format from offset between the 2 first sprites
        {
          int offset1, offset2;
          fseek(handle, 3, SEEK_SET);
          offset1 = freadle16(handle);
          offset2 = freadle16(handle);
          while (offset2 - offset1 > 8)
            offset2 -= 7;
          if (offset2 - offset1 > 7)
            oldformat = 1;
        }

        if (!oldformat)
        {
          for (;;)
          {
            SPRHEADER tempheader;
            int slice;
            int slicemask = 0;
            Uint16 offset;
  
            fseek(handle, frameindex*2+3, SEEK_SET);
            offset = freadle16(handle);
            offset += 3;
            fseek(handle, offset, SEEK_SET);
  
            tempheader.slicemask = fread8(handle);
            tempheader.color = fread8(handle);
            tempheader.hotspotx = fread8(handle) * 2;
            tempheader.connectspotx = fread8(handle) * 2;
            tempheader.hotspoty = fread8(handle);
            tempheader.connectspoty = fread8(handle);
            tempheader.cacheframe = fread8(handle);
  
            hotspotx[frame] = tempheader.hotspotx;
            hotspoty[frame] = tempheader.hotspoty;
            connectspotx[frame] = tempheader.connectspotx;
            connectspoty[frame] = tempheader.connectspoty;
            magx[frame] = (tempheader.color & 16) >> 4;
            spritedata[frame*64+63] = tempheader.color & 15;
  
            slicemask = ((int)tempheader.slicemask) | (((int)tempheader.color & 128) << 1);
  
            for (slice = 0; slice < 9; slice++)
            {
              if (slicemask & (1 << slice))
              {
                int slicey;
                for (slicey = 0; slicey < 7; slicey++)
                {
                  spritedata[frame * 64 + sliceoffset[slice] + slicey * 3] = fread8(handle);
                }
              }
              else
              {
                int slicey;
                for (slicey = 0; slicey < 7; slicey++)
                {
                  spritedata[frame * 64 + sliceoffset[slice] + slicey * 3] = 0;
                }
              }
            }
            frameindex++;
            frame++;
            if (ftell(handle) >= length) break;
            if (frame > 255) break;
          }
        }
        else
        {
          for (;;)
          {
            OLDSPRHEADER tempheader;            
            int slice;
            Uint16 offset;
  
            fseek(handle, frameindex*2+3, SEEK_SET);
            offset = freadle16(handle);
            offset += 3;
            fseek(handle, offset, SEEK_SET);
  
            tempheader.slicemask = freadle16(handle);
            tempheader.hotspotx = fread8(handle);
            tempheader.reversehotspotx = fread8(handle);
            tempheader.hotspoty = fread8(handle);
            tempheader.connectspotx = fread8(handle);
            tempheader.reverseconnectspotx = fread8(handle);
            tempheader.connectspoty = fread8(handle);
  
            spritedata[frame*64+63] = tempheader.slicemask >> 9;
            hotspotx[frame] = tempheader.hotspotx;
            hotspoty[frame] = tempheader.hotspoty;
            connectspotx[frame] = tempheader.connectspotx;
            connectspoty[frame] = tempheader.connectspoty;
            magx[frame] = spritedata[frame*64+63] >> 4;
            spritedata[frame*64+63] &= 15;
  
            for (slice = 0; slice < 9; slice++)
            {
              if (tempheader.slicemask & (1 << slice))
              {
                int slicey;
                for (slicey = 0; slicey < 7; slicey++)
                {
                  spritedata[frame * 64 + sliceoffset[slice] + slicey * 3] = fread8(handle);
                }
              }
              else
              {
                int slicey;
                for (slicey = 0; slicey < 7; slicey++)
                {
                  spritedata[frame * 64 +
                  sliceoffset[slice] + slicey * 3] = 0;
                }
              }
            }
            frameindex++;
            frame++;
            if (ftell(handle) >= length) break;
            if (frame > 255) break;
          }
        }

        fclose(handle);
        return;
      }
    }
  }
}

void loadoldspr(void)
{
  unsigned char ib2[5];
  int phase = 1;
  ib2[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD OLDSTYLE SPRITEFILE:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("LOAD AT SPRITENUM:",95,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib2,105,SPR_FONTS,COL_HIGHLIGHT);
    }
    gfx_updatepage();
    if (phase == 1)
    {
      int r = inputtext(ib1, 80);
      if (r == -1) return;
      if (r == 1) phase = 2;
    }
    if (phase == 2)
    {
      int r = inputtext(ib2, 5);
      if (r == -1) return;
      if (r == 1)
      {
        int frame;
        FILE *handle;
        int maxbytes = 16384;
        sscanf(ib2, "%d", &frame);
        if (frame < 0) frame = 0;
        if (frame > 255) frame = 255;
        maxbytes -= frame*64;
        handle = fopen(ib1, "rb");
        if (!handle) return;
        fread(&spritedata[frame*64], maxbytes, 1, handle);
        fclose(handle);
        return;
      }
    }
  }
}

void savespr(void)
{
  unsigned char ib2[5];
  unsigned char ib3[5];
  int phase = 1;
  ib2[0] = 0;
  ib3[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("SAVE SPRITEFILE:",60,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,70,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("SAVE FROM SPRITENUM:",85,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib2,95,SPR_FONTS,COL_HIGHLIGHT);
    }
    if (phase > 2)
    {
      printtext_center_color("SAVE HOW MANY:",110,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib3,120,SPR_FONTS,COL_HIGHLIGHT);
    }
    gfx_updatepage();
    if (phase == 1)
    {
      int r = inputtext(ib1, 80);
      if (r == -1) return;
      if (r == 1) phase = 2;
    }
    if (phase == 2)
    {
      int r = inputtext(ib2, 5);
      if (r == -1) return;
      if (r == 1) phase = 3;
    }
    if (phase == 3)
    {
      int r = inputtext(ib3, 5);
      if (r == -1) return;
      if (r == 1)
      {
        int c;
        int datasize = 0;
        int frame, frames;
        FILE *handle;
        sscanf(ib2, "%d", &frame);
        sscanf(ib3, "%d", &frames);
        if (frame < 0) frame = 0;
        if (frame > 255) frame = 255;
        if (frames < 1) frames = 1;
        if (frame+frames > 256) frames = 256-frame;

        handle = fopen(ib1, "wb");
        if (!handle) return;
        fwritele16(handle, datasize);
        fwrite8(handle, frames);
        for (c = 0; c < frames; c++)
        {
          short offset = 0; /* Don't know the offsets yet */
          fwritele16(handle, offset);
        }
        for (c = 0; c < frames; c++)
        {
          int slice;
          int currentpos;
          int slicemask = 0;
          SPRHEADER tempheader;

          currentpos = ftell(handle);
          fseek(handle, 2*c+3, SEEK_SET);
          currentpos -= 3;
          fwritele16(handle, currentpos);
          currentpos += 3;
          fseek(handle, currentpos, SEEK_SET);
          datasize += 2;

          tempheader.slicemask = 0;
          for (slice = 0; slice < 9; slice++)
          {
            int slicey;
            char data = 0;
            for (slicey = 0; slicey < 7; slicey++)
            {
              data |= spritedata[(frame+c) * 64 +
              sliceoffset[slice] + slicey * 3];
            }
            if (data) slicemask |= (1 << slice);
          }
          tempheader.slicemask = slicemask & 0xff;
          tempheader.color = spritedata[(frame+c)*64+63] & 15;
          tempheader.color |= (slicemask & 0x100) >> 1;
          tempheader.color |= magx[frame+c] << 4;
          tempheader.hotspotx = hotspotx[frame+c];
          tempheader.hotspoty = hotspoty[frame+c];
          tempheader.connectspotx = connectspotx[frame+c];
          tempheader.connectspoty = connectspoty[frame+c];
          tempheader.cacheframe = 0;
          fwrite8(handle, tempheader.slicemask);
          fwrite8(handle, tempheader.color);
          fwrite8(handle, tempheader.hotspotx / 2);
          fwrite8(handle, tempheader.connectspotx / 2);
          fwrite8(handle, tempheader.hotspoty);
          fwrite8(handle, tempheader.connectspoty);
          fwrite8(handle, tempheader.cacheframe);

          datasize += sizeof(SPRHEADER);
          for (slice = 0; slice < 9; slice++)
          {
            int slicey;
            char data = 0;
            for (slicey = 0; slicey < 7; slicey++)
            {
              data |= spritedata[(frame+c) * 64 +
              sliceoffset[slice] + slicey * 3];
            }
            if (data)
            {
              for (slicey = 0; slicey < 7; slicey++)
              {
                fwrite8(handle, spritedata[(frame+c) * 64 +
                sliceoffset[slice] + slicey * 3]);
              }
              datasize += 7;
            }
          }
        }
        fseek(handle, 0, SEEK_SET);
        fwritele16(handle, datasize);

        fclose(handle);
        return;
      }
    }
  }
}


void changecol(void)
{
  int y;
  if (colordelay < COLOR_DELAY) colordelay++;
  if (!mouseb) return;
  if ((mousex < 130) || (mousex >= 235)) return;
  if ((mousey < 80) || (mousey >= 135)) return;
  y = mousey - 80;
  if ((y % 15) >= 9) return;
  if (mousex < 220)
  {
    ccolor = y / 15;
  }
  else
  {
    if ((!prevmouseb) || (colordelay >= COLOR_DELAY))
    {
      if (mouseb & LEFT_BUTTON)
      {
        switch(y/15)
        {
          case 0:
          bgcol++;
          bgcol &= 15;
          break;
          case 1:
          multicol1++;
          multicol1 &= 15;
          break;
          case 2:
          spritedata[sprnum*64+63]++;
          spritedata[sprnum*64+63] &= 15;
          break;
          case 3:
          multicol2++;
          multicol2 &= 15;
          break;
        }
        colordelay = 0;
      }
      if (mouseb & RIGHT_BUTTON)
      {
        switch(y/15)
        {
          case 0:
          bgcol--;
          bgcol &= 15;
          break;
          case 1:
          multicol1--;
          multicol1 &= 15;
          break;
          case 2:
          spritedata[sprnum*64+63]--;
          spritedata[sprnum*64+63] &= 15;
          break;
          case 3:
          multicol2--;
          multicol2 &= 15;
          break;
        }
        colordelay = 0;
      }
    }
  }
}

void editspr(void)
{
  unsigned char *ptr = &spritedata[sprnum*64];
  int x,y;

  if ((mousex < 0) || (mousex >= 24*5)) return;
  if ((mousey < 0) || (mousey >= 21*5)) return;

  y = mousey / 5;
  x = mousex / 5;
  if (spritedata[sprnum*64+63] & 16)
  {
    unsigned char byte, bit;
    byte = x >> 3;
    bit = 7 - (x & 7);

    if (mouseb & LEFT_BUTTON)
    {
      ptr[byte+3*y] |= (1 << bit);
    }
    if (mouseb & RIGHT_BUTTON)
    {
      ptr[byte+3*y] &= ~(1 << bit);
    }
  }
  else
  {
    unsigned char byte, bit;
    byte = x >> 3;
    bit = (7 - (x & 7)) & 6;

    if (mouseb & LEFT_BUTTON)
    {
      ptr[byte+3*y] &= ~(3 << bit);
      ptr[byte+3*y] |= (ccolor << bit);
    }
    if (mouseb & RIGHT_BUTTON)
    {
      ptr[byte+3*y] &= ~(3 << bit);
    }
  }
  if (k == KEY_H)
  {
    if (!magx[sprnum])
    {
      hotspotx[sprnum] = x & 0xfe;
      hotspoty[sprnum] = y;
    }
    else
    {
      hotspotx[sprnum] = (x & 0xfe) * 2;
      hotspoty[sprnum] = y;
    }
  }
  if (k == KEY_J)
  {
    if (!magx[sprnum])
    {
      connectspotx[sprnum] = x & 0xfe;
      connectspoty[sprnum] = y;
    }
    else
    {
      connectspotx[sprnum] = (x & 0xfe) * 2;
      connectspoty[sprnum] = y;
    }
  }
}

void flipsprx(void)
{
  unsigned char c,a;
  unsigned char *ptr = &spritedata[sprnum*64];
  int y,x;

  if (!magx[sprnum])
  {
    hotspotx[sprnum] = 22 - hotspotx[sprnum];
    connectspotx[sprnum] = 22 - connectspotx[sprnum];
  }
  else
  {
    hotspotx[sprnum] = 44 - hotspotx[sprnum];
    connectspotx[sprnum] = 44 - connectspotx[sprnum];
  }

  if (spritedata[sprnum*64+63] & 16)
  {
    c = 1;
    a = 1;
  }
  else
  {
    c = 2;
    a = 3;
  }

  for (y = 0; y < 21; y++)
  {
    unsigned src = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
    unsigned dest = 0;
    for (x = 0; x < 24; x += c)
    {
      unsigned stuff = (src >> x) & a;
      dest |= stuff << ((24-c)-x);
    }
    ptr[0] = dest>>16;
    ptr[1] = dest>>8;
    ptr[2] = dest;
    ptr += 3;
  }
}

void flipspry(void)
{
  unsigned char *ptr = &spritedata[sprnum*64];
  unsigned char temp[63];
  int y;

  hotspoty[sprnum] = 20 - hotspoty[sprnum];
  connectspoty[sprnum] = 20 - connectspoty[sprnum];
  for (y = 0; y < 21; y++)
  {
    temp[60-y*3] = ptr[y*3];
    temp[60-y*3+1] = ptr[y*3+1];
    temp[60-y*3+2] = ptr[y*3+2];
  }
  memcpy(ptr, temp, 63);
}

void scrollsprleft(void)
{
  unsigned char c;
  int y;

  if (spritedata[sprnum*64+63] & 16) c = 1;
  else c = 2;

  while (c)
  {
    unsigned char *ptr = &spritedata[sprnum*64];
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      unsigned char bit = ptr[0] >> 7;
      data <<= 1;
      ptr[0] = data>>16;
      ptr[1] = data>>8;
      ptr[2] = data | bit;
      ptr += 3;
    }
    c--;
  }
}

void scrollsprright(void)
{
  unsigned char c;
  int y;

  if (spritedata[sprnum*64+63] & 16) c = 1;
  else c = 2;

  while (c)
  {
    unsigned char *ptr = &spritedata[sprnum*64];
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      unsigned char bit = ptr[2] << 7;
      data >>= 1;
      ptr[0] = (data>>16) | bit;
      ptr[1] = data>>8;
      ptr[2] = data;
      ptr += 3;
    }
    c--;
  }
}

void scrollsprup(void)
{
  int y;
  unsigned char *ptr = &spritedata[sprnum*64];
  unsigned char vara1 = ptr[0];
  unsigned char vara2 = ptr[1];
  unsigned char vara3 = ptr[2];
  for (y = 0; y < 20; y++)
  {
    ptr[y*3]=ptr[y*3+3];
    ptr[y*3+1]=ptr[y*3+4];
    ptr[y*3+2]=ptr[y*3+5];
  }
  ptr[60]=vara1;
  ptr[61]=vara2;
  ptr[62]=vara3;
}

void scrollsprdown(void)
{
  int y;
  unsigned char *ptr = &spritedata[sprnum*64];
  unsigned char vara1 = ptr[60];
  unsigned char vara2 = ptr[61];
  unsigned char vara3 = ptr[62];
  for (y = 19; y >= 0; y--)
  {
    ptr[y*3+3]=ptr[y*3];
    ptr[y*3+4]=ptr[y*3+1];
    ptr[y*3+5]=ptr[y*3+2];
  }
  ptr[0]=vara1;
  ptr[1]=vara2;
  ptr[2]=vara3;
}

void drawc64sprite(int bx, int by, int num)
{
  unsigned char *ptr = &spritedata[num*64];
  unsigned char sprcol = ptr[63];
  unsigned char v = 0;
  int x,y;

  if (sprcol & 16)
  {
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      for (x = 23; x >= 0; x--)
      {
        unsigned char c = data & 1;
        v = 17;
        if (c) v = sprcol & 15;
        if (v != 17)
        {
          if (!magx[num])
          {
            gfx_plot(bx+x,by+y,v);
          }
          else
          {
            gfx_plot(bx+x*2,by+y,v);
            gfx_plot(bx+x*2+1,by+y,v);
          }
        }
        data >>= 1;
      }
      ptr += 3;
    }
  }
  else
  {
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      for (x = 11; x >= 0; x--)
      {
        unsigned char c = data & 3;
        switch (c)
        {
          case 1:
          v = multicol1;
          break;

          case 2:
          v = sprcol;
          break;

          case 3:
          v = multicol2;
          break;
        }
        if (c)
        {
          if (!magx[num])
          {
            gfx_plot(bx+x*2,by+y,v);
            gfx_plot(bx+1+x*2,by+y,v);
          }
          else
          {
            gfx_plot(bx+x*4,by+y,v);
            gfx_plot(bx+1+x*4,by+y,v);
            gfx_plot(bx+2+x*4,by+y,v);
            gfx_plot(bx+3+x*4,by+y,v);
          }
        }
        data >>= 2;
      }
      ptr += 3;
    }
  }
}


void drawgrid(void)
{
  unsigned char *ptr = &spritedata[sprnum*64];
  unsigned char sprcol = ptr[63];
  unsigned char v = 0;
  int x,y;

  if (sprcol & 16)
  {
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      for (x = 23; x >= 0; x--)
      {
        unsigned char c = data & 1;
        if (c) v = sprcol & 15;
        else v = bgcol;

        gfx_drawsprite(x*5,y*5,0x00000001+v);
        gfx_plot(130+x,y,v);

        data >>= 1;
      }
      ptr += 3;
    }
  }
  else
  {
    for (y = 0; y < 21; y++)
    {
      unsigned data = (ptr[0]<<16) | (ptr[1]<<8) | ptr[2];
      for (x = 11; x >= 0; x--)
      {
        unsigned char c = data & 3;
        switch (c)
        {
          case 0:
          v = bgcol;
          break;

          case 1:
          v = multicol1;
          break;

          case 2:
          v = sprcol;
          break;

          case 3:
          v = multicol2;
          break;
        }
        gfx_drawsprite(x*10,y*5,0x00000011+v);
        if (!magx[sprnum])
        {
          gfx_plot(130+x*2,y,v);
          gfx_plot(131+x*2,y,v);
        }
        else
        {
          gfx_plot(130+x*4,y,v);
          gfx_plot(131+x*4,y,v);
          gfx_plot(132+x*4,y,v);
          gfx_plot(133+x*4,y,v);
        }

        data >>= 2;
      }
      ptr += 3;
    }
  }
  hotspotflash++;
  if ((hotspotflash & 31) >= 16)
  {
    if (!magx[sprnum])
    {
      gfx_drawsprite(hotspotx[sprnum]*5, hotspoty[sprnum]*5, 0x00000011+1);
      gfx_drawsprite(connectspotx[sprnum]*5, connectspoty[sprnum]*5, 0x00000011+10);
      gfx_plot(130+hotspotx[sprnum], hotspoty[sprnum], 1);
      gfx_plot(130+connectspotx[sprnum], connectspoty[sprnum], 10);
      gfx_plot(131+hotspotx[sprnum], hotspoty[sprnum], 1);
      gfx_plot(131+connectspotx[sprnum], connectspoty[sprnum], 10);
    }
    else
    {
      gfx_drawsprite((hotspotx[sprnum]/2)*5, hotspoty[sprnum]*5, 0x00000011+1);
      gfx_drawsprite((connectspotx[sprnum]/2)*5, connectspoty[sprnum]*5, 0x00000011+10);
      gfx_plot(130+hotspotx[sprnum], hotspoty[sprnum], 1);
      gfx_plot(130+connectspotx[sprnum], connectspoty[sprnum], 10);
      gfx_plot(131+hotspotx[sprnum], hotspoty[sprnum], 1);
      gfx_plot(131+connectspotx[sprnum], connectspoty[sprnum], 10);
    }
  }

  sprintf(textbuffer, "SPRITE %03d", sprnum);
  printtext_color(textbuffer, 0,110,SPR_FONTS,COL_WHITE);
  v = COL_WHITE;
  if (ccolor == 0) v = COL_HIGHLIGHT;
  printtext_color("BACKGROUND",130,80,SPR_FONTS,v);
  v = COL_WHITE;
  if (ccolor == 1) v = COL_HIGHLIGHT;
  printtext_color("MULTICOL 1",130,95,SPR_FONTS,v);
  v = COL_WHITE;
  if (ccolor == 2) v = COL_HIGHLIGHT;
  printtext_color("SPRITE COL",130,110,SPR_FONTS,v&15);
  v = COL_WHITE;
  if (ccolor == 3) v = COL_HIGHLIGHT;
  printtext_color("MULTICOL 2",130,125,SPR_FONTS,v);
  drawcbar(220,80,bgcol);
  drawcbar(220,95,multicol1);
  drawcbar(220,110,(sprcol&15));
  drawcbar(220,125,multicol2);
}

void drawcbar(int x, int y, unsigned char col)
{
  int a;
  for (a = y; a < y+9; a++)
  {
    gfx_line(x, a, x+14, a, col);
  }
}

int initsprites(void)
{
  unsigned char *ptr;
  int c;
  spritedata = malloc(256*64);
  if (!spritedata) return 0;
  ptr = spritedata;
  for (c = 0; c < 16; c++)
  {
    testsprf[c] = 255;
  }
  for (c = 0; c < 256; c++)
  {
    hotspotx[c] = 0;
    hotspoty[c] = 0;
    connectspotx[c] = 0;
    connectspoty[c] = 0;

    memset(ptr, 0, 63); /* Tyhjennet„„n spritedata */
    ptr += 63;
    *ptr = 1; /* Spriten v„ri */
    ptr++;
  }

  return 1;
}

void mouseupdate(void)
{
  mou_getpos(&mousex, &mousey);
  prevmouseb = mouseb;
  mouseb = mou_getbuttons();
}

void printtext_color(unsigned char *string, int x, int y, unsigned spritefile, int color)
{
  unsigned char *xlat = colxlattable[color];

  spritefile <<= 16;
  while (*string)
  {
    unsigned num = *string - 31;

    if (num >= 64) num -= 32;
    gfx_drawspritex(x, y, spritefile + num, xlat);
    x += spr_xsize;
    string++;
  }
}

void printtext_center_color(unsigned char *string, int y, unsigned spritefile, int color)
{
  int x = 0;
  unsigned char *stuff = string;
  unsigned char *xlat = colxlattable[color];
  spritefile <<= 16;

  while (*stuff)
  {
    unsigned num = *stuff - 31;

    if (num >= 64) num -= 32;
    gfx_getspriteinfo(spritefile + num);
    x += spr_xsize;
    stuff++;
  }
  x = 160 - x / 2;

  while (*string)
  {
    unsigned num = *string - 31;

    if (num >= 64) num -= 32;
    gfx_drawspritex(x, y, spritefile + num, xlat);
    x += spr_xsize;
    string++;
  }
}

void initstuff(void)
{
  int c;
  for (c = 0; c < 63; c++)
  {
        copybuffer[c] = 0;
  }
  if (!initsprites())
  {
    win_messagebox("Out of memory!");
    exit(1);
  }

  kbd_init();

  win_fullscreen = 0;
  if (!gfx_init(320,200,70,GFX_DOUBLESIZE))
  {
    win_messagebox("Graphics init error!");
    exit(1);
  }
  win_setmousemode(MOUSE_ALWAYS_HIDDEN);

  if ((!gfx_loadsprites(SPR_C, "editor.spr")) ||
      (!gfx_loadsprites(SPR_FONTS, "editfont.spr")))
  {
    win_messagebox("Error loading editor graphics!");
    exit(1);
  }
  if (!gfx_loadpalette("editor.pal"))
  {
    win_messagebox("Error loading editor palette!");
    exit(1);
  }
}

int inputtext(unsigned char *buffer, int maxlength)
{
  int len = strlen(buffer);

  ascii = kbd_getascii();
  k = ascii;

  if (!k) return 0;
  if (k == 27) return -1;
  if (k == 13) return 1;

  if (k >= 32)
  {
    if (len < maxlength-1)
    {
      buffer[len] = k;
      buffer[len+1] = 0;
    }
  }
  if ((k == 8) && (len > 0))
  {
    buffer[len-1] = 0;
  }
  return 0;
}

void handle_int(int a)
{
  exit(0); /* Atexit functions will be called! */
}


