#define CMD_DONOTHING 0
#define CMD_PORTAUP 1
#define CMD_PORTADOWN 2
#define CMD_TONEPORTA 3
#define CMD_VIBRATO 4
#define CMD_SETAD 5
#define CMD_SETSR 6
#define CMD_SETWAVE 7
#define CMD_SETWAVEPTR 8
#define CMD_SETPULSEPTR 9
#define CMD_SETFILTERPTR 10
#define CMD_SETFILTERCTRL 11
#define CMD_SETFILTERCUTOFF 12
#define CMD_SETMASTERVOL 13
#define CMD_FUNKTEMPO 14
#define CMD_SETTEMPO 15

#define MST_NOFINEVIB 0
#define MST_FINEVIB 1
#define MST_FUNKTEMPO 2
#define MST_PORTAMENTO 3
#define MST_RAW 4

#define WTBL 0
#define PTBL 1
#define FTBL 2
#define STBL 3

#define MAX_FILT 64
#define MAX_STR 32
#define MAX_INSTR 64
#define MAX_CHN 3
#define MAX_PATT 208
#define MAX_TABLES 4
#define MAX_TABLELEN 255
#define MAX_INSTRNAMELEN 16
#define MAX_PATTROWS 128
#define MAX_SONGLEN 254
#define MAX_SONGS 32
#define MAX_NOTES 96

#define REPEAT 0xd0
#define TRANSDOWN 0xe0
#define TRANSUP 0xf0
#define LOOPSONG 0xff

#define ENDPATT 0xff
#define INSTRCHG 0x00
#define FX 0x40
#define FXONLY 0x50
#define FIRSTNOTE 0x60
#define LASTNOTE 0xbc
#define REST 0xbd
#define KEYOFF 0xbe
#define KEYON 0xbf
#define OLDKEYOFF 0x5e
#define OLDREST 0x5f

#define WAVEDELAY 0x1
#define WAVELASTDELAY 0xf
#define WAVESILENT 0xe0
#define WAVELASTSILENT 0xef
#define WAVECMD 0xf0
#define WAVELASTCMD 0xfe

#define MAX_NTSONGS 16
#define MAX_NTPATT 127
#define MAX_NTCMD 127
#define MAX_NTCMDNAMELEN 9
#define MAX_NTPATTLEN 192
#define MAX_NTSONGLEN 256
#define MAX_NTTBLLEN 255

#define NT_ENDPATT 0x00
#define NT_CMD 0x01
#define NT_KEYON 0x02*2
#define NT_KEYOFF 0x04*2
#define NT_FIRSTNOTE 0x0c*2
#define NT_LASTNOTE 0x5f*2
#define NT_DUR 0xc0
#define NT_MAXDUR 65

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fileio.h"

typedef struct
{
  unsigned char ad;
  unsigned char sr;
  unsigned char ptr[MAX_TABLES];
  unsigned char vibdelay;
  unsigned char gatetimer;
  unsigned char firstwave;
  char name[MAX_INSTRNAMELEN];
} INSTR;

INSTR instr[MAX_INSTR];
unsigned char ltable[MAX_TABLES][MAX_TABLELEN];
unsigned char rtable[MAX_TABLES][MAX_TABLELEN];
unsigned char songorder[MAX_SONGS][MAX_CHN][MAX_SONGLEN+2];
unsigned char pattern[MAX_PATT][MAX_PATTROWS*4+4];
unsigned char patttempo[MAX_PATT][MAX_PATTROWS];
unsigned char pattinstr[MAX_PATT][MAX_PATTROWS];
unsigned char pattkeyon[MAX_PATT][MAX_PATTROWS];
char songname[MAX_STR];
char authorname[MAX_STR];
char copyrightname[MAX_STR];
int pattlen[MAX_PATT];
int songlen[MAX_SONGS][MAX_CHN];
int tbllen[MAX_TABLES];
int highestusedpatt;
int highestusedinstr;
int highestusedsong;
int defaultpatternlength = 64;

unsigned char ntwavetbl[MAX_NTTBLLEN+1];
unsigned char ntnotetbl[MAX_NTTBLLEN+1];
unsigned char ntpulsetimetbl[MAX_NTTBLLEN+1];
unsigned char ntpulsespdtbl[MAX_NTTBLLEN+1];
unsigned char ntfilttimetbl[MAX_NTTBLLEN+1];
unsigned char ntfiltspdtbl[MAX_NTTBLLEN+1];

unsigned char ntpatterns[MAX_NTPATT][MAX_NTPATTLEN];

unsigned char nttracks[MAX_NTSONGS][MAX_NTSONGLEN];

unsigned char ntcmdad[MAX_NTCMD];
unsigned char ntcmdsr[MAX_NTCMD];
unsigned char ntcmdwavepos[MAX_NTCMD];
unsigned char ntcmdpulsepos[MAX_NTCMD];
unsigned char ntcmdfiltpos[MAX_NTCMD];

unsigned char ntcmdnames[MAX_NTCMD][MAX_NTCMDNAMELEN+1];

unsigned char ntsonglen[MAX_NTSONGS][3];
unsigned char nttbllen[3];
unsigned char ntcmdlen;

unsigned char nthrparam = 0x0f;
unsigned char ntfirstwave = 0x09;

int prevwritebyte = 0x100;
int blocklen = 0;
FILE* out = 0;

void loadsong(const char* songfilename);
void clearsong(int cs, int cp, int ci, int cf, int cn);
void clearinstr(int num);
void clearpattern(int num);
void countpatternlengths(void);
int makespeedtable(unsigned data, int mode, int makenew);
void printsonginfo(void);
void clearntsong(void);
void convertsong(void);
void getpatttempos(void);
void saventsong(const char* songfilename);
void writeblock(unsigned char *adr, int len);
void writebyte(unsigned char c);

int main(int argc, const char** argv)
{
    if (argc < 3)
    {
        printf("Usage: gt2nt2 <input> <output>");
        return 1;
    }

    loadsong(argv[1]);
    printsonginfo();
    clearntsong();
    convertsong();
    saventsong(argv[2]);
}

void loadsong(const char* songfilename)
{
    int c;
    int ok = 0;
    char ident[4];
    FILE *handle;

    handle = fopen(songfilename, "rb");

    if (!handle)
    {
        printf("Could not open input song %s\n", songfilename);
        exit(1);
    }

    fread(ident, 4, 1, handle);
    if ((!memcmp(ident, "GTS3", 4)) || (!memcmp(ident, "GTS4", 4)) || (!memcmp(ident, "GTS5", 4)))
    {
      int d;
      int length;
      int amount;
      int loadsize;
      clearsong(1,1,1,1,1);
      ok = 1;

      // Read infotexts
      fread(songname, sizeof songname, 1, handle);
      fread(authorname, sizeof authorname, 1, handle);
      fread(copyrightname, sizeof copyrightname, 1, handle);

      // Read songorderlists
      amount = fread8(handle);
      for (d = 0; d < amount; d++)
      {
        for (c = 0; c < MAX_CHN; c++)
        {
          length = fread8(handle);
          loadsize = length;
          loadsize++;
          fread(songorder[d][c], loadsize, 1, handle);
        }
      }
      // Read instruments
      amount = fread8(handle);
      for (c = 1; c <= amount; c++)
      {
        instr[c].ad = fread8(handle);
        instr[c].sr = fread8(handle);
        instr[c].ptr[WTBL] = fread8(handle);
        instr[c].ptr[PTBL] = fread8(handle);
        instr[c].ptr[FTBL] = fread8(handle);
        instr[c].ptr[STBL] = fread8(handle);
        instr[c].vibdelay = fread8(handle);
        instr[c].gatetimer = fread8(handle);
        instr[c].firstwave = fread8(handle);
        fread(&instr[c].name, MAX_INSTRNAMELEN, 1, handle);
      }
      // Read tables
      for (c = 0; c < MAX_TABLES; c++)
      {
        loadsize = fread8(handle);
        tbllen[c] = loadsize;
        fread(ltable[c], loadsize, 1, handle);
        fread(rtable[c], loadsize, 1, handle);
      }
      // Read patterns
      amount = fread8(handle);
      for (c = 0; c < amount; c++)
      {
        length = fread8(handle) * 4;
        fread(pattern[c], length, 1, handle);
      }
      countpatternlengths();
    }

    // Goattracker v2.xx (3-table) import
    if (!memcmp(ident, "GTS2", 4))
    {
      int d;
      int length;
      int amount;
      int loadsize;
      clearsong(1,1,1,1,1);
      ok = 1;

      // Read infotexts
      fread(songname, sizeof songname, 1, handle);
      fread(authorname, sizeof authorname, 1, handle);
      fread(copyrightname, sizeof copyrightname, 1, handle);

      // Read songorderlists
      amount = fread8(handle);
      for (d = 0; d < amount; d++)
      {
        for (c = 0; c < MAX_CHN; c++)
        {
          length = fread8(handle);
          loadsize = length;
          loadsize++;
          fread(songorder[d][c], loadsize, 1, handle);
        }
        highestusedsong = d;
      }


      // Read instruments
      amount = fread8(handle);
      for (c = 1; c <= amount; c++)
      {
        instr[c].ad = fread8(handle);
        instr[c].sr = fread8(handle);
        instr[c].ptr[WTBL] = fread8(handle);
        instr[c].ptr[PTBL] = fread8(handle);
        instr[c].ptr[FTBL] = fread8(handle);
        instr[c].vibdelay = fread8(handle);
        instr[c].ptr[STBL] = makespeedtable(fread8(handle), MST_FINEVIB, 0) + 1;
        instr[c].gatetimer = fread8(handle);
        instr[c].firstwave = fread8(handle);
        fread(&instr[c].name, MAX_INSTRNAMELEN, 1, handle);
      }
      // Read tables
      for (c = 0; c < MAX_TABLES-1; c++)
      {
        loadsize = fread8(handle);
        tbllen[c] = loadsize;
        fread(ltable[c], loadsize, 1, handle);
        fread(rtable[c], loadsize, 1, handle);
      }
      // Read patterns
      amount = fread8(handle);
      for (c = 0; c < amount; c++)
      {
        int d;
        length = fread8(handle) * 4;
        fread(pattern[c], length, 1, handle);

        // Convert speedtable-requiring commands
        for (d = 0; d < length; d++)
        {
          switch (pattern[c][d*4+2])
          {
            case CMD_FUNKTEMPO:
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_FUNKTEMPO, 0) + 1;
            break;

            case CMD_PORTAUP:
            case CMD_PORTADOWN:
            case CMD_TONEPORTA:
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_PORTAMENTO, 0) + 1;
            break;

            case CMD_VIBRATO:
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_FINEVIB, 0) + 1;
            break;
          }
        }
      }
      countpatternlengths();
    }
    // Goattracker 1.xx import
    if (!memcmp(ident, "GTS!", 4))
    {
      int d;
      int length;
      int amount;
      int loadsize;
      int fw = 0;
      int fp = 0;
      int ff = 0;
      int fi = 0;
      int numfilter = 0;
      unsigned char filtertable[256];
      unsigned char filtermap[64];
      int arpmap[32][256];
      unsigned char pulse[32], pulseadd[32], pulselimitlow[32], pulselimithigh[32];
      int filterjumppos[64];

      clearsong(1,1,1,1,1);
      ok = 1;

      // Read infotexts
      fread(songname, sizeof songname, 1, handle);
      fread(authorname, sizeof authorname, 1, handle);
      fread(copyrightname, sizeof copyrightname, 1, handle);

      // Read songorderlists
      amount = fread8(handle);
      for (d = 0; d < amount; d++)
      {
        for (c = 0; c < MAX_CHN; c++)
        {
          length = fread8(handle);
          loadsize = length;
          loadsize++;
          fread(songorder[d][c], loadsize, 1, handle);
        }
      }

      // Convert instruments
      for (c = 1; c < 32; c++)
      {
        unsigned char wavelen;

        instr[c].ad = fread8(handle);
        instr[c].sr = fread8(handle);
        pulse[c] = fread8(handle);
        pulseadd[c] = fread8(handle);
        pulselimitlow[c] = fread8(handle);
        pulselimithigh[c] = fread8(handle);
        instr[c].ptr[FTBL] = fread8(handle); // Will be converted later
        if (instr[c].ptr[FTBL] > numfilter) numfilter = instr[c].ptr[FTBL];
        if (pulse[c] & 1) instr[c].gatetimer |= 0x80; // "No hardrestart" flag
        pulse[c] &= 0xfe;
        wavelen = fread8(handle)/2;
        fread(&instr[c].name, MAX_INSTRNAMELEN, 1, handle);
        instr[c].ptr[WTBL] = fw+1;

        // Convert wavetable
        for (d = 0; d < wavelen; d++)
        {
          if (fw < MAX_TABLELEN)
          {
            ltable[WTBL][fw] = fread8(handle);
            rtable[WTBL][fw] = fread8(handle);
            if (ltable[WTBL][fw] == 0xff)
              if (rtable[WTBL][fw]) rtable[WTBL][fw] += instr[c].ptr[WTBL]-1;
            if ((ltable[WTBL][fw] >= 0x8) && (ltable[WTBL][fw] <= 0xf))
              ltable[WTBL][fw] |= 0xe0;
            fw++;
          }
          else
          {
            fread8(handle);
            fread8(handle);
          }
        }

        // Remove empty wavetable afterwards
        if ((wavelen == 2) && (!ltable[WTBL][fw-2]) && (!rtable[WTBL][fw-2]))
        {
          instr[c].ptr[WTBL] = 0;
          fw -= 2;
          ltable[WTBL][fw] = 0;
          rtable[WTBL][fw] = 0;
          ltable[WTBL][fw+1] = 0;
          rtable[WTBL][fw+1] = 0;
        }

        // Convert pulsetable
        if (pulse[c])
        {
          int pulsetime, pulsedist, hlpos;

          // Check for duplicate pulse settings
          for (d = 1; d < c; d++)
          {
            if ((pulse[d] == pulse[c]) && (pulseadd[d] == pulseadd[c]) && (pulselimitlow[d] == pulselimitlow[c]) &&
                (pulselimithigh[d] == pulselimithigh[c]))
            {
              instr[c].ptr[PTBL] = instr[d].ptr[PTBL];
              goto PULSEDONE;
            }
          }

          // Initial pulse setting
          if (fp >= MAX_TABLELEN) goto PULSEDONE;
          instr[c].ptr[PTBL] = fp+1;
          ltable[PTBL][fp] = 0x80 | (pulse[c] >> 4);
          rtable[PTBL][fp] = pulse[c] << 4;
          fp++;

          // Pulse modulation
          if (pulseadd[c])
          {
            int startpulse = pulse[c]*16;
            int currentpulse = pulse[c]*16;
            // Phase 1: From startpos to high limit
            pulsedist = pulselimithigh[c]*16 - currentpulse;
            if (pulsedist > 0)
            {
              pulsetime = pulsedist/pulseadd[c];
              currentpulse += pulsetime*pulseadd[c];
              while (pulsetime)
              {
                int acttime = pulsetime;
                if (acttime > 127) acttime = 127;
                if (fp >= MAX_TABLELEN) goto PULSEDONE;
                ltable[PTBL][fp] = acttime;
                rtable[PTBL][fp] = pulseadd[c] / 2;
                fp++;
                pulsetime -= acttime;
              }
            }

            hlpos = fp;
            // Phase 2: from high limit to low limit
            pulsedist = currentpulse - pulselimitlow[c]*16;
            if (pulsedist > 0)
            {
              pulsetime = pulsedist/pulseadd[c];
              currentpulse -= pulsetime*pulseadd[c];
              while (pulsetime)
              {
                int acttime = pulsetime;
                if (acttime > 127) acttime = 127;
                if (fp >= MAX_TABLELEN) goto PULSEDONE;
                ltable[PTBL][fp] = acttime;
                rtable[PTBL][fp] = -(pulseadd[c] / 2);
                fp++;
                pulsetime -= acttime;
              }
            }

            // Phase 3: from low limit back to startpos/high limit
            if ((startpulse < pulselimithigh[c]*16) && (startpulse > currentpulse))
            {
              pulsedist = startpulse - currentpulse;
              if (pulsedist > 0)
              {
                pulsetime = pulsedist/pulseadd[c];
                while (pulsetime)
                {
                  int acttime = pulsetime;
                  if (acttime > 127) acttime = 127;
                  if (fp >= MAX_TABLELEN) goto PULSEDONE;
                  ltable[PTBL][fp] = acttime;
                  rtable[PTBL][fp] = pulseadd[c] / 2;
                  fp++;
                  pulsetime -= acttime;
                }
              }
              // Pulse jump back to beginning
              if (fp >= MAX_TABLELEN) goto PULSEDONE;
              ltable[PTBL][fp] = 0xff;
              rtable[PTBL][fp] = instr[c].ptr[PTBL] + 1;
              fp++;
            }
            else
            {
              pulsedist = pulselimithigh[c]*16 - currentpulse;
              if (pulsedist > 0)
              {
                pulsetime = pulsedist/pulseadd[c];
                while (pulsetime)
                {
                  int acttime = pulsetime;
                  if (acttime > 127) acttime = 127;
                  if (fp >= MAX_TABLELEN) goto PULSEDONE;
                  ltable[PTBL][fp] = acttime;
                  rtable[PTBL][fp] = pulseadd[c] / 2;
                  fp++;
                  pulsetime -= acttime;
                }
              }
              // Pulse jump back to beginning
              if (fp >= MAX_TABLELEN) goto PULSEDONE;
              ltable[PTBL][fp] = 0xff;
              rtable[PTBL][fp] = hlpos + 1;
              fp++;
            }
          }
          else
          {
            // Pulse stopped
            if (fp >= MAX_TABLELEN) goto PULSEDONE;
            ltable[PTBL][fp] = 0xff;
            rtable[PTBL][fp] = 0;
            fp++;
          }
          PULSEDONE: {}
        }
      }
      // Convert patterns
      amount = fread8(handle);
      for (c = 0; c < amount; c++)
      {
        length = fread8(handle);
        for (d = 0; d < length/3; d++)
        {
          unsigned char note, cmd, data, instr;
          note = fread8(handle);
          cmd = fread8(handle);
          data = fread8(handle);
          instr = cmd >> 3;
          cmd &= 7;

          switch(note)
          {
            default:
            note += FIRSTNOTE;
            if (note > LASTNOTE) note = REST;
            break;

            case OLDKEYOFF:
            note = KEYOFF;
            break;

            case OLDREST:
            note = REST;
            break;

            case ENDPATT:
            break;
          }
          switch(cmd)
          {
            case 5:
            cmd = CMD_SETFILTERPTR;
            if (data > numfilter) numfilter = data;
            break;

            case 7:
            if (data < 0xf0)
              cmd = CMD_SETTEMPO;
            else
            {
              cmd = CMD_SETMASTERVOL;
              data &= 0x0f;
            }
            break;
          }
          pattern[c][d*4] = note;
          pattern[c][d*4+1] = instr;
          pattern[c][d*4+2] = cmd;
          pattern[c][d*4+3] = data;
        }
      }

      fi = highestusedinstr + 1;

      // Read filtertable
      fread(filtertable, 256, 1, handle);

      // Convert filtertable
      for (c = 0; c < 64; c++)
      {
        filterjumppos[c] = -1;
        filtermap[c] = 0;
        if (filtertable[c*4+3] > numfilter) numfilter = filtertable[c*4+3];
      }

      if (numfilter > 63) numfilter = 63;

      for (c = 1; c <= numfilter; c++)
      {
        filtermap[c] = ff+1;

        if (filtertable[c*4]|filtertable[c*4+1]|filtertable[c*4+2]|filtertable[c*4+3])
        {
          // Filter set
          if (filtertable[c*4])
          {
            ltable[FTBL][ff] = 0x80 + (filtertable[c*4+1] & 0x70);
            rtable[FTBL][ff] = filtertable[c*4];
            ff++;
            if (filtertable[c*4+2])
            {
              ltable[FTBL][ff] = 0x00;
              rtable[FTBL][ff] = filtertable[c*4+2];
              ff++;
            }
          }
          else
          {
            // Filter modulation
            int time = filtertable[c*4+1];

            while (time)
            {
              int acttime = time;
              if (acttime > 127) acttime = 127;
              ltable[FTBL][ff] = acttime;
              rtable[FTBL][ff] = filtertable[c*4+2];
              ff++;
              time -= acttime;
            }
          }

          // Jump to next step: unnecessary if follows directly
          if (filtertable[c*4+3] != c+1)
          {
            filterjumppos[c] = ff;
            ltable[FTBL][ff] = 0xff;
            rtable[FTBL][ff] = filtertable[c*4+3]; // Fix the jump later
            ff++;
          }
        }
      }

      // Now fix jumps as the filterstep mapping is known
      for (c = 1; c <= numfilter; c++)
      {
        if (filterjumppos[c] != -1)
          rtable[FTBL][filterjumppos[c]] = filtermap[rtable[FTBL][filterjumppos[c]]];
      }

      // Fix filterpointers in instruments
      for (c = 1; c < 32; c++)
        instr[c].ptr[FTBL] = filtermap[instr[c].ptr[FTBL]];

      // Now fix pattern commands
      memset(arpmap, 0, sizeof arpmap);
      for (c = 0; c < MAX_PATT; c++)
      {
        unsigned char i = 0;
        for (d = 0; d <= MAX_PATTROWS; d++)
        {
          if (pattern[c][d*4+1]) i = pattern[c][d*4+1];

          // Convert portamento & vibrato
          if (pattern[c][d*4+2] == CMD_PORTAUP)
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_PORTAMENTO, 0) + 1;
          if (pattern[c][d*4+2] == CMD_PORTADOWN)
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_PORTAMENTO, 0) + 1;
          if (pattern[c][d*4+2] == CMD_TONEPORTA)
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_PORTAMENTO, 0) + 1;
          if (pattern[c][d*4+2] == CMD_VIBRATO)
            pattern[c][d*4+3] = makespeedtable(pattern[c][d*4+3], MST_NOFINEVIB, 0) + 1;

          // Convert filterjump
          if (pattern[c][d*4+2] == CMD_SETFILTERPTR)
            pattern[c][d*4+3] = filtermap[pattern[c][d*4+3]];

          // Convert funktempo
          if ((pattern[c][d*4+2] == CMD_SETTEMPO) && (!pattern[c][d*4+3]))
          {
            pattern[c][d*4+2] = CMD_FUNKTEMPO;
            pattern[c][d*4+3] = makespeedtable((filtertable[2] << 4) | (filtertable[3] & 0x0f), MST_FUNKTEMPO, 0) + 1;
          }
          // Convert arpeggio
          if ((pattern[c][d*4+2] == CMD_DONOTHING) && (pattern[c][d*4+3]))
          {
            // Must be in conjunction with a note
            if ((pattern[c][d*4] >= FIRSTNOTE) && (pattern[c][d*4] <= LASTNOTE))
            {
              unsigned char param = pattern[c][d*4+3];
              if (i)
              {
                // Old arpeggio
                if (arpmap[i][param])
                {
                  // As command, or as instrument?
                  if (arpmap[i][param] < 256)
                  {
                    pattern[c][d*4+2] = CMD_SETWAVEPTR;
                    pattern[c][d*4+3] = arpmap[i][param];
                  }
                  else
                  {
                    pattern[c][d*4+1] = arpmap[i][param] - 256;
                    pattern[c][d*4+3] = 0;
                  }
                }
                else
                {
                  int e;
                  unsigned char arpstart;
                  unsigned char arploop;

                  // New arpeggio
                  // Copy first the instrument's wavetable up to loop/end point
                  arpstart = fw + 1;
                  if (instr[i].ptr[WTBL])
                  {
                    for (e = instr[i].ptr[WTBL]-1;; e++)
                    {
                      if (ltable[WTBL][e] == 0xff) break;
                      if (fw < MAX_TABLELEN)
                      {
                        ltable[WTBL][fw] = ltable[WTBL][e];
                        fw++;
                      }
                    }
                  }
                  // Then make the arpeggio
                  arploop = fw + 1;
                  if (fw < MAX_TABLELEN-3)
                  {
                    ltable[WTBL][fw] = (param & 0x80) >> 7;
                    rtable[WTBL][fw] = (param  & 0x70) >> 4;
                    fw++;
                    ltable[WTBL][fw] = (param & 0x80) >> 7;
                    rtable[WTBL][fw] = (param & 0xf);
                    fw++;
                    ltable[WTBL][fw] = (param & 0x80) >> 7;
                    rtable[WTBL][fw] = 0;
                    fw++;
                    ltable[WTBL][fw] = 0xff;
                    rtable[WTBL][fw] = arploop;
                    fw++;

                    // Create new instrument if possible
                    if (fi < MAX_INSTR)
                    {
                      arpmap[i][param] = fi + 256;
                      instr[fi] = instr[i];
                      instr[fi].ptr[WTBL] = arpstart;
                      // Add arpeggio parameter to new instrument name
                      if (strlen(instr[fi].name) < MAX_INSTRNAMELEN-3)
                      {
                        char arpname[8];
                        sprintf(arpname, "0%02X", param&0x7f);
                        strcat(instr[fi].name, arpname);
                      }
                      fi++;
                    }
                    else
                    {
                      arpmap[i][param] = arpstart;
                    }
                  }

                  if (arpmap[i][param])
                  {
                    // As command, or as instrument?
                    if (arpmap[i][param] < 256)
                    {
                      pattern[c][d*4+2] = CMD_SETWAVEPTR;
                      pattern[c][d*4+3] = arpmap[i][param];
                    }
                    else
                    {
                      pattern[c][d*4+1] = arpmap[i][param] - 256;
                      pattern[c][d*4+3] = 0;
                    }
                  }
                }
              }
            }
            // If arpeggio could not be converted, databyte zero
            if (!pattern[c][d*4+2])
              pattern[c][d*4+3] = 0;
          }
        }
      }
      
      tbllen[WTBL] = fw;
      tbllen[PTBL] = fp;
      tbllen[FTBL] = ff;
    }
    fclose(handle);

    // Convert pulsemodulation speed of < v2.4 songs
    if (ident[3] < '4')
    {
      for (c = 0; c < MAX_TABLELEN; c++)
      {
        if ((ltable[PTBL][c] < 0x80) && (rtable[PTBL][c]))
        {
          int speed = ((signed char)rtable[PTBL][c]);
          speed <<= 1;
          if (speed > 127) speed = 127;
          if (speed < -128) speed = -128;
          rtable[PTBL][c] = speed;
        }
      }
    }

    // Convert old legato/nohr parameters
    if (ident[3] < '5')
    {
        for (c = 1; c < MAX_INSTR; c++)
        {
            if (instr[c].firstwave >= 0x80)
            {
                instr[c].gatetimer |= 0x80;
                instr[c].firstwave &= 0x7f;
            }
            if (!instr[c].firstwave) instr[c].gatetimer |= 0x40;
        }
    }
}

void clearsong(int cs, int cp, int ci, int ct, int cn)
{
  int c;

  if (!(cs | cp | ci | ct | cn)) return;

  for (c = 0; c < MAX_CHN; c++)
  {
    int d;
    if (cs)
    {
      for (d = 0; d < MAX_SONGS; d++)
      {
        memset(&songorder[d][c][0], 0, MAX_SONGLEN+2);
        if (!d)
        {
          songorder[d][c][0] = c;
          songorder[d][c][1] = LOOPSONG;
        }
        else
        {
          songorder[d][c][0] = LOOPSONG;
        }
      }
    }
  }
  if (cn)
  {
    memset(songname, 0, sizeof songname);
    memset(authorname, 0, sizeof authorname);
    memset(copyrightname, 0, sizeof copyrightname);
  }
  if (cp)
  {
    for (c = 0; c < MAX_PATT; c++)
      clearpattern(c);
  }
  if (ci)
  {
    for (c = 0; c < MAX_INSTR; c++)
      clearinstr(c);
  }
  if (ct == 1)
  {
    for (c = MAX_TABLES-1; c >= 0; c--)
    {
      memset(ltable[c], 0, MAX_TABLELEN);
      memset(rtable[c], 0, MAX_TABLELEN);
    }
  }
  countpatternlengths();
}

void clearpattern(int p)
{
  int c;

  memset(pattern[p], 0, MAX_PATTROWS*4);
  for (c = 0; c < defaultpatternlength; c++) pattern[p][c*4] = REST;
  for (c = defaultpatternlength; c <= MAX_PATTROWS; c++) pattern[p][c*4] = ENDPATT;
}

void clearinstr(int num)
{
  memset(&instr[num], 0, sizeof(INSTR));
  if (num)
  {
    instr[num].gatetimer = 2;
    instr[num].firstwave = 0x9;
  }
}

void countpatternlengths(void)
{
  int c, d, e;

  highestusedpatt = 0;
  highestusedinstr = 0;
  for (c = 0; c < MAX_PATT; c++)
  {
    for (d = 0; d <= MAX_PATTROWS; d++)
    {
      if (pattern[c][d*4] == ENDPATT) break;
      if ((pattern[c][d*4] != REST) || (pattern[c][d*4+1]) || (pattern[c][d*4+2]) || (pattern[c][d*4+3]))
        highestusedpatt = c;
      if (pattern[c][d*4+1] > highestusedinstr) highestusedinstr = pattern[c][d*4+1];
    }
    pattlen[c] = d;
  }

  for (e = 0; e < MAX_SONGS; e++)
  {
    for (c = 0; c < MAX_CHN; c++)
    {
      for (d = 0; d < MAX_SONGLEN; d++)
      {
        if (songorder[e][c][d] >= LOOPSONG) break;
        if ((songorder[e][c][d] < REPEAT) && (songorder[e][c][d] > highestusedpatt))
          highestusedpatt = songorder[e][c][d];
      }
      songlen[e][c] = d;
    }
  }
}

int makespeedtable(unsigned data, int mode, int makenew)
{
  int c;
  unsigned char l = 0, r = 0;

  if (!data) return -1;

  switch (mode)
  {
    case MST_NOFINEVIB:
    l = (data & 0xf0) >> 4;
    r = (data & 0x0f) << 4;
    break;

    case MST_FINEVIB:
    l = (data & 0x70) >> 4;
    r = ((data & 0x0f) << 4) | ((data & 0x80) >> 4);
    break;

    case MST_FUNKTEMPO:
    l = (data & 0xf0) >> 4;
    r = data & 0x0f;
    break;

    case MST_PORTAMENTO:
    l = (data << 2) >> 8;
    r = (data << 2) & 0xff;
    break;
    
    case MST_RAW:
    r = data & 0xff;
    l = data >> 8;
    break;
  }

  if (makenew == 0)
  {
    for (c = 0; c < MAX_TABLELEN; c++)
    {
      if ((ltable[STBL][c] == l) && (rtable[STBL][c] == r))
        return c;
    }
  }

  for (c = 0; c < MAX_TABLELEN; c++)
  {
    if ((!ltable[STBL][c]) && (!rtable[STBL][c]))
    {
      ltable[STBL][c] = l;
      rtable[STBL][c] = r;
      return c;
    }
  }
  return -1;
}

void printsonginfo(void)
{
    printf("Songs: %d Patterns: %d Instruments: %d\n", highestusedsong+1, highestusedpatt+1, highestusedinstr+1);
}

void clearntsong(void)
{
    memset(ntwavetbl, 0, sizeof ntwavetbl);
    memset(ntnotetbl, 0, sizeof ntnotetbl);
    memset(ntpulsetimetbl, 0, sizeof ntpulsetimetbl);
    memset(ntpulsespdtbl, 0, sizeof ntpulsespdtbl);
    memset(ntfilttimetbl, 0, sizeof ntfilttimetbl);
    memset(ntfiltspdtbl, 0, sizeof ntfiltspdtbl);
    memset(ntpatterns, 0, sizeof ntpatterns);
    memset(nttracks, 0, sizeof nttracks);
    memset(ntcmdad, 0, sizeof ntcmdad);
    memset(ntcmdsr, 0, sizeof ntcmdsr);
    memset(ntcmdwavepos, 0, sizeof ntcmdwavepos);
    memset(ntcmdpulsepos, 0, sizeof ntcmdpulsepos);
    memset(ntcmdfiltpos, 0, sizeof ntcmdfiltpos);
    memset(ntsonglen, 0, sizeof ntsonglen);
    memset(nttbllen, 0, sizeof nttbllen);
    ntcmdlen = 0;
}

void convertsong(void)
{
    int e,c;
    unsigned char wavetblmap[256];
    unsigned char filttblmap[256];
    wavetblmap[0] = 0;
    filttblmap[0] = 0;
    unsigned char lastfiltparam = 0;
    unsigned char lastcutoff = 0;

    if (highestusedpatt > 126)
    {
        printf("Ninjatracker supports max. 127 patterns\n");
        exit(1);
    }

    getpatttempos();

    // Convert trackdata
    for (e = 0; e <= highestusedsong; e++)
    {
        printf("Converting trackdata for song %d\n", e+1);

        int dest = 0;

        for (c = 0; c < MAX_CHN; c++)
        {
            int sp = -1;
            int len = 0;
            int startdest = dest;
            unsigned char positionmap[256];

            while (1)
            {
                int rep = 1;
                sp++;
                if (songorder[e][c][sp] >= LOOPSONG)
                    break;
                while (songorder[e][c][sp] >= TRANSDOWN)
                {
                    positionmap[sp] = len;
                    nttracks[e][dest++] = songorder[e][c][sp++] - TRANSUP + 0xc0;
                    len++;
                }
                while ((songorder[e][c][sp] >= REPEAT) && (songorder[e][c][sp] < TRANSDOWN))
                {
                    positionmap[sp] = len;
                    rep = songorder[e][c][sp++] - REPEAT + 1;
                }
                while (rep--)
                {
                    positionmap[sp] = len;
                    nttracks[e][dest++] = songorder[e][c][sp] + 1;
                    len++;
                }
            }
            sp++;
            nttracks[e][dest++] = 0;
            nttracks[e][dest++] = positionmap[songorder[e][c][sp]] + startdest;
            len += 2;
            ntsonglen[e][c] = len;
        }
        if (dest > 256)
        {
            printf("Song %d's trackdata does not fit in 256 bytes\n", e+1);
            exit(1);
        }
    }

    // Convert tables. Note: more data will be added to tables as pattern commands are converted
    printf("Converting tables\n");
    for (c = 0; c < tbllen[WTBL]; c++)
    {
        unsigned char wave = ltable[WTBL][c];
        unsigned char note = rtable[WTBL][c];
        wavetblmap[c + 1] = nttbllen[0] + 1;

        if (wave == 0xff)
        {
            ntwavetbl[nttbllen[0]] = 0xff;
            ntnotetbl[nttbllen[0]] = note; // Jumps need to be fixed later when mapping is known
            nttbllen[0]++;
        }
        else if (wave >= 0x10 && wave <= 0x8f)
        {
            ntwavetbl[nttbllen[0]] = wave;
            ntnotetbl[nttbllen[0]] = note;
            nttbllen[0]++;
        }
        else if (wave >= 0xe1 && wave <= 0xef)
        {
            ntwavetbl[nttbllen[0]] = wave - 0xe0;
            ntnotetbl[nttbllen[0]] = note;
            nttbllen[0]++;
        }
        else if (wave < 0x10)
        {
            ntwavetbl[nttbllen[0]] = wave + 0x90;
            ntnotetbl[nttbllen[0]] = note;
            nttbllen[0]++;
        }
    }
    // Fix up jumps
    for (c = 0; c < nttbllen[0]; c++)
    {
        if (ntwavetbl[c] == 0xff)
            ntnotetbl[c] = wavetblmap[ntnotetbl[c]];
    }

    for (c = 0; c < tbllen[PTBL]; c++)
    {
        unsigned char time = ltable[PTBL][c];
        unsigned char speed = rtable[PTBL][c];

        if (time == 0xff)
        {
            ntpulsetimetbl[nttbllen[1]] = 0xff;
            ntpulsespdtbl[nttbllen[1]] = speed;
        }
        else if (time < 0x80)
        {
            ntpulsetimetbl[nttbllen[1]] = time;
            if (speed >= 0x80)
                speed = (speed >> 4) | 0xf0;
            else
                speed = speed >> 4;
            ntpulsespdtbl[nttbllen[1]] = speed;
        }
        else
        {
            ntpulsetimetbl[nttbllen[1]] = 0x80;
            ntpulsespdtbl[nttbllen[1]] = ((time & 0xf) << 4) | (speed >> 4);
        }
        nttbllen[1]++;
    }
    
    for (c = 0; c < tbllen[FTBL]; c++)
    {
        unsigned char time = ltable[FTBL][c];
        unsigned char speed = rtable[FTBL][c];
        filttblmap[c + 1] = nttbllen[2] + 1;

        if (time == 0xff)
        {
            ntfilttimetbl[nttbllen[2]] = 0xff;
            ntfiltspdtbl[nttbllen[2]] = speed; // Jumps need to be fixed later when mapping is known
        }
        else if (time > 0x00 && time < 0x80)
        {
            ntfilttimetbl[nttbllen[2]] = time;
            ntfiltspdtbl[nttbllen[2]] = speed;
            lastcutoff += time * speed;
        }
        else if (time == 0x00)
        {
            lastcutoff = speed;
            ntfilttimetbl[nttbllen[2]] = lastfiltparam;
            ntfiltspdtbl[nttbllen[2]] = lastcutoff;
        }
        else if (time >= 0x80 && time < 0xff)
        {
            lastfiltparam = (time & 0xf0) | (speed & 0xf);
            if (ltable[FTBL][c+1] == 0x00)
            {
                lastcutoff = rtable[FTBL][c+1];
                c++;
            }
            ntfilttimetbl[nttbllen[2]] = lastfiltparam;
            ntfiltspdtbl[nttbllen[2]] = lastcutoff;
        }
        nttbllen[2]++;
    }
    // Fix up jumps
    for (c = 0; c < nttbllen[2]; c++)
    {
        if (ntfilttimetbl[c] == 0xff)
            ntfiltspdtbl[c] = filttblmap[ntfiltspdtbl[c]];
    }
    
    // Convert instruments
    printf("Converting instruments\n");
    for (e = 1; e <= highestusedinstr; e++)
    {
        ntcmdad[e-1] = instr[e].ad;
        ntcmdsr[e-1] = instr[e].sr;
        ntcmdwavepos[e-1] = wavetblmap[instr[e].ptr[WTBL]];
        ntcmdpulsepos[e-1] = instr[e].ptr[PTBL];
        ntcmdfiltpos[e-1] = filttblmap[instr[e].ptr[FTBL]];
        for (c = 0; c < MAX_NTCMDNAMELEN; c++)
            ntcmdnames[e-1][c] = tolower(instr[e].name[c]);
        // Todo: add instrument vibrato
        ntcmdlen++;
    }

    // Convert patterns
    printf("Converting patterns\n");
    for (e = 0; e <= highestusedpatt; e++)
    {
        unsigned char notecolumn[MAX_PATTROWS+1];
        unsigned char cmdcolumn[MAX_PATTROWS+1];
        unsigned char durcolumn[MAX_PATTROWS+1];
        memset(cmdcolumn, 0, sizeof cmdcolumn);
        memset(durcolumn, 0, sizeof durcolumn);
        int pattlen = 0;
        int lastinstr = -1;
        int lastdur;

        for (c = 0; c < MAX_PATTROWS+1; c++)
        {
            int note = pattern[e][c*4];
            if (note == ENDPATT)
            {
                notecolumn[c] = NT_ENDPATT;
                break;
            }
            int instr = pattinstr[e][c];
            int dur = patttempo[e][c];
            int keyon = pattkeyon[e][c];

            if (note >= FIRSTNOTE+12 && note <= LASTNOTE)
            {
                notecolumn[c] = (note-FIRSTNOTE-12)*2+NT_FIRSTNOTE;
                if (instr != lastinstr)
                {
                    cmdcolumn[c] = instr;
                    lastinstr = instr;
                }
            }
            else
                notecolumn[c] = keyon ? NT_KEYON : NT_KEYOFF;

            durcolumn[c] = dur;
        }

        // Merge rows where possible
        for (c = 0; c < MAX_PATTROWS+1;)
        {
            int merge = 0;
            if (notecolumn[c] == NT_ENDPATT)
                break;
            if (notecolumn[c+1] != NT_ENDPATT)
            {
                if ((durcolumn[c] + durcolumn[c+1]) < NT_MAXDUR && cmdcolumn[c+1] == 0)
                {
                    if (notecolumn[c] == NT_KEYOFF && notecolumn[c+1] == NT_KEYOFF)
                        merge = 1;
                    else if (notecolumn[c] == NT_KEYON && notecolumn[c+1] == NT_KEYON)
                        merge = 1;
                    else if (notecolumn[c] >= NT_FIRSTNOTE && notecolumn[c] <= NT_LASTNOTE && notecolumn[c+1] == NT_KEYON)
                        merge = 1;
                }
            }

            if (merge)
            {
                int d;
                durcolumn[c] += durcolumn[c+1];
                for (d = c+1; d < MAX_PATTROWS; d++)
                {
                    notecolumn[d] = notecolumn[d+1];
                    cmdcolumn[d] = cmdcolumn[d+1];
                    durcolumn[d] = durcolumn[d+1];
                }
            }
            else
                c++;
        }

        // Clear unneeded durations
        for (c = 0; c < MAX_PATTROWS+1; c++)
        {
            if (notecolumn[c] == NT_ENDPATT)
                break;
            if (c && durcolumn[c] == lastdur)
                durcolumn[c] = 0;
            if (durcolumn[c])
                lastdur = durcolumn[c];
        }

        // Build the final patterndata
        for (c = 0; c < MAX_PATTROWS+1; c++)
        {
            if (notecolumn[c] == NT_ENDPATT)
            {
                ntpatterns[e][pattlen++] = NT_ENDPATT;
                break;
            }
            if (notecolumn[c] >= NT_FIRSTNOTE)
            {
                if (cmdcolumn[c])
                {
                    ntpatterns[e][pattlen++] = notecolumn[c] + NT_CMD;
                    ntpatterns[e][pattlen++] = cmdcolumn[c];
                }
                else
                    ntpatterns[e][pattlen++] = notecolumn[c];
            }
            else
            {
                if (cmdcolumn[c])
                {
                    ntpatterns[e][pattlen++] = notecolumn[c];
                    ntpatterns[e][pattlen++] = cmdcolumn[c];
                }
                else
                    ntpatterns[e][pattlen++] = notecolumn[c] | 0x2;
            }
            if (durcolumn[c])
                ntpatterns[e][pattlen++] = 0x101 - durcolumn[c];
        }

        if (pattlen > MAX_NTPATTLEN)
        {
            printf("Pattern %d does not fit in 192 bytes when compressed\n", e);
            exit(1);
        }
    }
}

void getpatttempos(void)
{
    int e,c;

    memset(patttempo, 6, sizeof patttempo);
    memset(pattinstr, 0, sizeof pattinstr);

    // Simulates playroutine going through the songs
    for (e = 0; e <= highestusedsong; e++)
    {
        printf("Determining tempo & instruments for song %d\n", e+1);
        int sp[3] = {-1,-1,-1};
        int pp[3] = {0xff,0xff,0xff};
        int pn[3] = {0,0,0};
        int rep[3] = {0,0,0};
        int stop[3] = {0,0,0};
        int instr[3] = {1,1,1};
        int tempo[3] = {6,6,6};
        int tick[3] = {0,0,0};
        int keyon[3] = {0,0,0};

        while ((!stop[0])||(!stop[1])||(!stop[2]))
        {
            for (c = 0; c < MAX_CHN; c++)
            {
                if (!stop[c])
                {
                    if (pp[c] == 0xff)
                    {
                        if (!rep[c])
                        {
                            sp[c]++;
                            if (songorder[e][c][sp[c]] >= LOOPSONG)
                            {
                                stop[c] = 1;
                                break;
                            }
                            while (songorder[e][c][sp[c]] >= TRANSDOWN)
                                sp[c]++;
                            while ((songorder[e][c][sp[c]] >= REPEAT) && (songorder[e][c][sp[c]] < TRANSDOWN))
                            {
                                rep[c] = songorder[e][c][sp[c]] - REPEAT;
                                sp[c]++;
                            }
                        }
                        else
                            rep[c]--;

                        pn[c] = songorder[e][c][sp[c]];
                        pp[c] = 0;
                    }
                    if (pattern[pn[c]][pp[c]*4] == ENDPATT)
                        pp[c] = 0xff;
                    else
                    {
                        int note = pattern[pn[c]][pp[c]*4];
                        if (note >= FIRSTNOTE && note <= LASTNOTE)
                            keyon[c] = 1;
                        if (note == KEYON)
                            keyon[c] = 1;
                        if (note == KEYOFF)
                            keyon[c] = 0;

                        if (pattern[pn[c]][pp[c]*4+1])
                            instr[c] = pattern[pn[c]][pp[c]*4+1];

                        if ((pattern[pn[c]][pp[c]*4+2] == 0xf) && (!tick[c]))
                        {
                            int newtempo = pattern[pn[c]][pp[c]*4+3];
                            if (newtempo < 0x80)
                            {
                                tempo[0] = newtempo;
                                tempo[1] = newtempo;
                                tempo[2] = newtempo;
                            }
                            else
                                tempo[c] = newtempo & 0x7f;
                        }
                    }
                }
            }
            for (c = 0; c < MAX_CHN; c++)
            {
                if (!stop[c])
                {
                    if (pp[c] != 0xff)
                    {
                        patttempo[pn[c]][pp[c]] = tempo[c];
                        pattinstr[pn[c]][pp[c]] = instr[c];
                        pattkeyon[pn[c]][pp[c]] = keyon[c];
                        tick[c]++;
                        if (tick[c] >= tempo[c])
                        {
                            tick[c] = 0;
                            pp[c]++;
                        }
                    }
                }
            }
        }
    }
}

void saventsong(const char* songfilename)
{
    out = fopen(songfilename, "wb");
    if (!out)
    {
        printf("Could not open destination file %s\n", songfilename);
        exit(1);
    }
    
    writebyte('N');
    writebyte('2');
    writeblock(ntwavetbl, sizeof ntwavetbl);
    writeblock(ntnotetbl, sizeof ntnotetbl);
    writeblock(ntpulsetimetbl, sizeof ntpulsetimetbl);
    writeblock(ntpulsespdtbl, sizeof ntpulsespdtbl);
    writeblock(ntfilttimetbl, sizeof ntfilttimetbl);
    writeblock(ntfiltspdtbl, sizeof ntfiltspdtbl);
    writeblock(&ntpatterns[0][0], sizeof ntpatterns);
    writeblock(&nttracks[0][0], sizeof nttracks);
    writeblock(ntcmdad, sizeof ntcmdad);
    writeblock(ntcmdsr, sizeof ntcmdsr);
    writeblock(ntcmdwavepos, sizeof ntcmdwavepos);
    writeblock(ntcmdpulsepos, sizeof ntcmdpulsepos);
    writeblock(ntcmdfiltpos, sizeof ntcmdfiltpos);
    writeblock(&ntcmdnames[0][0], sizeof ntcmdnames);
    writeblock(&ntsonglen[0][0], sizeof ntsonglen);
    writeblock(nttbllen, sizeof nttbllen);
    writeblock(&ntcmdlen, sizeof ntcmdlen);
    writeblock(&nthrparam, sizeof nthrparam);
    writeblock(&ntfirstwave, sizeof ntfirstwave);
    fclose(out);
}

void writeblock(unsigned char *adr, int len)
{
  while(len--)
  {
    writebyte(*adr);
    adr++;
  }
}

void writebyte(unsigned char c)
{
  if (prevwritebyte == c)
  {
    blocklen++;
    if (blocklen == 255)
    {
      fputc(0xbf, out);
      fputc(prevwritebyte, out);
      fputc(blocklen, out);
      blocklen = 0;
    }
  }
  else
  {
    if (blocklen > 0)
    {
      fputc(0xbf, out);
      fputc(prevwritebyte, out);
      fputc(blocklen, out);
      blocklen = 0;
    }
    if (c == 0xbf)
    {
      fputc(0xbf, out);
      fputc(0xbf, out);
      fputc(0x01, out);
    }
    else
    {
      fputc(c, out);
    }
    prevwritebyte = c;
  }
}
