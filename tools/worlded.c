/*
 * Hessian game world editor, based on MW4 editor
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <ctype.h>
#include "bme.h"
#include "editio.h"
#include "stb_image_write.h"

#define MAPCOPYSIZE 4096
#define MAXPATH 4096

#define COLOR_DELAY 10
#define NUMZONES 2048
#define NUMLVLOBJ 8192
#define NUMLVLACT 8192
#define NUMLEVELS 64
#define NUMCHARSETS 64
#define NUMLVLOBJ_PER_LEVEL 128
#define NUMLVLACT_PER_LEVEL 80

#define LEFT_BUTTON 1
#define RIGHT_BUTTON 2
#define SINGLECOLOR 0
#define MULTICOLOR 1

#define EM_QUIT 0
#define EM_CHARS 1
#define EM_MAP 2
#define EM_LEVEL 3
#define EM_ZONE 4

#define BLOCKS 256
#define SPR_C 0
#define SPR_FONTS 1
#define COL_WHITE 0
#define COL_HIGHLIGHT 1
#define COL_NUMBER 2

#define MAPSIZEX 2048
#define MAPSIZEY 128

unsigned short lvlobjx[NUMLVLOBJ];
unsigned short lvlobjy[NUMLVLOBJ];
unsigned char lvlobjb[NUMLVLOBJ];
unsigned char lvlobjdl[NUMLVLOBJ];
unsigned char lvlobjdh[NUMLVLOBJ];

unsigned short lvlactx[NUMLVLACT];
unsigned short lvlacty[NUMLVLACT];
unsigned char lvlactf[NUMLVLACT];
unsigned char lvlactt[NUMLVLACT];
unsigned char lvlactw[NUMLVLACT];

unsigned short levelx[NUMLEVELS];
unsigned short levely[NUMLEVELS];
unsigned short levelsx[NUMLEVELS];
unsigned short levelsy[NUMLEVELS];

unsigned char zonecharset[NUMZONES];
unsigned char zonelevel[NUMZONES];
unsigned short zonex[NUMZONES];
unsigned short zoney[NUMZONES];
unsigned short zonesx[NUMZONES];
unsigned short zonesy[NUMZONES];
unsigned char zonebg1[NUMZONES];
unsigned char zonebg2[NUMZONES];
unsigned char zonebg3[NUMZONES];
unsigned char zonemusic[NUMZONES];
unsigned char zonespawnparam[NUMZONES];
unsigned char zonespawnspeed[NUMZONES];
unsigned char zonespawncount[NUMZONES];
unsigned char mapdata[MAPSIZEX*MAPSIZEY];
unsigned char chardata[NUMCHARSETS][2048];
unsigned char blockdata[NUMCHARSETS][4096];
unsigned char chcol[NUMCHARSETS][256];
unsigned char chinfo[NUMCHARSETS][256];
unsigned char blockinfo[BLOCKS/2];

unsigned char pathx[MAXPATH];
unsigned char pathy[MAXPATH];
unsigned char pathsx;
unsigned char pathsy;
unsigned char pathex;
unsigned char pathey;
int pathlength;
int pathmode = 0;

char *actorname[256];
char *itemname[256];
char *modename[16];

char *modetext[] = {
  "NONE",
  "TRIG",
  "MAN.",
  "MAN.AD"};

char *actiontext[] = {
  "SIDEDOOR",
  "DOOR",
  "BACKDROP",
  "SWITCH",
  "REVEAL",
  "SCRIPT",
  "CHAIN",
  "UNUSED"
};

unsigned char slopetbl[] = {
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,   // Slope 0
  0x38,0x30,0x28,0x20,0x18,0x10,0x08,0x00,   // Slope 1
  0x38,0x38,0x30,0x30,0x28,0x28,0x20,0x20,   // Slope 2
  0x18,0x18,0x10,0x10,0x08,0x08,0x00,0x00,   // Slope 3
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,   // Slope 4
  0x00,0x08,0x10,0x18,0x20,0x28,0x30,0x38,   // Slope 5
  0x00,0x00,0x08,0x08,0x10,0x10,0x18,0x18,   // Slope 6
  0x20,0x20,0x28,0x28,0x30,0x30,0x38,0x38    // Slope 7
};

unsigned char cwhite[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35};
unsigned char chl[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,35};
unsigned char cnum[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35};
Uint8 *colxlattable[] = {cwhite, chl, cnum};
unsigned char textbuffer[80];
unsigned char copybuffer[8];
unsigned char bcopybuffer[16];
unsigned char charused[256];
unsigned blockusecount[NUMCHARSETS][256];
unsigned char animatingblock[NUMCHARSETS][256];
unsigned char mapcopybuffer[MAPCOPYSIZE];
unsigned char finemapcopybuffer[MAPCOPYSIZE];
unsigned char ascii;
int k;
int blockeditmode = 0;
int blockselectmode = 0;
int zoomoutmode = 0;
int bsy = 0;
unsigned char copychcol;
unsigned char copychinfo;
unsigned char intensity[] = {0,15,4,11,5,10,1,14,6,2,9,3,7,13,8,12};

int dataeditmode = 0;
int dataeditcursor = 0;
int dataeditflash = 0;

int markx1, markx2, marky1, marky2;
int markmode = 0;

int finemarkx1, finemarkx2, finemarky1, finemarky2;
int finemarkmode = 0;

int mapcopyx = 0;
int mapcopyy = 0;

int finemapcopyx = 0;
int finemapcopyy = 0;

int maxusedblocks[NUMCHARSETS];
int colordelay = 0;
unsigned char oldchar;
unsigned char blockeditnum;

int charsetnum = 0;

int mousex;
int mousey;
int mouseb;
int prevmouseb = 0;
unsigned char charnum = 0;
int blocknum = 0;
int zonenum = 0;
int ccolor = 3;
int flash = 0;
int editmode = EM_CHARS;
int mapx = 0;
int mapy = 0;
int mapsx = MAPSIZEX;
int mapsy = MAPSIZEY;
char levelname[80];

int actfound = 0;
int actindex = 0;
int objfound = 0;
int objindex = 0;
unsigned short actnum = 1;
unsigned char frommap = 0;

int initchars(void);
int findzone(int x, int y);
int findzonefast(int x, int y, int lastzone);
int findnearestzone(int x, int y);
void moveonmap(int k, int shiftdown);
void gotopos(int x, int y);
void endblockeditmode(void);
void initblockeditmode(int frommap);
void findusedblocksandchars(void);
void findanimatingblocks(void);
int checkzonelegal(int num, int newx, int newy, int newsx, int newsy);
void switchzoomout(int newvalue);
void calculatelevelorigins(void);
void confirmquit(void);
void loadchars(void);
void savechars(void);
void loadblocks(void);
void saveblocks(void);
void loadcharsinfo(void);
void savecharsinfo(void);
void loadalldata(void);
void savealldata(void);
void importlevelmap(void);
void exportpng(void);
void scrollcharleft(void);
void scrollcharright(void);
void scrollcharup(void);
void scrollchardown(void);
void lightenchar(void);
void darkenchar(void);
void char_mainloop(void);
void editchar(void);
void editblock(void);
void map_mainloop(void);
void level_mainloop(void);
void zone_mainloop(void);
void drawimage(void);
void drawblock(int x, int y, int num, int charset);
void drawsmallblock(int x, int y, int num, int charset);
void drawchar(int x, int y, int num, int charset);
void mouseupdate(void);
void handle_int(int a);
void drawmap();
void drawblocks(void);
void drawgrid(void);
void changecol(void);
void changechar(void);
void initstuff(void);
void drawcbar(int x, int y, char col);
unsigned getcharsprite(unsigned char ch);
void printtext_color(unsigned char *string, int x, int y, unsigned spritefile, int color);
void printtext_center_color(unsigned char *string, int y, unsigned spritefile, int color);
void editmain(void);
void copychar(int c, int d);
void transferchar(int c, int d);
int findsamechar(int c, int d);
int findsameblock(int c, int d);
void transferblock(int c, int d);
void swapblocks(int c, int d);
void insertblock(int c, int d);
void copyblock(int c, int d);
void relocatezone(int x, int y);
void reorganizedata(void);
void optimizechars(void);
void optimizeblocks(void);
void copycharset(void);
void updateblockinfo(void);
unsigned char getblockinfo(int x, int y);
void markpath(int x, int y);
void calculatepath();
void drawpath();

extern unsigned char datafile[];

int main (int argc, char *argv[])
{
  int c;
  FILE *names;

  io_openlinkeddatafile(datafile);

  if (!win_openwindow("World editor", NULL)) return 1;
  win_fullscreen = 0;

  for (c = 0; c < 256; c++) actorname[c] = " ";
  for (c = 0; c < 256; c++) itemname[c] = " ";
  for (c = 0; c < 16; c++) modename[c] = " ";
  strcpy(levelname, "world");
  names = fopen("names.txt", "rt");
  if (!names) goto NONAMES;

  for (c = 0; c < 256; c++)
  {
    actorname[c] = malloc(80);
    actorname[c][0] = 0;
    AGAIN1:
    if (!fgets(actorname[c], 80, names)) break;
    if (actorname[c][0] == ' ') goto AGAIN1;
    if (actorname[c][0] == ';') goto AGAIN1;
    if (strlen(actorname[c]) > 1) actorname[c][strlen(actorname[c])-1] = 0; /* Delete newline */
    if (!strcmp(actorname[c], "end")) break;
  }
  for (c = 0; c < 256; c++)
  {
    itemname[c] = malloc(80);
    itemname[c][0] = 0;
    AGAIN2:
    if (!fgets(itemname[c], 80, names)) break;
    if (itemname[c][0] == ' ') goto AGAIN2;
    if (itemname[c][0] == ';') goto AGAIN2;
    if (strlen(itemname[c]) > 1) itemname[c][strlen(itemname[c])-1] = 0; /* Delete newline */
    if (!strcmp(itemname[c], "end")) break;
  }
  for (c = 0; c < 16; c++)
  {
    modename[c] = malloc(80);
    modename[c][0] = 0;
    AGAIN5:
    if (!fgets(modename[c], 80, names)) break;
    if (modename[c][0] == ' ') goto AGAIN5;
    if (modename[c][0] == ';') goto AGAIN5;
    if (strlen(modename[c]) > 1) modename[c][strlen(modename[c])-1] = 0; /* Delete newline */
  }

  fclose(names);
  NONAMES:

  initstuff();

  gfx_setpalette();

  while (editmode)
  {
    if (editmode == EM_CHARS) char_mainloop();
    if (editmode == EM_MAP) map_mainloop();
    if (editmode == EM_LEVEL) level_mainloop();
    if (editmode == EM_ZONE) zone_mainloop();
  }
  return 0;
}

void moveonmap(int k, int shiftdown)
{
  if (k == KEY_LEFT) mapx -= shiftdown ? 10 : 1;
  if (k == KEY_RIGHT) mapx += shiftdown ? 10 : 1;
  if (k == KEY_UP) mapy -= shiftdown ? 6 : 1;
  if (k == KEY_DOWN) mapy += shiftdown ? 6 : 1;
  if (mapx < 0) mapx = 0;
  if (mapy < 0) mapy = 0;
  if (mapx > (mapsx-10)) mapx = mapsx-10;
  if (mapy > (mapsy-6)) mapy = mapsy-6;
}

void gotopos(int x, int y)
{
  int divisor = zoomoutmode ? 8 : 32;
  mapx = x - 160/divisor;
  mapy = y - 96/divisor;

  if (mapx < 0) mapx = 0;
  if (mapx >= mapsx - 320/divisor) mapx = mapsx - 320/divisor;
  if (mapy < 0) mapy = 0;
  if (mapy >= mapsy - 192/divisor) mapy = mapsy - 192/divisor;
}

void level_mainloop(void)
{
  pathmode = 0;
  switchzoomout(0);
  calculatelevelorigins();

  for (;;)
  {
    int s, shiftdown, ctrldown;

    s = win_getspeed(70);
    flash += s;
    flash &= 31;
    k = kbd_getkey();
    ascii = kbd_getascii();
    shiftdown = win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT];
    ctrldown = win_keystate[KEY_CTRL];
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }
    if (k == KEY_F5)
    {
      editmode = EM_CHARS;
      break;
    }
    if (k == KEY_F6)
    {
      editmode = EM_MAP;
      blockselectmode = 0;
      break;
    }
    if (k == KEY_F7)
    {
      editmode = EM_ZONE;
      break;
    }
    if (k == KEY_F8)
    {
      editmode = EM_LEVEL;
      break;
    }

    if (k == KEY_P)
    {
      if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
      {
        int x = mapx+mousex/32;
        int y = mapy+mousey/32;
        markpath(x, y);
      }
    }

    {
      moveonmap(k, shiftdown);

      if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
      {
        int c;
        int x = mapx+mousex/32;
        int y = mapy+mousey/32;
        int xf = (((mapx*32+mousex) % 32) & 0x18) / 8;
        int yf = (((mapy*32+mousey) % 32) & 0x18) / 8;

        actfound = 0;
        objfound = 0;

        // Always move to the zone under cursor to get accurate per-level stats
        if (findzone(x,y) < NUMZONES)
        {
          zonenum = findzone(x,y);
          charsetnum = zonecharset[zonenum];
        }

        if (!dataeditmode)
        {
          for (c = 0; c < NUMLVLOBJ; c++)
          {
            if ((lvlobjx[c]) || (lvlobjy[c]))
            {
              if ((x == lvlobjx[c]) && (y == (lvlobjy[c] & 0x7f)))
              {
                objfound = 1;
                objindex = c;
                break;
              }
            }
          }
          for (c = 0; c < NUMLVLACT; c++)
          {
            if ((lvlactt[c]) && (lvlactx[c] == x) && ((lvlacty[c]&0x7f) == y) &&
                (((lvlactf[c] >> 4) & 3) == xf) && (((lvlactf[c] >> 6) & 3) == yf))
            {
              actfound = 1;
              actindex = c;
            }
          }
        }
        else
        {
          objfound = 1;
          actfound = 0;
        }

        if ((!actfound) && (!objfound))
        {
          if (k == KEY_Z && !shiftdown) actnum--;
          if (k == KEY_X && !shiftdown) actnum++;
          if (k == KEY_1 && !shiftdown) actnum--;
          if (k == KEY_2 && !shiftdown) actnum++;
          if (k == KEY_Z && shiftdown) actnum -= 16;
          if (k == KEY_X && shiftdown) actnum += 16;
          if (k == KEY_1 && shiftdown) actnum -= 16;
          if (k == KEY_2 && shiftdown) actnum += 16;
          if (k == KEY_I) actnum ^= 128;
        }

        if (actfound)
        {
          if (k == KEY_M)
          {
            int mode = lvlactf[actindex] & 0xf;
            mode++;
            mode &= 0xf;
            lvlactf[actindex] &= 0xf0;
            lvlactf[actindex] |= mode;
          }
          if (k == KEY_N)
          {
            int mode = lvlactf[actindex] & 0xf;
            mode--;
            mode &= 0xf;
            lvlactf[actindex] &= 0xf0;
            lvlactf[actindex] |= mode;
          }
          if (k == KEY_D) // Dir
          {
              lvlactw[actindex] ^= 128;
          }

          if ((k == KEY_Q) || (k == KEY_1))
          {
            if (lvlactt[actindex] & 0x80)
            {
              lvlactw[actindex]--; // Weapon
            }
            else
            {
              int dir = lvlactw[actindex] & 0x80;
              lvlactw[actindex]--;
              lvlactw[actindex] &= 0x7f;
              lvlactw[actindex] |= dir;
            }
          }
          if ((k == KEY_W) || (k == KEY_2))
          {
            if (lvlactt[actindex] & 0x80)
            {
              lvlactw[actindex]++; // Weapon
            }
            else
            {
              int dir = lvlactw[actindex] & 0x80;
              lvlactw[actindex]++;
              lvlactw[actindex] &= 0x7f;
              lvlactw[actindex] |= dir;
            }
          }


          if (k == KEY_3)
          {
            if (lvlactt[actindex] & 0x80)
            {
              lvlactw[actindex] -= 10; // Weapon
            }
            else
            {
              int dir = lvlactw[actindex] & 0x80;
              lvlactw[actindex] -= 10;
              lvlactw[actindex] &= 0x7f;
              lvlactw[actindex] |= dir;
            }
          }
          if (k == KEY_4)
          {
            if (lvlactt[actindex] & 0x80)
            {
              lvlactw[actindex] += 10; // Weapon
            }
            else
            {
              int dir = lvlactw[actindex] & 0x80;
              lvlactw[actindex] += 10;
              lvlactw[actindex] &= 0x7f;
              lvlactw[actindex] |= dir;
            }
          }
          if (k == KEY_H)
          {
            lvlacty[actindex] ^= 128; // Hidden
          }
          if ((k == KEY_DEL) || (k == KEY_BACKSPACE))
          {
            lvlactx[actindex] = 0;
            lvlacty[actindex] = 0;
            lvlactf[actindex] = 0;
            lvlactt[actindex] = 0;
            lvlactw[actindex] = 0;
          }
        }
        else
        {
          if (objfound)
          {
            if (!dataeditmode)
            {
              if (k == KEY_DEL)
              {
                lvlobjx[objindex] = 0;
                lvlobjy[objindex] = 0;
                lvlobjb[objindex] = 0;
                lvlobjdl[objindex] = 0;
                lvlobjdh[objindex] = 0;
              }
              if (k == KEY_S) // Size
              {
                lvlobjb[objindex] ^= 64;
              }
              if (k == KEY_A) // Animation toggle
              {
                lvlobjy[objindex] ^= 128;
              }
              if ((k == KEY_Q) || (k == KEY_M)) // Activation
              {
                int a = lvlobjb[objindex] & 3;
                a++;
                a &= 3;
                lvlobjb[objindex] &= 0xfc;
                lvlobjb[objindex] |= a;
              }

              if ((k == KEY_W) || (k == KEY_T)) // Action
              {
                int a = (lvlobjb[objindex] >> 2) & 7;
                a++;
                if (a >= 7) a = 0;
                lvlobjb[objindex] &= 0xe3;
                lvlobjb[objindex] |= (a << 2);
              }
              if (k == KEY_Y) // Action backwards
              {
                int a = (lvlobjb[objindex] >> 2) & 7;
                a--;
                if (a < 0) a = 6;
                lvlobjb[objindex] &= 0xe3;
                lvlobjb[objindex] |= (a << 2);
              }

              if (k == KEY_D) // Auto-deactivate
              {
                  lvlobjb[objindex] ^= 32;
              }
            }
            else
            {
              int hex = -1;

              if ((k == KEY_DEL) || (k == KEY_BACKSPACE))
              {
                dataeditcursor--;
                if (dataeditcursor < 0) dataeditcursor = 0;
                  hex = 0;
              }

              if (k == KEY_0) hex = 0;
              if (k == KEY_1) hex = 1;
              if (k == KEY_2) hex = 2;
              if (k == KEY_3) hex = 3;
              if (k == KEY_4) hex = 4;
              if (k == KEY_5) hex = 5;
              if (k == KEY_6) hex = 6;
              if (k == KEY_7) hex = 7;
              if (k == KEY_8) hex = 8;
              if (k == KEY_9) hex = 9;
              if (k == KEY_A) hex = 10;
              if (k == KEY_B) hex = 11;
              if (k == KEY_C) hex = 12;
              if (k == KEY_D) hex = 13;
              if (k == KEY_E) hex = 14;
              if (k == KEY_F) hex = 15;

              if (hex >= 0)
              {
                switch(dataeditcursor)
                {
                  case 0:
                  lvlobjdh[objindex] &= 0x0f;
                  lvlobjdh[objindex] |= hex << 4;
                  break;

                  case 1:
                  lvlobjdh[objindex] &= 0xf0;
                  lvlobjdh[objindex] |= hex;
                  break;

                  case 2:
                  lvlobjdl[objindex] &= 0x0f;
                  lvlobjdl[objindex] |= hex << 4;
                  break;

                  case 3:
                  lvlobjdl[objindex] &= 0xf0;
                  lvlobjdl[objindex] |= hex;
                  break;
                }

                if ((k != KEY_DEL) && (k != KEY_BACKSPACE))
                {
                  dataeditcursor++;
                  if (dataeditcursor > 4) dataeditcursor = 4;
                }
              }
            }

            if (k == KEY_RIGHT)
            {
              dataeditcursor++;
              if (dataeditcursor > 4) dataeditcursor = 4;
            }

            if (k == KEY_LEFT)
            {
              dataeditcursor--;
              if (dataeditcursor < 0) dataeditcursor = 0;
            }

            if ((k == KEY_ENTER) || (k == KEY_SPACE))
            {
              if ((dataeditmode) || (objfound))
                dataeditmode ^= 1;
              if (dataeditmode) dataeditcursor = 0;
            }
          }
        }
        if (mouseb & 1)
        {
          if ((!dataeditmode) && (!objfound))
          {
            for (c = 0; c < NUMLVLOBJ; c++)
            {
              if ((!lvlobjx[c]) && (!lvlobjy[c]))
              {
                lvlobjx[c] = x;
                lvlobjy[c] = y;
                break;
              }
            }
          }
        }
        if (mouseb & 2)
        {
          if ((!actfound) && (!dataeditmode) && (actnum))
          {
            for (c = 0; c < NUMLVLACT; c++)
            {
              if (!lvlactt[c])
              {
                lvlactt[c] = actnum;
                lvlactx[c] = x;
                lvlacty[c] = y;
                lvlactf[c] = (yf << 6) + (xf << 4);
                if (actnum < 128) // Not item
                  lvlactw[c] = 0;
                else
                  lvlactw[c] = 255; // Default add
                break;
              }
            }
          }
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportpng();
    if (k == KEY_F12) copycharset();

    gfx_fillscreen(254);
    drawmap();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void zone_mainloop(void)
{
  calculatelevelorigins();

  for (;;)
  {
    int s, shiftdown, ctrldown;
    int divisor = zoomoutmode ? 8 : 32;

    s = win_getspeed(70);
    flash += s;
    flash &= 31;
    k = kbd_getkey();
    ascii = kbd_getascii();
    shiftdown = win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT];
    ctrldown = win_keystate[KEY_CTRL];
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }

    {
      moveonmap(k, shiftdown);

      if (k == KEY_1 || k == KEY_Z)
      {
        zonenum--;
        if (zonenum < 0) zonenum = NUMZONES-1;
        charsetnum = zonecharset[zonenum];
      }
      if (k == KEY_2 || k == KEY_X)
      {
        zonenum++;
        if (zonenum >= NUMZONES) zonenum = 0;
        charsetnum = zonecharset[zonenum];
      }
      if (k == KEY_TAB && shiftdown)
      {
        zonecharset[zonenum]--;
        zonecharset[zonenum] &= NUMCHARSETS-1;
        charsetnum = zonecharset[zonenum];
      }
      if (k == KEY_TAB && !shiftdown)
      {
        zonecharset[zonenum]++;
        zonecharset[zonenum] &= NUMCHARSETS-1;
        charsetnum = zonecharset[zonenum];
      }
      if (k == KEY_3)
      {
        if (!shiftdown)
          zonespawnparam[zonenum]--;
        else
          zonespawnparam[zonenum] -= 16;
      }
      if (k == KEY_4)
      {
        if (!shiftdown)
          zonespawnparam[zonenum]++;
        else
          zonespawnparam[zonenum] += 16;
      }
      if (k == KEY_5)
      {
        if (!shiftdown)
          zonespawnspeed[zonenum]--;
        else
          zonespawnspeed[zonenum] -= 16;
      }
      if (k == KEY_6)
      {
        if (!shiftdown)
          zonespawnspeed[zonenum]++;
        else
          zonespawnspeed[zonenum] += 16;
      }
      if (k == KEY_7)
      {
        if (!shiftdown)
          zonespawncount[zonenum]--;
        else
          zonespawncount[zonenum] -= 16;
      }
      if (k == KEY_8)
      {
        if (!shiftdown)
          zonespawncount[zonenum]++;
        else
          zonespawncount[zonenum] += 16;
      }
      if (k == KEY_C)
      {
        zonebg1[zonenum] ^= 128;
      }
      if (k == KEY_T)
      {
        zonebg2[zonenum] ^= 128;
      }
      if (k == KEY_N)
      {
        if (!shiftdown)
          zonemusic[zonenum]--;
        else
          zonemusic[zonenum] -= 4;
      }
      if (k == KEY_M)
      {
        if (!shiftdown)
          zonemusic[zonenum]++;
        else
          zonemusic[zonenum] += 4;
      }
      if (k == KEY_L)
      {
        zonelevel[zonenum]++;
        zonelevel[zonenum] &= NUMLEVELS-1;
        calculatelevelorigins();
      }
      if (k == KEY_K)
      {
        zonelevel[zonenum]--;
        zonelevel[zonenum] &= NUMLEVELS-1;
        calculatelevelorigins();
      }
      if (k == KEY_U)
      {
        int c;
        for (c = 0; c < NUMZONES; ++c)
        {
          if (!zonesx[c] && !zonesy[c])
          {
            zonenum = c;
            charsetnum = zonecharset[zonenum];
            break;
          }
        }
      }
      if (k == KEY_V)
        switchzoomout(zoomoutmode ^ 1);
      if (k == KEY_DEL)
      {
        zonex[zonenum] = 0;
        zoney[zonenum] = 0;
        zonesx[zonenum] = 0;
        zonesy[zonenum] = 0;
        calculatelevelorigins();
      }
      if (k == KEY_R && shiftdown)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          int x = mapx+mousex/divisor;
          int y = mapy+mousey/divisor;
          // Round to full screens horizontally
          relocatezone(x / 10 * 10, y);
        }
      }
      if (k == KEY_G && zonesx[zonenum] && zonesy[zonenum])
      {
        mapx = zonex[zonenum];
        mapy = zoney[zonenum];
      }
    }

    if (k == KEY_F5)
    {
      editmode = EM_CHARS;
      break;
    }
    if (k == KEY_F6)
    {
      editmode = EM_MAP;
      blockselectmode = 0;
      break;
    }
    if (k == KEY_F7)
    {
      editmode = EM_ZONE;
      break;
    }
    if (k == KEY_F8)
    {
      editmode = EM_LEVEL;
      break;
    }

    if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
    {
      int x = mapx+mousex/divisor;
      int y = mapy+mousey/divisor;

      if (mouseb == 1)
      {
        if (findzone(x,y) < NUMZONES)
        {
          zonenum = findzone(x,y);
          charsetnum = zonecharset[zonenum];
        }
      }
      if (mouseb == 2)
      {
        if (!zonesx[zonenum] && !zonesy[zonenum])
        {
          int nx = x/10*10;
          int ny = y;
          int nsx = 10;
          int nsy = 3;
          if (checkzonelegal(zonenum, nx, ny, nsx, nsy))
          {
            // Copy properties from nearest zone to speed up
            int nearest = findnearestzone((nx+nx+nsx)/2, (nx+nx+nsy)/2);

            zonex[zonenum] = nx;
            zoney[zonenum] = ny;
            zonesx[zonenum] = nsx;
            zonesy[zonenum] = nsy;

            if (nearest < NUMZONES)
            {
              zonebg1[zonenum] = zonebg1[nearest];
              zonebg2[zonenum] = zonebg2[nearest];
              zonebg3[zonenum] = zonebg3[nearest];
              zonecharset[zonenum] = zonecharset[nearest];
              zonemusic[zonenum] = zonemusic[nearest];
              zonelevel[zonenum] = zonelevel[nearest];
            }

            calculatelevelorigins();
          }
        }
        else
        {
          int px = x / 10 * 10;
          int py = y;
          int nx = zonex[zonenum];
          int ny = zoney[zonenum];
          int nsx = zonesx[zonenum];
          int nsy = zonesy[zonenum];
          if (px < nx)
          {
            nx = px;
            nsx = zonex[zonenum]+zonesx[zonenum]-nx;
          }
          else if (px+10-zonex[zonenum] > zonesx[zonenum])
            nsx = px+10-zonex[zonenum];
          if (py < ny)
          {
            ny = py;
            nsy = zoney[zonenum]+zonesy[zonenum]-ny;
          }
          else if (py+1-zoney[zonenum] > zonesy[zonenum])
            nsy = py+1-zoney[zonenum];
          if (checkzonelegal(zonenum, nx, ny, nsx, nsy))
          {
            zonex[zonenum] = nx;
            zoney[zonenum] = ny;
            zonesx[zonenum] = nsx;
            zonesy[zonenum] = nsy;
            calculatelevelorigins();
          }
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportpng();
    if (k == KEY_F12) copycharset();

    gfx_fillscreen(254);
    drawmap();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void map_mainloop(void)
{
  for (;;)
  {
    int divisor = zoomoutmode ? 8 : 32;
    int shiftdown;
    win_getspeed(70);
    k = kbd_getkey();
    ascii = kbd_getascii();
    shiftdown = win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT];
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }

    if (k == KEY_F5)
    {
      editmode = EM_CHARS;
      break;
    }
    if (k == KEY_F6)
    {
      editmode = EM_MAP;
      blockselectmode = 0;
      break;
    }
    if (k == KEY_F7)
    {
      editmode = EM_ZONE;
      break;
    }
    if (k == KEY_F8)
    {
      editmode = EM_LEVEL;
      break;
    }
    if (k == KEY_B)
    {
      findusedblocksandchars();
      blockselectmode ^= 1;
    }
    if (k == KEY_V)
      switchzoomout(zoomoutmode ^ 1);
    if ((k == KEY_Z) && (blocknum > 0))
      blocknum--;
    if ((k == KEY_X) && (blocknum < BLOCKS-1))
      blocknum++;
    if (k == KEY_Q)
      memcpy(bcopybuffer, &blockdata[charsetnum][blocknum*16],16);
    if (k == KEY_W)
    {
      memcpy(&blockdata[charsetnum][blocknum*16],bcopybuffer,16);
    }

    if (k == KEY_TAB && shiftdown)
    {
      zonecharset[zonenum]--;
      zonecharset[zonenum] &= NUMCHARSETS-1;
      charsetnum = zonecharset[zonenum];
    }
    if (k == KEY_TAB && !shiftdown)
    {
      zonecharset[zonenum]++;
      zonecharset[zonenum] &= NUMCHARSETS-1;
      charsetnum = zonecharset[zonenum];
    }

    if (!blockselectmode)
    {
      moveonmap(k, shiftdown);
      // Continuously shift to the charset in the zone under cursor
      if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
      {
        int x = mapx+mousex/divisor;
        int y = mapy+mousey/divisor;
        int newzonenum = findzone(x,y);
        if (newzonenum < NUMZONES)
        {
          zonenum = newzonenum;
          charsetnum = zonecharset[newzonenum];
        }
      }

      if (k == KEY_F)
      {
        int c;
        int dist = 0x7fffffff, nx = -1, ny = -1;
        for (c = 0; c < mapsx*mapsy; c++)
        {
          if (mapdata[c] == blocknum)
          {
            int x = c % mapsx;
            int y = c / mapsx;
            int newzonenum = findzone(x,y);
            // Make sure is in same charset. Try to find nearest match
            if (newzonenum < NUMZONES && zonecharset[newzonenum] == charsetnum)
            {
              int newdist = abs(x-(mapx+160/divisor))+abs(y-(mapy+96/divisor));
              if (newdist < dist)
              {
                nx = x;
                ny = y;
                dist = newdist;
              }
            }
          }
        }
        if (nx >= 0 && ny >= 0)
          gotopos(nx,ny);
      }
      if (k == KEY_P)
      {
        if (finemarkmode == 2)
        {
            int x,y;
            int i = 0;
            for (y = finemarky1; y <= finemarky2; y++)
            {
                for (x = finemarkx1; x <= finemarkx2; x++)
                {
                    if (i >= MAPCOPYSIZE)
                      break;
                    int yb = y >> 2;
                    int xb = x >> 2;
                    int yc = y & 3;
                    int xc = x & 3;
                    int b = mapdata[yb*mapsx+xb];
                    finemapcopybuffer[i] = blockdata[charsetnum][b*16+yc*4+xc];
                    i++;
                }
            }
            if (i <= MAPCOPYSIZE)
            {
                finemapcopyx = finemarkx2-finemarkx1+1;
                finemapcopyy = finemarky2-finemarky1+1;
                mapcopyx = 0;
                mapcopyy = 0;
                finemarkmode = 0;
            }
            else
            {
                finemapcopyx = 0;
                finemapcopyy = 0;
            }
        }
        else if (markmode == 2)
        {
          int x,y;
          int i = 0;

          for (y = marky1; y <= marky2; y++)
          {
            for (x = markx1; x <= markx2; x++)
            {
              mapcopybuffer[i] = mapdata[y*mapsx+x];
              i++;
              if (i >= MAPCOPYSIZE)
              {
                i++;
                break;
              }
            }
          }
          if (i <= MAPCOPYSIZE)
          {
            mapcopyx = markx2-markx1+1;
            mapcopyy = marky2-marky1+1;
            finemapcopyx = 0;
            finemapcopyy = 0;
            markmode = 0;
          }
          else
          {
            mapcopyx = 0;
            mapcopyy = 0;
          }
        }
      }
      if (k == KEY_T)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192) &&
            (mapcopyx) && (mapcopyy))
        {
          int x,y;
          int i = 0;

          for (y = 0; y < mapcopyy; y++)
          {
            for (x = 0; x < mapcopyx; x++)
            {
              int rx = x + mapx + mousex/divisor;
              int ry = y + mapy + mousey/divisor;
              if ((rx < mapsx) & (ry < mapsy)) mapdata[ry*mapsx+rx] = mapcopybuffer[i];
              i++;
            }
          }
        }
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192) &&
            (finemapcopyx) && (finemapcopyy))
        {
          int x,y;
          int i = 0;
          int newblocks;

          findusedblocksandchars();

          newblocks = maxusedblocks[charsetnum];

          for (y = 0; y < finemapcopyy; y++)
          {
              for (x = 0; x < finemapcopyx; x++)
              {
                  int rx = x + mapx*4 + mousex/8;
                  int ry = y + mapy*4 + mousey/8;

                  int xb = rx >> 2;
                  int yb = ry >> 2;
                  int xc = rx & 3;
                  int yc = ry & 3;

                  int b = mapdata[yb*mapsx+xb];
                  if (blockusecount[charsetnum][b] > 1 && b < maxusedblocks[charsetnum] && newblocks < 256)
                  {
                      copyblock(b, newblocks);
                      mapdata[yb*mapsx+xb] = newblocks;
                      b = newblocks;
                      newblocks++;
                  }

                  blockdata[charsetnum][b*16+yc*4+xc] = finemapcopybuffer[i];
                  i++;
              }
          }

          optimizeblocks();
        }
      }
      if ((k == KEY_G) || (ascii == 13))
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          blocknum = mapdata[mapx+mousex/divisor+(mapy+mousey/divisor)*mapsx];
        }
      }
      if (ascii == 13)
      {
        initblockeditmode(1);
        break;
      }
      if (mouseb & 1)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          mapdata[mapx+mousex/divisor+(mapy+mousey/divisor)*mapsx]=blocknum;
        }
      }
      if ((mouseb & 2) && (!prevmouseb))
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          finemarkmode = 0;
          switch(markmode)
          {
            case 0:
            markx1 = mapx+mousex/divisor;
            marky1 = mapy+mousey/divisor;
            markmode = 1;
            break;

            case 1:
            markx2 = mapx+mousex/divisor;
            marky2 = mapy+mousey/divisor;
            if ((markx2 >= markx1) && (marky2 >= marky1))
            {
              markmode = 2;
            }
            else
            {
              markx1 = markx2;
              marky1 = marky2;
            }
            break;

            case 2:
            markmode = 0;
          }
        }
      }

      if (k == KEY_M && !zoomoutmode)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          markmode = 0;
          switch(finemarkmode)
          {
            case 0:
            finemarkx1 = mapx*4+mousex/8;
            finemarky1 = mapy*4+mousey/8;
            finemarkmode = 1;
            break;

            case 1:
            finemarkx2 = mapx*4+mousex/8;
            finemarky2 = mapy*4+mousey/8;
            if ((finemarkx2 >= finemarkx1) && (finemarky2 >= finemarky1))
            {
              finemarkmode = 2;
            }
            else
            {
              finemarkx1 = finemarkx2;
              finemarky1 = finemarky2;
            }
            break;

            case 2:
            finemarkmode = 0;
          }
        }
      }
    }
    else
    {
      if (k == KEY_UP) bsy--;
      if (k == KEY_DOWN) bsy++;
      if (bsy < 0) bsy = 0;
      if (bsy > 21) bsy = 21;
      if (mouseb & 1 || k == KEY_G)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          blocknum = mousey/32*10+mousex/32+bsy*10;
          if (blocknum > 255)
            blocknum = 255;
        }
      }
      if (k == KEY_S)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          int blocknum2 = mousey/32*10+mousex/32+bsy*10;
          swapblocks(blocknum, blocknum2);
        }
      }
      if (k == KEY_I || k == KEY_INS)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 192))
        {
          int blocknum2 = mousey/32*10+mousex/32+bsy*10;
          insertblock(blocknum, blocknum2);
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportpng();
    if (k == KEY_F12) copycharset();

    gfx_fillscreen(254);
    if (!blockselectmode)
    {
      int c;
      drawmap();
      // Charinfo debug
      if (!zoomoutmode)
      {
        for (c = 0; c < 8; c++)
        {
          if (win_keystate[KEY_1 + c])
          {
            int x,y;
            int currentzone = 0;
            int currentcharset = 0;
            for (y = 0; y < 6; y++)
            {
              for (x = 0; x < 10; x++)
              {
                int b = mapdata[mapx+x+(mapy+y)*mapsx];
                int bx,by;
                currentzone = findzonefast(mapx+x, mapy+y, currentzone);
                if (currentzone < NUMZONES)
                  currentcharset = zonecharset[currentzone];
  
                for (by = 0; by < 4; by++)
                {
                  for (bx = 0; bx < 4; bx++)
                  {
                    if (chinfo[currentcharset][blockdata[currentcharset][b*16+by*4+bx]] & (1 << c))
                    {
                      gfx_line(x*32+bx*8, y*32+by*8, x*32+bx*8+7, y*32+by*8+7, 1);
                      gfx_line(x*32+bx*8+7, y*32+by*8, x*32+bx*8, y*32+by*8+7, 1);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    else
      drawblocks();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void drawblocks(void)
{
  int x,y;

  for (y = 0; y < 6; y++)
  {
    for (x = 0; x < 10; x++)
    {
      int blk = y*10+x+bsy*10;
      if (blk < 256)
      {
        drawblock(x*32,y*32,blk,charsetnum);
        if (blk == blocknum)
        {
          gfx_line(x*32,y*32,x*32+31,y*32,1);
          gfx_line(x*32,y*32,x*32,y*32+31,1);
          gfx_line(x*32+31,y*32,x*32+31,y*32+31,1);
          gfx_line(x*32,y*32+31,x*32+31,y*32+31,1);
        }
        if (blk && blk < maxusedblocks[charsetnum] && blockusecount[charsetnum][blk] < 3)
        {
          sprintf(textbuffer, "%d", blockusecount[charsetnum][blk]);
          printtext_color(textbuffer, x*32, y*32+22,SPR_FONTS,COL_WHITE);
        }
      }
    }
  }

  if (mousey < 192)
  {
    int bx = mousex & 0xffe0;
    int by = mousey & 0xffe0;
    gfx_line(bx, by, bx+31, by, 1);
    gfx_line(bx, by+1, bx+31, by+1, 1);
    gfx_line(bx, by+30, bx+31, by+30, 1);
    gfx_line(bx, by+31, bx+31, by+31, 1);
    gfx_line(bx, by, bx, by+31, 1);
    gfx_line(bx+1, by, bx+1, by+31, 1);
    gfx_line(bx+30, by, bx+30, by+31, 1);
    gfx_line(bx+31, by, bx+31, by+31, 1);
  }

  drawblock(320-32,224-32,blocknum,charsetnum);
  sprintf(textbuffer, "CHSET %d", zonecharset[zonenum]);
  printtext_color(textbuffer, 216,195,SPR_FONTS,COL_WHITE);
  sprintf(textbuffer, "BLOCK %d", blocknum);
  printtext_color(textbuffer, 216,205,SPR_FONTS,COL_WHITE);
  sprintf(textbuffer, "(USE %d)", blockusecount[charsetnum][blocknum]);
  printtext_color(textbuffer, 216,215,SPR_FONTS,COL_WHITE);
}

void drawmap(void)
{
  int y,x;
  int currentzone = 0;
  int currentcharset = 0;
  int oldzone = zonenum;
  int divisor = zoomoutmode ? 8 : 32;
  int divminusone = divisor-1;
  int divminustwo = divisor-2;
  int limitx = zoomoutmode ? 40 : 10;
  int limity = zoomoutmode ? 24 : 6;
  // For non-zoned map area, use charset from the one nearest to the visible map center
  int defaultzone = findnearestzone(mapx+160/divisor, mapy+96/divisor);
  if (defaultzone >= NUMZONES) defaultzone = 0;

  for (y = 0; y < 192/divisor; y++)
  {
    for (x = 0; x < 320/divisor; x++)
    {
      if (mapx+x < mapsx && mapy+y < mapsy)
      {
        int newzonenum = findzonefast(mapx+x, mapy+y, zonenum);
        zonenum = newzonenum < NUMZONES ? newzonenum : defaultzone;
        currentcharset = zonecharset[zonenum];

        if (!zoomoutmode)
          drawblock(x*divisor,y*divisor,mapdata[mapx+x+(mapy+y)*mapsx], currentcharset);
        else
          drawsmallblock(x*divisor,y*divisor,mapdata[mapx+x+(mapy+y)*mapsx], currentcharset);

        // Draw warning indicator for map areas that do not belong to any zone
        if (mapdata[mapx+x+(mapy+y)*mapsx] > 0 && newzonenum >= NUMZONES)
        {
          int bx,by;
          gfx_line(x*divisor, y*divisor, x*divisor+divminusone, y*divisor+divminusone, 2);
          gfx_line(x*divisor+divminusone, y*divisor, x*divisor, y*divisor+divminusone, 2);
        }
        // Draw screen edge indicators (only when not in map edit mode or zoomed out)
        if (editmode != EM_MAP || zoomoutmode)
        {
          if (((x+mapx) % 10) == 0)
            gfx_line(x*divisor, y*divisor, x*divisor, y*divisor+divminusone, 12);
          if (((y+mapy) % 6) == 0)
            gfx_line(x*divisor, y*divisor, x*divisor+divminusone, y*divisor, 12);
        }
      }
    }
  }

  zonenum = oldzone;

  if (editmode == EM_ZONE)
  {
    int c;
    int levelcolors[] = {4,5,8,10,14,15};
    int col = 0;

    // In zoomed out zone edit mode, draw bounds for all zones
    if (zoomoutmode)
    {
      for (c = 0; c < NUMZONES; c++)
      {
        if (zonesx[c] && zonesy[c])
        {
          int l,r,u,d;
          l = zonex[c] - mapx;
          r = l + zonesx[c]-1;
          u = zoney[c] - mapy;
          d = u + zonesy[c]-1;
          gfx_line(l*divisor,u*divisor,r*divisor+divisor,u*divisor,2);
          gfx_line(l*divisor,u*divisor,l*divisor,d*divisor+divisor,2);
          gfx_line(l*divisor,d*divisor+divisor,r*divisor+divisor,d*divisor+divisor,2);
          gfx_line(r*divisor+divisor,u*divisor,r*divisor+divisor,d*divisor+divisor,2);
        }
      }
    }

    // Draw level bounds, colorcoded
    for (c = 0; c < NUMLEVELS; c++)
    {
      if (levelsx[c] && levelsy[c])
      {
        int l,r,u,d;
        l = levelx[c] - mapx;
        r = l + levelsx[c]-1;
        u = levely[c] - mapy;
        d = u + levelsy[c]-1;
        gfx_line(l*divisor,u*divisor,r*divisor+divisor,u*divisor,levelcolors[col]);
        gfx_line(l*divisor,u*divisor,l*divisor,d*divisor+divisor,levelcolors[col]);
        gfx_line(l*divisor,d*divisor+divisor,r*divisor+divisor,d*divisor+divisor,levelcolors[col]);
        gfx_line(r*divisor+divisor,u*divisor,r*divisor+divisor,d*divisor+divisor,levelcolors[col]);
        col++;
        if (col == 6) col = 0;
      }
    }
  }

  // Draw current zone edge indicators. In map mode dislocate the left & up edges to make sure no block data is obscured
  if (zonesx[zonenum] && zonesy[zonenum])
  {
    int l,r,u,d;

    l = zonex[zonenum] - mapx;
    r = l + zonesx[zonenum]-1;
    u = zoney[zonenum] - mapy;
    d = u + zonesy[zonenum]-1;
    l *= divisor;
    r *= divisor;
    r += divisor;
    u *= divisor;
    d *= divisor;
    d += divisor;
    if (editmode == EM_MAP && !zoomoutmode)
    {
      l--;
      u--;
    }
    gfx_line(l,u,r,u,7);
    gfx_line(l,u,l,d,7);
    gfx_line(l,d,r,d,7);
    gfx_line(r,u,r,d,7);
  }

  // Clean up lines that spill to the status area
  for (y = 192; y < 224; ++y)
    gfx_line(0, y, 319, y, 254);

  if (editmode == EM_MAP)
  {
    int l,r,u,d;

    if (finemarkmode)
    {
      l = finemarkx1 - mapx*4;
      u = finemarky1 - mapy*4;
      if ((l >= 0) && (u >= 0) && (l < 40) && (u < 24))
      {
        gfx_line(l*8,u*8,l*8+7,u*8,1);
        gfx_line(l*8,u*8+1,l*8+7,u*8+1,1);
        gfx_line(l*8,u*8,l*8,u*8+7,1);
        gfx_line(l*8+1,u*8,l*8+1,u*8+7,1);
      }
    }
    if (finemarkmode == 2)
    {
      r = finemarkx2 - mapx*4;
      d = finemarky2 - mapy*4;
      if ((r >= 0) && (d >= 0) && (r < 40) && (d < 24))
      {
        gfx_line(r*8+6,d*8,r*8+6,d*8+7,1);
        gfx_line(r*8+7,d*8,r*8+7,d*8+7,1);
        gfx_line(r*8,d*8+6,r*8+7,d*8+6,1);
        gfx_line(r*8,d*8+7,r*8+7,d*8+7,1);
      }
    }

    if (markmode)
    {
      l = markx1 - mapx;
      u = marky1 - mapy;

      if ((l >= 0) && (u >= 0) && (l < limitx) && (u < limity))
      {
        gfx_line(l*divisor,u*divisor,l*divisor+divminusone,u*divisor,1);
        gfx_line(l*divisor,u*divisor+1,l*divisor+divminusone,u*divisor+1,1);
        gfx_line(l*divisor,u*divisor,l*divisor,u*divisor+divminusone,1);
        gfx_line(l*divisor+1,u*divisor,l*divisor+1,u*divisor+divminusone,1);
      }
    }
    if (markmode == 2)
    {
      r = markx2 - mapx;
      d = marky2 - mapy;

      if ((r >= 0) && (d >= 0) && (r < limitx) && (d < limity))
      {
        gfx_line(r*divisor+divminustwo,d*divisor,r*divisor+divminustwo,d*divisor+divminusone,1);
        gfx_line(r*divisor+divminusone,d*divisor,r*divisor+divminusone,d*divisor+divminusone,1);
        gfx_line(r*divisor,d*divisor+divminustwo,r*divisor+divminusone,d*divisor+divminustwo,1);
        gfx_line(r*divisor,d*divisor+divminusone,r*divisor+divminusone,d*divisor+divminusone,1);
      }
    }

    if (zonesx[zonenum] && zonesy[zonenum])
      sprintf(textbuffer, "ZONE %d (%d,%d)-(%d,%d)", zonenum, zonex[zonenum],zoney[zonenum],zonex[zonenum]+zonesx[zonenum]-1,zoney[zonenum]+zonesy[zonenum]-1);
    else
      sprintf(textbuffer, "ZONE %d (UNUSED)", zonenum);
    printtext_color(textbuffer, 0,195,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "XPOS %d", mapx+mousex/divisor);
    printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "YPOS %d", mapy+mousey/divisor);
    printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
    drawblock(320-32,224-32,blocknum,zonecharset[zonenum]);
    sprintf(textbuffer, "CHSET %d", zonecharset[zonenum]);
    printtext_color(textbuffer, 216,195,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "BLOCK %d", blocknum);
    printtext_color(textbuffer, 216,205,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "(USE %d)", blockusecount[charsetnum][blocknum]);
    printtext_color(textbuffer, 216,215,SPR_FONTS,COL_WHITE);
  }
  if (editmode == EM_ZONE)
  {
    int levelmapdatasize = 0;
    for (x = 0; x < NUMZONES; x++)
    {
      if (zonesx[x] && zonesy[x] && zonelevel[x] == zonelevel[zonenum])
        levelmapdatasize += zonesx[x] * zonesy[x];
    }

    // Print level numbers for zones in zoomout mode
    if (zoomoutmode)
    {
      int c;
      for (c = 0; c < NUMZONES; ++c)
      {
        if (zonesx[c] && zonesy[c])
        {
          sprintf(textbuffer, "%d", zonelevel[c]);
          printtext_color(textbuffer, (zonex[c]-mapx)*divisor, (zoney[c]-mapy)*divisor, SPR_FONTS, COL_WHITE);
        }
      }
    }

    sprintf(textbuffer, "SP.PARAM %02X SP.SPEED %02X SP.COUNT %02X", zonespawnparam[zonenum], zonespawnspeed[zonenum], zonespawncount[zonenum]);
    printtext_color(textbuffer, 0,185,SPR_FONTS,COL_WHITE);
    if (zonesx[zonenum] && zonesy[zonenum])
      sprintf(textbuffer, "ZONE %d (%d,%d)-(%d,%d)", zonenum, zonex[zonenum],zoney[zonenum],zonex[zonenum]+zonesx[zonenum]-1,zoney[zonenum]+zonesy[zonenum]-1);
    else
      sprintf(textbuffer, "ZONE %d (UNUSED)", zonenum);
    printtext_color(textbuffer, 0,195,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "CHSET %d", zonecharset[zonenum]);
    printtext_color(textbuffer, 216,195,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "LEVEL %d", zonelevel[zonenum]);
    printtext_color(textbuffer, 216,205,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "(DS %d)", levelmapdatasize);
    printtext_color(textbuffer, 216,215,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "XPOS %d", mapx+mousex/divisor);
    printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "YPOS %d", mapy+mousey/divisor);
    printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "COLORS %01X %01X %01X ", zonebg1[zonenum] & 15, zonebg2[zonenum] & 15, zonebg3[zonenum] & 15);
    printtext_color(textbuffer, 80,205,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "");
    if (zonebg1[zonenum] & 128)
      strcat(textbuffer, "(NOCHECKP.)");
    if (zonebg2[zonenum] & 128)
      strcat(textbuffer, "(TOXIC AIR)");
    printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);

    sprintf(textbuffer, "MUSIC %02X-%01X", zonemusic[zonenum] / 4, zonemusic[zonenum] % 4);
    printtext_color(textbuffer, 80,215,SPR_FONTS,COL_WHITE);
  }

  if (editmode == EM_LEVEL)
  {
    int x,y,c;

    drawpath();

    {
      if (actfound)
      {
        int a = actindex;

        if (lvlactt[a] < 128)
        {
          sprintf(textbuffer, "ACTOR %02X (%s) (%02X,%02X) ", lvlactt[a], actorname[lvlactt[a]], lvlactx[a]-levelx[zonelevel[zonenum]], lvlacty[a] & 0x7f);
          if (lvlacty[a] & 128) strcat(textbuffer, "(HIDDEN)");
          printtext_color(textbuffer, 0,195,SPR_FONTS,COL_WHITE);
          if (lvlactw[a] & 128) sprintf(textbuffer, "LEFT");
          else sprintf(textbuffer, "RIGHT");
          printtext_color(textbuffer, 256,195,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "MODE:%1X (%s)", lvlactf[a] & 0xf, modename[lvlactf[a] & 0xf]);
          printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "WPN:%02X (%s)", lvlactw[a] & 0x7f, itemname[lvlactw[a] & 0x7f]);
          printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
        }
        else
        {
          sprintf(textbuffer, "ITEM %02X (%s) (%02X,%02X) ", lvlactt[a] & 0x7f, itemname[lvlactt[a]-128], lvlactx[a]-levelx[zonelevel[zonenum]], lvlacty[a] & 0x7f);
          if (lvlacty[a] & 128) strcat(textbuffer, "(HIDDEN)");
          printtext_color(textbuffer, 0,195,SPR_FONTS,COL_WHITE);
          if (lvlactw[a] != 255)
          {
            sprintf(textbuffer, "COUNT:%d", lvlactw[a]);
          }
          else
          {
            sprintf(textbuffer, "COUNT:DEFAULT");
          }
          printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
        }
      }
      else
      {
        if (objfound)
        {
          int o = objindex;
          int lid = -1;
          int z;
          int lev = -1;
          // Find out index within level for the currently selected object
          z = findzone(lvlobjx[o], lvlobjy[o]&0x7f);
          if (z < NUMZONES)
          {
            lev = zonelevel[z];
            lid = 0;
            for (c = 0; c < objindex; c++)
            {
              if (lvlobjx[c] || lvlobjy[c])
              {
                z = findzonefast(lvlobjx[c], lvlobjy[c]&0x7f, z);
                if (z < NUMZONES && zonelevel[z] == lev)
                  lid++;
              }
            }
          }

          if (lid >= 0)
            sprintf(textbuffer, "OBJ (%02X,%02X) ID:%02X", lvlobjx[o]-levelx[zonelevel[zonenum]], lvlobjy[o] & 0x7f, lid);
          else
          {
            // Object outside zone: levelid cannot be determined
            sprintf(textbuffer, "OBJ (%02X,%02X) ID:??", lvlobjx[o]-levelx[zonelevel[zonenum]], lvlobjy[o] & 0x7f);
          }
          printtext_color(textbuffer, 0, 195, SPR_FONTS, COL_WHITE);

          sprintf(textbuffer, "HSIZE:%d", (lvlobjb[o] & 64) ? 2 : 1);
          if (lvlobjy[o] & 128)
            strcat(textbuffer, " (ANIM)");
          printtext_color(textbuffer, 160,195,SPR_FONTS,COL_WHITE);

          sprintf(textbuffer, "MODE:%s", modetext[(lvlobjb[o] & 0x3)]);
          if (lvlobjb[o] & 32) strcat(textbuffer, "+AUTO-DEACT");
          printtext_color(textbuffer, 160,205,SPR_FONTS,COL_WHITE);

          sprintf(textbuffer, "TYPE:%s (%02X%02X)", actiontext[(lvlobjb[o] & 0x1c) >> 2], lvlobjdh[o],lvlobjdl[o]);
          if (dataeditmode) dataeditflash++;

          if ((dataeditmode) && (dataeditflash & 16))
            printtext_color(textbuffer, 160,215,SPR_FONTS,COL_HIGHLIGHT);
          else
            printtext_color(textbuffer, 160,215,SPR_FONTS,COL_WHITE);

          // Requirement in high databit for everything but scripts
          if ((lvlobjdh[o]&0x7f) && (lvlobjb[o] & 0x1c) != 0x10)
          {
            sprintf(textbuffer, "REQ:%02X", lvlobjdh[o]&0x7f);
            printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
            sprintf(textbuffer, "%-16s", itemname[lvlobjdh[o]&0x7f]);
            printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
          }
        }
      }
      if ((!objfound) && (!actfound))
      {
        int o = 0;
        int a = 0;
        int z = 0;
        int lo = 0;
        int la = 0;

        if (actnum < 128)
        {
          sprintf(textbuffer, "ACTOR %X (%s)", actnum, actorname[actnum]);
        }
        else
        {
          sprintf(textbuffer, "ITEM %X (%s)", actnum-128, itemname[actnum-128]);
        }
        printtext_color(textbuffer, 0,195,SPR_FONTS,COL_WHITE);

        for (c = 0; c < NUMLVLOBJ; c++)
        {
          if ((lvlobjx[c]) || (lvlobjy[c]))
          {
            o++;
            z = findzonefast(lvlobjx[c], lvlobjy[c]&0x7f, z);
            if (z < NUMZONES && zonelevel[z] == zonelevel[zonenum])
              lo++;
          }
        }
        for (c = 0; c < NUMLVLACT; c++)
        {
          if (lvlactt[c])
          {
            a++;
            z = findzonefast(lvlactx[c], lvlacty[c]&0x7f, z);
            if (z < NUMZONES && zonelevel[z] == zonelevel[zonenum])
              la++;
          }
        }

        if (findzone(mapx+mousex/divisor, mapy+mousey/divisor) < NUMZONES)
        {
          sprintf(textbuffer, "XPOS %d (%02X)", mapx+mousex/divisor, mapx+mousex/divisor-levelx[zonelevel[zonenum]]);
          printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "YPOS %d (%02X)", mapy+mousey/divisor, mapy+mousey/divisor);
          printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
        }
        else
        {
          sprintf(textbuffer, "XPOS %d", mapx+mousex/divisor);
          printtext_color(textbuffer, 0,205,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "YPOS %d", mapy+mousey/divisor);
          printtext_color(textbuffer, 0,215,SPR_FONTS,COL_WHITE);
        }
        sprintf(textbuffer, "ZONE %d (LEVEL %d)", zonenum, zonelevel[zonenum]);
        printtext_color(textbuffer, 120,205,SPR_FONTS,COL_WHITE);
        sprintf(textbuffer, "OBJ %d/%d ACT %d/%d", lo, o, la, a);
        printtext_color(textbuffer, 120,215,SPR_FONTS,COL_WHITE);
      }
      for (c = 0; c < NUMLVLOBJ; c++)
      {
        if ((lvlobjx[c]) || (lvlobjy[c]))
        {
          x = lvlobjx[c] - mapx;
          y = (lvlobjy[c] & 0x7f) - mapy;
          if ((x >= 0) && (x < 10) && (y >= 0) && (y < 6))
          {
            // 2 blocks high
            if (lvlobjb[c] & 64)
            {
              gfx_line(x*32,y*32-32,x*32+31,y*32-32,1);
              gfx_line(x*32+31,y*32-32,x*32+31,y*32+31,1);
              gfx_line(x*32+31,y*32+31,x*32,y*32+31,1);
              gfx_line(x*32,y*32+31,x*32,y*32-32,1);
            }
            else
            {
              gfx_line(x*32,y*32,x*32+31,y*32,1);
              gfx_line(x*32+31,y*32,x*32+31,y*32+31,1);
              gfx_line(x*32+31,y*32+31,x*32,y*32+31,1);
              gfx_line(x*32,y*32+31,x*32,y*32,1);
            }
          }
        }
      }
      for (c = 0; c < NUMLVLACT; c++)
      {
        if (lvlactt[c])
        {
          x = lvlactx[c] - mapx;
          y = (lvlacty[c] & 0x7f) - mapy;

          if ((x >= 0) && (x < 10) && (y >= 0) && (y < 6))
          {
            int xc = x * 32 + ((lvlactf[c] >> 4) & 3) * 8;
            int yc = y * 32 + ((lvlactf[c] >> 6) & 3) * 8;

            gfx_line(xc,yc,xc+7,yc+7,1);
            gfx_line(xc+7,yc,xc,yc+7,1);
            if (lvlacty[c] & 0x80) // Hidden
            {
              gfx_line(xc,yc,xc+7,yc,1);
              gfx_line(xc+7,yc,xc+7,yc+7,1);
              gfx_line(xc+7,yc+7,xc,yc+7,1);
              gfx_line(xc,yc+7,xc,yc,1);
            }
            sprintf(textbuffer, "%02X", lvlactt[c]);
            printtext_color(textbuffer, xc-4,yc+10,SPR_FONTS,COL_NUMBER);
          }
        }
      }
    }
  }
}

void char_mainloop(void)
{
  findusedblocksandchars();

  if ((blockeditmode) && (blocknum != blockeditnum))
  {
    endblockeditmode();
  }
  for (;;)
  {
    int s, shiftdown, ctrldown;
    s = win_getspeed(70);
    flash += s;
    flash &= 31;
    k = kbd_getkey();
    ascii = kbd_getascii();
    shiftdown = win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT];
    ctrldown = win_keystate[KEY_CTRL];
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }
    if (ascii == 13)
    {
      if (blockeditmode)
      {
        endblockeditmode();
      }
      else
      {
        initblockeditmode(0);
      }
    }
    if (k == KEY_TAB)
    {
      if (!shiftdown)
        charsetnum++;
      else
        charsetnum--;
      charsetnum &= NUMCHARSETS-1;
    }

    if (k == KEY_O)
    {
      if (shiftdown)
        reorganizedata();
      else
      {
        optimizechars();
        optimizeblocks();
      }
    }
    if (k == KEY_C)
    {
      memset(&chardata[charsetnum][charnum*8],0,8);
      chinfo[charsetnum][charnum]=0;
      chcol[charsetnum][charnum] &= 0xf;
    }
    if (!shiftdown && !ctrldown)
    {
      if (k == KEY_1) chinfo[charsetnum][charnum] ^= 1;
      if (k == KEY_2) chinfo[charsetnum][charnum] ^= 2;
      if (k == KEY_3) chinfo[charsetnum][charnum] ^= 4;
      if (k == KEY_4) chinfo[charsetnum][charnum] ^= 8;
      if (k == KEY_5) chinfo[charsetnum][charnum] ^= 16;
      if (k == KEY_6) chinfo[charsetnum][charnum] ^= 32;
      if (k == KEY_7) chinfo[charsetnum][charnum] ^= 64;
      if (k == KEY_8) chinfo[charsetnum][charnum] ^= 128;
    }
    else if (ctrldown)
    {
      if (k == KEY_0) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x0; }
      if (k == KEY_1) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x1; }
      if (k == KEY_2) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x2; }
      if (k == KEY_3) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x3; }
      if (k == KEY_4) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x4; }
      if (k == KEY_5) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x5; }
      if (k == KEY_6) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x6; }
      if (k == KEY_7) { chcol[charsetnum][charnum] &= 0xf8; chcol[charsetnum][charnum] |= 0x7; }
    }
    else if (shiftdown)
    {
        if (k == KEY_1) ccolor = 0;
        if (k == KEY_2) ccolor = 1;
        if (k == KEY_3) ccolor = 2;
        if (k == KEY_4) ccolor = 3;
    }
    if (k == KEY_S)
    {
      // Edit slope bits
      chinfo[charsetnum][charnum] += 32;
    }

    if (k == KEY_M)
    {
      chcol[charsetnum][charnum] ^= 8;
    }
    if (k == KEY_F)
    {
      chcol[charsetnum][charnum] ^= 64;
    }
    if (k == KEY_V)
    {
      int c,y,x;
      char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      if (!shiftdown)
      {
        for (y = 0; y < 8; y++)
        {
          for (x = 0; x < 4; x++)
          {
            char bit = (chardata[charsetnum][charnum*8+y] >> (x*2)) & 3;
            if (bit == 2) bit = 1;
            else if (bit == 1) bit = 2;
            chardata[charsetnum][charnum*8+y] &= andtable[x];
            chardata[charsetnum][charnum*8+y] |= (bit << (x*2));
          }
        }
      }
      else
      {
        for (c = 0; c < 256; c++)
        {
          if (chcol[charsetnum][c] >= 8)
          {
            for (y = 0; y < 8; y++)
            {
              for (x = 0; x < 4; x++)
              {
                char bit = (chardata[charsetnum][c*8+y] >> (x*2)) & 3;
                if (bit == 2) bit = 1;
                else if (bit == 1) bit = 2;
                chardata[charsetnum][c*8+y] &= andtable[x];
                chardata[charsetnum][c*8+y] |= (bit << (x*2));
              }
            }
          }
        }
        for (c = 0; c < NUMZONES; c++)
        {
          if (zonesx[c] && zonesy[c] && zonecharset[c] == charsetnum)
          {
            int col1 = zonebg2[c] & 0xf;
            int col2 = zonebg3[c] & 0xf;
            zonebg2[c] &= 0xf0;
            zonebg2[c] |= col2;
            zonebg3[c] &= 0xf0;
            zonebg3[c] |= col1;
          }
        }
      }
    }

    if (k == KEY_R)
    {
      if (!shiftdown)
      {
        int y;
        for (y = 0; y < 8; y++)
        {
          chardata[charsetnum][charnum*8+y] ^= 0xff;
        }
      }
      else
      {
        int y,x;
        char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
        for (y = 0; y < 8; y++)
        {
          for (x = 0; x < 4; x++)
          {
            char bit = (chardata[charsetnum][charnum*8+y] >> (x*2)) & 3;
            if (bit == 0) bit = 1;
            else if (bit == 1) bit = 0;
            chardata[charsetnum][charnum*8+y] &= andtable[x];
            chardata[charsetnum][charnum*8+y] |= (bit << (x*2));
          }
        }
      }
    }

    if (k == KEY_B)
    {
      int y,x;
      char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 8; y++)
      {
        for (x = 0; x < 4; x++)
        {
          char bit = (chardata[charsetnum][charnum*8+y] >> (x*2)) & 3;
          if (bit == 3) bit = 1;
          else if (bit == 1) bit = 3;
          chardata[charsetnum][charnum*8+y] &= andtable[x];
          chardata[charsetnum][charnum*8+y] |= (bit << (x*2));
        }
      }
    }
    if (k == KEY_N)
    {
      int y,x;
      char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 8; y++)
      {
        for (x = 0; x < 4; x++)
        {
          char bit = (chardata[charsetnum][charnum*8+y] >> (x*2)) & 3;
          if (bit == 3) bit = 2;
          else if (bit == 2) bit = 3;
          chardata[charsetnum][charnum*8+y] &= andtable[x];
          chardata[charsetnum][charnum*8+y] |= (bit << (x*2));
        }
      }
    }

    if ((k == KEY_COMMA) && (charnum > 0)) charnum--;
    if ((k == KEY_COLON) && (charnum < 255)) charnum++;

    if (!blockeditmode)
    {
      if ((k == KEY_Z) && (blocknum > 0))
      {
        blocknum--;
      }
      if ((k == KEY_X) && (blocknum < BLOCKS-1))
      {
        blocknum++;
      }
    }
    if (k == KEY_P)
    {
      memcpy(copybuffer, &chardata[charsetnum][charnum*8],8);
      copychcol = chcol[charsetnum][charnum];
      copychinfo = chinfo[charsetnum][charnum];
    }
    if (k == KEY_T)
    {
      memcpy(&chardata[charsetnum][charnum*8],copybuffer,8);
      chcol[charsetnum][charnum] = copychcol;
      chinfo[charsetnum][charnum] = copychinfo;
    }
    if (k == KEY_Q)
    {
      memcpy(bcopybuffer, &blockdata[charsetnum][blocknum*16],16);
    }
    if (k == KEY_W)
    {
      memcpy(&blockdata[charsetnum][blocknum*16],bcopybuffer,16);
    }

    if (!blockeditmode)
    {
      if (k == KEY_F5)
      {
        editmode = EM_CHARS;
        break;
      }
      if (k == KEY_F6)
      {
        editmode = EM_MAP;
        blockselectmode = 0;
        break;
      }
      if (k == KEY_F7)
      {
        editmode = EM_ZONE;
        break;
      }
      if (k == KEY_F8)
      {
        editmode = EM_LEVEL;
        break;
      }
    }
    
    if (k == KEY_G)
    {
      if ((mousex >= 170) && (mousex < 170+32) && (mousey >= 0) && (mousey < 32))
      {
        charnum = blockdata[charsetnum][blocknum * 16 + mousey / 8 * 4 + (mousex - 170) / 8];
      }
      if (!blockeditmode)
      {
        if (mousex >= 32 && mousey >= 128 && mousex < 320-32 && mousey < 192)
        {
          charnum = (mousey-128)/8*32+(mousex-32)/8;
        }
      }
       else
      {
        if (mousex < 192 && mousey < 192)
        {
          charnum = blockdata[charsetnum][blocknum * 16 + mousey / 40 * 4 + mousex / 40];
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportpng();
    if (k == KEY_F12) copycharset();
    if (k == KEY_LEFT) scrollcharleft();
    if (k == KEY_RIGHT) scrollcharright();
    if (k == KEY_UP) scrollcharup();
    if (k == KEY_DOWN) scrollchardown();
    if (k == KEY_L) lightenchar();
    if (k == KEY_D) darkenchar();
    if (k == KEY_U)
    {
      findusedblocksandchars();
      if (!shiftdown)
      {
        if (maxusedblocks[charsetnum] < 256)
          blocknum = maxusedblocks[charsetnum];
      }
      else
      {
        int c;
        for (c = 0; c <= 255; c++)
        {
          if (!charused[c])
          {
            charnum = c;
            break;
          }
        }
      }
    }

    changecol();
    changechar();
    editchar();
    editblock();
    gfx_fillscreen(254);
    drawgrid();
    drawblock(170,0,blocknum,charsetnum);
    if (!blockeditmode)
    {
      drawimage();
      if (flash < 16) gfx_drawsprite((charnum&31)*8+32, 128+(charnum/32)*8, 0x00000022);
      if (chinfo[charsetnum][charnum] & 1)
      {
        int x;
        int slopeindex = (chinfo[charsetnum][charnum] >> 5) << 3;
        for (x = 0; x < 8; x++)
        {
          int slopey = slopetbl[slopeindex+x]/8;
          gfx_line(48+x,slopey,48+x,7, 2);
          gfx_plot(48+x,slopey,1);
        }
      }
    }

    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void scrollcharleft(void)
{
  unsigned char c;
  int y;

  if ((chcol[charsetnum][charnum]&15) < 8) c=1;
  else c = 2;

  while (c)
  {
    Uint8 *ptr = &chardata[charsetnum][charnum*8];
    for (y = 0; y < 8; y++)
    {
      unsigned data = *ptr;
      unsigned char bit = *ptr >> 7;
      data <<= 1;
      *ptr = data | bit;
      ptr++;
    }
    c--;
  }
}

void scrollcharright(void)
{
  unsigned char c;
  int y;

  if ((chcol[charsetnum][charnum]&15) < 8) c=1;
  else c = 2;

  while (c)
  {
    Uint8 *ptr = &chardata[charsetnum][charnum*8];
    for (y = 0; y < 8; y++)
    {
      unsigned data = *ptr;
      unsigned char bit = (*ptr & 1) << 7;
      data >>= 1;
      *ptr = data | bit;
      ptr++;
    }
    c--;
  }
}

void scrollcharup(void)
{
  int y;
  Uint8 *ptr = &chardata[charsetnum][charnum*8];
  unsigned char vara1 = ptr[0];
  for (y = 0; y < 7; y++)
  {
    ptr[y]=ptr[y+1];
  }
  ptr[7]=vara1;
}

void scrollchardown(void)
{
  int y;
  Uint8 *ptr = &chardata[charsetnum][charnum*8];
  unsigned char vara1 = ptr[7];
  for (y = 6; y >= 0; y--)
  {
    ptr[y+1]=ptr[y];
  }
  ptr[0]=vara1;
}

void lightenchar(void)
{
  int x,y;
  int ints[4];
  int nextbits[4];
  Uint8 andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};

  if (chcol[charsetnum][charnum] < 8) return;

  ints[0] = intensity[zonebg1[zonenum] & 15];
  ints[1] = intensity[zonebg2[zonenum] & 15];
  ints[2] = intensity[zonebg3[zonenum] & 15];
  ints[3] = intensity[chcol[charsetnum][charnum] & 7];
  for (x = 0; x < 4; x++)
  {
    int diff = 16;
    int best = x;
    for (y = 0; y < 4; y++)
    {
      int newdiff = ints[y] - ints[x];
      if (newdiff > 0 && newdiff < diff)
      {
        best = y;
        diff = newdiff;
      }
    }
    nextbits[x]= best;
  }

  Uint8 *ptr = &chardata[charsetnum][charnum*8];
  for (y = 0; y < 8; y++)
  {
    for (x = 0; x < 4; x++)
    {
      Uint8 bits = (ptr[y] >> (x*2)) & 3;
      bits = nextbits[bits];
      ptr[y] &= andtable[x];
      ptr[y] |= bits << (x*2);
    }
  }
}

void darkenchar(void)
{
  int x,y;
  int ints[4];
  int nextbits[4];
  Uint8 andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};

  if (chcol[charsetnum][charnum] < 8) return;

  ints[0] = intensity[zonebg1[zonenum] & 15];
  ints[1] = intensity[zonebg2[zonenum] & 15];
  ints[2] = intensity[zonebg3[zonenum] & 15];
  ints[3] = intensity[chcol[charsetnum][charnum] & 7];
  for (x = 0; x < 4; x++)
  {
    int diff = 16;
    int best = x;
    for (y = 0; y < 4; y++)
    {
      int newdiff = ints[y] - ints[x];
      if (newdiff < 0 && abs(newdiff) < diff)
      {
        best = y;
        diff = abs(newdiff);
      }
    }
    nextbits[x]= best;
  }

  Uint8 *ptr = &chardata[charsetnum][charnum*8];
  for (y = 0; y < 8; y++)
  {
    for (x = 0; x < 4; x++)
    {
      Uint8 bits = (ptr[y] >> (x*2)) & 3;
      bits = nextbits[bits];
      ptr[y] &= andtable[x];
      ptr[y] |= bits << (x*2);
    }
  }
}

void drawgrid(void)
{
  Uint8 *ptr = &chardata[charsetnum][charnum*8];
  char v = 0;
  int x,y;
  int xc = 0,yc = 0;

  if (!blockeditmode)
  {
    if ((chcol[charsetnum][charnum]&15) < 8)
    {
      for (y = 0; y < 8; y++)
      {
        unsigned data = *ptr;

        for (x = 7; x >= 0; x--)
        {
          if (data & 1) v = (chcol[charsetnum][charnum]&15);
          else v = zonebg1[zonenum] & 15;

          gfx_drawsprite(x*5+xc*40,y*5+yc*40,0x00000001+v);
          data >>= 1;
        }
        ptr++;
      }
    }
    else
    {
      for (y = 0; y < 8; y++)
      {
        unsigned data = *ptr;
        for (x = 3; x >= 0; x--)
        {
          char c = data & 3;
          switch (c)
          {
            case 0:
            v = zonebg1[zonenum] & 15;
            break;

            case 1:
            v = zonebg2[zonenum] & 15;
            break;

            case 2:
            v = zonebg3[zonenum] & 15;
            break;

            case 3:
            v = (chcol[charsetnum][charnum]&15)-8;
            break;

          }
          gfx_drawsprite(x*10+xc*40,y*5+yc*40,0x00000011+v);
          data >>= 2;
        }
        ptr++;
      }
    }
  }
  else
  {
    for (yc = 0; yc < 4; yc++)
    {
      for (xc = 0; xc < 4; xc++)
      {
        int ch = blockdata[charsetnum][blocknum*16+yc*4+xc];
        ptr = &chardata[charsetnum][ch * 8];
        if ((chcol[charsetnum][ch]&15) < 8)
        {
          for (y = 0; y < 8; y++)
          {
            unsigned data = *ptr;

            for (x = 7; x >= 0; x--)
            {
              if (data & 1) v = (chcol[charsetnum][ch]&15);
              else v = zonebg1[zonenum] & 15;

              gfx_drawsprite(x*5+xc*40,y*5+yc*40,0x00000001+v);
              data >>= 1;
            }
            ptr++;
          }
        }
        else
        {
          for (y = 0; y < 8; y++)
          {
            unsigned data = *ptr;
            for (x = 3; x >= 0; x--)
            {
              char c = data & 3;
              switch (c)
              {
                case 0:
                v = zonebg1[zonenum] & 15;
                break;

                case 1:
                v = zonebg2[zonenum] & 15;
                break;

                case 2:
                v = zonebg3[zonenum] & 15;
                break;

                case 3:
                v = (chcol[charsetnum][ch]&15)-8;
                break;

              }
              gfx_drawsprite(x*10+xc*40,y*5+yc*40,0x00000011+v);
              data >>= 2;
            }
            ptr++;
          }
        }
        if ((charnum == ch) && (flash<16))
        {
          gfx_line(xc*40-1,yc*40-1, xc*40+39, yc*40-1, 1);
          gfx_line(xc*40+39,yc*40-1, xc*40+39, yc*40+39, 1);
          gfx_line(xc*40+39,yc*40+39, xc*40-1, yc*40+39, 1);
          gfx_line(xc*40-1,yc*40+39, xc*40-1, yc*40-1, 1);
        }
      }
    }
  }

  if (!blockeditmode)
  {
    for (x = 0; x < 8; x++)
    {
      if ((chinfo[charsetnum][charnum] >> (7-x)) & 1) gfx_drawsprite(x*4, 41, 0x00000023);
      else gfx_drawsprite(x*4, 41, 0x00000024);
    }
    sprintf(textbuffer, "CHAR %d", charnum);
    printtext_color(textbuffer, 0,50,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "BLOCK %d (USE %d)", blocknum, blockusecount[charsetnum][blocknum]);
    printtext_color(textbuffer, 0,65,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "ZONE %d CHSET %d", zonenum, charsetnum);
    printtext_color(textbuffer, 0,80,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "BLOCKS %d", maxusedblocks[charsetnum]);
    printtext_color(textbuffer, 0,110,SPR_FONTS,COL_WHITE);
    if ((chcol[charsetnum][charnum]&15) < 8)
      printtext_color("SINGLE",0,95,SPR_FONTS,COL_WHITE);
    else
      printtext_color("MULTI",0,95,SPR_FONTS,COL_WHITE);
    if ((chinfo[charsetnum][charnum] & 17) == 17)
      printtext_color("NOPATH",64,95,SPR_FONTS,COL_WHITE);
    if (chcol[charsetnum][charnum] & 64)
      printtext_color("FIXED",64,95,SPR_FONTS,COL_WHITE);
  }
  else
  {
    for (x = 0; x < 8; x++)
    {
      if ((chinfo[charsetnum][charnum] >> (7-x)) & 1)
        gfx_drawsprite(x*4, 161, 0x00000023);
      else 
        gfx_drawsprite(x*4, 161, 0x00000024);
    }
  }
  v = COL_WHITE;
  if (ccolor == 0) v = COL_HIGHLIGHT;
  printtext_color("BACK",170,50,SPR_FONTS,v);
  v = COL_WHITE;
  if (ccolor == 1) v = COL_HIGHLIGHT;
  printtext_color("MC 1",170,65,SPR_FONTS,v);
  v = COL_WHITE;
  if (ccolor == 2) v = COL_HIGHLIGHT;
  printtext_color("MC 2",170,80,SPR_FONTS,v);
  v = COL_WHITE;
  if (ccolor == 3) v = COL_HIGHLIGHT;
  printtext_color("CHAR",170,95,SPR_FONTS,v);
  drawcbar(220,50,zonebg1[zonenum] & 15);
  drawcbar(220,65,zonebg2[zonenum] & 15);
  drawcbar(220,80,zonebg3[zonenum] & 15);
  drawcbar(220,95,chcol[charsetnum][charnum]&7);
  gfx_line(218,48+15*ccolor,236,48+15*ccolor,1);
  gfx_line(236,48+15*ccolor,236,60+15*ccolor,1);
  gfx_line(236,60+15*ccolor,218,60+15*ccolor,1);
  gfx_line(218,60+15*ccolor,218,48+15*ccolor,1);
}

void changechar(void)
{
  if (blockeditmode) return;
  if (!mouseb) return;
  if ((mousex < 32) || (mousex >= 288)) return;
  if ((mousey < 128) || (mousey >= 192)) return;
  charnum = (mousex-32)/8+((mousey-128)/8)*32;
}

void editblock(void)
{
  Uint8 *bptr;
  if (!mouseb) return;
  if (blockeditmode) return;
  if ((mousex < 170) || (mousex >= 8*4+170)) return;
  if ((mousey < 0) || (mousey >= 8*4)) return;
  bptr = &blockdata[charsetnum][blocknum*16+(mousey/8)*4+((mousex-170)/8)];
  *bptr = charnum;
}

void editchar(void)
{
  Uint8 *ptr;
  int x,y;

  if (!mouseb) return;
  if (!blockeditmode)
  {
    if ((mousex < 0) || (mousex >= 8*5)) return;
    if ((mousey < 0) || (mousey >= 8*5)) return;
  }
  else
  {
    if ((mousex < 0) || (mousex >= 32*5)) return;
    if ((mousey < 0) || (mousey >= 32*5)) return;
    charnum = blockdata[charsetnum][blocknum*16 + mousex / 40 + (mousey / 40) * 4];
  }

  ptr = &chardata[charsetnum][charnum*8];

  y = (mousey % 40) / 5;
  if ((chcol[charsetnum][charnum]&15) < 8)
  {
    char bit;
    x = (mousex % 40) / 5;
    bit = 7 - (x & 7);

    if (mouseb & LEFT_BUTTON)
    {
      ptr[y] |= (1 << bit);
    }
    if (mouseb & RIGHT_BUTTON)
    {
      ptr[y] &= ~(1 << bit);
    }
  }
  else
  {
    char bit;
    x = (mousex % 40) / 5;
    bit = (7 - (x & 7)) & 6;

    if (mouseb & LEFT_BUTTON)
    {
      ptr[y] &= ~(3 << bit);
      ptr[y] |= (ccolor << bit);
    }
    if (mouseb & RIGHT_BUTTON)
    {
      ptr[y] &= ~(3 << bit);
    }
  }
}

void changecol(void)
{
  int y;
  int old;
  if (colordelay < COLOR_DELAY) colordelay++;
  if (!mouseb) return;
  if ((mousex < 170) || (mousex >= 235)) return;
  if ((mousey < 50) || (mousey >= 110)) return;
  y = mousey - 50;
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
          old = zonebg1[zonenum] & 128;
          zonebg1[zonenum]++;
          zonebg1[zonenum] &= 15;
          zonebg1[zonenum] |= old;
          break;
          case 1:
          old = zonebg2[zonenum] & 128;
          zonebg2[zonenum]++;
          zonebg2[zonenum] &= 15;
          zonebg2[zonenum] |= old;
          break;
          case 2:
          old = zonebg3[zonenum] & 128;
          zonebg3[zonenum]++;
          zonebg3[zonenum] &= 15;
          zonebg3[zonenum] |= old;
          break;
          case 3:
          {
            unsigned char highbits = chcol[charsetnum][charnum] & 0xc0;
            chcol[charsetnum][charnum]++;
            chcol[charsetnum][charnum] &= 15;
            chcol[charsetnum][charnum] |= highbits;
          }
          break;
        }
        colordelay = 0;
      }
      if (mouseb & RIGHT_BUTTON)
      {
        switch(y/15)
        {
          case 0:
          old = zonebg1[zonenum] & 128;
          zonebg1[zonenum]--;
          zonebg1[zonenum] &= 15;
          zonebg1[zonenum] |= old;
          break;
          case 1:
          old = zonebg2[zonenum] & 128;
          zonebg2[zonenum]--;
          zonebg2[zonenum] &= 15;
          zonebg2[zonenum] |= old;
          break;
          case 2:
          old = zonebg3[zonenum] & 128;
          zonebg3[zonenum]--;
          zonebg3[zonenum] &= 15;
          zonebg3[zonenum] |= old;
          break;
          case 3:
          {
            unsigned char highbits = chcol[charsetnum][charnum] & 0xc0;
            chcol[charsetnum][charnum]--;
            chcol[charsetnum][charnum] &= 15;
            chcol[charsetnum][charnum] |= highbits;
          }
          break;
        }
        colordelay = 0;
      }
    }
  }
}

unsigned getcharsprite(unsigned char ch)
{
  unsigned num = ch-31;
  if (num >= 64) num -= 32;
  if (num > 59) num = 32;
  return num;
}

void printtext_color(unsigned char *string, int x, int y, unsigned spritefile, int color)
{
  unsigned char *xlat = colxlattable[color];

  spritefile <<= 16;
  while (*string)
  {
    unsigned num = getcharsprite(*string);
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
    unsigned num = getcharsprite(*stuff);
    gfx_getspriteinfo(spritefile + num);
    x += spr_xsize;
    stuff++;
  }
  x = 160 - x / 2;

  while (*string)
  {
    unsigned num = getcharsprite(*string);
    gfx_drawspritex(x, y, spritefile + num, xlat);
    x += spr_xsize;
    string++;
  }
}

void mouseupdate(void)
{
  mou_getpos(&mousex, &mousey);
  prevmouseb = mouseb;
  mouseb = mou_getbuttons();
}

int initchars(void)
{
  int c;
  int handle;
  memset(mapdata,0,mapsx*mapsy);
  for (c = 0; c < NUMCHARSETS; ++c)
  {
    memset(&chardata[c][0],0, 2048);
    memset(&chinfo[c][0],0,256);
    memset(&chcol[c][0],9,256);
    memset(&blockdata[c][0],0,4096);
  }

  for (c = 0; c < NUMZONES; c++)
  {
    zonex[c] = 0;
    zoney[c] = 0;
    zonesx[c] = 0;
    zonesy[c] = 0;
    zonebg1[c] = 0;
    zonebg2[c] = 11;
    zonebg3[c] = 12;
    zonelevel[c] = 0;
    zonecharset[c] = 0;
    zonespawnparam[c] = 0;
    zonespawnspeed[c] = 0;
    zonespawncount[c] = 0;
    zonemusic[c] = 0;
  }
  for (c = 0; c < NUMLVLOBJ; c++)
  {
    lvlobjx[c] = 0;
    lvlobjy[c] = 0;
    lvlobjb[c] = 0;
    lvlobjdl[c] = 0;
    lvlobjdh[c] = 0;
  }
  for (c = 0; c < NUMLVLACT; c++)
  {
    lvlactx[c] = 0;
    lvlacty[c] = 0;
    lvlactf[c] = 0;
    lvlactt[c] = 0;
    lvlactw[c] = 0;
  }
  findusedblocksandchars();
  return 1;
}

void endblockeditmode()
{
  if (blockeditmode)
  {
    optimizechars();
    blockeditmode = 0;
    charnum = oldchar;
    if (frommap)
      editmode = EM_MAP;
  }
}

void initblockeditmode(int fm)
{
    optimizechars();

    int c,d;
    int e = 255;
    int nocopy = win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT];

    findusedblocksandchars();

    for (c = 240; c < 256; c++)
    {
      if (charused[c])
      {
        nocopy = 1;
        break;
      }
    }

    // Unless explicitly disabled, ensure all chars are unique. However, do not copy fixed chars
    // as optimizing them back is problematic
    if (!nocopy)
    {
      for (c = 0; c < 16; c++)
      {
        int ch = blockdata[charsetnum][16*blocknum+c];
        if (!(chcol[charsetnum][ch] & 64))
        {
          copychar(ch, e);
          blockdata[charsetnum][16*blocknum+c] = e;
          e--;
        }
      }
    }

    blockeditmode = 1;
    blockeditnum = blocknum;
    oldchar = charnum;
    charnum = blockdata[charsetnum][16*blocknum+c];
    findusedblocksandchars();
    editmode = EM_CHARS;
    frommap = fm;
}

void findanimatingblocks(void)
{
  int c,d;
  for (d = 0; d < NUMCHARSETS; d++)
  {
    for (c = 0; c < 256; c++)
      animatingblock[d][c] = 0;
  }

  for (c = 0; c < NUMLVLOBJ; c++)
  {
    if ((lvlobjy[c] & 0x80) && (lvlobjx[c] || lvlobjy[c]))
    {
      int newzonenum = findzone(lvlobjx[c], lvlobjy[c]&0x7f);
      if (newzonenum < NUMZONES)
      {
        int newcharsetnum = zonecharset[newzonenum];
        animatingblock[newcharsetnum][mapdata[lvlobjx[c] + mapsx * (lvlobjy[c] & 0x7f)]] = 1;
        if ((lvlobjb[c] & 64) && ((lvlobjy[c] & 0x7f) > 0))
        {
          animatingblock[newcharsetnum][mapdata[lvlobjx[c] + mapsx * ((lvlobjy[c] & 0x7f)-1)]] = 1;
        }
      }
    }
  }
}

int checkzonelegal(int num, int newx, int newy, int newsx, int newsy)
{
  // Check for no overlap
  int c;
  for (c = 0; c < NUMZONES; c++)
  {
    if (c != num && zonesx[c] && zonesy[c])
    {
      int xoverlap = 0, yoverlap = 0;
      if (newx < zonex[c] && newx+newsx > zonex[c])
        xoverlap = 1;
      if (newx >= zonex[c] && newx < zonex[c]+zonesx[c])
        xoverlap = 1;
      if (newy < zoney[c] && newy+newsy > zoney[c])
        yoverlap = 1;
      if (newy >= zoney[c] && newy < zoney[c]+zonesy[c])
        yoverlap = 1;
      if (xoverlap && yoverlap) return 0;
    }
  }
  return 1;
}

void switchzoomout(int newvalue)
{
  if (zoomoutmode == newvalue)
    return;
  int olddivisor = zoomoutmode ? 8 : 32;
  int oldcenterx = mapx + 160/olddivisor;
  int oldcentery = mapy + 96/olddivisor;
  zoomoutmode = newvalue;
  gotopos(oldcenterx, oldcentery);
}

void calculatelevelorigins(void)
{
  int c;

  for (c = 0; c < NUMLEVELS; ++c)
  {
    levelx[c] = 0;
    levely[c] = 0;
    levelsx[c] = 0;
    levelsy[c] = 0;
  }
  for (c = 0; c < NUMZONES; ++c)
  {
    if (zonesx[c] && zonesy[c])
    {
      int l = zonelevel[c];
      if (!levelsx[l] && !levelsy[l])
      {
        levelx[l] = zonex[c];
        levely[l] = zoney[c];
        levelsx[l] = zonesx[c];
        levelsy[l] = zonesy[c];
      }
      else
      {
        if (zonex[c] < levelx[l])
        {
          levelsx[l] += levelx[l]-zonex[c];
          levelx[l] = zonex[c];
        }
        if (zoney[c] < levely[l])
        {
          levelsy[l] += levely[l]-zoney[c];
          levely[l] = zoney[c];
        }
      }
      if (zonex[c]+zonesx[c] > levelx[l]+levelsx[l])
        levelsx[l] = zonex[c]+zonesx[c]-levelx[l];
      if (zoney[c]+zonesy[c] > levely[l]+levelsy[l])
        levelsy[l] = zoney[c]+zonesy[c]-levely[l];
    }
  }
}

void findusedblocksandchars(void)
{
  int s,c;
  int currentzone = 0;
  findanimatingblocks();

  for (s = 0; s < NUMCHARSETS; s++)
  {
    for (c = 255; c > 0; c--)
    {
      int d;
      for (d = 0; d < 16; d++)
      {
        if (blockdata[s][c*16+d]) goto FOUND;
      }
    }
    FOUND:
    maxusedblocks[s] = c+1;
    for (c = 0; c < 256; c++)
      blockusecount[s][c] = 0;
    blockusecount[s][0] = 255; // Consider first block (emptiness) always used

    if (s == charsetnum)
    {
      for (c = 0; c < 256; c++) charused[c] = 0;
      for (c = 0; c < maxusedblocks[s]*16; c++)
      {
        charused[blockdata[s][c]] = 1;
      }
    }
  }

  for (c = 0; c < mapsx*mapsy; c++)
  {
    int blk = mapdata[c];
    if (blk)
    {
      int x = c % mapsx;
      int y = c / mapsx;
      currentzone = findzonefast(x, y, currentzone);
      if (currentzone < NUMZONES)
      {
        s = zonecharset[currentzone];
        blockusecount[s][blk]++;
        if (animatingblock[s][blk])
          blockusecount[s][blk+1]++;
      }
    }
  }
}

void transferchar(int c, int d)
{
  int e;
  if (c == d) return;
  for (e = 0; e < 8; e++)
  {
    chardata[charsetnum][d*8+e] = chardata[charsetnum][c*8+e];
    chardata[charsetnum][c*8+e] = 0;
  }
  for (e = 0; e < BLOCKS*16; e++)
  {
    if (blockdata[charsetnum][e] == c) blockdata[charsetnum][e] = d;
  }
  chinfo[charsetnum][d] = chinfo[charsetnum][c];
  chinfo[charsetnum][c] = 0;
  chcol[charsetnum][d] = chcol[charsetnum][c];
  chcol[charsetnum][c] = 9;
}

void transferblock(int c, int d)
{
  // Note: needs up-to-date blockusecount

  int e;
  if (c == d) return;
  for (e = 0; e < 16; e++)
  {
    blockdata[charsetnum][d*16+e] = blockdata[charsetnum][c*16+e];
    blockdata[charsetnum][c*16+e] = 0;
  }
  int currentzone = 0;
  if (blockusecount[charsetnum][c])
  {
    for (e = 0; e < mapsx * mapsy; e++)
    {
      if (mapdata[e] == c)
      {
        int x = e % mapsx;
        int y = e / mapsx;
        currentzone = findzonefast(x, y, currentzone);
        if (currentzone < NUMZONES && zonecharset[currentzone] == charsetnum)
        {
          mapdata[e] = d;
          blockusecount[charsetnum][c]++;
        }
      }
    }
    blockusecount[charsetnum][c] = 0;
  }
}

void copyblock(int c, int d)
{
  int e;
  if (c == d) return;
  for (e = 0; e < 16; e++)
  {
    blockdata[charsetnum][d*16+e] = blockdata[charsetnum][c*16+e];
  }
}

void swapblocks(int c, int d)
{
  int e;
  unsigned char temp[16];

  if (c == d) return;

  memcpy(temp, &blockdata[charsetnum][c*16], 16);
  memcpy(&blockdata[charsetnum][c*16], &blockdata[charsetnum][d*16], 16);
  memcpy(&blockdata[charsetnum][d*16], temp, 16);

  int newzonenum = 0;
  for (e = 0; e < mapsx * mapsy; e++)
  {
    if (mapdata[e])
    {
      int x = e % mapsx;
      int y = e / mapsx;
      int newzonenum = findzonefast(x,y, newzonenum);
      if (newzonenum < NUMZONES && zonecharset[newzonenum] == charsetnum)
      {
        if (mapdata[e] == c)
          mapdata[e] = d;
        else if (mapdata[e] == d)
          mapdata[e] = c;
       }
    }
  }

  findusedblocksandchars();
}

void insertblock(int c, int d)
{
  int e;
  unsigned char temp[16];

  if (c == d) return;

  memcpy(temp, &blockdata[charsetnum][c*16], 16);
  memset(&blockdata[charsetnum][c*16], 0, 16);
  memmove(&blockdata[charsetnum][d*16+16], &blockdata[charsetnum][d*16], (255-d)*16);
  memcpy(&blockdata[charsetnum][d*16], temp, 16);

  int newzonenum = 0;

  for (e = 0; e < mapsx * mapsy; e++)
  {
    if (mapdata[e])
    {
      int x = e % mapsx;
      int y = e / mapsx;
      int newzonenum = findzonefast(x,y, newzonenum);
      if (newzonenum < NUMZONES && zonecharset[newzonenum] == charsetnum)
      {
        if (mapdata[e] == c)
          mapdata[e] = d;
        else if (mapdata[e] >= d)
          mapdata[e]++;
      }
    }
  }

  findusedblocksandchars();
}

void copychar(int c, int d)
{
  int e;
  for (e = 0; e < 8; e++)
  {
    chardata[charsetnum][d*8+e] = chardata[charsetnum][c*8+e];
  }
  chinfo[charsetnum][d] = chinfo[charsetnum][c];
  chcol[charsetnum][d] = chcol[charsetnum][c];
}


int findsamechar(int c, int d)
{
  int e;
  int charcolorused = 0;
  if (c == d) return 0;

  for (e = 0; e < 8; e++)
  {
    int v = chardata[charsetnum][c*8+e];
    if (v != chardata[charsetnum][d*8+e]) return 0;
    if ((v & 0xc0) == 0xc0) charcolorused = 1;
    if ((v & 0x30) == 0x30) charcolorused = 1;
    if ((v & 0x0c) == 0x0c) charcolorused = 1;
    if ((v & 0x03) == 0x03) charcolorused = 1;
  }

  if (chinfo[charsetnum][c] != chinfo[charsetnum][d]) return 0;
  if (chcol[charsetnum][c] & 64) return 0; // No-optimize flag, is not duplicate
  if (chcol[charsetnum][d] & 64) return 0; // No-optimize flag, is not duplicate
  if (chcol[charsetnum][c] < 8 && chcol[charsetnum][c] != chcol[charsetnum][d]) return 0;
  if (chcol[charsetnum][c] >= 8 && charcolorused && chcol[charsetnum][c] != chcol[charsetnum][d]) return 0;

  return 1;
}

int findsameblock(int c, int d)
{
  int e;
  if (c == d) return 0;
  for (e = 0; e < 16; e++)
  {
    if (blockdata[charsetnum][c*16+e] != blockdata[charsetnum][d*16+e]) return 0;
  }

  // If block is used in animating levelobject, do not consider same
  if (animatingblock[charsetnum][c] || animatingblock[charsetnum][d] || (c > 0 && animatingblock[charsetnum][c-1]) || (d > 0 && animatingblock[charsetnum][d-1]))
    return 0;

  return 1;
}

void relocatezone(int x, int y)
{
  int sx, sy, oldx, oldy, ox, oy, c, bx, by;
  if (!zonesx[zonenum] || !zonesy[zonenum])
    return;
  sx = zonesx[zonenum];
  sy = zonesy[zonenum];
  if (x + sx > mapsx) return;
  if (y + sy > mapsy) return;
  if (!checkzonelegal(zonenum, x, y, sx, sy)) return;
  unsigned char* tempmapdata = malloc(sx*sy);
  oldx = zonex[zonenum];
  oldy = zoney[zonenum];
  ox = x - oldx;
  oy = y - oldy;
  // Relocate objects & actors within zone
  for (c = 0; c < NUMLVLOBJ; c++)
  {
    if ((lvlobjx[c]) || (lvlobjy[c]))
    {
      if (lvlobjx[c] >= zonex[zonenum] && lvlobjx[c] < (zonex[zonenum]+zonesx[zonenum]) && (lvlobjy[c] & 0x7f) >= zoney[zonenum] && (lvlobjy[c] & 0x7f) < (zoney[zonenum]+zonesy[zonenum]))
      {
        lvlobjx[c] += ox;
        lvlobjy[c] += oy;
      }
    }
  }
  for (c = 0; c < NUMLVLACT; c++)
  {
    if (lvlactt[c])
    {
      if (lvlactx[c] >= zonex[zonenum] && lvlactx[c] < (zonex[zonenum]+zonesx[zonenum]) && (lvlacty[c] & 0x7f) >= zoney[zonenum] && (lvlacty[c] & 0x7f) < (zoney[zonenum]+zonesy[zonenum]))
      {
        lvlactx[c] += ox;
        lvlacty[c] += oy;
      }
    }
  }
  c = 0;
  for (by = 0; by < sy; by++)
  {
    for (bx = 0; bx < sx; bx++)
    {
      tempmapdata[c++] = mapdata[(by+zoney[zonenum])*mapsx + bx+zonex[zonenum]];
      mapdata[(by+zoney[zonenum])*mapsx + bx+zonex[zonenum]] = 0;
    }
  }
  c = 0;
  for (by = 0; by < sy; by++)
  {
    for (bx = 0; bx < sx; bx++)
    {
      mapdata[(by+y)*mapsx + bx+x] = tempmapdata[c++];
    }
  }
  zonex[zonenum] = x;
  zoney[zonenum] = y;

  free(tempmapdata);
  calculatelevelorigins();
}

void reorganizedata()
{
  unsigned char newchardata[2048];
  unsigned char newblockdata[4096];
  unsigned char* newmapdata = malloc(mapsx * mapsy);
  unsigned char newchcol[256];
  unsigned char newchinfo[256];
  unsigned char newcharused[256];
  unsigned char newblockused[256];
  int blockmapping[256];
  int charmapping[256];
  int c,d,e,z,x,y,s,newblk;

  optimizechars();
  optimizeblocks();
  findusedblocksandchars();

  memset(newcharused, 0, sizeof newcharused);
  memset(newblockused, 0, sizeof newblockused);
  memset(newchardata, 0, sizeof newchardata);
  memset(newblockdata, 0, sizeof newblockdata);
  memset(newmapdata, 0, mapsx*mapsy);

  for (c = 0; c < 256; c++)
  {
    blockmapping[c] = -1;
    charmapping[c] = -1;
    newchcol[c] = 9;
    newchinfo[c] = 0;
  }
  // Copy fixed chars first
  for (c = 0; c < 256; c++)
  {
    if (chcol[charsetnum][c] & 64)
    {
      memcpy(&newchardata[c*8], &chardata[charsetnum][c*8], 8);
      newchcol[c] = chcol[charsetnum][c];
      newchinfo[c] = chinfo[charsetnum][c];
      newcharused[c] = 1;
      charmapping[c] = c;
    }
  }

  // Process blocks & chars
  newblk = 0;
  for (c = 0; c < 256; c++)
  {
    if (!c || blockusecount[charsetnum][c] > 0)
    {
      newblockused[newblk] = 1;
      blockmapping[c] = newblk;
      for (d = 0; d < 16; d++)
      {
        unsigned char ch = blockdata[charsetnum][c*16+d];
        if (charmapping[ch] >= 0)
          newblockdata[newblk*16+d] = charmapping[ch];
        else
        {
          unsigned char newch = 0;
          while (newcharused[newch])
            newch++;

          for (e = 0; e < 8; e++)
            newchardata[newch*8+e] = chardata[charsetnum][ch*8+e];

          newcharused[newch] = 1;
          newchcol[newch] = chcol[charsetnum][ch];
          newchinfo[newch] = chinfo[charsetnum][ch];
          charmapping[ch] = newch;
          newblockdata[newblk*16+d] = newch;
        }
      }
      newblk++;
    }
  }
  
  // Rewrite mapdata
  for (z = 0; z < NUMZONES; z++)
  {
    if (!zonesx[z] || !zonesy[z])
      continue;
    for (y = zoney[z]; y < zoney[z]+zonesy[z]; y++)
    {
      for (x = zonex[z]; x < zonex[z]+zonesx[z]; x++)
      {
        if (zonecharset[z] == charsetnum)
          newmapdata[y*mapsx+x] = blockmapping[mapdata[y*mapsx+x]];
        else
          newmapdata[y*mapsx+x] = mapdata[y*mapsx+x];
      }
    }
  }

  memcpy(chardata[charsetnum], newchardata, 2048);
  memcpy(blockdata[charsetnum], newblockdata, 4096);
  memcpy(chcol[charsetnum], newchcol, 256);
  memcpy(chinfo[charsetnum], newchinfo, 256);
  memcpy(mapdata, newmapdata, mapsx*mapsy);

  findusedblocksandchars();

  // Tidying up step: if char does not use char color, reset color to that used by first char
  if ((chcol[charsetnum][0] & 0xf) >= 8)
  {
    for (c = 1; c < 256; c++)
    {
      int e;
      int charcolorused = 0;
      if ((chcol[charsetnum][c] & 0xf) < 8)
        continue;

      for (e = 0; e < 8; e++)
      {
        int v = chardata[charsetnum][c*8+e];
        if ((v & 0xc0) == 0xc0) charcolorused = 1;
        if ((v & 0x30) == 0x30) charcolorused = 1;
        if ((v & 0x0c) == 0x0c) charcolorused = 1;
        if ((v & 0x03) == 0x03) charcolorused = 1;
        if (charcolorused)
          break;
      }

      if (!charcolorused)
        chcol[charsetnum][c] = chcol[charsetnum][0] | (chcol[charsetnum][c] & 0x40);
    }
  }
}

void optimizeblocks(void)
{
  int c,d;
  unsigned char blockused[256];

  findusedblocksandchars();

  for (c = 0; c < 256; c++) blockused[c] = 1;

  for (d = 1; d < 256; d++)
  {
    for (c = 0; c < d; c++)
    {
      if (findsameblock(d,c))
      {
        transferblock(d,c);
        blockused[d] = 0;
        blockused[c] = 1;
        break;
      }
    }
  }

  for (d = 1; d < 256; d++)
  {
    int v = 0;
    for (c = 0; c < 16; c++) v += blockdata[charsetnum][d*16+c];
    if (v)
    {
      for (c = 0; c < d; c++)
      {
        if (!blockused[c])
        {
          transferblock(d,c);
          blockused[d] = 0;
          blockused[c] = 1;
          break;
        }
      }
    }
  }

  findusedblocksandchars();
}

void optimizechars(void)
{
  int c,d;
  for (c = 0; c < 256; c++) charused[c] = 1;

  for (d = 1; d < 256; d++)
  {
    for (c = 0; c < d; c++)
    {
      if (findsamechar(d,c))
      {
        transferchar(d,c);
        charused[d] = 0;
        charused[c] = 1;
        break;
      }
    }
  }
  for (d = 1; d < 256; d++)
  {
    int v = 0;
    if (chcol[charsetnum][d] & 64)
      continue;
    for (c = 0; c < 8; c++) v += chardata[charsetnum][d*8+c];
    if (v)
    {
      for (c = 0; c < d; c++)
      {
        if (!charused[c])
        {
          transferchar(d,c);
          charused[d] = 0;
          charused[c] = 1;
          break;
        }
      }
    }
  }
  findusedblocksandchars();
}

void updateblockinfo(void)
{
  int c, d;
  for (c = 0; c < BLOCKS; c++)
  {
    char bi = 0;
    if ((chinfo[charsetnum][blockdata[charsetnum][c*16+12]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16+9]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16+6]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16+3]] & 1))
    {
      bi = 8; // Stairs to up-right
      if (chinfo[charsetnum][blockdata[charsetnum][c*16]] & 1)
        bi |= 1; // Junction down
    }
    else if ((chinfo[charsetnum][blockdata[charsetnum][c*16+15]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16+10]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16+5]] & 1) && (chinfo[charsetnum][blockdata[charsetnum][c*16]] & 1))
    {
      bi = 10; // Stairs to up-left
      if (chinfo[charsetnum][blockdata[charsetnum][c*16+3]] & 1)
        bi |= 1; // Junction down
    }
    else
    {
      int gc = 0;

      if (chinfo[charsetnum][blockdata[charsetnum][c*16+5]] & 2)
        bi |= 2; // Obstacle
      if (chinfo[charsetnum][blockdata[charsetnum][c*16+1]] & 4)
        bi |= 4; // Ladder
      for (d = 0; d < 16; d++)
      {
        // Shelf bit can be used to mark objects nonnavigable
        if ((chinfo[charsetnum][blockdata[charsetnum][c*16+d]] & 17) == 1)
          gc++;
      }
      if (gc >= 4)
        bi |= 1; // Ground
    }
    if ((c & 1) == 0)
    {
      blockinfo[c/2] &= 0xf0;
      blockinfo[c/2] |= bi;
    }
    else
    {
      blockinfo[c/2] &= 0x0f;
      blockinfo[c/2] |= (bi << 4);
    }
  }
}

unsigned char getblockinfo(int x, int y)
{
  unsigned char blknum;
  unsigned char bi;
  if (x < 0 || x >= mapsx ||y < 0 || y >= mapsy)
    return 2; // Obstacle
  blknum = mapdata[y * mapsx + x];
  if (blknum & 1)
    bi = blockinfo[blknum/2] >> 4;
  else
    bi = blockinfo[blknum/2] & 0xf;
  return bi;
}

void markpath(int x, int y)
{
  if (pathmode > 1)
    pathmode = 0;

  if (pathmode == 0)
  {
    printf("Mark path start: %d,%d\n", x, y);
    pathsx = x;
    pathsy = y;
    pathmode++;
  }
  else if (pathmode == 1)
  {
    printf("Mark path end: %d,%d\n", x, y);
    pathex = x;
    pathey = y;
    pathmode++;
    calculatepath();
  }
}

void calculatepath()
{
  unsigned char tempx[4][256];
  unsigned char tempy[4][256];
  unsigned char length[4];
  unsigned char csx,csy, tx, ty, bi, bia;
  int success[4];
  int dirsused[4];
  int lastdirsused = 0;
  int iterations = 0;
  int c;
  pathlength = 0;
  csx = pathsx;
  csy = pathsy;

  updateblockinfo();

  printf("Calculate path from %d,%d to %d,%d\n", pathsx, pathsy, pathex, pathey);

  // Check that start is valid
  bi = getblockinfo(csx, csy);
  if (bi == 2 || (bi < 8 && ((bi & 1) == 0)))
    return;

  printf("Path start is valid\n");

  for (;;)
  {
    int bestdist = 0x7fffffff;
    int bestdir = -1;

    printf("Testing subpaths at %d,%d, lastdirs is %d\n", csx, csy, lastdirsused);

    for (c = 0; c < 4; c++)
    {
      int first = 1;
      int foundjunction = 0;
      int godownstairs = 0;
      int d = 0;
      tx = csx;
      ty = csy;
      success[c] = -1;
      dirsused[c] = 0;

      for (;;)
      {
        tempx[c][d] = tx;
        tempy[c][d] = ty;
        d++;
        length[c] = d;

        // Check for reaching path endpoint (destination)
        if (tx == pathex && ty == pathey)
        {
          success[c] = 1;
          goto NEXT;
        }
        switch (c)
        {
          case 0: // Up
          {
            // Eliminate going back
            if (lastdirsused & 2)
            {
              success[c] = 0;
              goto NEXT;
            }

            bi = getblockinfo(tx, ty);
            if (bi & 4) // Ladder
            {
              dirsused[c] = 1;
              if (!first && (bi & 1)) // Ladder & ground
              {
                //printf("Up: found junction at %d,%d\n", tx, ty);
                success[c] = 1; // Reached next junction
              }
              ty--;
              if (ty < 0)
              {
                //printf("Up: went outside map at %d,%d\n", tx, ty);
                success[c] = 0;
              }
              goto NEXT;
            }
            else if (bi == 8 || bi == 10) // Stairs up-right
            {
              dirsused[c] = 8;
              tx++;
              if ((getblockinfo(tx, ty) & 1) == 0)
                ty--;
              goto NEXT;
            }
            else if (bi == 9 || bi == 11) // Stairs up-left
            {
              dirsused[c] = 4;
              tx--;
              if ((getblockinfo(tx, ty) & 1) == 0)
                ty--;
              goto NEXT;
            }
            if ((bi & 1) && !first) // Ground
            {
              //printf("Up: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            else
            {
              if (first)
              {
                ty--;
                bi = getblockinfo(tx, ty);
                if ((bi & 4) || bi >= 8)
                  goto NEXT;
              }

              //printf("Up: no route at %d,%d\n", tx, ty);
              success[c] = 0;
              goto NEXT; // Not a valid up-route
            }
          }
          break;

          case 1: // Down
          {
            // Eliminate going back
            if (lastdirsused & 1)
            {
              success[c] = 0;
              goto NEXT;
            }

            bi = getblockinfo(tx, ty);
            if (first && bi >= 8 && (bi & 1))
                godownstairs = 1; // Down at a stairs junction
                
            if (bi & 4) // Ladder
            {
              dirsused[c] = 2;
              if ((bi & 1) && !first) // Ladder & ground
              {
                //printf("Down: found junction at %d,%d\n", tx, ty);
                success[c] = 1; // Reached next junction
              }
              ty++;
              if (ty >= mapsy)
              {
                //printf("Down: went outside map at %d,%d\n", tx, ty);
                success[c] = 0;
              }
              goto NEXT;
            }
            else if (godownstairs && ((bi & 14) == 8)) // Stairs down-left
            {
              dirsused[c] = 2;
              ty++;
              tx--;
              goto NEXT;
            }
            else if (godownstairs && ((bi & 14) == 10)) // Stairs down-right
            {
               dirsused[c] = 2;
               ty++;
               tx++;
               goto NEXT;
            }
            if ((bi & 1) && !first) // Ground
            {
              //printf("Down: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            else
            {
              //printf("Down: no route at %d,%d\n", tx, ty);
              success[c] = 0;
              goto NEXT; // Not a valid up-route
            }
          }
          break;

          case 2: // Left
          {
            // Eliminate going back
            if (lastdirsused & 8)
            {
              success[c] = 0;
              goto NEXT;
            }

            if (foundjunction) // Found junction on last step?
            {
              //printf("Left: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            dirsused[c] = 4;
            bia = getblockinfo(tx, ty-1);
            bi = getblockinfo(tx, ty);
            if ((bi & 1) == 0 && bi < 8 && bia < 8)
            {
              //printf("Left: wall or gap at %d,%d\n", tx, ty);
              success[c] = 0;
              goto NEXT; // Reached a wall or gap
            }
            if ((bi & 1) == 0 && bi < 8 && bia >= 8)
            {
              ty--;
              tempy[c][length[c]-1] = ty;
              bia = getblockinfo(tx, ty-1);
              bi = getblockinfo(tx, ty);
            }
            if (!first && ((bia & 4) || bia >= 8))
            {
              //printf("Left: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            if (!first && ((bi & 4) || (bi >= 8 && (bi && 1))))
            {
              //printf("Left: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            if (bi == 8)
            {
              dirsused[c] = 2;
              ty++;
              // Check if arrived at a junction by going down
              if (getblockinfo(tx, ty) & 1)
                foundjunction = 1;
            }
            if (bi == 10 || bi == 11)
            {
              unsigned char bia2 = getblockinfo(tx-1,ty-1);
              if ((bia2 & 1) || bia2 >= 8)
              {
                dirsused[c] = 1;
                ty--;
              }
            }
            tx--;
            if (tx < 0)
            {
              //printf("Left: outside map at %d,%d\n", tx, ty);
              success[c] = 0; // Went outside map
              goto NEXT;
            }
          }
          break;

          case 3: // Right
          {
            // Eliminate going back
            if (lastdirsused & 4)
            {
              success[c] = 0;
              goto NEXT;
            }

            if (foundjunction) // Found junction on last step?
            {
              //printf("Right: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }

            dirsused[c] = 8;
            bia = getblockinfo(tx, ty-1);
            bi = getblockinfo(tx, ty);
            if ((bi & 1) == 0 && bi < 8 && bia < 8)
            {
              //printf("Right: wall or gap at %d,%d\n", tx, ty);
              success[c] = 0;
              goto NEXT; // Reached a wall or gap
            }
            if ((bi & 1) == 0 && bi < 8 && bia >= 8)
            {
              ty--;
              tempy[c][length[c]-1] = ty;
              bia = getblockinfo(tx, ty-1);
              bi = getblockinfo(tx, ty);
            }
            if (!first && ((bia & 4) || bia >= 8))
            {
              //printf("Right: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            if (!first && ((bi & 4) || (bi >= 8 && (bi && 1))))
            {
              //printf("Right: found junction at %d,%d\n", tx, ty);
              success[c] = 1; // Reached next junction
              goto NEXT;
            }
            if (bi == 8 || bi == 9)
            {
              unsigned char bia2 = getblockinfo(tx+1,ty-1);
              if ((bia2 & 1) || bia2 >= 8)
              {
                dirsused[c] = 1;
                ty--;
              }
            }
            if (bi == 10)
            {
              dirsused[c] = 2;
              ty++;
              // Check if arrived at a junction by going down
              if (getblockinfo(tx, ty) & 1)
                foundjunction = 1;
            }
            tx++;
            if (tx < 0)
            {
              //printf("Right: outside map at %d,%d\n", tx, ty);
              success[c] = 0; // Went outside map
              goto NEXT;
            }
          }
          break;
        }

        NEXT:
        first = 0;
        if (success[c] != -1)
        {
          if (success[c] == 1)
            printf("Subpath %d from %d,%d to %d,%d success\n", c, csx, csy, tempx[c][length[c]-1], tempy[c][length[c]-1]);
          break;
        }
        if (d >= 256)
        {
          printf("Subpath %d storage exceeded\n", c);
          break;
        }
      }
    }

    // Check which successful direction goes closest to target
    for (c = 0; c < 4; c++)
    {
      int dx,dy,dist;
      unsigned char ex,ey;
      ex = tempx[c][length[c]-1];
      ey = tempy[c][length[c]-1];
      if (success[c] == 1)
      {
        dx = ex-pathex;
        dy = ey-pathey;
        if (dx < 0) dx = -dx;
        if (dy < 0) dy = -dy;
        dist = dx+dy;
        // Give a penalty if a target is further up or down, but the endpoint doesn't give possibility to go there
        bi = getblockinfo(ex,ey);
        bia = getblockinfo(ex,ey-1);
        if (pathey > ey && bi < 4)
          dist *= 2;
        if (pathey < ey && bia < 4)
          dist *= 2;
        if (dist < bestdist)
        {
          bestdir = c;
          bestdist = dist;
        }
      }
    }

    // Copy the best sub-path to final path
    if (bestdir >= 0)
    {
      printf("Best subpath from %d,%d: %d\n", csx, csy, bestdir);
      for (c = 0; c < length[bestdir]; c++)
      {
        pathx[pathlength] = tempx[bestdir][c];
        pathy[pathlength] = tempy[bestdir][c];
        csx = tempx[bestdir][c];
        csy = tempy[bestdir][c];
        pathlength++;
        if (pathlength >= MAXPATH)
          return;
      }
      lastdirsused = dirsused[bestdir];
    }
    else
    {
      printf("Found no successful dir, pathfinding terminated\n");
      return; // No next step found
    }

    iterations++;
    if (iterations >= 256)
      return;
  }
}

void drawpath()
{
  int c;

  if (pathmode == 1)
    gfx_line((pathsx-mapx)*32+16,(pathsy-mapy)*32+16, (pathsx-mapx)*32+16,(pathsy-mapy)*32+16, 1);

  if (pathmode < 2 || pathlength < 2)
    return;

  for (c = 0; c < pathlength - 1; c++)
  {
    gfx_line((pathx[c]-mapx)*32+16,(pathy[c]-mapy)*32+16, (pathx[c+1]-mapx)*32+16,(pathy[c+1]-mapy)*32+16, 1);
  }
}


void initstuff(void)
{
  if (!initchars())
  {
    win_messagebox("Out of memory!");
    exit(1);
  }

  if (!kbd_init())
  {
    win_messagebox("Keyboard init error!");
    exit(1);
  }

  if (!gfx_init(320,224,70,GFX_DOUBLESIZE))
  {
    win_messagebox("Graphics init error!");
    exit(1);
  }
  win_setmousemode(MOUSE_ALWAYS_HIDDEN);

  if ((!gfx_loadsprites(SPR_C, "editor.spr")) ||
      (!gfx_loadsprites(SPR_FONTS, "editfont.spr")))
  {
    win_messagebox("Error loading sprites!");
    exit(1);
  }
  if (!gfx_loadpalette("editor.pal"))
  {
    win_messagebox("Error loading palette!");
    exit(1);
  }
}

int inputtext(char *buffer, int maxlength)
{
  int len = strlen(buffer);
  int k;

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

void loadalldata(void)
{
  if (win_keystate[KEY_LEFTSHIFT] | win_keystate[KEY_RIGHTSHIFT])
  {
    importlevelmap();
    return;
  }

  char ib1[80];
  strcpy(ib1, levelname);

  for (;;)
  {
    int r;

    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD ALL LEVELDATA:",90,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,100,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();

    r = inputtext(ib1, 80);
    if (r == -1) return;
    if (r == 1)
    {
      int handle;
      int c;
      int length;
      int s;
      char ib2[80];

      if (!strlen(ib1))
        return;
      strcpy(levelname, ib1);

      for (s = 0; s < NUMCHARSETS; s++)
      {
        sprintf(ib2, "%s%02d.chi", ib1, s);
        handle = open(ib2, O_RDONLY | O_BINARY);
        if (handle != -1)
        {
          read(handle, chinfo[s], 256);
          close(handle);
        }
        memset(blockdata[s],0,4096);
        memset(chcol[s],9,256);

        sprintf(ib2, "%s%02d.blk", ib1, s);
        handle = open(ib2, O_RDONLY | O_BINARY);
        if (handle != -1)
        {
          lseek(handle, 3, SEEK_SET); // Skip chunk header
          read(handle, blockdata[s], BLOCKS*16);
          close(handle);
        }
        sprintf(ib2, "%s%02d.chc", ib1, s);
        handle = open(ib2, O_RDONLY | O_BINARY);
        if (handle != -1)
        {
          read(handle, &chcol[s], 256);
          close(handle);
        }

        sprintf(ib2, "%s%02d.chr", ib1, s);
        handle = open(ib2, O_RDONLY | O_BINARY);
        if (handle != -1)
        {
          read(handle, &chardata[s][0], 256*8);
          close(handle);
        }
        else
          break;
      }

      for (c = 0; c < NUMLVLOBJ; c++)
      {
        lvlobjx[c] = 0;
        lvlobjy[c] = 0;
        lvlobjb[c] = 0;
        lvlobjdl[c] = 0;
        lvlobjdh[c] = 0;
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".lvo");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        length = lseek(handle, 0, SEEK_END);
        lseek(handle, 0, SEEK_SET);
        read(handle, &lvlobjx[0], NUMLVLOBJ*2);
        read(handle, &lvlobjy[0], NUMLVLOBJ*2);
        read(handle, &lvlobjb[0], NUMLVLOBJ);
        read(handle, &lvlobjdl[0], NUMLVLOBJ);
        read(handle, &lvlobjdh[0], NUMLVLOBJ);
        close(handle);
      }

      for (c = 0; c < NUMLVLACT; c++)
      {
        lvlactx[c] = 0;
        lvlacty[c] = 0;
        lvlactf[c] = 0;
        lvlactt[c] = 0;
        lvlactw[c] = 0;
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".lva");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        int numobj;
        // Handle legacy formats / changing object count
        length = lseek(handle, 0, SEEK_END);
        lseek(handle, 0, SEEK_SET);
        numobj = length / 7;
        read(handle, &lvlactx[0], numobj*2);
        read(handle, &lvlacty[0], numobj*2);
        read(handle, &lvlactf[0], numobj);
        read(handle, &lvlactt[0], numobj);
        read(handle, &lvlactw[0], numobj);
        close(handle);
      }

      memset(mapdata, 0, mapsx*mapsy);

      strcpy(ib2, ib1);
      strcat(ib2, ".map");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        int sx = readle16(handle);
        int sy = readle16(handle);
        // Abort if we're reading a per-level map mistakenly
        if (sx <= mapsx && sy <= mapsy)
        {
          int x,y;
          for (y = 0; y < sy; y++)
          {
            for (x = 0; x < sx; x++)
            {
              mapdata[y*mapsx+x] = read8(handle);
            }
          }
        }
        close(handle);
      }

      for (c = 0; c < NUMZONES; c++)
      {
        zonex[c] = 0;
        zoney[c] = 0;
        zonesx[c] = 0;
        zonesy[c] = 0;
        zonecharset[c] = 0;
        zonelevel[c] = 0;
        zonebg1[c] = 0;
        zonebg2[c] = 11;
        zonebg3[c] = 12;
        zonespawnparam[c] = 0;
        zonespawnspeed[c] = 0;
        zonespawncount[c] = 0;
        zonemusic[c] = 0;
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lvz");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        read(handle, &zonex[0], NUMZONES*2);
        read(handle, &zoney[0], NUMZONES*2);
        read(handle, &zonesx[0], NUMZONES*2);
        read(handle, &zonesy[0], NUMZONES*2);
        read(handle, &zonecharset[0], NUMZONES);
        read(handle, &zonelevel[0], NUMZONES);
        read(handle, &zonebg1[0], NUMZONES);
        read(handle, &zonebg2[0], NUMZONES);
        read(handle, &zonebg3[0], NUMZONES);
        read(handle, &zonemusic[0], NUMZONES);
        read(handle, &zonespawnparam[0], NUMZONES);
        read(handle, &zonespawnspeed[0], NUMZONES);
        read(handle, &zonespawncount[0], NUMZONES);
        close(handle);
      }

      findusedblocksandchars();
      return;
    }
  }
}

void exportpng(void)
{
  char ib1[80];
  strcpy(ib1, levelname);

  for (;;)
  {
    int r;
    win_getspeed(70);
    gfx_fillscreen(254);

    printtext_center_color("EXPORT WHOLE MAP TO:",90,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,100,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();

    r = inputtext(ib1, 80);
    if (r == -1) return;
    if (r == 1)
    {
      int oldzonenum = zonenum;
      int c;
      char filename[256];
      int minx = 0xffff, miny = 0xffff;
      int maxx = 0, maxy = 0;
      for (c = 0; c < NUMZONES; c++)
      {
        if (zonesx[c] && zonesy[c])
        {
          if (zonex[c] < minx) minx = zonex[c];
          if (zoney[c] < miny) miny = zoney[c];
          if (maxx < zonex[c]+zonesx[c]) maxx = zonex[c] + zonesx[c];
          if (maxy < zoney[c]+zonesy[c]) maxy = zoney[c] + zonesy[c];
        }
      }
      {
        int sizex = (maxx-minx)*32;
        int sizey = (maxy-miny)*32;
        unsigned char* image = malloc(sizey*sizex*3);
        if (image)
        {
          int xb, yb;
          memset(image, 0, sizey*sizex*3);
          sprintf(filename, "%s.png", ib1, c+1);
          for (yb = 0; yb < sizey / 32; yb++)
          {
            for (xb = 0; xb < sizex / 32; xb++)
            {
              int x, y;
              if (mapdata[(yb+miny)*mapsx+xb+minx])
              {
                zonenum = findzonefast(xb+minx, yb+miny, zonenum);
                if (zonenum < NUMZONES)
                {
                  drawblock(0, 0, mapdata[(yb+miny)*mapsx+xb+minx], zonecharset[zonenum]);
                  for (y = 0; y < 32; y++)
                  {
                    for (x = 0; x < 32; x++)
                    {
                      int r,g,b;
                      r = gfx_palette[gfx_vscreen[y*320+x]*3] * 4;
                      g = gfx_palette[gfx_vscreen[y*320+x]*3+1] * 4;
                      b = gfx_palette[gfx_vscreen[y*320+x]*3+2] * 4;
                      if (r > 255) r = 255;
                      if (g > 255) g = 255;
                      if (b > 255) b = 255;
  
                      image[((yb*32+y)*sizex+(xb*32+x))*3] = r;
                      image[((yb*32+y)*sizex+(xb*32+x))*3+1] = g;
                      image[((yb*32+y)*sizex+(xb*32+x))*3+2] = b;
                    }
                  }
                }
              }
            }
          }
          stbi_write_png(filename, sizex, sizey, 3, image, 0);
          free(image);
        }
      }
      zonenum = oldzonenum;
      return;
    }
  }
}

void savealldata(void)
{
  char ib1[80];
  strcpy(ib1, levelname);

  endblockeditmode();
  findusedblocksandchars();
  calculatelevelorigins();

  unsigned char actorsperlevel[NUMLEVELS];
  unsigned char objectsperlevel[NUMLEVELS];
  unsigned char persistentobjectsperlevel[NUMLEVELS];
  unsigned char actbitareasize[NUMLEVELS];
  unsigned char objbitareasize[NUMLEVELS];
  unsigned char actbitareaindex[NUMLEVELS];
  unsigned char objbitareaindex[NUMLEVELS];
  int totalmapdatasize = 0;
  int totalactbitareasize = 0;
  int totalobjbitareasize = 0;
  int numlevels = 0;
  int screensize = 0;
  memset(actorsperlevel, 0, sizeof actorsperlevel);
  memset(objectsperlevel, 0, sizeof objectsperlevel);
  memset(persistentobjectsperlevel, 0, sizeof persistentobjectsperlevel);
  memset(actbitareaindex, 0, sizeof actbitareaindex);
  memset(actbitareasize, 0, sizeof actbitareasize);
  memset(objbitareaindex, 0, sizeof objbitareaindex);
  memset(objbitareasize, 0, sizeof objbitareasize);

  for (;;)
  {
    int r;

    win_getspeed(70);
    gfx_fillscreen(254);

    printtext_center_color("SAVE ALL LEVELDATA:",90,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,100,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();

    r = inputtext(ib1, 80);
    if (r == -1) return;
    if (r == 1)
    {
      int c;
      int handle;
      int s;
      int oldcharset = charsetnum;
      char ib2[80];

      if (!strlen(ib1))
        return;

      // Check first that we have some data (prevent mistaken save of empty data over existing)
      for (s = 0; s < NUMLEVELS; ++s)
      {
        if (!levelsx[s] || !levelsy[s])
          continue;
        if (numlevels < s+1)
          numlevels = s+1;
      }
      
      if (!numlevels)
        return;

      strcpy(levelname, ib1);

      for (s = 0; s < NUMCHARSETS; s++)
      {
        int v = 0;
        // Check simply for charset being completely empty
        for (c = 0; c < 2048; c++)
          v += chardata[s][c];
        if (!v)
          continue;
        charsetnum = s;

        sprintf(ib2, "%s%02d.chr", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          write(handle, &chardata[s][0], 256*8);
          close(handle);
        }
        sprintf(ib2, "%s%02d.chi", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          write(handle, chinfo[s], 256);
          close(handle);
        }
        sprintf(ib2, "%s%02d.blk", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          writele16(handle, maxusedblocks[s]*16);
          write8(handle, 0);
          write(handle, blockdata[s], maxusedblocks[s]*16);
          close(handle);
        }
        updateblockinfo();
        strcpy(ib2, ib1);
        sprintf(ib2, "%s%02d.bli", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          write(handle, blockinfo, (maxusedblocks[s]+1)/2);
          close(handle);
        }
        strcpy(ib2, ib1);
        sprintf(ib2, "%s%02d.chc", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          write(handle, &chcol[s], 256);
          close(handle);
        }
      }

      charsetnum = oldcharset;

      strcpy(ib2, ib1);
      strcat(ib2, ".lvo");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &lvlobjx[0], NUMLVLOBJ*2);
        write(handle, &lvlobjy[0], NUMLVLOBJ*2);
        write(handle, &lvlobjb[0], NUMLVLOBJ);
        write(handle, &lvlobjdl[0], NUMLVLOBJ);
        write(handle, &lvlobjdh[0], NUMLVLOBJ);
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lva");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &lvlactx[0], NUMLVLACT*2);
        write(handle, &lvlacty[0], NUMLVLACT*2);
        write(handle, &lvlactf[0], NUMLVLACT);
        write(handle, &lvlactt[0], NUMLVLACT);
        write(handle, &lvlactw[0], NUMLVLACT);
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".map");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        writele16(handle, mapsx);
        writele16(handle, mapsy);
        int x,y;
        for (y = 0; y < mapsy; y++)
        {
          for (x = 0; x < mapsx; x++)
          {
            write8(handle, mapdata[y*mapsx+x]);
          }
        }
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lvz");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &zonex[0], NUMZONES*2);
        write(handle, &zoney[0], NUMZONES*2);
        write(handle, &zonesx[0], NUMZONES*2);
        write(handle, &zonesy[0], NUMZONES*2);
        write(handle, &zonecharset[0], NUMZONES);
        write(handle, &zonelevel[0], NUMZONES);
        write(handle, &zonebg1[0], NUMZONES);
        write(handle, &zonebg2[0], NUMZONES);
        write(handle, &zonebg3[0], NUMZONES);
        write(handle, &zonemusic[0], NUMZONES);
        write(handle, &zonespawnparam[0], NUMZONES);
        write(handle, &zonespawnspeed[0], NUMZONES);
        write(handle, &zonespawncount[0], NUMZONES);
        close(handle);
      }
      
      // Save level maps which contain data
      for (s = 0; s < NUMLEVELS; ++s)
      {
        if (!levelsx[s] || !levelsy[s])
          continue;
        if (numlevels < s+1)
          numlevels = s+1;

        strcpy(ib2, ib1);
        sprintf(ib2, "%s%02d.lva", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          unsigned char savelvlactx[NUMLVLACT_PER_LEVEL];
          unsigned char savelvlacty[NUMLVLACT_PER_LEVEL];
          unsigned char savelvlactf[NUMLVLACT_PER_LEVEL];
          unsigned char savelvlactt[NUMLVLACT_PER_LEVEL];
          unsigned char savelvlactw[NUMLVLACT_PER_LEVEL];
          int d = 0;

          memset(savelvlactx, 0, sizeof savelvlactx);
          memset(savelvlacty, 0, sizeof savelvlacty);
          memset(savelvlactf, 0, sizeof savelvlactf);
          memset(savelvlactt, 0, sizeof savelvlactt);
          memset(savelvlactw, 0, sizeof savelvlactw);

          for (c = 0; c < NUMLVLACT; c++)
          {
            if (lvlactt[c])
            {
              int z = findzone(lvlactx[c], lvlacty[c]&0x7f);
              if (z < NUMZONES && zonelevel[z] == s)
              {
                savelvlactx[d] = lvlactx[c]-levelx[s];
                savelvlacty[d] = lvlacty[c];
                savelvlactf[d] = lvlactf[c];
                savelvlactt[d] = lvlactt[c];
                savelvlactw[d] = lvlactw[c];
                actorsperlevel[s]++;
                d++;
                if (d >= NUMLVLACT_PER_LEVEL)
                  break;
              }
            }
          }
          write(handle, &savelvlactx, sizeof savelvlactx);
          write(handle, &savelvlacty, sizeof savelvlacty);
          write(handle, &savelvlactf, sizeof savelvlactf);
          write(handle, &savelvlactt, sizeof savelvlactt);
          write(handle, &savelvlactw, sizeof savelvlactw);
          close(handle);
        }

        strcpy(ib2, ib1);
        sprintf(ib2, "%s%02d.lvo", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          unsigned char savelvlobjx[NUMLVLOBJ_PER_LEVEL];
          unsigned char savelvlobjy[NUMLVLOBJ_PER_LEVEL];
          unsigned char savelvlobjb[NUMLVLOBJ_PER_LEVEL];
          unsigned char savelvlobjdl[NUMLVLOBJ_PER_LEVEL];
          unsigned char savelvlobjdh[NUMLVLOBJ_PER_LEVEL];
          int d = 0;
          
          memset(savelvlobjx, 0, sizeof savelvlobjx);
          memset(savelvlobjy, 0, sizeof savelvlobjy);
          memset(savelvlobjb, 0, sizeof savelvlobjb);
          memset(savelvlobjdl, 0, sizeof savelvlobjdl);
          memset(savelvlobjdh, 0, sizeof savelvlobjdh);

          for (c = 0; c < NUMLVLOBJ; c++)
          {
            if (lvlobjx[c] && (lvlobjy[c]&0x7f))
            {
              int z = findzone(lvlobjx[c], lvlobjy[c]&0x7f);
              if (z < NUMZONES && zonelevel[z] == s)
              {
                savelvlobjx[d] = lvlobjx[c]-levelx[s];
                savelvlobjy[d] = lvlobjy[c];
                savelvlobjb[d] = lvlobjb[c];
                savelvlobjdl[d] = lvlobjdl[c];
                savelvlobjdh[d] = lvlobjdh[c];
                objectsperlevel[s]++;
                // If object is not autodeactivating, and either animates or is a switch/script, it's persistent
                if (((lvlobjb[c] & 0x20) == 0) && ((lvlobjy[c] & 0x80) || (lvlobjb[c] & 0x1c > 0x8)))
                  persistentobjectsperlevel[s]++;
                d++;
                if (d >= NUMLVLOBJ_PER_LEVEL)
                  break;
              }
            }
          }
          write(handle, &savelvlobjx, sizeof savelvlobjx);
          write(handle, &savelvlobjy, sizeof savelvlobjy);
          write(handle, &savelvlobjb, sizeof savelvlobjb);
          write(handle, &savelvlobjdl, sizeof savelvlobjdl);
          write(handle, &savelvlobjdh, sizeof savelvlobjdh);
          close(handle);
        }
        strcpy(ib2, ib1);
        sprintf(ib2, "%s%02d.map", ib1, s);
        handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle != -1)
        {
          int activezones = 0;
          int datasize = 0;
          int zoneoffsets[NUMZONES];
          int d = 0;

          for (c = 0; c < NUMZONES; c++)
          {
            if (zonesx[c] && zonesy[c] && zonelevel[c] == s)
              activezones++;
          }
          datasize = activezones*2;

          for (c = 0; c < NUMZONES; c++)
          {
            if (zonesx[c] && zonesy[c] && zonelevel[c] == s)
            {
              zoneoffsets[d] = datasize;
              datasize += 12 + zonesx[c]*zonesy[c];
              totalmapdatasize += zonesx[c]*zonesy[c];
              screensize += (zonesx[c]/10)*((zonesy[c]+3)/5);
              d++;
            }
          }

          writele16(handle, datasize);
          write8(handle, activezones);
          for (c = 0; c < activezones; c++)
            writele16(handle, zoneoffsets[c]);

          int x,y;
          for (c = 0; c < NUMZONES; c++)
          {
            if (zonesx[c] && zonesy[c] && zonelevel[c] == s)
            {
              write8(handle, zonex[c]-levelx[zonelevel[c]]);
              write8(handle, zonex[c]-levelx[zonelevel[c]]+zonesx[c]);
              write8(handle, zoney[c]);
              write8(handle, zoney[c]+zonesy[c]);
              write8(handle, zonecharset[c]);
              write8(handle, zonebg1[c]);
              write8(handle, zonebg2[c]);
              write8(handle, zonebg3[c]);
              write8(handle, zonemusic[c]);
              write8(handle, zonespawnparam[c]);
              write8(handle, zonespawnspeed[c]);
              write8(handle, zonespawncount[c]);

              for (y = zoney[c]; y < zoney[c]+zonesy[c]; y++)
              {
                for (x = zonex[c]; x < zonex[c]+zonesx[c]; x++)
                {
                  write8(handle, mapdata[y*mapsx+x]);
                }
              }
            }
          }
        }
        close(handle);
      }
      
      c = 0;
      for (s = 0; s < numlevels; ++s)
      {
        actbitareasize[s] = (actorsperlevel[s]+7)/8;
        if (actbitareasize[s] == 0) actbitareasize[s] = 1; // Always at least 1 byte
        actbitareaindex[s] = c;
        c += actbitareasize[s];
      }
      totalactbitareasize = c;

      c = 0;
      for (s = 0; s < numlevels; ++s)
      {
        objbitareasize[s] = (persistentobjectsperlevel[s]+7)/8;
        if (objbitareasize[s] == 0) objbitareasize[s] = 1; // Always at least 1 byte
        objbitareaindex[s] = c;
        c += objbitareasize[s];
      }
      totalobjbitareasize = c;

      strcpy(ib2, ib1);
      sprintf(ib2, "%s.s", ib1);
      FILE* out = fopen(ib2, "wt");
      if (out)
      {
        fprintf(out, "NUMLEVELS = %d\n\n", numlevels);
        fprintf(out, "WORLDSIZEBLOCKS = %d\n\n", totalmapdatasize);
        fprintf(out, "WORLDSIZESCREENS = %d\n\n", screensize);
        fprintf(out, "LVLDATAACTTOTALSIZE = %d\n\n", totalactbitareasize);
        fprintf(out, "LVLOBJTOTALSIZE = %d\n\n", totalobjbitareasize);

        fprintf(out, "lvlDataActBitsStart:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", actbitareaindex[c]);
        }
        fprintf(out, "lvlDataActBitsLen:\n");
        for  (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", actbitareasize[c]);
        }
        fprintf(out, "lvlObjBitsStart:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", objbitareaindex[c]);
        }
        fprintf(out, "lvlObjBitsLen:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", objbitareasize[c]);
        }
        fprintf(out, "lvlLimitL:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", levelx[c]/10); // In screens
        }
        fprintf(out, "lvlLimitR:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", (levelx[c]+levelsx[c])/10); // In screens
        }
        fprintf(out, "lvlLimitU:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", levely[c]);
        }
        fprintf(out, "lvlLimitD:\n");
        for (c = 0; c < numlevels; c++)
        {
            fprintf(out, "                dc.b %d\n", levely[c]+levelsy[c]);
        }
        fclose(out);
      }
      return;
    }
  }
}

void importlevelmap(void)
{
  char ib1[80];
  char ib2[5];
  char ib3[5];
  char ib4[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;
  ib3[0] = 0;
  ib4[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("IMPORT LEVEL MAP:",50,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,60,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("USE CHARSET:",80,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib2,90,SPR_FONTS,COL_HIGHLIGHT);
    }
    if (phase > 2)
    {
      printtext_center_color("MAP X OFFSET:",110,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib3,120,SPR_FONTS,COL_HIGHLIGHT);
    }
    if (phase > 3)
    {
      printtext_center_color("MAP Y OFFSET:",140,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib4,150,SPR_FONTS,COL_HIGHLIGHT);
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
      if (r == 1) phase = 4;
    }
    if (phase == 4)
    {
      int r = inputtext(ib4, 5);
      if (r == -1) return;
      if (r == 1)
      {
        int charset, xofs, yofs;
        sscanf(ib2, "%d", &charset);
        sscanf(ib3, "%d", &xofs);
        sscanf(ib4, "%d", &yofs);
        if (charset >= 0 && charset < NUMCHARSETS && xofs >= 0 && yofs >= 0)
        {
          int handle;
          char filename[80];
          strcpy(filename, ib1);
          strcat(filename, ".map");
          handle = open(filename, O_RDONLY | O_BINARY);
          if (handle != -1)
          {
            int datasize = readle16(handle);
            int activezones = read8(handle);
            int zoneoffsets[NUMZONES];
            int z,y,x,c;
            int freelevel = 0;
            for (z = 0; z < NUMZONES; z++)
            {
              if (zonesx[z] && zonesy[z] && zonelevel[z] >= freelevel)
                freelevel = zonelevel[z]+1;
            }
            // Import everything into a single zone for easy deletion later (colors may be wrong)
            for (z = 0; z < NUMZONES-1; z++)
            {
              if (!zonesx[z] && !zonesy[z])
                break;
            }

            for (c = 0; c < activezones; c++)
            {
                zoneoffsets[c] = readle16(handle) + 3;
            }

            for (c = 0; c < activezones; c++)
            {
              int l,r,u,d;
              lseek(handle, zoneoffsets[c], SEEK_SET);

              l = read8(handle) + xofs;
              r = read8(handle) + xofs;
              u = read8(handle) + yofs;
              d = read8(handle) + yofs;
              zonecharset[z] = charset;
              zonelevel[z] = freelevel;
              zonebg1[z] = read8(handle);
              zonebg2[z] = read8(handle);
              zonebg3[z] = read8(handle);
              zonemusic[z] = read8(handle);
              zonespawnparam[z] = read8(handle);
              zonespawnspeed[z] = read8(handle);
              zonespawncount[z] = read8(handle);
              if (!zonesx[z] && !zonesy[z])
              {
                zonesx[z] = r-l;
                zonesy[z] = d-u;
                zonex[z] = l;
                zoney[z] = u;
              }
              else
              {
                if (l < zonex[z])
                {
                  zonex[z] = l;
                  zonesx[z] += (zonex[z]-l);
                }
                if (u < zoney[z])
                {
                  zoney[z] = u;
                  zonesy[z] += (zoney[z]-u);
                }
                if (r > zonex[z]+zonesx[z])
                  zonesx[z] = r-zonex[z];
                if (d > zoney[z]+zonesy[z])
                  zonesy[z] = d-zoney[z];
              }

              for (y = u; y < d; y++)
              {
                for (x = l; x < r; x++)
                {
                  mapdata[y*mapsx+x] = read8(handle);
                }
              }
            }
            close(handle);
          }
        }
        calculatelevelorigins();
        return;
      }
    }
  }
}

void loadblocks(void)
{
  char ib1[80];
  char ib2[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;

  findusedblocksandchars();
  
  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD BLOCKFILE:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("LOAD AT BLOCKNUM:",95,SPR_FONTS,COL_WHITE);
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
        int numblocks;
        int datalen;
        int frame;
        int handle;
        int offset;
        int c;

        sscanf(ib2, "%d", &frame);
        if (frame < 0) frame = 0;
        optimizechars();
        handle = open(ib1, O_RDONLY | O_BINARY);
        if (handle == -1) return;

        for (c = 255; c >= 64; c--)
        {
          if (charused[c]) break;
        }
        offset = c + 1;
        if (c == 256) c = 255;

        int length = lseek(handle, 0, SEEK_END);
        lseek(handle, 0, SEEK_SET);
        read(handle, &numblocks, sizeof numblocks);
        read(handle, &datalen, sizeof datalen);

        if (length >= sizeof numblocks + sizeof datalen + numblocks*16 + datalen + datalen/8*2)
        {
            for (c = frame; c < frame+numblocks; c++)
            {
              int b = c;
              int d;
    
              if (b > BLOCKS-1) b = BLOCKS-1;
              read(handle, &blockdata[charsetnum][16*b], 16);
              for (d = 0; d < 16; d++)
              {
                blockdata[charsetnum][16*b+d] += offset;
              }
            }
            if ((datalen + offset*8) > 2048)
              datalen = 2048 - offset*8;
            read(handle, &chardata[charsetnum][offset*8], datalen);
            read(handle, &chcol[charsetnum][offset], datalen/8);
            read(handle, &chinfo[charsetnum][offset], datalen/8);
        }
        else
        {
            // MW4 import (block colors, will be discarded)
            for (c = frame; c < frame+numblocks; c++)
            {
              unsigned char blockcol;
              read(handle, &blockcol, 1);

              int b = c;
              int d;

              if (b > BLOCKS-1) b = BLOCKS-1;
              read(handle, &blockdata[charsetnum][16*b], 16);
              for (d = 0; d < 16; d++)
              {
                blockdata[charsetnum][16*b+d] += offset;
              }
            }
            if ((datalen + offset*8) > 2048)
              datalen = 2048 - offset*8;
            read(handle, &chardata[charsetnum][offset*8], datalen);
        }

        close(handle);
        optimizechars();
        findusedblocksandchars();
        return;
      }
    }
  }
}

void saveblocks(void)
{
  char ib1[80];
  char ib2[5];
  char ib3[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;
  ib3[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("SAVE BLOCKFILE:",60,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,70,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("SAVE FROM BLOCKNUM:",85,SPR_FONTS,COL_WHITE);
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
        int b,c,d;
        int frame, frames;
        int handle;
        int chardatasize = 0;
        unsigned char tempchars[2048];
        unsigned char tempchcol[256];
        unsigned char tempchinfo[256];
        unsigned char tempblocks[4096];
        int numtempchars = 0;

        sscanf(ib2, "%d", &frame);
        sscanf(ib3, "%d", &frames);
        if (frame < 0) frame = 0;
        if (frame > BLOCKS-1) frame = BLOCKS-1;
        if (frames < 1) frames = 1;
        if (frame+frames > BLOCKS) frames = BLOCKS-frame;

        handle = open(ib1, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle == -1) return;

        for (c = frame; c < frame+frames; c++)
        {
          for (b = 0; b < 16; b++)
          {
            int ch = blockdata[charsetnum][16*c+b];
            int found = 0;
            for (d = 0; d < numtempchars; d++)
            {
              if (!memcmp(&chardata[charsetnum][ch*8], &tempchars[d*8], 8))
              {
                found = 1;
                break;
              }
            }
            if (found)
            {
              tempblocks[16*c+b] = d;
            }
            else
            {
              tempblocks[16*c+b] = d;
              numtempchars = d+1;
              memcpy(&tempchars[d*8], &chardata[charsetnum][ch*8], 8);
              tempchcol[d] = chcol[charsetnum][ch];
              tempchinfo[d] = chinfo[charsetnum][ch];
            }
          }
        }
        chardatasize = numtempchars*8;

        write(handle, &frames, sizeof frames);
        write(handle, &chardatasize, sizeof chardatasize);
        for (c = frame; c < frame+frames; c++)
        {
          write(handle, &tempblocks[16*c], 16);
        }
        write(handle, tempchars, chardatasize);
        write(handle, tempchcol, chardatasize/8);
        write(handle, tempchinfo, chardatasize/8);
        close(handle);
        return;
      }
    }
  }
}

void copycharset(void)
{
  char ib1[5];
  char ib2[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("COPY FROM CHARSET:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("COPY TO CHARSET:",95,SPR_FONTS,COL_WHITE);
      printtext_center_color(ib2,105,SPR_FONTS,COL_HIGHLIGHT);
    }
    gfx_updatepage();
    if (phase == 1)
    {
      int r = inputtext(ib1, 6);
      if (r == -1) return;
      if (r == 1) phase = 2;
    }
    if (phase == 2)
    {
      int r = inputtext(ib2, 5);
      if (r == -1) return;
      if (r == 1)
      {
        int src,dest;
        sscanf(ib1, "%d", &src);
        sscanf(ib2, "%d", &dest);
        if (src < 0 || dest < 0 || src >= NUMCHARSETS || dest >= NUMCHARSETS)
          return;
        memcpy(chardata[dest], chardata[src], 2048);
        memcpy(blockdata[dest], blockdata[src], 4096);
        memcpy(chcol[dest], chcol[src], 256);
        memcpy(chinfo[dest], chinfo[src], 256);
        return;
      }
    }
  }
}

void loadcharsinfo(void)
{
  char ib1[80];
  int handle;
  ib1[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD CHARS WITH INFO:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();
    {
      int r = inputtext(ib1, 80);
      if (r == -1) return;
      if (r == 1)
      {
        handle = open(ib1, O_RDONLY | O_BINARY);
        if (handle == -1) return;
        read(handle, chinfo[charsetnum], 256);
        read(handle, chardata[charsetnum], 2048);
        close(handle);
        findusedblocksandchars();
        return;
      }
    }
  }
}

void savecharsinfo(void)
{
  char ib1[80];
  int handle;
  ib1[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("SAVE CHARS WITH INFO:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();
    {
      int r = inputtext(ib1, 80);
      if (r == -1) return;
      if (r == 1)
      {
        handle = open(ib1, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle == -1) return;
        write(handle, chinfo[charsetnum], 256);
        write(handle, chardata[charsetnum], 2048);
        close(handle);
        return;
      }
    }
  }
}

void confirmquit(void)
{
    for (;;)
    {
        int k;
        win_getspeed(70);
        gfx_fillscreen(254);
        printtext_center_color("PRESS Y TO CONFIRM QUIT",90,SPR_FONTS,COL_WHITE);
        printtext_center_color("UNSAVED DATA WILL BE LOST",100,SPR_FONTS,COL_WHITE);
        gfx_updatepage();
        k = kbd_getascii();
        if (k)
        {
            if (k == 'y')
                editmode = EM_QUIT;
            return;
        }
    }
}

void loadchars(void)
{
  char ib1[80];
  char ib2[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("LOAD CHARFILE:",70,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,80,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("LOAD AT CHARNUM:",95,SPR_FONTS,COL_WHITE);
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
        int handle;
        int maxbytes = 2048;
        sscanf(ib2, "%d", &frame);
        if (frame < 0) frame = 0;
        if (frame > 255) frame = 255;
        maxbytes -= frame*8;
        handle = open(ib1, O_RDONLY | O_BINARY);
        if (handle == -1) return;
        read(handle, &chardata[charsetnum][frame*8], maxbytes);
        close(handle);
        findusedblocksandchars();
        return;
      }
    }
  }
}

void savechars(void)
{
  char ib1[80];
  char ib2[5];
  char ib3[5];
  int phase = 1;
  ib1[0] = 0;
  ib2[0] = 0;
  ib3[0] = 0;

  for (;;)
  {
    win_getspeed(70);
    gfx_fillscreen(254);
    printtext_center_color("SAVE CHARFILE:",60,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,70,SPR_FONTS,COL_HIGHLIGHT);
    if (phase > 1)
    {
      printtext_center_color("SAVE FROM CHARNUM:",85,SPR_FONTS,COL_WHITE);
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
        int frame, frames;
        int handle;
        sscanf(ib2, "%d", &frame);
        sscanf(ib3, "%d", &frames);
        if (frame < 0) frame = 0;
        if (frame > 255) frame = 255;
        if (frames < 1) frames = 1;
        if (frame+frames > 256) frames = 256-frame;

        handle = open(ib1, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
        if (handle == -1) return;
        write(handle, &chardata[charsetnum][frame*8], frames*8);
        close(handle);
        return;
      }
    }
  }
}

void drawcbar(int x, int y, char col)
{
  int a;
  for (a = y; a < y+9; a++)
  {
    gfx_line(x, a, x+14, a, col);
  }
}

void handle_int(int a)
{
  exit(0); /* Atexit functions will be called! */
}

void drawimage(void)
{
    int c, x, y;

    c = 0;
    for (y = 0; y < 8; y++)
    {
        for (x = 0; x < 32; x++)
        {
            drawchar(x*8+32, y*8+128, c, charsetnum);
            c++;
        }
    }
}

void drawchar(int dx, int dy, int c, int charset)
{
  Uint8 *destptr = &gfx_vscreen[dy*320 + dx];
  Uint8 *ptr = &chardata[charset][c*8];
  char v = 0;
  int x,y;

  if ((chcol[charset][c]&15) < 8)
  {
    for (y = 0; y < 8; y++)
    {
      unsigned data = *ptr;

      for (x = 7; x >= 0; x--)
      {
        if (data & 1) v = (chcol[charset][c]&15);
        else v = zonebg1[zonenum] & 15;

        destptr[y*320+x]=v;

        data >>= 1;
      }
      ptr++;
    }
  }
  else
  {
    for (y = 0; y < 8; y++)
    {
      unsigned data = *ptr;
      for (x = 3; x >= 0; x--)
      {
        char b = data & 3;
        switch (b)
        {
          case 0:
          v = zonebg1[zonenum] & 15;
          break;

          case 1:
          v = zonebg2[zonenum] & 15;
          break;

          case 2:
          v = zonebg3[zonenum] & 15;
          break;

          case 3:
          v = (chcol[charset][c]&15)-8;
          break;

        }
        destptr[y*320+x*2]=v;
        destptr[y*320+x*2+1]=v;
        data >>= 2;
      }
      ptr++;
    }
  }
}

void drawblock(int x, int y, int num, int charset)
{
    int c;
    int xb, yb;

    for (yb = 0; yb < 4; yb++)
    {
        for (xb = 0; xb < 4; xb++)
        {
            drawchar(x+xb*8, y+yb*8, blockdata[charset][num*16+yb*4+xb], charset);
        }
    }
}

void drawsmallblock(int x, int y, int num, int charset)
{
  Uint8 *destptr = &gfx_vscreen[y*320 + x];
  int bx,by;
  unsigned char smallblock[8][8];

  for (by = 0; by < 4; ++by)
  {
    for (bx = 0; bx < 4; ++bx)
    {
      int cy, cx;
      drawchar(x, y, blockdata[charset][num*16+by*4+bx], charset);
      smallblock[by*2][bx*2] = destptr[0];
      smallblock[by*2][bx*2+1] = destptr[4];
      smallblock[by*2+1][bx*2] = destptr[320];
      smallblock[by*2+1][bx*2+1] = destptr[324];
    }
  }
  for (by = 0; by < 8; ++by)
    memcpy(&destptr[320*by], &smallblock[by][0], 8);
}

int findzone(int x, int y)
{
  int c;
  for (c = 0; c < NUMZONES; c++)
  {
    if (zonesx[c] && zonesy[c])
    {
      if (x >= zonex[c] && x < (zonex[c]+zonesx[c]) &&
          y >= zoney[c] && y < (zoney[c]+zonesy[c])) return c;
    }
  }
  return NUMZONES+1;
}

int findzonefast(int x, int y, int lastzone)
{
  int c;
  if (lastzone < NUMZONES && zonesx[lastzone] && zonesy[lastzone])
  {
    if (x >= zonex[lastzone] && x < (zonex[lastzone]+zonesx[lastzone]) &&
        y >= zoney[lastzone] && y < (zoney[lastzone]+zonesy[lastzone])) return lastzone;
  }

  for (c = 0; c < NUMZONES; c++)
  {
    if (zonesx[c] && zonesy[c])
    {
      if (x >= zonex[c] && x < (zonex[c]+zonesx[c]) &&
          y >= zoney[c] && y < (zoney[c]+zonesy[c])) return c;
    }
  }
  return NUMZONES+1;
}

int findnearestzone(int x, int y)
{
  int nearest = NUMZONES;
  int nearestdist = 0x7fffffff;
  int c;
  for (c = 0; c < NUMZONES; c++)
  {
    if (zonesx[c] && zonesy[c])
    {
      int dist = abs(x - (zonex[c]+zonex[c]+zonesx[c])/2) + abs(y - (zoney[c]+zoney[c]+zonesy[c])/2);
      if (dist < nearestdist)
      {
        nearest = c;
        nearestdist = dist;
      }
    }
  }
  return nearest;
}
