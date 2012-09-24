/*
 * Extract a program file from a D64 image
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int snumtable[] =
{
  21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,
  19,19,19,19,19,19,19,
  18,18,18,18,18,18,
  17,17,17,17,17
};

int firstsecttbl[35];

int main(int argc, char **argv);
int getoffset(int track, int sector);

int main(int argc, char **argv)
{
  int c,s;
  int ofs;
  char noheader = 0;

  FILE *d64handle, *prghandle;
  unsigned char *d64buf;
  unsigned char *ptr;

  if (argc < 4)
  {
    printf("Usage: d642prg <d64 image name> <program to extract> <dos filename for prg>\n"
           "Use _ to represent spaces in the c64 filename. Use -h switch after the\n"
           "filenames to skip the startaddress.\n");
    return 1;
  }

  if (argc > 4)
  {
    for (c = 4; c < argc; c++)
    {
      if ((argv[c][0] == '-') || (argv[c][0] == '/'))
      {
        switch(toupper(argv[c][1]))
        {
          case 'H':
          noheader = 1;
          break;
        }
      }
    }
  }

  d64handle = fopen(argv[1], "rb");
  if (!d64handle)
  {
    printf("Couldn't open d64 image.\n");
    return 1;
  }

  d64buf = malloc(174848);
  if (!d64buf)
  {
    printf("No memory for d64 image.\n");
    return 1;
  }

  prghandle = fopen(argv[3], "wb");
  if (!prghandle)
  {
    fclose(d64handle);
    printf("Couldn't open destination.\n");
    return 1;
  }
  fread(d64buf,174848,1,d64handle);
  fclose(d64handle);

  s = 0;
  for (c = 0; c < 35; c++)
  {
    firstsecttbl[c] = s;
    s += snumtable[c];
  }

  ptr = &d64buf[getoffset(18,1)];
  ofs = 2;

  for (;;)
  {
    for (c = 0; c<16;c++)
    {
      if (ptr[ofs+3+c] == 0xa0) ptr[ofs+3+c] = 0x5f;
      if (ptr[ofs+3+c] == 0x20) ptr[ofs+3+c] = 0x5f;
    }
    ptr[ofs+3+16] = 0;

    if ((ptr[ofs] & 0x83)==0x82)
    {
      int a;
      int err = 0;
      for (a = 0; a < strlen(argv[2]); a++)
      {
        if (toupper(ptr[ofs+3+a]) != toupper(argv[2][a]))
        {
          err = 1;
          break;
        }
      }
      if (!err)
      {
        printf("Found on track %d sector %d\n", ptr[ofs+1],ptr[ofs+2]);
        ptr = &d64buf[getoffset(ptr[ofs+1],ptr[ofs+2])];
        for (;;)
        {
          if (ptr[0])
          {
            if (!noheader)
            {
              fwrite(&ptr[2], 254, 1, prghandle);
            }
            else
            {
              fwrite(&ptr[4], 252, 1, prghandle);
              noheader = 0;
            }
            ptr = &d64buf[getoffset(ptr[0],ptr[1])];
            printf(".");
            fflush(stdout);
          }
          else
          {
            if (!noheader)
            {
              fwrite(&ptr[2], ptr[1]-1, 1, prghandle);
            }
            else
            {
              fwrite(&ptr[4], ptr[1]-3, 1, prghandle);
              noheader = 0;
            }
            printf(".\n");
            break;
          }
        }
        printf("File extracted successfully.\n");
        fclose(prghandle);
        return 0;
      }
    }
    ofs += 32;
    if (ofs >= 256)
    {
      if (ptr[0])
      {
        ptr = &d64buf[getoffset(ptr[0],ptr[1])];
        ofs = 2;
      }
      else
      {
        printf("File not found.\n");
        return 1;
      }
    }
  }
}




int getoffset(int track, int sector)
{
  int offset;
  track--;
  offset = (firstsecttbl[track]+sector)*256;
  return offset;
}


