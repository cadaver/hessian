#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <ctype.h>
#include <string.h>
#include "fileio.h"

typedef struct
{
  unsigned char slicemask;
  unsigned char color;
  signed char hotspotx;
  signed char fliphotspotx;
  signed char connectspotx;
  signed char flipconnectspotx;
  signed char hotspoty;
  signed char connectspoty;
  unsigned char cacheframe;
  unsigned char flipcacheframe;
} SPRHEADER;

typedef struct
{
  unsigned char slicemask;
  unsigned char color;
  signed char hotspotx;
  signed char connectspotx;
  signed char hotspoty;
  signed char connectspoty;
  unsigned char cacheframe;
} OLDSPRHEADER;

typedef struct
{
  short slicemask;
  signed char hotspotx;
  signed char reversehotspotx;
  signed char hotspoty;
  signed char connectspotx;
  signed char reverseconnectspotx;
  signed char connectspoty;
} OLDSPRHEADER2;

unsigned char copybuffer[64] = {0};
signed char magx[256];
signed char hotspotx[256];
signed char hotspoty[256];
signed char connectspotx[256];
signed char connectspoty[256];
unsigned char spritedata[256*64];
int sliceoffset[] = {0,1,2,21,22,23,42,43,44};

int main(int argc, char** argv)
{
  char* filename;
  int c;
  int length;
  int format = 0;
  int frame = 0;
  int frameindex = 0;
  FILE* handle;

  if (argc > 1)
    filename = argv[1];
  else
  {
    printf("Usage: spr2txt <inputfile>\n");
    return 1;
  }

  handle = fopen(filename, "rb");
  if (!handle)
  {
    printf("Could not open input\n");
    return 1;
  }
  fseek(handle, 0, SEEK_END);
  length = ftell(handle);

  // Detect format from offset between the 2 first sprites
  {
    int offset1, offset2;
    fseek(handle, 3, SEEK_SET);
    offset1 = freadle16(handle);
    offset2 = freadle16(handle);
    while (offset2 - offset1 > 10)
      offset2 -= 7;
    if (offset2 - offset1 == 8)
      format = 2;
    if (offset2 - offset1 == 7)
      format = 1;
  }

  if (format == 0)
  {
    for (;;)
    {
      SPRHEADER tempheader;
      int slice;
      int slicemask = 0;
      unsigned short offset;

      fseek(handle, frameindex*2+3, SEEK_SET);
      offset = freadle16(handle);
      offset += 3;
      fseek(handle, offset, SEEK_SET);

      tempheader.slicemask = fread8(handle);
      tempheader.color = fread8(handle);
      tempheader.hotspotx = fread8(handle);
      tempheader.fliphotspotx = fread8(handle);
      tempheader.connectspotx = fread8(handle);
      tempheader.flipconnectspotx = fread8(handle);
      tempheader.hotspoty = fread8(handle);
      tempheader.connectspoty = fread8(handle);
      tempheader.cacheframe = fread8(handle);
      tempheader.flipcacheframe = fread8(handle);

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
  if (format == 1)
  {
    for (;;)
    {
      SPRHEADER tempheader;
      int slice;
      int slicemask = 0;
      unsigned short offset;

      fseek(handle, frameindex*2+3, SEEK_SET);
      offset = freadle16(handle);
      offset += 3;
      fseek(handle, offset, SEEK_SET);

      tempheader.slicemask = fread8(handle);
      tempheader.color = fread8(handle);
      tempheader.hotspotx = fread8(handle);
      tempheader.connectspotx = fread8(handle);
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
  if (format == 2)
  {
    for (;;)
    {
      OLDSPRHEADER2 tempheader;
      int slice;
      unsigned short offset;

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
  printf("%s (%d frames)\n\n", filename, frame);
  for (c = 0; c < frame; ++c)
  {
    int x, y;
    int miny = 20;
    int maxy = 0;
    for (y = 0; y < 21; ++y)
    {
      for (x = 0; x < 12; ++x)
      {
        if (spritedata[c*64+y*3+x/4])
        {
          if (y < miny)
            miny = y;
          if (y > maxy)
            maxy = y;
        }
      }
    }

    for (y = miny; y <= maxy; ++y)
    {
      for (x = 0; x < 12; ++x)
      {
        int pixel = (spritedata[c*64+y*3+x/4] >> ((3-(x&3))*2)) & 3;
        printf("%c ", pixel + 'o');
      }
      printf("\n");
    }
    printf("\n");
  }
  return 0;
}