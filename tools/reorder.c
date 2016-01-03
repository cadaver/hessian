/*
 * Reorder 2-letter files to number order on disk
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TRACK 35
#define MAX_SECTOR 21

int sectornumtable[] =
{
  0, 21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,
  19,19,19,19,19,19,19,
  18,18,18,18,18,18,
  17,17,17,17,17
};

unsigned char image[174848];
unsigned char buffer[256];
int sectoroffsettable[MAX_TRACK+1][MAX_SECTOR];

void makesectortable(void);
void sortdirentries(void);
void readsector(int track, int sector);
void writesector(int track, int sector);

int main(int argc, char **argv)
{
        int c;
        FILE *in;
            FILE *out;

        /* Check commandline */
        if (argc < 2)
        {
                printf("Usage: reorder <diskimage>\n");
                return 1;
        }

        in = fopen(argv[1], "rb");
        if (!in)
        {
                printf("Couldn't open diskimage for reading!\n");
                return 255;
        }
        fread(image, 174848, 1, in);
        fclose(in);

        makesectortable();
        sortdirentries();

        /* Write image & exit */
        out = fopen(argv[1], "wb");
        if (!out)
        {
                printf("Couldn't open diskimage for writing!\n");
                return 255;
        }
        fwrite(image, 174848, 1, out);
        fclose(out);
        printf("Diskimage written.\n");
        return 0;
}

void sortdirentries(void)
{
    unsigned char direntry[128][32];
    int track = 18;
    int sector = 1;
    int entries = 0;
    memset(direntry, 0, 128*32);

    for (;;)
    {
        int c;
        readsector(track, sector);
        for (c = 2; c < 256; c += 32)
        {
            if (buffer[c] == 0x82)
            {
                int filenumber = 0; // The boot file is not 2-letter, put it first
                if (buffer[c+5] == 0xa0)
                {
                    filenumber = (buffer[c+3] - 0x30) * 16;
                    if (buffer[c+4] < 0x40)
                        filenumber |= (buffer[c+4]-0x30);
                    else
                        filenumber |= (buffer[c+4]-0x41+0xa);
                    filenumber++;
                }
                memcpy(&direntry[filenumber][0], &buffer[c], 32);
            }
        }
        if (buffer[0])
        {
            track = buffer[0];
            sector = buffer[1];
        }
        else
            break;
    }
    
    track = 18;
    sector = 1;

    for (;;)
    {
        int c;
        readsector(track, sector);

        for (c = 2; c < 256; c += 32)
        {
            if (buffer[c] == 0x82)
            {
                while (!direntry[entries][0])
                    ++entries;
                memcpy(&buffer[c], &direntry[entries][0], 32);
                ++entries;
            }
        }
        writesector(track, sector);
        if (buffer[0])
        {
            track = buffer[0];
            sector = buffer[1];
        }
        else
            break;
    }
}

void makesectortable(void)
{
        int c,d,e;

        /* Make sectortable */
        e = 0;
        for (c = 1; c <= MAX_TRACK; c++)
        {
                for (d = 0; d < sectornumtable[c]; d++)
                {
                        sectoroffsettable[c][d] = e;
                        e += 256;
                }
        }
}

void writesector(int track, int sector)
{
        memcpy(&image[sectoroffsettable[track][sector]], buffer, 256);
}

void readsector(int track, int sector)
{
        memcpy(buffer, &image[sectoroffsettable[track][sector]], 256);
}
