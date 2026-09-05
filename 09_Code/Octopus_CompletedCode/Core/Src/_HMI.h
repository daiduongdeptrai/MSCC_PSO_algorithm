/*
 * _HMI.h
 *
 *  Created on: Dec 20, 2024
 *      Author: Duy-Dinh Nguyen
 */

#ifndef SRC__HMI_H_
#define SRC__HMI_H_

#include "myI2CLCD.h"

#define HMI_UPDATE_PERIOD		450U	// 500ms

#define _HMI_STR_MAX_LENGTH		(LCD_MAX_COL * 2U)
#define _HMI_SHOW_TIME			3U
#define _HMI_BLINK_LINE_1		(1U<<0)
#define _HMI_BLINK_LINE_2		(1U<<1)
#define _HMI_BLINK_LINE_3		(1U<<2)
#define _HMI_BLINK_LINE_4		(1U<<3)

#define _HMI_BLINK__ONLY_LINE_1		1
#define _HMI_BLINK__ONLY_LINE_2		2
#define _HMI_BLINK__ONLY_LINE_3		4
#define _HMI_BLINK__ONLY_LINE_4		8

#define _HMI_BLINK_LINE_2_CBL	(1U<<4)

typedef enum hmi_status_enum {
	_HMI_PAGE_00,
	_HMI_PAGE_01,
	_HMI_PAGE_02,
	_HMI_PAGE_03,
	_HMI_PAGE_04,
	_HMI_PAGE_05,
	_HMI_PAGE_06,
	_HMI_PAGE_07,
	_HMI_PAGE_08,
	_HMI_PAGE_09,
	_HMI_PAGE_10,
	_HMI_PAGE_11,
	_HMI_PAGE_12,
	_HMI_PAGE_13,
	_HMI_PAGE_14,
	_HMI_PAGE_15,
	_HMI_PAGE_16,
	_HMI_PAGE_17,
	_HMI_PAGE_18,
	_HMI_PAGE_19,
	_HMI_PAGE_20,
	_HMI_PAGE_21,
	_HMI_PAGE_22,
	_HMI_PAGE_23,
	_HMI_PAGE_24,
	_HMI_PAGE_25,
	_HMI_PAGE_26,
	_HMI_PAGE_27,
	_HMI_PAGE_28,
	_HMI_PAGE_29,
} HMI_Page_TypeDef;

typedef struct {
	uint16_t	updateCounter;
	uint16_t	updatePeriod;
	_Bool		updateFlag;
	uint16_t	lineBlink;
	char	strLine1[_HMI_STR_MAX_LENGTH];
	char	strLine2[_HMI_STR_MAX_LENGTH];
	char	strLine3[_HMI_STR_MAX_LENGTH];
	char	strLine4[_HMI_STR_MAX_LENGTH];
	HMI_Page_TypeDef	pageNumber;
	uint16_t	showTime;
} HMI_TypeDef;



void hmiUpdatedisplay(HMI_TypeDef *thisHMI);
void hmiUpdatemessage(HMI_TypeDef *thisHMI);
void hmiTestmessage(HMI_TypeDef *thisHMI);
void hmiInit(HMI_TypeDef *thisHMI);
void hmiUpdatemessageVN(HMI_TypeDef *thisHMI);
void hmiUpdatemessageVNESE(HMI_TypeDef *thisHMI);
void hmiCleardisplay(HMI_TypeDef *thisHMI);

#endif /* SRC__HMI_H_ */
