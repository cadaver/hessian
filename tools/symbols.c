#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLISTSYMBOLS 16384

char *symbol[MAXLISTSYMBOLS];

int main(int argc, char **argv)
{
  FILE *in = NULL;
  FILE *out = NULL;
  FILE *list = NULL;
  char buffer[80];
  char name[80];
  int address;
  int c, d;
  if (argc < 2)
  {
    printf("Usage: symbols <infile> [outfile] [list]\n"
      "If list-file is not specified, will output all symbols.\n"
      "If out-file is not specified, only analyzes the symbols.\n");
    return 1;
  }

  in = fopen(argv[1], "rt");
  if (!in)
  {
    printf("Error opening input file!\n");
    return 1;
  }

  if (argc > 2)
  {
    out = fopen(argv[2], "wt");
    if (!out)
    {
      printf("Error opening output file!\n");
      return 1;
    }
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

  if (out)
  {
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
    fclose(out);
  }
  else
  {
    // Analyze-mode
    int numsymbols = 0;
    char* symbols[MAXLISTSYMBOLS];
    int addresses[MAXLISTSYMBOLS];

    while (fgets(buffer, 80, in))
    {
      int nameok = 1;
      int pos = 0;

      address = -1;
      sscanf(buffer, "%s %x", &name[0], &address);
      if (address == -1)
        sscanf(buffer, "%s = $%x", &name[0], &address);

      for (c = 0; c < strlen(name); c++)
      {
        if (name[c] == '.')
        {
          nameok = 0; // Don't use macro labels
          break;
        }
      }
      // In Hessian code labels begin with uppercase; these can be ignored
      if (isupper(name[0]))
        nameok = 0;
      if (!nameok)
        continue;

      for (pos = 0; pos < numsymbols; pos++)
      {
        if (addresses[pos] > address)
          break;
      }

      for (c = numsymbols - 1; c >= pos; c--)
      {
        symbols[c+1] = symbols[c];
        addresses[c+1] = addresses[c];
      }
      symbols[pos] = strdup(name);
      addresses[pos] = address;
      numsymbols++;
    }

    for (c = 0; c < numsymbols; c++)
    {
      printf("%s = $%04x", symbols[c], addresses[c]);
      if (c < numsymbols - 1)
      {
        if ((addresses[c+1] - addresses[c] <= 0x100) && addresses[c] >= 0x200)
        {
          if ((addresses[c] & 0xff00) != ((addresses[c+1]-1) & 0xff00))
            printf(" (PAGE CROSS)");
        }
      }
      printf("\n");
    }
  }

  fclose(in);

  return 0;
}
