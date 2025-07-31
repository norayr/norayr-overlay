#ifndef CONFIG_H
#define CONFIG_H


#define NOBORDER
//#define LOCK_SIZE

#define WIDTH_SCALE      1/1   // (nominator)/(denomitator)
#define HEIGHT_SCALE     1/3

#define TITLE            "coolkbd"
#define MIN_WIDTH        250
#define MIN_HEIGHT       150
#define LONGPRESS_MS     1500

#define FONTS            { "DejaVu Sans:bold", "DejaVu Sans", "DejaVu" }
#define FONT_SIZES       { 2, 3, 4, 6, 8, 10, 12, 16, 18, 24, 32, 40, 48 }
#define FONT_MAX_SIZES 16

#define LABEL_MAXLEN     32

#define KEY_BORDER       2   // see also S in layout.defs.h


#endif
