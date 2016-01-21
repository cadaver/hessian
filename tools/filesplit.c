#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  FILE *in;
  FILE *out;
  unsigned c;
  char *inbuffer;
  int length;
  int startpos = 0;
  int splitlength = 0xffff;

  if (argc < 4)
  {
    printf("Usage: filesplit <in> <out> <startpos> [length]\n");
    return 1;
  }

  sscanf(argv[3], "%d", &startpos);
  if (argc > 4)
    sscanf(argv[4], "%d", &splitlength);

  in = fopen(argv[1], "rb");
  if (in)
  {
    fseek(in, 0, SEEK_END);
    length = ftell(in);
    fseek(in, 0, SEEK_SET);
    if (length)
    {
      inbuffer = malloc(length);
      if (!inbuffer) return 1;
      fread(inbuffer, length, 1, in);
      if (startpos + splitlength > length)
        splitlength = length - startpos;
      out = fopen(argv[2], "wb");
      if (!out)
      {
        printf("Could not open output file %s\n", argv[2]);
        free(inbuffer);
        fclose(in);
        return 1;
      }
      fwrite(&inbuffer[startpos], splitlength, 1, out);
      free(inbuffer);
      fclose(out);
    }
    fclose(in);
  }
  else
  {
    printf("Could not open input file %s\n", argv[1]);
    return 1;
  }

  return 0;
}
