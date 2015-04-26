/*
 * Write a program file to a D64 image
 * by Cadaver
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

int sectoroffsettable[MAX_TRACK+1][MAX_SECTOR];

unsigned char image[174848];
unsigned char buffer[256];
unsigned char diskname[23];
unsigned char commandbuf[80];
unsigned char c64name[80];
unsigned char dosname[80];
int interleave = 10;
int starttrack, startsector;
FILE *in;
FILE *out;

int main(int argc, char **argv);
void makesectortable(void);
int writefile(char *dosname, char *c64name);
void readsector(int track, int sector);
void writesector(int track, int sector);
void marksectorfree(int track, int sector);
void marksectorused(int track, int sector);
int querysector(int track, int sector);

int main(int argc, char **argv)
{
        /* Check commandline */
        if (argc < 4)
        {
                printf("Usage: prg2d64 <diskimage> <c64 filename> <dos filename>\n"
                       "Use _ to represent spaces in the c64 filename.\n");
                return 1;
        }

        /* Init image */
        makesectortable();
        out = fopen(argv[1], "rb");
        if (!out)
        {
                printf("Couldn't open diskimage for reading!\n");
                return 255;
        }
        fread(image, 174848, 1, out);
        fclose(out);

        /* Write the file */
        if (!writefile(argv[3], argv[2]))
        {
                printf("Error writing file %s\n", argv[2]);
        }
        else
        {
                printf("File %s written at track %d sector %d\n", argv[2],starttrack,startsector);
        }

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

int writefile(char *dosname, char *c64name)
{
        int strack1, strack2;
        int track, sector;
        int lasttrack, lastsector;
        int blocks = 0;
        int c, d;
        FILE *src;

        /* Search for & delete duplicate file */
        track = 18;
        sector = 1;

        for (;;)
        {
                readsector(track, sector);
                for (c = 2; c < 256; c += 32)
                {
                        if (buffer[c])
                        {
                                /* Found file name? */
                                for (d = 0; d < 16; d++)
                                {
                                        unsigned char ch;

                                        if (d < strlen(c64name)) ch = c64name[d];
                                        else ch = 0xa0;
                                        if (ch == '_') ch = 0x20;
                                        if (buffer[c+d+3] != ch) break;
                                }
                                if (d == 16)
                                {
                                        buffer[c] = 0;
                                        writesector(track,sector);
                                        track = buffer[c+1];
                                        sector = buffer[c+2];

                                        for (;;)
                                        {
                                                marksectorfree(track,sector);
                                                readsector(track,sector);
                                                track = buffer[0];
                                                sector = buffer[1];
                                                if (!track) break;
                                        }
                                        goto DELETEDONE;
                                }
                        }
                }
                /* More directoryblocks? */
                if (buffer[0])
                {
                        track = buffer[0];
                        sector = buffer[1];
                }
                else break;
        }
        DELETEDONE:

        /* Open the dos file */
        src = fopen(dosname, "rb");
        if (!src) return 0;

        /*
         * Search for free sector, starting from as close to the directory
         * as possible
         */
        strack1 = 19;
        strack2 = 17;
        for (;;)
        {
                if (interleave > 10)
                {
                        startsector = 0;
                        starttrack = strack1;
                        for (c = 0; c < sectornumtable[starttrack]; c++)
                        {
                                if (querysector(starttrack, startsector)) goto FIRSTFOUND;
                                startsector--;
                                if (startsector < 0) startsector = sectornumtable[starttrack]-1;
                        }
                        startsector = 0;
                        starttrack = strack2;
                        for (c = 0; c < sectornumtable[starttrack]; c++)
                        {
                                if (querysector(starttrack, startsector)) goto FIRSTFOUND;
                                startsector--;
                                if (startsector < 0) startsector = sectornumtable[starttrack]-1;
                        }
                }
                else
                {
                        startsector = 0;
                        starttrack = strack2;
                        for (c = 0; c < sectornumtable[starttrack]; c++)
                        {
                                if (querysector(starttrack, startsector)) goto FIRSTFOUND;
                                startsector++;
                                if (startsector >= sectornumtable[starttrack]) startsector = 0;
                        }
                        startsector = 0;
                        starttrack = strack1;
                        for (c = 0; c < sectornumtable[starttrack]; c++)
                        {
                                if (querysector(starttrack, startsector)) goto FIRSTFOUND;
                                startsector++;
                                if (startsector >= sectornumtable[starttrack]) startsector = 0;
                        }
                }
                if ((strack2 == 1) && (strack1 == MAX_TRACK))
                {
                        /* No free sector found */
                        fclose(src);
                        return 0;
                }
                /* Move outwards on disk */
                if (strack1 < MAX_TRACK) strack1++;
                if (strack2 > 1) strack2--;
        }
        FIRSTFOUND:
        track = starttrack;
        sector = startsector;
        lasttrack = -1;
        lastsector = -1;

        for (;;)
        {
                int bytesread;

                memset(buffer, 0, 256);
                bytesread = fread(&buffer[2], 1, 254, src);
                if (bytesread == 0)
                {
                        if (lasttrack > 0)
                        {
                                readsector(lasttrack, lastsector);
                                buffer[0] = 0;
                                buffer[1] = 255; /* File ends just on the block
                                                  * boundary
                                                  */
                                writesector(lasttrack, lastsector);
                        }
                        else
                        {
                                /* Zero sized file, but we still mark one block
                                 * used
                                 */
                                marksectorused(track, sector);
                                blocks++;
                        }
                        break;
                }
                else
                {
                        if (bytesread == 254)
                        {
                                /* Full block */
                                writesector(track, sector);
                                marksectorused(track, sector);
                                blocks++;
                        }
                        else
                        {
                                /* Less than full block, file ends */
                                buffer[0] = 0;
                                buffer[1] = bytesread+1;
                                writesector(track, sector);
                                marksectorused(track, sector);
                                blocks++;
                                break;
                        }
                }
                lasttrack = track;
                lastsector = sector;

                /* Now search next free sector */
                /* Preferably on the same track */
                sector += interleave;
                if (sector >= sectornumtable[track]) sector %= sectornumtable[track];
                if (querysector(track, sector)) goto FOUND;
                if (interleave > 10)
                {
                        for (c = 0; c < sectornumtable[track]; c++)
                        {
                                sector--;
                                if (sector < 0) sector = sectornumtable[track]-1;
                                if (querysector(track, sector)) goto FOUND;
                        }
                }
                else
                {
                        for (c = 0; c < sectornumtable[track]; c++)
                        {
                                sector++;
                                if (sector >= sectornumtable[track]) sector = 0;
                                if (querysector(track, sector)) goto FOUND;
                        }
                }

                /* No free blocks on same track */
                if (track < 18)
                {
                        for (; track >= 1; track--)
                        {
                                for (sector = 0; sector < sectornumtable[track]; sector++)
                                {
                                        if (querysector(track, sector)) goto FOUND;
                                }
                        }
                        /* Now search the other half */
                        for (track = 19; track <= MAX_TRACK; track++)
                        {
                                for (sector = 0; sector < sectornumtable[track]; sector++)
                                {
                                        if (querysector(track, sector)) goto FOUND;
                                }
                        }
                }
                else
                {
                        for (; track <= MAX_TRACK; track++)
                        {
                                for (sector = 0; sector < sectornumtable[track]; sector++)
                                {
                                        if (querysector(track, sector)) goto FOUND;
                                }
                        }
                        /* Now search the other half */
                        for (track = 17; track >= 1; track--)
                        {
                                for (sector = 0; sector < sectornumtable[track]; sector++)
                                {
                                        if (querysector(track, sector)) goto FOUND;
                                }
                        }
                }
                /* Give up */
                fclose(src);
                return 0;

                FOUND:
                /* Make link to this track */
                readsector(lasttrack, lastsector);
                buffer[0] = track;
                buffer[1] = sector;
                writesector(lasttrack, lastsector);

                /* Then go back to read more of the file */
        }
        /* File ready, now we must make directory entry */
        fclose(src);

        track = 18;
        sector = 1;

        for (;;)
        {
                NEXTDIRBLOCK:
                readsector(track, sector);
                /* Room in this directory block? */
                for (c = 2; c < 256; c += 32)
                {
                        if (!buffer[c])
                        {
                                /* File name */
                                for (d = 0; d < 16; d++)
                                {
                                        unsigned char ch;

                                        if (d < strlen(c64name)) ch = c64name[d];
                                        else ch = 0xa0;
                                        if (ch == '_') ch = 0x20;
                                        buffer[c+d+3] = ch;
                                }
                                /* File location */
                                buffer[c] = 0x82; /* PRG */
                                buffer[c+1] = starttrack;
                                buffer[c+2] = startsector;
                                /* File size */
                                buffer[c+28] = blocks;
                                buffer[c+29] = blocks / 256;
                                writesector(track, sector);
                                return 1; /* OK! */
                        }
                }
                /* More directoryblocks? */
                if (buffer[0])
                {
                        track = buffer[0];
                        sector = buffer[1];
                        goto NEXTDIRBLOCK;
                }

                /* Room for new directoryblock? */
                if (sector == sectornumtable[track]-1) return 0;
                buffer[0] = track;
                buffer[1] = sector+1;
                writesector(track, sector);
                sector++;
                readsector(track, sector);
                buffer[0] = 0;
                buffer[1] = 0xff;       /* Assume new block is the last */
                marksectorused(track, sector);
                writesector(track, sector);
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

void marksectorfree(int track, int sector)
{
        unsigned char *bam = &image[sectoroffsettable[18][0]];

        bam[4*track]++;
        bam[4*track+sector/8+1] |= (1 << (sector%8));
}

void marksectorused(int track, int sector)
{
        unsigned char *bam = &image[sectoroffsettable[18][0]];

        bam[4*track]--;
        bam[4*track+sector/8+1] &= 0xff - (1 << (sector%8));
}

int querysector(int track, int sector)
{
        unsigned char *bam = &image[sectoroffsettable[18][0]];

        return (bam[4*track+sector/8+1] & (1 << (sector%8)));
}

