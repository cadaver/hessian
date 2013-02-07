#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fileio.h"

#define MAX_LEVELS 32
#define MAX_LVLACT 128

int numlvlact[MAX_LEVELS];
int numbytes[MAX_LEVELS];
unsigned char lvlactx[MAX_LVLACT];
unsigned char lvlacty[MAX_LVLACT];
unsigned char lvlactf[MAX_LVLACT];
unsigned char lvlactt[MAX_LVLACT];
unsigned char lvlactw[MAX_LVLACT];
int bitareasize = 0;

int main(int argc, char** argv)
{
    int c,d;
    int actuallevels = 0;
    int offset = 0;
    for (c = 0; c < MAX_LEVELS; c++)
    {
        int length;
        int numact;
        char namebuf[256];
        sprintf(namebuf, "bg/level%02d.lva", c);
        FILE* in = fopen(namebuf, "rb");
        if (!in)
            break;
        fseek(in, SEEK_END, 0);
        length = ftell(in);
        fseek(in, SEEK_SET, 0);

        actuallevels++;
        numact = length / 5;
        memset(lvlactt, 0, sizeof lvlactt);
        fread(&lvlactx[0], numact, 1, in);
        fread(&lvlacty[0], numact, 1, in);
        fread(&lvlactf[0], numact, 1, in);
        fread(&lvlactt[0], numact, 1, in);
        fread(&lvlactw[0], numact, 1, in);
        fclose(in);
        for (d = MAX_LVLACT-1; d >= 0; d--)
        {
            if (lvlactt[d])
                break;
        }
        if (d < 0) d = 0; // Always have some data per level
        numlvlact[c] = d+1;
        numbytes[c] = (numlvlact[c] + 7) / 8;
        bitareasize += numbytes[c];
        printf("Level %d has %d actors\n", c, numlvlact[c]);
    }
    printf("Total bit area size is %d", bitareasize);
    FILE* out = fopen("levelactors.s", "wt");
    fprintf(out, "LVLDATAACTTOTALSIZE = %d\n\n", bitareasize);
    fprintf(out, "lvlDataActBitsStart:\n");
    for (c = 0; c < actuallevels; c++)
    {
        fprintf(out, "                dc.b %d\n", offset);
        offset += numbytes[c];
    }
    fprintf(out, "lvlDataActBitsLen:\n");
    for  (c = 0; c < actuallevels; c++)
    {
        fprintf(out, "                dc.b %d\n", numbytes[c]);
    }
    fclose(out);
}