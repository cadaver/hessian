#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  FILE *in, *out;
  int length;
  int datasize;
  int dataitems = 0;
  char *buffer;

  if (argc < 3)
  {
    printf("Makes a chunk-datafile out of a raw binary file.\nUsage: mchunk <in> <out>\n");
    return 1;
  }
  in = fopen(argv[1], "rb");
  out = fopen(argv[2], "wb");

  if ((!in) || (!out))
  {
    printf("Open error!\n");
    return 1;
  }

  fseek(in, 0, SEEK_END);
  length = ftell(in);
  fseek(in, 0, SEEK_SET);
  buffer = malloc(length);
  if (!buffer)
  {
    printf("Memory error!\n");
    return 1;
  }
  fread(buffer, 1, length, in);
  fclose(in);

  fputc(length, out);
  fputc(length >> 8, out);
  fputc(dataitems, out);
  fwrite(buffer, 1, length, out);
  fclose(out);
  return 0;
}
