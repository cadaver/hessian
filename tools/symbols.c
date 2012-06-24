#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLISTSYMBOLS 16384

char *symbol[MAXLISTSYMBOLS];

int main(int argc, char **argv)
{
  FILE *in;
  FILE *out;
  FILE *list = NULL;
  char buffer[80];
  char name[80];
  int address;
  int c;
  if (argc < 3)
  {
    printf("Usage: symbols <infile> <outfile> [list]\n"
      "If list-file is not present, will output all symbols.\n");
    return 1;
  }

  in = fopen(argv[1], "rt");
  out = fopen(argv[2], "wt");
  if ((!in) || (!out))
  {
    printf("Error opening files!\n");
    return 1;
  }

  if (argc > 3)
  {
    list = fopen(argv[3], "rt");
    if (list)
    {
      for (c = 0; c < MAXLISTSYMBOLS-1; c++)
      {
        if (!fgets(buffer, 80, list)) break;
        if (strlen(buffer))
        {
	  char *sptr = buffer;

	  while (*sptr)
	  {
            /* Erase newline in all of its forms */
            if (*sptr == 13) *sptr = 0;
            if (*sptr == 10) *sptr = 0;
	    sptr++;
	  }
          symbol[c] = strdup(buffer);
        }
        else break;
      }
      symbol[c] = NULL;
      fclose(list);
    }
  }

  while (fgets(buffer, 80, in))
  {
    int nameok = 1;

    sscanf(buffer, "%s %x", &name[0], &address);
    for (c = 0; c < strlen(name); c++)
    {
      if (name[c] == '.') nameok = 0; // Don't dump macro labels
    }
    if (!strcmp(name, "---")) nameok = 0; // Newer DASM symbol file title, skip
    
    if (nameok)
    {
      if (list)
      {
        for (c = 0;; c++)
        {
          if (!symbol[c]) break;
          if (!strcmp(symbol[c], name))
          {
            fprintf(out, "%s = $%04x\n", name, address);
            break;
          }
        }
      }
      else fprintf(out, "%s = $%04x\n", name, address);
    }
  }
  fclose(in);
  fclose(out);
  return 0;
}
