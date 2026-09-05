/*
 * myI2CLCD.c
 *
 *  Created on: Sep 22, 2020
 *      Author: powersystem
 */

#include "myI2CLCD.h"

extern I2C_HandleTypeDef hi2c1;
#define hi2c hi2c1

unsigned char ROW_ADDR[4] = {0x80, 0xC0, 0x94, 0xD4};

void lcd_send_cmd (char cmd)
{
	uint8_t data_u, data_l;
	uint8_t data_t[4];
	data_u = (cmd & 0xF0);
	data_l = ((cmd<<4) & 0xF0);
	data_t[0] = data_u|0x0C;  //en=1, rs=0
	data_t[1] = data_u|0x08;  //en=0, rs=0
	data_t[2] = data_l|0x0C;  //en=1, rs=0
	data_t[3] = data_l|0x08;  //en=0, rs=0
	HAL_I2C_Master_Transmit(&hi2c, LCD_ADDRESS, data_t, sizeof(data_t), 100);
	return;
}

void lcd_send_data (char data)
{
	uint8_t data_u, data_l;
	uint8_t data_t[4];
	data_u = (data & 0xF0);
	data_l = ((data<<4) & 0xF0);
	data_t[0] = data_u|0x0D;  //en=1, rs=1
	data_t[1] = data_u|0x09;  //en=0, rs=1
	data_t[2] = data_l|0x0D;  //en=1, rs=1
	data_t[3] = data_l|0x09;  //en=0, rs=1
	HAL_I2C_Master_Transmit(&hi2c, LCD_ADDRESS, data_t, sizeof(data_t), 100);
	return;
}

void lcdInit ()
{
	HAL_Delay(50);
	lcd_send_cmd (0x03);
	HAL_Delay(5);
	lcd_send_cmd (0x03);
	HAL_Delay(1);
	lcd_send_cmd (0x03);
	HAL_Delay(10);
	lcd_send_cmd (0x02);
	HAL_Delay(10);

	lcd_send_cmd(0x28); // Function set --> DL=0 (4 bit mode), N = 1 (2 line display) F = 0 (5x8 characters)
	HAL_Delay(1);
	lcd_send_cmd(0x08); //Display on/off control --> D=0,C=0, B=0  ---> display off
	HAL_Delay(1);
	lcd_send_cmd (0x06);	// text flows Left to Right
	HAL_Delay(1);
	lcd_send_cmd (0x0C);	// display on no cursor, no blinking
	HAL_Delay(1);
	lcd_send_cmd (0x01);	// clear screen
	HAL_Delay(1);
	return;
}

void lcd_gotoXY(uint8_t row, uint8_t col) {
	lcd_send_cmd (ROW_ADDR[row] + col);
	HAL_Delay(1);
	return;
}

void lcdClear() {
	lcd_send_cmd (0x01);	// clear screen
	HAL_Delay(2);
	return;
}

void lcdPrintf(char *str)	// print at (0,0)
{
#ifndef LCD_DEBUGGING_MODE
	return;
#endif
	unsigned int col = 0, row = 0;

	lcdClear();
	while (*str) {
		if ((*str == '\n') || (col >= LCD_MAX_COL)) {
			row++; col = 0;
			lcd_send_cmd (ROW_ADDR[row]);
			str++;
		}
		lcd_send_data (*str++);

		//position update
		col++;
	}
	return;
}

void lcdXYprintf (unsigned char row, unsigned char col, char *str) {
	lcd_send_cmd (ROW_ADDR[row] + col);
	while (*str) {
		lcd_send_data (*str++);
		col++;
	}
	while (col++ < LCD_MAX_COL)
		lcd_send_data(' ');

	return;
}
