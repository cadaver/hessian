#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAXOUTPUT 2*1024*1024

int main(int argc, char **argv);

int main(int argc, char **argv)
{
  unsigned char *inbuffer;
  unsigned char *outbuffer;

  FILE *in;
  FILE *out;
  int length;
  unsigned char depackbits = 0;

  int inbytes = 0;
  int outbytes = 0;

  int literal = 0;
  int onebyte = 0;
  int twobyte = 0;

  if (argc < 3)
  {
    printf("Loaderpart depacker\n"
           "Usage: ldepack <in> <out>\n");
    return 1;
  }

  in = fopen(argv[1], "rb");
  if (!in)
  {
    return 0;
  }
  inbuffer = malloc(MAXOUTPUT);
  outbuffer = malloc(MAXOUTPUT);

  if ((!inbuffer) || (!outbuffer))
  {
    printf("Out of memory\n");
    return 1;
  }

  fseek(in, 0, SEEK_END);
  length = ftell(in);
  fseek(in, 0, SEEK_SET);
  fread(inbuffer, length, 1, in);
  fclose(in);

  out = fopen(argv[2], "wb");
  if (!out)
  {
    printf("Destination open error\n");
    return 1;
  }
  for (;;)
  {
    int bit = depackbits & 1;
    depackbits >>= 1;
    if (!depackbits)
    {
      depackbits = inbuffer[inbytes];
      inbytes++;
      bit = depackbits & 1;
      depackbits >>= 1;
      depackbits |= 0x80;
    }
    if (bit)
    {
      literal++;

      outbuffer[outbytes] = inbuffer[inbytes];
      outbytes++;
      inbytes++;
    }
    else
    {
      int length, index;

      if (!inbuffer[inbytes])
      {
        inbytes++;
        break; /* EOF */
      }

      if (inbuffer[inbytes] >= 0x80)
      {
        onebyte++;
        length = 2;
        index = inbuffer[inbytes];
        index -= 256;
        inbytes++;
      }
      else
      {
        twobyte++;
        length = inbuffer[inbytes] >> 3;
        index = inbuffer[inbytes+1] | ((inbuffer[inbytes] & 0x07) << 8);
        index -= 2048;
        inbytes += 2;
      }

      while(length)
      {
        outbuffer[outbytes] = outbuffer[outbytes+index];
        outbytes++;
        length--;
      }
    }
  }
  fwrite(outbuffer, outbytes, 1, out);
  printf("In: %d Out: %d\n", inbytes, outbytes);
  printf("Literals: %d 1-byte: %d 2-byte: %d\n", literal, onebyte, twobyte);
  fclose(out);
  return 0;
}
