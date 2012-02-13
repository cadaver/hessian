#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
  char header[3];
  int val;
  FILE *in;
  FILE *out;
  char cmd[256];
  if (argc < 3) printf("Invokes exomizer2 (forward mode + literals) pchunk2 <infile> <outfile> - invokes exomizer2 (forward + literals), output with chunkfile header & custom shortened exomizer header\n");
  in = fopen(argv[1], "rb");
  if (!in) return 1;
  out = fopen("temp.bin", "wb");
  if (!out) return 1;
  header[0] = fgetc(in);
  header[1] = fgetc(in);
  header[2] = fgetc(in);
  for(;;)
  {
    int c = fgetc(in);
    if (c == EOF) break;
    fputc(c, out);
  }
  fclose(in);
  fclose(out);
  
  sprintf(cmd, "exomizer2 level -f -o%s %s@0", "temp2.bin", "temp.bin");
  val = system(cmd);
  if (val > 0) return val;

  unlink("temp.bin");
  in = fopen("temp2.bin", "rb");
  if (!in) return 1;
  out = fopen(argv[2], "wb");
  if (!out) return 1;
  fputc(header[0], out);
  fputc(header[1], out);
  fputc(header[2], out);
  // Skip first 2 bytes of exomized output
  fgetc(in);
  fgetc(in);
  for(;;)
  {
    int c = fgetc(in);
    if (c == EOF) break;
    fputc(c, out);
  }
  fclose(in);
  fclose(out);
  unlink("temp2.bin");
  return val;
}
