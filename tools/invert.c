#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  int length;
  int c;
  char *buffer = 0;
  FILE *in;
  FILE *out;

  if (argc < 3)
  {
    printf("Binary file invertor\n"
           "Usage: invert <infile> <outfile>\n");
    return 0;
  }
  
  in = fopen(argv[1], "rb");
  if (!in)
  {
    printf("Couldn't open infile\n");
    return 1;
  }
  
  fseek(in, 0, SEEK_END);
  length = ftell(in);
  fseek(in, 0, SEEK_SET);
  
  buffer = malloc(length);
  if (!buffer)
  {
    printf("Out of memory!\n");
    fclose(in);
    return 1;
  }

  fread(buffer, length, 1, in);
  fclose(in);

  out = fopen(argv[2], "wb");
  if (!out)
  {
    printf("Couldn't open outfile\n");
    return 1;
  }

  for (c = length-1; c >= 0; c--)
  {
    fputc(buffer[c], out);
  }
  fclose(out);
  return 0;
}




