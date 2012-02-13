// BME blockmap module header file

#define MAX_LAYERS 4

extern MAPHEADER map_header;
extern LAYERHEADER map_layer[MAX_LAYERS];
extern unsigned short *map_layerdataptr[];
extern unsigned char *map_blkinfdata;

void map_freemap(void);
int map_loadmap(char *name);
void map_drawalllayers(int xpos, int ypos, int xorigin, int yorigin, int xblocks, int yblocks);
void map_drawlayer(int l, int xpos, int ypos, int xorigin, int yorigin, int xblocks, int yblocks);
int map_loadblockinfo(char *name);
unsigned map_getblocknum(int l, int xpos, int ypos);
void map_setblocknum(int l, int xpos, int ypos, unsigned num);
unsigned char map_getblockinfo(int l, int xpos, int ypos);
void map_shiftblocksback(unsigned first, int amount, int step);
void map_shiftblocksforward(unsigned first, int amount, int step);
