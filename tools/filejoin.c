#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  FILE *in;
  FILE *out;
  unsigned c;
  char filename[80];
  char *inbuffer;
  int length;

  if (argc < 3)
  {
    printf("Usage: filejoin <in1>+<in2>... <out>\n");
    return 1;
  }

  out = fopen(argv[2], "wb");
  if (!out)
  {
    printf("Destination open error\n");
    return 1;
  }

  memset(filename, 0, sizeof filename);
  for (c = 0; c < strlen(argv[1])+1; c++)
  {
    if ((argv[1][c] != '+') && (argv[1][c]))
    {
      filename[strlen(filename)] = argv[1][c];
    }
    else
    {
      in = fopen(filename, "rb");
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
          fwrite(inbuffer, length, 1, out);
          free(inbuffer);
        }
        fclose(in);
        memset(filename, 0, sizeof filename);
      }
      else return 1;
    }
  }
  fclose(out);
  return 0;
}



