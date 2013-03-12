/*
 * Level editor, based on MW4 editor
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

#define COLOR_DELAY 10
#define NUMZONES 128
#define NUMLVLOBJ 128
#define NUMLVLACT 80

#define NUMRANDOMACT 16

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

unsigned char lvlobjx[NUMLVLOBJ];
unsigned char lvlobjy[NUMLVLOBJ];
unsigned char lvlobjb[NUMLVLOBJ];
unsigned char lvlobjd1[NUMLVLOBJ];
unsigned char lvlobjd2[NUMLVLOBJ];

unsigned char randomactt[NUMRANDOMACT];
unsigned char randomactw[NUMRANDOMACT];
unsigned char randomactp[NUMRANDOMACT];

unsigned char lvlactx[NUMLVLACT];
unsigned char lvlacty[NUMLVLACT];
unsigned char lvlactf[NUMLVLACT];
unsigned char lvlactt[NUMLVLACT];
unsigned char lvlactw[NUMLVLACT];

unsigned char zonex[NUMZONES];  // Zone centerpoint
unsigned char zoney[NUMZONES];
unsigned char zonel[NUMZONES];
unsigned char zoner[NUMZONES];
unsigned char zoneu[NUMZONES];
unsigned char zoned[NUMZONES];
unsigned char zonebg1[NUMZONES];
unsigned char zonebg2[NUMZONES];
unsigned char zonebg3[NUMZONES];
unsigned char zonemusic[NUMZONES];

char *actorname[256];
char *itemname[256];
char *modename[16];

char *modetext[] = {
  "NONE",
  "TRIG",
  "MAN.",
  "MAN.AD"};

char *actiontext[] = {
  "NONE",
  "DOOR",
  "SWITCH",
  "REVEAL",
  "SCRIPT",
  "CHAIN",
  "SIDEDOOR",
  "SPAWN"};

char *spawnmodename[] = {
  "GROUND",
  "GROUND",
  "AIR-SIDE",
  "AIR-TOP"};

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
unsigned char chcol[256];
unsigned char chinfo[256];
unsigned char charused[256];
unsigned char blockused[256];
unsigned blockusecount[256];
unsigned char animatingblock[256];
unsigned char mapcopybuffer[MAPCOPYSIZE];
unsigned char finemapcopybuffer[MAPCOPYSIZE];
unsigned char ascii;
int k;
int blockeditmode = 0;
int blockselectmode = 0;
int bsy = 0;
unsigned char copychcol;
unsigned char copychinfo;
unsigned char intensity[] = {0,15,4,11,5,10,1,14,6,2,9,3,7,13,8,12};

int randomeditmode = 0;
int randomactnum = 0;

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

int maxusedblocks = 0;
int colordelay = 0;
unsigned char oldchar;
unsigned char blockeditnum;

int levelnum = 0;

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
int mapsx = 255;
int mapsy = 128;
char levelname[80];

Uint8 *chardata;
Uint8 *blockdata;
Uint8 *mapdata;

int actfound = 0;
int actindex = 0;
int objfound = 0;
int objindex = 0;
unsigned char actnum = 1;
unsigned char frommap = 0;

int initchars(void);
int findzone(int x, int y);
void gotopos(int x, int y);
void updatezone(int z);
void updateallzones(void);
void endblockeditmode(void);
void initblockeditmode(int frommap);
void findusedblocksandchars(void);
void findanimatingblocks(void);
void confirmquit(void);
void loadchars(void);
void savechars(void);
void loadblocks(void);
void saveblocks(void);
void loadcharsinfo(void);
void savecharsinfo(void);
void loadalldata(void);
void savealldata(void);
void exportmap(void);
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
void drawblock(int x, int y, int num);
void drawchar(int x, int y, int num);
void mouseupdate(void);
void handle_int(int a);
void drawmap(void);
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

extern unsigned char datafile[];

int main (int argc, char *argv[])
{
  int c;
  FILE *names;

  io_openlinkeddatafile(datafile);

  if (!win_openwindow("Level editor", NULL)) return 1;
  win_fullscreen = 0;

  for (c = 0; c < 256; c++) actorname[c] = " ";
  for (c = 0; c < 256; c++) itemname[c] = " ";
  for (c = 0; c < 16; c++) modename[c] = " ";
  levelname[0] = 0;
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

void gotopos(int x, int y)
{
  mapx = x - 5;
  mapy = y - 3;
  if (mapx < 0) mapx = 0;
  if (mapx >= mapsx - 10) mapx = mapsx - 10;
  if (mapy < 0) mapy = 0;
  if (mapy >= mapsy - 5) mapy = mapsy - 10;
}

void level_mainloop(void)
{
  findusedblocksandchars();

  for (;;)
  {
    int s;

    s = win_getspeed(70);
    flash += s;
    flash &= 31;
    k = kbd_getkey();
    ascii = kbd_getascii();
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }
    if (k == KEY_TAB)
    {
      if (editmode != EM_CHARS)
        editmode = EM_CHARS;
      else
        editmode = EM_MAP;
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

    if (k == KEY_R) randomeditmode ^= 1;

    if (randomeditmode)
    {
      int wpn;
      if (k == KEY_DOWN) randomactnum++;
      if (k == KEY_UP) randomactnum--;
      randomactnum &= NUMRANDOMACT-1;
      if (k == KEY_Z) randomactt[randomactnum]--;
      if (k == KEY_X) randomactt[randomactnum]++;
      if (k == KEY_1) randomactt[randomactnum]--;
      if (k == KEY_2) randomactt[randomactnum]++;
      if (k == KEY_3) randomactt[randomactnum] -= 16;
      if (k == KEY_4) randomactt[randomactnum] += 16;
      randomactt[randomactnum] &= 0x7f;

      wpn = randomactw[randomactnum] & 0x3f;
      if (k == KEY_Q) wpn--;
      if (k == KEY_W) wpn++;
      randomactw[randomactnum] &= 0xc0;
      randomactw[randomactnum] |= wpn & 0x3f;

      if (k == KEY_A) randomactp[randomactnum]--;
      if (k == KEY_S) randomactp[randomactnum]++;

      if (k == KEY_M)
        randomactw[randomactnum] += 0x40;
    }
    else
    {

      if (k == KEY_LEFT) mapx--;
      if (k == KEY_RIGHT) mapx++;
      if (k == KEY_UP) mapy--;
      if (k == KEY_DOWN) mapy++;
      if (mapx < 0) mapx = 0;
      if (mapy < 0) mapy = 0;
      if (mapx > (mapsx-10)) mapx = mapsx-10;
      if (mapy > (mapsy-5)) mapy = mapsy-5;
      if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
      {
        int c;
        int x = mapx+mousex/32;
        int y = mapy+mousey/32;
        int xf = (((mapx*32+mousex) % 32) & 0x18) / 8;
        int yf = (((mapy*32+mousey) % 32) & 0x18) / 8;

        actfound = 0;
        objfound = 0;

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
          if (k == KEY_Z) actnum--;
          if (k == KEY_X) actnum++;
          if (k == KEY_1) actnum--;
          if (k == KEY_2) actnum++;
          if (k == KEY_3) actnum -= 16;
          if (k == KEY_4) actnum += 16;
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
              if (k == KEY_G)
              {
                switch((lvlobjb[objindex] & 0x1c) >> 2)
                {
                  case 1:
                  case 6:
                  if (lvlobjd2[objindex] == levelnum)
                  {
                    int tgt = lvlobjd1[objindex];
                    if (tgt < NUMLVLOBJ)
                      gotopos(lvlobjx[tgt], lvlobjy[tgt] & 0x7f);
                  }
                  break;
                }
              }

              if (k == KEY_DEL)
              {
                lvlobjx[objindex] = 0;
                lvlobjy[objindex] = 0;
                lvlobjb[objindex] = 0;
                lvlobjd1[objindex] = 0;
                lvlobjd2[objindex] = 0;
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
                a &= 7;
                lvlobjb[objindex] &= 0xe3;
                lvlobjb[objindex] |= (a << 2);
              }
              if (k == KEY_Y) // Action backwards
              {
                int a = (lvlobjb[objindex] >> 2) & 7;
                a--;
                a &= 7;
                lvlobjb[objindex] &= 0xe3;
                lvlobjb[objindex] |= (a << 2);
              }
              // Spawnpoint default values: add 0, and 15, half speed
              if ((lvlobjb[objindex] & 0x1c) == 0x1c)
              {
                if ((!lvlobjd1[objindex]) && (!lvlobjd2[objindex]))
                {
                  lvlobjd1[objindex] = 0x7f;
                  lvlobjd2[objindex] = 0xf;
                }
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
                  lvlobjd2[objindex] &= 0x0f;
                  lvlobjd2[objindex] |= hex << 4;
                  break;

                  case 1:
                  lvlobjd2[objindex] &= 0xf0;
                  lvlobjd2[objindex] |= hex;
                  break;

                  case 2:
                  lvlobjd1[objindex] &= 0x0f;
                  lvlobjd1[objindex] |= hex << 4;
                  break;

                  case 3:
                  lvlobjd1[objindex] &= 0xf0;
                  lvlobjd1[objindex] |= hex;
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
          if ((dataeditmode) && (objfound))
          {
            int action = (lvlobjb[objindex] & 0x1c) >> 2;
            switch(action)
            {
              case 1:
              case 2:
              case 4:
              for (c = 0; c < NUMLVLOBJ; c++)
              {
                if ((lvlobjx[c] == x) && ((lvlobjy[c] & 0x7f) == y))
                {
                  lvlobjd1[objindex] = c;
                  if (action <= 2)
                    lvlobjd2[objindex] = levelnum;
                  break;
                }
              }
              break;
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
    if (k == KEY_F11) exportmap();

    gfx_fillscreen(254);
    drawmap();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void zone_mainloop(void)
{
  findusedblocksandchars();

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
    if (k == KEY_TAB)
    {
      if (editmode != EM_CHARS)
        editmode = EM_CHARS;
      else
        editmode = EM_MAP;
      break;
    }
    if (k == KEY_LEFT) mapx--;
    if (k == KEY_RIGHT) mapx++;
    if (k == KEY_UP) mapy--;
    if (k == KEY_DOWN) mapy++;
    if (mapx < 0) mapx = 0;
    if (mapy < 0) mapy = 0;
    if (mapx > (mapsx-10)) mapx = mapsx-10;
    if (mapy > (mapsy-5)) mapy = mapsy-5;
    if ((k == KEY_1) || (k == KEY_Z))
    {
      zonenum--;
      if (zonenum < 0) zonenum = NUMZONES-1;
    }
    if ((k == KEY_2) || (k == KEY_X))
    {
      zonenum++;
      if (zonenum >= NUMZONES) zonenum = 0;
    }
    if (k == KEY_S)
    {
      zonebg1[zonenum] ^= 128;
    }
    if (k == KEY_N)
    {
      zonemusic[zonenum]--;
    }
    if (k == KEY_M)
    {
      zonemusic[zonenum]++;
    }
    if (k == KEY_V)
    {
      zonemusic[zonenum] -= 4;
    }
    if (k == KEY_B)
    {
      zonemusic[zonenum] += 4;
    }
    if (k == KEY_DEL)
    {
      zonex[zonenum] = 0;
      zoney[zonenum] = 0;
    }
    if (k == KEY_R && shiftdown)
    {
      if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
      {
        int x = mapx+mousex/32;
        int y = mapy+mousey/32;
        relocatezone(x,y);
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

    if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
    {
      int x = mapx+mousex/32;
      int y = mapy+mousey/32;

      if (mouseb == 1)
      {
        if (findzone(x,y) < NUMZONES)
        {
          zonenum = findzone(x,y);
        }
      }
      if (mouseb == 2)
      {
        zonex[zonenum] = x;
        zoney[zonenum] = y;
        zonel[zonenum] = x;
        zoner[zonenum] = x+1;
        zoneu[zonenum] = y;
        zoned[zonenum] = y+1;
        updatezone(zonenum);
        zonex[zonenum] = (zonel[zonenum]+zoner[zonenum])/2;
        zoney[zonenum] = (zoneu[zonenum]+zoned[zonenum])/2;
        if ((zonel[zonenum] == zoner[zonenum]-1) &&
            (zoneu[zonenum] == zoned[zonenum]-1))
        {
          zonex[zonenum] = 0; // Delete zone
          zoney[zonenum] = 0;
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportmap();

    gfx_fillscreen(254);
    drawmap();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}


void map_mainloop(void)
{
  findusedblocksandchars();

  for (;;)
  {
    win_getspeed(70);
    k = kbd_getkey();
    ascii = kbd_getascii();
    mouseupdate();
    if (ascii == 27)
    {
      confirmquit();
      break;
    }
    if (k == KEY_TAB)
    {
      if (editmode != EM_CHARS)
        editmode = EM_CHARS;
      else
        editmode = EM_MAP;
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
      blockselectmode ^= 1;
    if ((k == KEY_Z) && (blocknum > 0))
      blocknum--;
    if ((k == KEY_X) && (blocknum < BLOCKS-1))
      blocknum++;
    if (k == KEY_Q)
      memcpy(bcopybuffer, &blockdata[blocknum*16],16);
    if (k == KEY_W)
    {
      memcpy(&blockdata[blocknum*16],bcopybuffer,16);
      findusedblocksandchars();
    }

    if (!blockselectmode)
    {
      if (k == KEY_LEFT) mapx--;
      if (k == KEY_RIGHT) mapx++;
      if (k == KEY_UP) mapy--;
      if (k == KEY_DOWN) mapy++;
      if (mapx < 0) mapx = 0;
      if (mapy < 0) mapy = 0;
      if (mapx > (mapsx-10)) mapx = mapsx-10;
      if (mapy > (mapsy-5)) mapy = mapsy-5;

      if (k == KEY_F)
      {
        int c;
        for (c = 0; c < mapsx*mapsy; c++)
        {
          if (mapdata[c] == blocknum)
          {
            int x = c % mapsx;
            int y = c / mapsx;
            mapx = x - 5;
            if (mapx < 0) mapx = 0;
            mapy = y - 2;
            if (mapy < 0) mapy = 0;
          }
        }
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
                    finemapcopybuffer[i] = blockdata[b*16+yc*4+xc];
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
              mapcopybuffer[i] = mapdata[y*255+x];
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
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160) &&
            (mapcopyx) && (mapcopyy))
        {
          int x,y;
          int i = 0;

          for (y = 0; y < mapcopyy; y++)
          {
            for (x = 0; x < mapcopyx; x++)
            {
              int rx = x + mapx + mousex/32;
              int ry = y + mapy + mousey/32;
              if ((rx < 255) & (ry < 255)) mapdata[ry*255+rx] = mapcopybuffer[i];
              i++;
            }
          }
        }
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160) &&
            (finemapcopyx) && (finemapcopyy))
        {
          int x,y;
          int i = 0;
          int newblocks;

          findusedblocksandchars();

          newblocks = maxusedblocks;

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
                  if (b < maxusedblocks && newblocks < 256)
                  {
                      copyblock(b, newblocks);
                      mapdata[yb*mapsx+xb] = newblocks;
                      b = newblocks;
                      newblocks++;
                  }

                  blockdata[b*16+yc*4+xc] = finemapcopybuffer[i];
                  i++;
              }
          }

          optimizeblocks();
        }

        findusedblocksandchars();
      }
      if ((k == KEY_G) || (ascii == 13))
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
        {
          blocknum=mapdata[mapx+mousex/32+(mapy+mousey/32)*255];
        }
      }
      if (ascii == 13)
      {
        initblockeditmode(1);
        break;
      }
      if (mouseb & 1)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
        {
          mapdata[mapx+mousex/32+(mapy+mousey/32)*255]=blocknum;
        }
        findusedblocksandchars();
      }
      if ((mouseb & 2) && (!prevmouseb))
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
        {
          finemarkmode = 0;
          switch(markmode)
          {
            case 0:
            markx1 = mapx+mousex/32;
            marky1 = mapy+mousey/32;
            markmode = 1;
            break;

            case 1:
            markx2 = mapx+mousex/32;
            marky2 = mapy+mousey/32;
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

      if (k == KEY_M)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
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
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
        {
          blocknum = mousey/32*10+mousex/32+bsy*10;
          if (blocknum > 255)
            blocknum = 255;
        }
      }
      if (k == KEY_S)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
        {
          int blocknum2 = mousey/32*10+mousex/32+bsy*10;
          swapblocks(blocknum, blocknum2);
        }
      }
      if (k == KEY_I || k == KEY_INS)
      {
        if ((mousex >= 0) && (mousex < 320) && (mousey >= 0) && (mousey < 160))
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
    if (k == KEY_F11) exportmap();

    gfx_fillscreen(254);
    if (!blockselectmode)
      drawmap();
    else
      drawblocks();
    gfx_drawsprite(mousex, mousey, 0x00000021);
    gfx_updatepage();
  }
}

void drawblocks(void)
{
  int x,y;

  for (y = 0; y < 5; y++)
  {
    for (x = 0; x < 10; x++)
    {
      int blk = y*10+x+bsy*10;
      if (blk < 256)
      {
        drawblock(x*32,y*32,blk);
        if (blk == blocknum)
        {
          gfx_line(x*32,y*32,x*32+31,y*32,1);
          gfx_line(x*32,y*32,x*32,y*32+31,1);
          gfx_line(x*32+31,y*32,x*32+31,y*32+31,1);
          gfx_line(x*32,y*32+31,x*32+31,y*32+31,1);
        }
        if (blk && blk < maxusedblocks && blockusecount[blk] < 3)
        {
          sprintf(textbuffer, "%d", blockusecount[blk]);
          printtext_color(textbuffer, x*32, y*32+22,SPR_FONTS,COL_WHITE);
        }
      }
    }
  }

  if (mousey < 160)
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

  drawblock(320-32,160,blocknum);
  sprintf(textbuffer, "BLOCK %03d", blocknum);
  printtext_color(textbuffer, 200,175,SPR_FONTS,COL_WHITE);
  sprintf(textbuffer, "(%d)", blockusecount[blocknum]);
  printtext_color(textbuffer, 200,185,SPR_FONTS,COL_WHITE);
}

void drawmap(void)
{
  int y,x;

  for (y = 0; y < 5; y++)
  {
    for (x = 0; x < 10; x++)
    {
      drawblock(x*32,y*32,mapdata[mapx+x+(mapy+y)*255]);
    }
  }
  if (editmode == EM_MAP)
  {
    int l,r,u,d;

    if (finemarkmode)
    {
      l = finemarkx1 - mapx*4;
      u = finemarky1 - mapy*4;
      if ((l >= 0) && (u >= 0) && (l < 40) && (u < 20))
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
      if ((r >= 0) && (d >= 0) && (r < 40) && (d < 20))
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

      if ((l >= 0) && (u >= 0) && (l < 10) && (u < 5))
      {
        gfx_line(l*32,u*32,l*32+31,u*32,1);
        gfx_line(l*32,u*32+1,l*32+31,u*32+1,1);
        gfx_line(l*32,u*32,l*32,u*32+31,1);
        gfx_line(l*32+1,u*32,l*32+1,u*32+31,1);
      }
    }
    if (markmode == 2)
    {
      r = markx2 - mapx;
      d = marky2 - mapy;

      if ((r >= 0) && (d >= 0) && (r < 10) && (d < 5))
      {
        gfx_line(r*32+30,d*32,r*32+30,d*32+31,1);
        gfx_line(r*32+31,d*32,r*32+31,d*32+31,1);
        gfx_line(r*32,d*32+30,r*32+31,d*32+30,1);
        gfx_line(r*32,d*32+31,r*32+31,d*32+31,1);
      }
    }

    sprintf(textbuffer, "XPOS %02X (%d)", mapx+mousex/32, mapx+mousex/32);
    printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "YPOS %02X (%d)", mapy+mousey/32, mapy+mousey/32);
    printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);
    drawblock(320-32,160,blocknum);
    sprintf(textbuffer, "BLOCK %03d", blocknum);
    printtext_color(textbuffer, 200,175,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "(%d)", blockusecount[blocknum]);
    printtext_color(textbuffer, 200,185,SPR_FONTS,COL_WHITE);
  }
  if (editmode == EM_ZONE)
  {
    int l,r,u,d,x,y;

    l = zonel[zonenum] - mapx;
    r = zoner[zonenum] - mapx - 1;
    u = zoneu[zonenum] - mapy;
    d = zoned[zonenum] - mapy - 1;
    x = zonex[zonenum] - mapx;
    y = zoney[zonenum] - mapy;

    if ((zonex[zonenum]) || (zoney[zonenum]))
    {
      if ((l >= 0) && (u >= 0) && (l < 10) && (u < 5))
      {
        gfx_line(l*32,u*32,l*32+31,u*32,1);
        gfx_line(l*32,u*32+1,l*32+31,u*32+1,1);
        gfx_line(l*32,u*32,l*32,u*32+31,1);
        gfx_line(l*32+1,u*32,l*32+1,u*32+31,1);
      }
      if ((r >= 0) && (d >= 0) && (r < 10) && (d < 5))
      {
        gfx_line(r*32+30,d*32,r*32+30,d*32+31,1);
        gfx_line(r*32+31,d*32,r*32+31,d*32+31,1);
        gfx_line(r*32,d*32+30,r*32+31,d*32+30,1);
        gfx_line(r*32,d*32+31,r*32+31,d*32+31,1);
      }
      if ((x >= 0) && (y >= 0) && (x < 10) && (y < 5))
      {
        gfx_line(x*32+8,y*32+8,x*32+24,y*32+24,1);
        gfx_line(x*32+24,y*32+8,x*32+8,y*32+24,1);
      }
    }
    sprintf(textbuffer, "XPOS %02X", mapx+mousex/32);
    printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "YPOS %02X", mapy+mousey/32);
    printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "COLORS %01X %01X %01X", zonebg1[zonenum] & 15, zonebg2[zonenum], zonebg3[zonenum]);
    if (zonebg1[zonenum] & 128)
      strcat(textbuffer, " (NOSAVE)");
    printtext_color(textbuffer, 80,175,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "MUSIC %02X-%01X", zonemusic[zonenum] / 4, zonemusic[zonenum] % 4);
    printtext_color(textbuffer, 80,185,SPR_FONTS,COL_WHITE);

    if ((zonex[zonenum]) || (zoney[zonenum]))
    {
      sprintf(textbuffer, "ZONE %02X (%02X,%02X)-(%02X,%02X)", zonenum, zonel[zonenum],zoneu[zonenum],zoner[zonenum]-1,zoned[zonenum]-1);
    }
    else
    {
      sprintf(textbuffer, "UNUSED ZONE %02X", zonenum);
    }
    printtext_color(textbuffer, 80,165,SPR_FONTS,COL_WHITE);
  }

  if (editmode == EM_LEVEL)
  {
    int x,y,c;
    if (randomeditmode)
    {
      int sp = 0;
      for (c = 0; c < NUMRANDOMACT; c++)
      {
        sprintf(textbuffer, "%01X: T%02X (%s) W%02X (%s) P%02X %s", c, randomactt[c], actorname[randomactt[c]], randomactw[c] & 0x3f, itemname[randomactw[c] & 0x3f], randomactp[c], spawnmodename[randomactw[c] >> 6]);
        if (c != randomactnum) printtext_color(textbuffer, 0,10*c,SPR_FONTS,COL_WHITE);
        else printtext_color(textbuffer,0,10*c,SPR_FONTS,COL_HIGHLIGHT);
      }
      for (c = 0; c < NUMLVLOBJ; c++)
      {
        if ((lvlobjb[c] & 0x1c) == 0x1c) sp++;
      }
      sprintf(textbuffer, "SPAWNERS IN LEVEL: %d", sp);
      printtext_color(textbuffer,0,175,SPR_FONTS,COL_WHITE);
    }
    else
    {
      if (actfound)
      {
        int a = actindex;

        if (lvlactt[a] < 128)
        {
          sprintf(textbuffer, "ACTOR %02X (%s) (%02X,%02X) ", lvlactt[a], actorname[lvlactt[a]], lvlactx[a], lvlacty[a] & 0x7f);
          if (lvlacty[a] & 128) strcat(textbuffer, "(HIDDEN)");
          printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);
          if (lvlactw[a] & 128) sprintf(textbuffer, "LEFT");
          else sprintf(textbuffer, "RIGHT");
          printtext_color(textbuffer, 256,165,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "MODE:%1X (%s)", lvlactf[a] & 0xf, modename[lvlactf[a] & 0xf]);
          printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);
          sprintf(textbuffer, "WPN:%02X (%s)", lvlactw[a] & 0x7f, itemname[lvlactw[a] & 0x7f]);
          printtext_color(textbuffer, 0,185,SPR_FONTS,COL_WHITE);
        }
        else
        {
          sprintf(textbuffer, "ITEM %02X (%s) (%02X,%02X) ", lvlactt[a] & 0x7f, itemname[lvlactt[a]-128], lvlactx[a], lvlacty[a] & 0x7f);
          if (lvlacty[a] & 128) strcat(textbuffer, "(HIDDEN)");
          printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);
          if (lvlactw[a] != 255)
          {
            sprintf(textbuffer, "COUNT:%d", lvlactw[a]);
          }
          else
          {
            sprintf(textbuffer, "COUNT:DEFAULT");
          }
          printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);
        }
      }
      else
      {
        if (objfound)
        {
          int o = objindex;
          sprintf(textbuffer, "OBJ %02X (%02X,%02X)", o, lvlobjx[o], lvlobjy[o] & 0x7f);
          printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);

          sprintf(textbuffer, "HSIZE:%d ", (lvlobjb[o] & 64) ? 2 : 1);

          if (lvlobjy[o] & 128)
          {
            strcat(textbuffer, "(ANIM)");
          }
          printtext_color(textbuffer, 128,165,SPR_FONTS,COL_WHITE);

          sprintf(textbuffer, "MODE:%s", modetext[(lvlobjb[o] & 0x3)]);
          if (lvlobjb[o] & 32) strcat(textbuffer, "+AUTO-DEACT");
          printtext_color(textbuffer, 128,175,SPR_FONTS,COL_WHITE);

          sprintf(textbuffer, "TYPE:%s (%02X%02X)", actiontext[(lvlobjb[o] & 0x1c) >> 2], lvlobjd2[o], lvlobjd1[o]);

          if (dataeditmode) dataeditflash++;

          if ((dataeditmode) && (dataeditflash & 16))
            printtext_color(textbuffer, 128,185,SPR_FONTS,COL_HIGHLIGHT);
          else
            printtext_color(textbuffer, 128,185,SPR_FONTS,COL_WHITE);
        }
      }
      if ((!objfound) && (!actfound))
      {
        int o = 0;
        int a = 0;
        if (actnum < 128)
        {
          sprintf(textbuffer, "ACTOR %02X (%s)", actnum, actorname[actnum]);
        }
        else
        {
          sprintf(textbuffer, "ITEM %02X (%s)", actnum-128, itemname[actnum-128]);
        }
        printtext_color(textbuffer, 0,165,SPR_FONTS,COL_WHITE);
        sprintf(textbuffer, "LEVEL %02X", levelnum);
        printtext_color(textbuffer, 192,165,SPR_FONTS,COL_WHITE);

        for (c = 0; c < NUMLVLOBJ; c++)
        {
          if ((lvlobjx[c]) || (lvlobjy[c])) o++;
        }
        for (c = 0; c < NUMLVLACT; c++)
        {
          if (lvlactt[c]) a++;
        }
        sprintf(textbuffer, "OBJECTS %d", o);
        printtext_color(textbuffer, 0,175,SPR_FONTS,COL_WHITE);
        sprintf(textbuffer, "ACTORS %d", a);
        printtext_color(textbuffer, 0,185,SPR_FONTS,COL_WHITE);
      }
      for (c = 0; c < NUMLVLOBJ; c++)
      {
        if ((lvlobjx[c]) || (lvlobjy[c]))
        {
          x = lvlobjx[c] - mapx;
          y = (lvlobjy[c] & 0x7f) - mapy;
          if ((x >= 0) && (x < 10) && (y >= 0) && (y < 5))
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

          if ((x >= 0) && (x < 10) && (y >= 0) && (y < 5))
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
      if (editmode != EM_CHARS)
        editmode = EM_CHARS;
      else
        editmode = EM_MAP;
      break;
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
    if (k == KEY_U)
    {
    }
    if (k == KEY_C)
    {
      memset(&chardata[charnum*8],0,8);
      chinfo[charnum]=0;
      chcol[charnum] &= 0xf;
    }
    if (!shiftdown && !ctrldown)
    {
      if (k == KEY_1) chinfo[charnum] ^= 1;
      if (k == KEY_2) chinfo[charnum] ^= 2;
      if (k == KEY_3) chinfo[charnum] ^= 4;
      if (k == KEY_4) chinfo[charnum] ^= 8;
      if (k == KEY_5) chinfo[charnum] ^= 16;
      if (k == KEY_6) chinfo[charnum] ^= 32;
      if (k == KEY_7) chinfo[charnum] ^= 64;
      if (k == KEY_8) chinfo[charnum] ^= 128;
    }
    else if (ctrldown)
    {
      if (k == KEY_0) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x0; }
      if (k == KEY_1) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x1; }
      if (k == KEY_2) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x2; }
      if (k == KEY_3) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x3; }
      if (k == KEY_4) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x4; }
      if (k == KEY_5) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x5; }
      if (k == KEY_6) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x6; }
      if (k == KEY_7) { chcol[charnum] &= 0xf8; chcol[charnum] |= 0x7; }
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
      chinfo[charnum] += 32;
    }

    /*
    if (k == KEY_A) // Global multicolor toggle
    {
      int c;
      for (c = 0; c < 256; c++)
        chcol[c] ^= 8;
      findusedblocksandchars();
    }
    */

    if (k == KEY_M)
    {
      chcol[charnum] ^= 8;
    }
    if (k == KEY_F)
    {
      chcol[charnum] ^= 64;
    }
    if (k == KEY_V)
    {
      int y,x;
      char andtable[4] = {0xfc, 0xf3, 0xcf, 0x3f};
      for (y = 0; y < 8; y++)
      {
        for (x = 0; x < 4; x++)
        {
          char bit = (chardata[charnum*8+y] >> (x*2)) & 3;
          if (bit == 2) bit = 1;
          else if (bit == 1) bit = 2;
          chardata[charnum*8+y] &= andtable[x];
          chardata[charnum*8+y] |= (bit << (x*2));
        }
      }
    }

    if (k == KEY_R)
    {
      int y;
      for (y = 0; y < 8; y++)
      {
        chardata[charnum*8+y] ^= 0xff;
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
          char bit = (chardata[charnum*8+y] >> (x*2)) & 3;
          if (bit == 3) bit = 1;
          else if (bit == 1) bit = 3;
          chardata[charnum*8+y] &= andtable[x];
          chardata[charnum*8+y] |= (bit << (x*2));
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
          char bit = (chardata[charnum*8+y] >> (x*2)) & 3;
          if (bit == 3) bit = 2;
          else if (bit == 2) bit = 3;
          chardata[charnum*8+y] &= andtable[x];
          chardata[charnum*8+y] |= (bit << (x*2));
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
      memcpy(copybuffer, &chardata[charnum*8],8);
      copychcol = chcol[charnum];
      copychinfo = chinfo[charnum];
    }
    if (k == KEY_T)
    {
      memcpy(&chardata[charnum*8],copybuffer,8);
      chcol[charnum] = copychcol;
      chinfo[charnum] = copychinfo;
    }
    if (k == KEY_Q)
    {
      memcpy(bcopybuffer, &blockdata[blocknum*16],16);
    }
    if (k == KEY_W)
    {
      memcpy(&blockdata[blocknum*16],bcopybuffer,16);
      findusedblocksandchars();
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
        charnum = blockdata[blocknum * 16 + mousey / 8 * 4 + (mousex - 170) / 8];
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
        if (mousex < 160 && mousey < 160)
        {
          charnum = blockdata[blocknum * 16 + mousey / 40 * 4 + mousex / 40];
        }
      }
    }

    if (k == KEY_F1) loadchars();
    if (k == KEY_F2) savechars();
    if (k == KEY_F3) loadblocks();
    if (k == KEY_F4) saveblocks();
    if (k == KEY_F9) loadalldata();
    if (k == KEY_F10) savealldata();
    if (k == KEY_F11) exportmap();
    if (k == KEY_LEFT) scrollcharleft();
    if (k == KEY_RIGHT) scrollcharright();
    if (k == KEY_UP) scrollcharup();
    if (k == KEY_DOWN) scrollchardown();
    if (k == KEY_L) lightenchar();
    if (k == KEY_D) darkenchar();

    changecol();
    changechar();
    editchar();
    editblock();
    gfx_fillscreen(254);
    drawgrid();
    drawblock(170,0,blocknum);
    if (!blockeditmode)
    {
      drawimage();
      if (flash < 16) gfx_drawsprite((charnum&31)*8+32, 128+(charnum/32)*8, 0x00000022);
      if (chinfo[charnum] & 1)
      {
        int x;
        int slopeindex = (chinfo[charnum] >> 5) << 3;
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

  if ((chcol[charnum]&15) < 8) c=1;
  else c = 2;

  while (c)
  {
    Uint8 *ptr = &chardata[charnum*8];
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

  if ((chcol[charnum]&15) < 8) c=1;
  else c = 2;

  while (c)
  {
    Uint8 *ptr = &chardata[charnum*8];
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
  Uint8 *ptr = &chardata[charnum*8];
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
  Uint8 *ptr = &chardata[charnum*8];
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

  if (chcol[charnum] < 8) return;

  ints[0] = intensity[zonebg1[zonenum]];
  ints[1] = intensity[zonebg2[zonenum]];
  ints[2] = intensity[zonebg3[zonenum]];
  ints[3] = intensity[chcol[charnum] & 7];
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

  Uint8 *ptr = &chardata[charnum*8];
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

  if (chcol[charnum] < 8) return;

  ints[0] = intensity[zonebg1[zonenum]];
  ints[1] = intensity[zonebg2[zonenum]];
  ints[2] = intensity[zonebg3[zonenum]];
  ints[3] = intensity[chcol[charnum] & 7];
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

  Uint8 *ptr = &chardata[charnum*8];
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
  Uint8 *ptr = &chardata[charnum*8];
  char v = 0;
  int x,y;
  int xc = 0,yc = 0;

  if (!blockeditmode)
  {
    if ((chcol[charnum]&15) < 8)
    {
      for (y = 0; y < 8; y++)
      {
        unsigned data = *ptr;

        for (x = 7; x >= 0; x--)
        {
          if (data & 1) v = (chcol[charnum]&15);
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
            v = zonebg2[zonenum];
            break;

            case 2:
            v = zonebg3[zonenum];
            break;

            case 3:
            v = (chcol[charnum]&15)-8;
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
        int ch = blockdata[blocknum*16+yc*4+xc];
        ptr = &chardata[ch * 8];
        if ((chcol[ch]&15) < 8)
        {
          for (y = 0; y < 8; y++)
          {
            unsigned data = *ptr;

            for (x = 7; x >= 0; x--)
            {
              if (data & 1) v = (chcol[ch]&15);
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
                v = zonebg2[zonenum];
                break;

                case 2:
                v = zonebg3[zonenum];
                break;

                case 3:
                v = (chcol[ch]&15)-8;
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
      if ((chinfo[charnum] >> (7-x)) & 1) gfx_drawsprite(x*4, 41, 0x00000023);
      else gfx_drawsprite(x*4, 41, 0x00000024);
    }
    sprintf(textbuffer, "CHAR %03d", charnum);
    printtext_color(textbuffer, 0,50,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "BLOCK %03d (%d)", blocknum, blockusecount[blocknum]);
    printtext_color(textbuffer, 0,65,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "ZONE %02X", zonenum);
    printtext_color(textbuffer, 0,80,SPR_FONTS,COL_WHITE);
    sprintf(textbuffer, "BLOCKS %03d", maxusedblocks);
    printtext_color(textbuffer, 0,110,SPR_FONTS,COL_WHITE);
    if ((chcol[charnum]&15) < 8)
    {
      printtext_color("SINGLE",0,95,SPR_FONTS,COL_WHITE);
    }
    else
    {
      printtext_color("MULTI",0,95,SPR_FONTS,COL_WHITE);
    }
    if (chcol[charnum] & 128)
    {
      printtext_color("NOPATH",64,95,SPR_FONTS,COL_WHITE);
    }
    if (chcol[charnum] & 64)
    {
      printtext_color("FIXED",64,95,SPR_FONTS,COL_WHITE);
    }
  }
  else
  {
    for (x = 0; x < 8; x++)
    {
      if ((chinfo[charnum] >> (7-x)) & 1) gfx_drawsprite(x*4, 161, 0x00000023);
      else gfx_drawsprite(x*4, 161, 0x00000024);
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
  drawcbar(220,65,zonebg2[zonenum]);
  drawcbar(220,80,zonebg3[zonenum]);
  drawcbar(220,95,chcol[charnum]&7);
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
  bptr = &blockdata[blocknum*16+(mousey/8)*4+((mousex-170)/8)];
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
    charnum = blockdata[blocknum*16 + mousex / 40 + (mousey / 40) * 4];
  }

  ptr = &chardata[charnum*8];

  y = (mousey % 40) / 5;
  if ((chcol[charnum]&15) < 8)
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
          zonebg2[zonenum]++;
          zonebg2[zonenum] &= 15;
          break;
          case 2:
          zonebg3[zonenum]++;
          zonebg3[zonenum] &= 15;
          break;
          case 3:
          {
            unsigned char highbits = chcol[charnum] & 0xc0;
            chcol[charnum]++;
            chcol[charnum] &= 15;
            chcol[charnum] |= highbits;
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
          zonebg2[zonenum]--;
          zonebg2[zonenum] &= 15;
          break;
          case 2:
          zonebg3[zonenum]--;
          zonebg3[zonenum] &= 15;
          break;
          case 3:
          {
            unsigned char highbits = chcol[charnum] & 0xc0;
            chcol[charnum]--;
            chcol[charnum] &= 15;
            chcol[charnum] |= highbits;
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
  mapdata = malloc(255*255);
  if (!mapdata) return 0;
  memset(mapdata,0,255*255);
  chardata = malloc(2048);
  if (!chardata) return 0;
  memset(chardata,0,2048);
  memset(chinfo,0,256);
  blockdata = malloc(4096);
  memset(blockdata,0,4096);
  memset(chcol,9,256);
  if (!blockdata) return 0;
  for (c = 0; c < NUMZONES; c++)
  {
    zonex[c] = 0;
    zoney[c] = 0;
    zonel[c] = 0;
    zoner[c] = 0;
    zoneu[c] = 254;
    zoned[c] = 255;
    zonebg1[c] = 0;
    zonebg2[c] = 11;
    zonebg3[c] = 12;
    zonemusic[c] = 0;
  }
  for (c = 0; c < NUMLVLOBJ; c++)
  {
    lvlobjx[c] = 0;
    lvlobjy[c] = 0;
    lvlobjb[c] = 0;
    lvlobjd1[c] = 0;
    lvlobjd2[c] = 0;
  }
  for (c = 0; c < NUMLVLACT; c++)
  {
    lvlactx[c] = 0;
    lvlacty[c] = 0;
    lvlactf[c] = 0;
    lvlactt[c] = 0;
    lvlactw[c] = 0;
  }
  memset(randomactt,0,NUMRANDOMACT);
  memset(randomactw,0,NUMRANDOMACT);
  memset(randomactp,0xff,NUMRANDOMACT);;
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
        int ch = blockdata[16*blocknum+c];
        if (!(chcol[ch] & 64))
        {
          copychar(ch, e);
          blockdata[16*blocknum+c] = e;
          e--;
        }
      }
    }

    blockeditmode = 1;
    blockeditnum = blocknum;
    oldchar = charnum;
    charnum = blockdata[16*blocknum+c];
    findusedblocksandchars();
    editmode = EM_CHARS;
    frommap = fm;
}

void findanimatingblocks(void)
{
  int c;
  for (c = 0; c < 256; c++) animatingblock[c] = 0;

  for (c = 0; c < NUMLVLOBJ; c++)
  {
    if ((lvlobjy[c] & 0x80) && (lvlobjx[c] || lvlobjy[c]))
    {
      animatingblock[mapdata[lvlobjx[c] + mapsx * (lvlobjy[c] & 0x7f)]] = 1;
      if ((lvlobjb[c] & 64) && ((lvlobjy[c] & 0x7f) > 0))
      {
        animatingblock[mapdata[lvlobjx[c] + mapsx * ((lvlobjy[c] & 0x7f)-1)]] = 1;
      }
    }
  }
}

void findusedblocksandchars(void)
{
  int c;
  for (c = 255; c > 0; c--)
  {
    int d;
    for (d = 0; d < 16; d++)
    {
      if (blockdata[c*16+d]) goto FOUND;
    }
  }
  FOUND:
  maxusedblocks = c+1;
  for (c = 0; c < 256; c++) charused[c] = 0;
  for (c = 0; c < maxusedblocks*16; c++)
  {
    charused[blockdata[c]] = 1;
  }

  findanimatingblocks();

  for (c = 0; c < 256; c++)
    blockusecount[c] = 0;
  for (c = 0; c < mapsx*mapsy; c++)
  {
    int blk = mapdata[c];
    if (blk)
    {
      blockusecount[blk]++;
      if (animatingblock[blk])
        blockusecount[blk+1]++;
    }
  }
}

void transferchar(int c, int d)
{
  int e;
  if (c == d) return;
  for (e = 0; e < 8; e++)
  {
    chardata[d*8+e] = chardata[c*8+e];
    chardata[c*8+e] = 0;
  }
  for (e = 0; e < BLOCKS*16; e++)
  {
    if (blockdata[e] == c) blockdata[e] = d;
  }
  chinfo[d] = chinfo[c];
  chinfo[c] = 0;
  chcol[d] = chcol[c];
  chcol[c] = 9;

}

void transferblock(int c, int d)
{
  int e;
  if (c == d) return;
  for (e = 0; e < 16; e++)
  {
    blockdata[d*16+e] = blockdata[c*16+e];
    blockdata[c*16+e] = 0;
  }
  for (e = 0; e < mapsx * mapsy; e++)
  {
    if (mapdata[e] == c)
      mapdata[e] = d;
  }
}

void copyblock(int c, int d)
{
  int e;
  if (c == d) return;
  for (e = 0; e < 16; e++)
  {
    blockdata[d*16+e] = blockdata[c*16+e];
  }
}

void swapblocks(int c, int d)
{
  int e;
  unsigned char temp[16];

  if (c == d) return;

  memcpy(temp, &blockdata[c*16], 16);
  memcpy(&blockdata[c*16], &blockdata[d*16], 16);
  memcpy(&blockdata[d*16], temp, 16);

  for (e = 0; e < mapsx * mapsy; e++)
  {
    if (mapdata[e] == c)
      mapdata[e] = d;
    else if (mapdata[e] == d)
      mapdata[e] = c;
  }

  findusedblocksandchars();
}

void insertblock(int c, int d)
{
  int e;
  unsigned char temp[16];

  if (c == d) return;

  memcpy(temp, &blockdata[c*16], 16);
  memset(&blockdata[c*16], 0, 16);
  memmove(&blockdata[d*16+16], &blockdata[d*16], (255-d)*16);
  memcpy(&blockdata[d*16], temp, 16);

  for (e = 0; e < mapsx * mapsy; e++)
  {
    if (mapdata[e] == c)
      mapdata[e] = d;
    else if (mapdata[e] >= d)
      mapdata[e]++;
  }
  
  findusedblocksandchars();
}

void copychar(int c, int d)
{
  int e;
  for (e = 0; e < 8; e++)
  {
    chardata[d*8+e] = chardata[c*8+e];
  }
  chinfo[d] = chinfo[c];
  chcol[d] = chcol[c];
}


int findsamechar(int c, int d)
{
  int e;
  int charcolorused = 0;
  if (c == d) return 0;

  for (e = 0; e < 8; e++)
  {
    int v = chardata[c*8+e];
    if (v != chardata[d*8+e]) return 0;
    if ((v & 0xc0) == 0xc0) charcolorused = 1;
    if ((v & 0x30) == 0x30) charcolorused = 1;
    if ((v & 0x0c) == 0x0c) charcolorused = 1;
    if ((v & 0x03) == 0x03) charcolorused = 1;
  }

  if (chinfo[c] != chinfo[d]) return 0;
  if (chcol[c] & 64) return 0; // No-optimize flag, is not duplicate
  if (chcol[d] & 64) return 0; // No-optimize flag, is not duplicate
  if (chcol[c] < 8 && chcol[c] != chcol[d]) return 0;
  if (chcol[c] >= 8 && charcolorused && chcol[c] != chcol[d]) return 0;

  return 1;
}

int findsameblock(int c, int d)
{
  int e;
  if (c == d) return 0;
  for (e = 0; e < 16; e++)
  {
    if (blockdata[c*16+e] != blockdata[d*16+e]) return 0;
  }

  // If block is used in animating levelobject, do not consider same
  if (animatingblock[c] || animatingblock[d] || (c > 0 && animatingblock[c-1]) || (d > 0 && animatingblock[d-1]))
    return 0;

  return 1;
}

void relocatezone(int x, int y)
{
  int sx, sy, oldx, oldy, ox, oy, c, bx, by;
  if (!zonex[zonenum] && !zoney[zonenum])
    return;
  sx = zoner[zonenum] - zonel[zonenum];
  sy = zoned[zonenum] - zoneu[zonenum];
  if (x + sx > 256) return;
  if (y + sy > 128) return;
  unsigned char* tempmapdata = malloc(sx*sy);
  oldx = zonel[zonenum];
  oldy = zoneu[zonenum];
  ox = x - oldx;
  oy = y - oldy;
  // Relocate objects & actors within zone
  for (c = 0; c < NUMLVLOBJ; c++)
  {
    if ((lvlobjx[c]) || (lvlobjy[c]))
    {
      if (lvlobjx[c] >= zonel[zonenum] && lvlobjx[c] < zoner[zonenum] && (lvlobjy[c] & 0x7f) >= zoneu[zonenum] && (lvlobjy[c] & 0x7f) < zoned[zonenum])
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
      if (lvlactx[c] >= zonel[zonenum] && lvlactx[c] < zoner[zonenum] && (lvlacty[c] & 0x7f) >= zoneu[zonenum] && (lvlacty[c] & 0x7f) < zoned[zonenum])
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
      tempmapdata[c++] = mapdata[(by+zoneu[zonenum])*mapsx + bx+zonel[zonenum]];
      mapdata[(by+zoneu[zonenum])*mapsx + bx+zonel[zonenum]] = 0;
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
  zonel[zonenum] = x;
  zoner[zonenum] = x+sx;
  zoneu[zonenum] = y;
  zoned[zonenum] = y+sy;
  zonex[zonenum] = (x+sx)/2;
  zoney[zonenum] = (y+sy)/2;

  free(tempmapdata);
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

  updateallzones();
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
    if (chcol[c] & 64)
    {
      memcpy(&newchardata[c*8], &chardata[c*8], 8);
      newchcol[c] = chcol[c];
      newchinfo[c] = chinfo[c];
      newcharused[c] = 1;
      charmapping[c] = c;
    }
  }

  // Process blocks & chars
  newblk = 0;
  for (c = 0; c < 256; c++)
  {
    if (!c || blockusecount[c] > 0)
    {
      newblockused[newblk] = 1;
      blockmapping[c] = newblk;
      for (d = 0; d < 16; d++)
      {
        unsigned char ch = blockdata[c*16+d];
        if (charmapping[ch] >= 0)
          newblockdata[newblk*16+d] = charmapping[ch];
        else
        {
          unsigned char newch = 0;
          while (newcharused[newch])
            newch++;

          for (e = 0; e < 8; e++)
            newchardata[newch*8+e] = chardata[ch*8+e];

          newcharused[newch] = 1;
          newchcol[newch] = chcol[ch];
          newchinfo[newch] = chinfo[ch];
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
    if (!zonex[z] && !zoney[z])
      continue;
    for (y = zoneu[z]; y < zoned[z]; y++)
    {
      for (x = zonel[z]; x < zoner[z]; x++)
      {
        newmapdata[y*mapsx+x] = blockmapping[mapdata[y*mapsx+x]];
      }
    }
  }

  memcpy(chardata, newchardata, 2048);
  memcpy(blockdata, newblockdata, 4096);
  memcpy(chcol, newchcol, 256);
  memcpy(chinfo, newchinfo, 256);
  memcpy(mapdata, newmapdata, mapsx*mapsy);

  findusedblocksandchars();

  // Tidying up step: if char does not use char color, reset color to that used by first char
  if ((chcol[0] & 0xf) >= 8)
  {
    for (c = 1; c < 256; c++)
    {
      int e;
      int charcolorused = 0;
      if ((chcol[c] & 0xf) < 8)
        continue;

      for (e = 0; e < 8; e++)
      {
        int v = chardata[c*8+e];
        if ((v & 0xc0) == 0xc0) charcolorused = 1;
        if ((v & 0x30) == 0x30) charcolorused = 1;
        if ((v & 0x0c) == 0x0c) charcolorused = 1;
        if ((v & 0x03) == 0x03) charcolorused = 1;
        if (charcolorused)
          break;
      }

      if (!charcolorused)
        chcol[c] = chcol[0] | (chcol[c] & 0x40);
    }
  }
}

void optimizeblocks(void)
{
  int c,d;

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
    for (c = 0; c < 16; c++) v += blockdata[d*16+c];
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
        break;
      }
    }
  }
  for (d = 1; d < 256; d++)
  {
    int v = 0;
    if (chcol[d] & 64)
      continue;
    for (c = 0; c < 8; c++) v += chardata[d*8+c];
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

  if (!gfx_init(320,200,70,GFX_DOUBLESIZE))
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
      int firstnum;
      int length;

      char ib2[80];

      for (firstnum = 0; firstnum < strlen(ib1); firstnum++)
      {
        if ((ib1[firstnum] >= '0') && (ib1[firstnum] <= '9')) break;
      }

      if (firstnum < strlen(ib1)) levelnum = atoi(&ib1[firstnum]);

      strcpy(ib2, ib1);
      strcat(ib2, ".chi");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        read(handle, chinfo, 256);
        close(handle);
        findusedblocksandchars();
      }
      memset(blockdata,0,4096);
      memset(chcol,9,256);
      strcpy(ib2, ib1);
      strcat(ib2, ".blk");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        lseek(handle, 3, SEEK_SET); // Skip chunk header
        read(handle, blockdata, BLOCKS*16);
        close(handle);
        findusedblocksandchars();
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".chc");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        read(handle, &chcol, 256);
        close(handle);
        findusedblocksandchars();
      }

      // If loaded a different level, reset map position
      if (strcmp(levelname, ib1))
      {
        mapx = 0;
        mapy = 0;
      }

      strcpy(levelname, ib1);
      strcpy(ib2, ib1);
      strcat(ib2, ".chr");
      handle = open(ib2, O_RDONLY | O_BINARY);
      length = lseek(handle, 0, SEEK_END);
      lseek(handle, 0, SEEK_SET);
      if (length < 256*8)
      {
        // Perform conversion from MW4 format (192 chars only, numbered 64-255)
        for (c = 0; c < BLOCKS*16; c++)
        {
          if (blockdata[c] >= 64) blockdata[c] -= 64;
          else
          {
            if (blockdata[c] == 32) blockdata[c] = 192;
          }
        }
        memmove(chinfo, &chinfo[64], 192);
        memset(&chinfo[192], 0, 64);
      }

      if (handle != -1)
      {
        read(handle, &chardata[0], 256*8);
        close(handle);
        findusedblocksandchars();
      }

      for (c = 0; c < NUMLVLOBJ; c++)
      {
        lvlobjx[c] = 0;
        lvlobjy[c] = 0;
        lvlobjb[c] = 0;
        lvlobjd1[c] = 0;
        lvlobjd2[c] = 0;
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".lvo");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        int numobj;
        // Handle legacy formats / changing object count
        length = lseek(handle, 0, SEEK_END);
        lseek(handle, 0, SEEK_SET);
        numobj = length / 5;
        read(handle, &lvlobjx[0], numobj);
        read(handle, &lvlobjy[0], numobj);
        read(handle, &lvlobjb[0], numobj);
        read(handle, &lvlobjd1[0], numobj);
        read(handle, &lvlobjd2[0], numobj);
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
        numobj = length / 5;
        read(handle, &lvlactx[0], numobj);
        read(handle, &lvlacty[0], numobj);
        read(handle, &lvlactf[0], numobj);
        read(handle, &lvlactt[0], numobj);
        read(handle, &lvlactw[0], numobj);
        close(handle);
      }

      for (c = 0; c < NUMZONES; c++)
      {
        zonex[c] = 0;
        zoney[c] = 0;
        zonel[c] = 0;
        zoner[c] = 0;
        zoneu[c] = 254;
        zoned[c] = 255;
        zonebg1[c] = 0;
        zonebg2[c] = 11;
        zonebg3[c] = 12;
        zonemusic[c] = 0;
      }

      memset(mapdata, 0, mapsx*mapsy);

      for (c = 0; c < NUMRANDOMACT; c++)
      {
        randomactt[c] = 0;
        randomactw[c] = 0;
        randomactp[c] = 0xff;
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".lvr");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        read(handle, randomactt, NUMRANDOMACT);
        read(handle, randomactw, NUMRANDOMACT);
        read(handle, randomactp, NUMRANDOMACT);
      }
      close(handle);

      strcpy(ib2, ib1);
      strcat(ib2, ".map");
      handle = open(ib2, O_RDONLY | O_BINARY);
      if (handle != -1)
      {
        int datasize = readle16(handle);
        int activezones = read8(handle);
        int zoneoffsets[NUMZONES];
        int y,x;

        for (c = 0; c < activezones; c++)
        {
            zoneoffsets[c] = readle16(handle) + 3;
        }

        for (c = 0; c < activezones; c++)
        {
          lseek(handle, zoneoffsets[c], SEEK_SET);

          zonel[c] = read8(handle);
          zoner[c] = read8(handle);
          zoneu[c] = read8(handle);
          zoned[c] = read8(handle);
          zonebg1[c] = read8(handle);
          zonebg2[c] = read8(handle);
          zonebg3[c] = read8(handle);
          zonemusic[c] = read8(handle);

          zonex[c] = ((int)zonel[c] + (int)zoner[c]) / 2;
          zoney[c] = ((int)zoneu[c] + (int)zoned[c]) / 2;

          for (y = zoneu[c]; y < zoned[c]; y++)
          {
            for (x = zonel[c]; x < zoner[c]; x++)
            {
              mapdata[y*255+x] = read8(handle);
            }
          }
        }
        close(handle);
      }
      findusedblocksandchars();
      

      return;
    }
  }
}

void exportmap(void)
{
  char ib1[80];
  strcpy(ib1, levelname);

  updateallzones();

  for (;;)
  {
    int r;
    win_getspeed(70);
    gfx_fillscreen(254);

    printtext_center_color("EXPORT ZONE MAPS TO:",90,SPR_FONTS,COL_WHITE);
    printtext_center_color(ib1,100,SPR_FONTS,COL_HIGHLIGHT);
    gfx_updatepage();

    r = inputtext(ib1, 80);
    if (r == -1) return;
    if (r == 1)
    {
      int oldzonenum = zonenum;
      int c;
      char filename[256];
      for (c = 0; c < NUMZONES; c++)
      {
        zonenum = c;
        if (zonex[c] || zoney[c])
        {
          int sizex = (zoner[c]-zonel[c])*32;
          int sizey = (zoned[c]-zoneu[c])*32;
          unsigned char* image = malloc(sizey*sizex*3);
          if (image)
          {
            int xb, yb;
            sprintf(filename, "%s_%d.png", ib1, c+1);
            for (yb = 0; yb < sizey / 32; yb++)
            {
                for (xb = 0; xb < sizex / 32; xb++)
                {
                    int x, y;
                    drawblock(0, 0, mapdata[(zoneu[c]+yb)*mapsx+zonel[c]+xb]);
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
            stbi_write_png(filename, sizex, sizey, 3, image, 0);
            free(image);
          }
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
      int firstnum;
      char ib2[80];

      for (firstnum = 0; firstnum < strlen(ib1); firstnum++)
      {
        if ((ib1[firstnum] >= '0') && (ib1[firstnum] <= '9')) break;
      }

      if (firstnum < strlen(ib1)) levelnum = atoi(&ib1[firstnum]);

      strcpy(levelname, ib1);
      strcpy(ib2, ib1);
      strcat(ib2, ".chr");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &chardata[0], 256*8);
        close(handle);
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".chi");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, chinfo, 256);
        close(handle);
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".blk");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        writele16(handle, maxusedblocks*16);
        write8(handle, 0);
        write(handle, blockdata, maxusedblocks*16);
        close(handle);
      }
      strcpy(ib2, ib1);
      strcat(ib2, ".chc");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &chcol, 256);
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lvr");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, randomactt, NUMRANDOMACT);
        write(handle, randomactw, NUMRANDOMACT);
        write(handle, randomactp, NUMRANDOMACT);
      }
      close(handle);

      updateallzones();

      strcpy(ib2, ib1);
      strcat(ib2, ".map");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        int activezones = 0;
        int datasize = 0;
        int zoneoffsets[NUMZONES];
        int d = 0;

        for (c = 0; c < NUMZONES; c++)
        {
          if ((zonex[c]) || (zoney[c]))
            activezones++;
        }
        datasize = activezones*2;

        for (c = 0; c < NUMZONES; c++)
        {
          if ((zonex[c]) || (zoney[c]))
          {
            zoneoffsets[d] = datasize;
            datasize += 8 + (zoned[c]-zoneu[c])*(zoner[c]-zonel[c]);
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
          if ((zonex[c]) || (zoney[c]))
          {
            write8(handle, zonel[c]);
            write8(handle, zoner[c]);
            write8(handle, zoneu[c]);
            write8(handle, zoned[c]);
            write8(handle, zonebg1[c]);
            write8(handle, zonebg2[c]);
            write8(handle, zonebg3[c]);
            write8(handle, zonemusic[c]);

            for (y = zoneu[c]; y < zoned[c]; y++)
            {
              for (x = zonel[c]; x < zoner[c]; x++)
              {
                write8(handle, mapdata[y*255+x]);
              }
            }
          }
        }
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lvo");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &lvlobjx[0], NUMLVLOBJ);
        write(handle, &lvlobjy[0], NUMLVLOBJ);
        write(handle, &lvlobjb[0], NUMLVLOBJ);
        write(handle, &lvlobjd1[0], NUMLVLOBJ);
        write(handle, &lvlobjd2[0], NUMLVLOBJ);
        close(handle);
      }

      strcpy(ib2, ib1);
      strcat(ib2, ".lva");
      handle = open(ib2, O_RDWR|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
      if (handle != -1)
      {
        write(handle, &lvlactx[0], NUMLVLACT);
        write(handle, &lvlacty[0], NUMLVLACT);
        write(handle, &lvlactf[0], NUMLVLACT);
        write(handle, &lvlactt[0], NUMLVLACT);
        write(handle, &lvlactw[0], NUMLVLACT);
        close(handle);
      }

      return;
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
              read(handle, &blockdata[16*b], 16);
              for (d = 0; d < 16; d++)
              {
                blockdata[16*b+d] += offset;
              }
            }
            if ((datalen + offset*8) > 2048)
              datalen = 2048 - offset*8;
            read(handle, &chardata[offset*8], datalen);
            read(handle, &chcol[offset], datalen/8);
            read(handle, &chinfo[offset], datalen/8);
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
              read(handle, &blockdata[16*b], 16);
              for (d = 0; d < 16; d++)
              {
                blockdata[16*b+d] += offset;
              }
            }
            if ((datalen + offset*8) > 2048)
              datalen = 2048 - offset*8;
            read(handle, &chardata[offset*8], datalen);
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
            int ch = blockdata[16*c+b];
            int found = 0;
            for (d = 0; d < numtempchars; d++)
            {
              if (!memcmp(&chardata[ch*8], &tempchars[d*8], 8))
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
              memcpy(&tempchars[d*8], &chardata[ch*8], 8);
              tempchcol[d] = chcol[ch];
              tempchinfo[d] = chinfo[ch];
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
        read(handle, chinfo, 256);
        read(handle, chardata, 2048);
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
        write(handle, chinfo, 256);
        write(handle, chardata, 2048);
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
        read(handle, &chardata[frame*8], maxbytes);
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
        write(handle, &chardata[frame*8], frames*8);
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
            drawchar(x*8+32, y*8+128, c);
            c++;
        }
    }
}

void drawchar(int dx, int dy, int c)
{
  Uint8 *destptr = &gfx_vscreen[dy*320 + dx];
  Uint8 *ptr = &chardata[c*8];
  char v = 0;
  int x,y;

  if ((chcol[c]&15) < 8)
  {
    for (y = 0; y < 8; y++)
    {
      unsigned data = *ptr;

      for (x = 7; x >= 0; x--)
      {
        if (data & 1) v = (chcol[c]&15);
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
          v = zonebg2[zonenum];
          break;

          case 2:
          v = zonebg3[zonenum];
          break;

          case 3:
          v = (chcol[c]&15)-8;
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

void drawblock(int x, int y, int num)
{
    int c;
    int xb, yb;

    for (yb = 0; yb < 4; yb++)
    {
        for (xb = 0; xb < 4; xb++)
        {
            drawchar(x+xb*8, y+yb*8, blockdata[num*16+yb*4+xb]);
        }
    }
}

int findzone(int x, int y)
{
  int c;
  for (c = 0; c < NUMZONES; c++)
  {
    if ((zonex[c]) || (zoney[c]))
    {
      if ((x >= zonel[c]) && (x < zoner[c]) &&
          (y >= zoneu[c]) && (y < zoned[c])) return c;
    }
  }
  return NUMZONES+1;
}

void updatezone(int z)
{
  int c;

  if ((!zonex[z]) && (!zoney[z])) return;

  for (c = zoneu[z]; c >= 0; c--)
  {
    if (mapdata[zonex[z] + c*255])
    {
      zoneu[z] = c;
    }
    else break;
  }
  for (c = zoned[z]-1; c < mapsy; c++)
  {
    if (mapdata[zonex[z] + c*255])
    {
      zoned[z] = c+1;
    }
    else break;
  }

  for (c = zonel[z]; c >= 0; c--)
  {
    if (mapdata[zoney[z]*255 + c])
    {
      zonel[z] = c;
    }
    else break;
  }
  for (c = zoner[z]-1; c < mapsx; c++)
  {
    if (mapdata[zoney[z]*255 + c])
    {
      zoner[z] = c+1;
    }
    else break;
  }
}

void updateallzones(void)
{
  int c;
  for (c = 0; c < NUMZONES; c++)
    updatezone(c);
}
