// BME text printing module header file

void txt_print(int x, int y, unsigned spritefile, char *string);
void txt_printcenter(int y, unsigned spritefile, char *string);
void txt_printx(int x, int y, unsigned spritefile, char *string, unsigned char *xlattable);
void txt_printcenterx(int y, unsigned spritefile, char *string, unsigned char *xlattable);

extern int txt_lastx;
extern int txt_lasty;
extern int txt_spacing;
