#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define SEEKBACK 2047
#define MAXSTRING 15
#define MAXINPUT 65536

#define LITERALBITS 9
#define ONEBYTEBITS 9
#define TWOBYTEBITS 17

FILE *in;
FILE *out;
int length;

unsigned char *inbuffer = NULL;
int *stlen = NULL;
int *stpos = NULL;
int *optbits = NULL;
int *optlen = NULL;

int main(int argc, char **argv);
int readinput();
void findmatches();
void findencoding();
void writeoutput();
int getstringbits(int pos);
int getsubstringbits(int pos, int len);

int main(int argc, char **argv)
{
  if (argc < 3)
  {
    printf("Loaderpart packer\n"
           "Usage: lpack <in> <out>\n");
    return 1;
  }

  in = fopen(argv[1], "rb");
  if (!in)
  {
    printf("Can't open source!\n");
    return 1;
  }

  if (readinput()) return 1;

  out = fopen(argv[2], "wb");
  if (!out)
  {
    printf("Can't open destination!\n");
    return 1;
  }

  findmatches();
  findencoding();
  writeoutput();

  return 0;
}

int readinput(void)
{
  fseek(in, 0, SEEK_END);
  length = ftell(in);
  fseek(in, 0, SEEK_SET);

  inbuffer = malloc(length);
  stlen = malloc(length * sizeof(int));
  stpos = malloc(length * sizeof(int));
  optbits = malloc(length * sizeof(int));
  optlen = malloc(length * sizeof(int));
  if ((!inbuffer) || (!stlen) || (!stpos) || (!optbits) || (!optlen))
  {
    printf("Out of memory!\n");
    return 1;
  }
  fread(inbuffer, length, 1, in);
  fclose(in);

  return 0;
}

void findmatches(void)
{
  int pos;
  int c;
  static int matches[256];
  static int matchtable[256][SEEKBACK];
  int matchtablestart = 0;
  int matchtableend = 0;
  int oldmatchtablestart;

  for (c = 0; c < 256; c++) matches[c] = 0;

  for (pos = 0; pos < length; pos++)
  {
    // Assume no string match
    stlen[pos] = 0;

    // Add characters to the match-table
    for (c = matchtableend; c < pos; c++)
    {
      int b = inbuffer[c];

      matchtable[b][matches[b]] = c;
      matches[b]++;
    }
    matchtableend = pos;

    if (pos >= 2)
    {
      // Try to find the longest string
      int cstlen = 0;
      int cstpos = 0;
      int bb = inbuffer[pos]; // Beginning byte to be compared against

      for (c = matches[bb]-1; c >= 0; c--)
      {
        int start = matchtable[bb][c];
        int end = start + MAXSTRING;
        if (end > pos) end = pos;

        if (end-start >= cstlen)
        {
          int max = end - start;
          int d;

          for (d = 1; d < max; d++)
          {
            if (inbuffer[start+d] != inbuffer[pos+d]) break;
          }
          if ((d >= 2) && (d > cstlen))
          {
            cstlen = d;
            cstpos = pos - start;
          }
          // Try to find as low position as possible (uses shorter encoding)
          if ((d == cstlen) && (pos - start < cstpos))
          {
            cstpos = pos - start;
          }
        }

        // Exit if already the best possible match
        if ((cstlen == MAXSTRING) && (cstpos == cstlen)) break;
      }

      // Store the best string at this position (if any)
      if (cstlen > 1)
      {
        stlen[pos] = cstlen;
        stpos[pos] = cstpos;
      }
    }

    // Remove too old matches
    oldmatchtablestart = matchtablestart;
    matchtablestart = pos - SEEKBACK;
    if (matchtablestart < 0) matchtablestart = 0;

    for (c = oldmatchtablestart; c < matchtablestart; c++)
    {
      int b = inbuffer[c];
      int d;

      for (d = 0; d < matches[b]; d++)
      {
        // Find the first OK entry and copy it+the rest to the start
        if (matchtable[b][d] >= matchtablestart)
        {
          memmove(&matchtable[b][0], &matchtable[b][d], (matches[b]-d)*sizeof(int));
          break;
        }
      }
      matches[b] -= d;
    }
  }
}

void findencoding()
{
  int pos;
  int c;

  for (pos = length-1; pos >= 0; pos--)
  {
    if (pos == length-1)
    {
      optbits[pos] = LITERALBITS;
      optlen[pos] = 0;
    }
    else
    {
      if (!stlen[pos])
      {
        optbits[pos] = LITERALBITS + optbits[pos+1];
        optlen[pos] = 0;
      }
      else
      {
        if (stlen[pos] + pos >= length)
        {
          optbits[pos] = getstringbits(pos);
          optlen[pos] = stlen[pos];
        }
        else
        {
          int bestbits = LITERALBITS + optbits[pos+1];
          int bestlen = 0;

          for (c = stlen[pos]; c >= 2; c--)
          {
            int cbits = getsubstringbits(pos, c) + optbits[pos + c];
            if (cbits < bestbits)
            {
              bestbits = cbits;
              bestlen = c;
            }
          }

          optbits[pos] = bestbits;
          optlen[pos] = bestlen;
        }
      }
    }
  }
}

void writeoutput()
{
  int pos;
  int bitcount = 0;
  int codecount = 0;
  unsigned char codebuffer[16];
  unsigned char bits = 0;

  int literals = 0;
  int onebyte = 0;
  int twobyte = 0;
  int packlength = 0;
  int controlbytes = 0;

  for (pos = 0; pos < length;)
  {
    if (!optlen[pos])
    {
      literals++;
      codebuffer[codecount] = inbuffer[pos];
      codecount++;

      bits |= 1 << bitcount;
      bitcount++;
      pos++;
    }
    else
    {
      if ((optlen[pos] == 2) && (stpos[pos] <= 128))
      {
        onebyte++;
        codebuffer[codecount] = (-stpos[pos]);
        codecount++;
      }
      else
      {
        twobyte++;
        codebuffer[codecount] = (optlen[pos] << 3) | (((-stpos[pos]) >> 8) & 0x07);
        codecount++;
        codebuffer[codecount] = (-stpos[pos]);
        codecount++;
      }
      bitcount++;
      pos += optlen[pos];
    }

    if (bitcount == 8)
    {
      controlbytes++;
      fputc(bits, out);
      fwrite(codebuffer, codecount, 1, out);
      packlength += 1 + codecount;
      bitcount = 0;
      codecount = 0;
      bits = 0;
    }
  }

  // EOF code
  codebuffer[codecount] = 0;
  codecount++;
  bitcount++;
  controlbytes++;
  fputc(bits, out);
  fwrite(codebuffer, codecount, 1, out);
  packlength += 1 + codecount;

  fclose(out);

  printf("In:%d Out:%d\n", length, packlength);
  printf("Literals: %d 1-byte: %d 2-byte: %d Control bytes: %d\n", literals, onebyte, twobyte, controlbytes);
}

int getstringbits(int pos)
{
  if ((stlen[pos] == 2) && (stpos[pos] <= 128))
    return ONEBYTEBITS;
  else
    return TWOBYTEBITS;
}

int getsubstringbits(int pos, int len)
{
  if ((len == 2) && (stpos[pos] <= 128))
    return ONEBYTEBITS;
  else
    return TWOBYTEBITS;
}
