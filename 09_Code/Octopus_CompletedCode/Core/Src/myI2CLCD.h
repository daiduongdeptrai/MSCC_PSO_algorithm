/*
 * myI2CLCD.h
 *
 *  Created on: Sep 22, 2020
 *      Author: powersystem
 */

#ifndef SRC_MYI2CLCD_H_
#define SRC_MYI2CLCD_H_

#include "main.h"
#include "string.h"

#define	LCD_DEBUGGING_MODE

#define LCD_ADDRESS (0x27 << 1)
#define LCD_DELAY_MS 5

#define LCD_MAX_COL	20U
#define LCD_MAX_ROW	4U
#define LCD_SIZE		(LCD_MAX_COL * LCD_MAX_ROW)

#define LCD_LINE0	0x80
#define LCD_LINE1	0xC0
#define LCD_LINE2	0x94
#define LCD_LINE3	0xD4

void lcdInit ();
void lcdClear();
void lcdPrintf(char *str);
void lcdXYprintf (unsigned char row, unsigned char col, char *str);

#endif /* SRC_MYI2CLCD_H_ */
