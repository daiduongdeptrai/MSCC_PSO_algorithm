/*
 * _HMI.c
 *
 *  Created on: Dec 20, 2024
 *      Author: Duy-Dinh Nguyen
 */

#include "globalDefine.h"
#include "_HMI.h"
#include "_Battery.h"
#include "myI2CLCD.h"
#include "_Speaker.h"
#include "_BMS.h"
#include "stdio.h"
#include "myADC.h"
#include "myBQ76942_I2C.h"
extern Battery_TypeDef	thisBattery;
extern Speaker_TypeDef	thisSpeaker;
extern BMS_TypeDef		thisBMS;
extern AdcTypeDef		thisADC;

HMI_TypeDef		thisHMI = { .updateCounter 	= 0,
							.updatePeriod	= 0,
							.updateFlag 	= true,
							.showTime		= _HMI_SHOW_TIME,
							.lineBlink		= 0x00,
							.strLine1 		= "       TBS-19       ",
							.strLine2 		= "DANG KHOI DONG...",
							.strLine3 		= "",
							.strLine4 		= "",
							.pageNumber			= _HMI_PAGE_00,
							};

/**
 * @brief Set the fan speed.
 * 
 * This function sets the fan speed by updating the PWM duty cycle.
 * The duty cycle is written to the CCR4 register of the timer controlling the fan.
 * 
 * @param pconfig Fan configuration structure containing the duty cycle.
 */							
void hmiCleardisplay(HMI_TypeDef *thisHMI){
	thisHMI->strLine1[0] = '\0';	// clear string
	thisHMI->strLine2[0] = '\0';	// clear string
	thisHMI->strLine3[0] = '\0';	// clear string
	thisHMI->strLine4[0] = '\0';	// clear string
	lcdClear();						// clear the LCD display
	return;
}

int	startTime 	= 0;
int	elapseTime	= 0;
/**
 * @brief Initialize the HMI module.
 * 
 * This function initializes the HMI module by setting up the LCD, clearing the display,
 * and configuring the initial parameters of the HMI structure.
 * 
 * @param thisHMI Pointer to the HMI structure.
 */
void hmiInit(HMI_TypeDef *thisHMI){
	lcdInit();
	lcdClear();
	HAL_Delay(1000);
	thisHMI->updateCounter	= 0;
	thisHMI->updatePeriod	= HMI_UPDATE_PERIOD;
	thisHMI->updateFlag 	= false;
	thisHMI->lineBlink 		= (_HMI_BLINK_LINE_1 | _HMI_BLINK_LINE_2 | _HMI_BLINK_LINE_3 | _HMI_BLINK_LINE_4);
	return;
}

/**
 * @brief Update the HMI message in Vietnamese.
 * 
 * This function updates the HMI display based on the current status of the BMS and battery.
 * It handles various error conditions and displays appropriate messages on the LCD.
 * 
 * @param thisHMI Pointer to the HMI structure.
 */
void hmiUpdatemessageVN(HMI_TypeDef *thisHMI){
	if ((thisBMS.Status.Shadow & BMS_ERROR_ADAPTOR_NEED_REPLACE) && (thisBMS.Status.Shadow & BMS_ERROR_BATTERY_NO_DETECTED)){
		if ((thisHMI->pageNumber != _HMI_PAGE_01) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_01;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_3 + _HMI_BLINK__ONLY_LINE_2;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON: CAN THAY THE ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  : CHUA KET NOI ");
		if (thisBMS.Status.Shadow & BMS_STT_ERROR_208){
			thisHMI->lineBlink  |= _HMI_BLINK__ONLY_LINE_4;
			snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "NHIET DO CAO!");
		}
		else snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "");
		setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		return;
	}

	if ((thisBMS.Status.Shadow & BMS_ERROR_ADAPTOR_NEED_REPLACE) && (thisBMS.Status.Shadow & BMS_ERROR_BATTERY_NEED_REPLACE)){
		if ((thisHMI->pageNumber != _HMI_PAGE_02) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_02;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_3 + _HMI_BLINK__ONLY_LINE_2;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON: CAN THAY THE ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  : CAN THAY THE ");
		if (thisBMS.Status.Shadow & BMS_STT_ERROR_208){
			thisHMI->lineBlink  |= _HMI_BLINK__ONLY_LINE_4;
			snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "NHIET DO CAO!");
		}
		else snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "");
		setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		return;
	}

	if ((thisBMS.Status.Shadow & BMS_ERROR_ADAPTOR_NEED_REPLACE) && (!(thisBMS.Status.Shadow & BMS_ERROR_BATTERY_NEED_REPLACE))){
		if ((thisHMI->pageNumber != _HMI_PAGE_03) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_03;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_2;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON: CAN THAY THE ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  :  DA KET NOI  ");
		if (thisBMS.Status.Shadow & BMS_STT_ERROR_208){
			thisHMI->lineBlink  |= _HMI_BLINK__ONLY_LINE_4;
			snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "NHIET DO CAO!");
		}
		else snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "");
		setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		return;
	}

	if ((!(thisBMS.Status.Shadow & BMS_ERROR_ADAPTOR_NEED_REPLACE)) && (thisBMS.Status.Shadow & BMS_ERROR_BATTERY_NO_DETECTED)){
		if ((thisHMI->pageNumber != _HMI_PAGE_04) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_04;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_3;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON:  DA KET NOI  ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  : CHUA KET NOI ");
		if (thisBMS.Status.Shadow & BMS_STT_ERROR_208){
			thisHMI->lineBlink  |= _HMI_BLINK__ONLY_LINE_4;
			snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "NHIET DO CAO!");
		}
		else snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "");
		setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		return;
	}

	if ((!(thisBMS.Status.Shadow & BMS_ERROR_ADAPTOR_NEED_REPLACE)) && (thisBMS.Status.Shadow & BMS_ERROR_BATTERY_NEED_REPLACE)){
		if ((thisHMI->pageNumber != _HMI_PAGE_05) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_05;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_3;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON:  DA KET NOI  ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  : CAN THAY THE ");
		if (thisBMS.Status.Shadow & BMS_STT_ERROR_208){
			thisHMI->lineBlink  |= _HMI_BLINK__ONLY_LINE_4;
			snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "NHIET DO CAO!");
		}
		else snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "");
		setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		return;
	}

	// Bo sung them phan hien thi so lan sac neu an giu mot thoi gian
	if (((thisBMS.Status1.Shadow & BMS_STT_NUMCHARGE_HMI)) && (thisHMI->showTime == 0)){
		if ((thisHMI->pageNumber != _HMI_PAGE_06) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_06;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink = _HMI_BLINK__ONLY_LINE_4;
			setSpeaker_Config(&thisSpeaker, SPEAKER_DOUBLE_BEEP, 1);
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "SO LAN DA SAC: %d", thisBattery.numberOfCharge);
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "");
		snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "BAM NUT DE SAC      ");
		return;
	}

	if (((thisBMS.Status1.Shadow & BMS_STT_BATTERY_FULL)) && (thisHMI->showTime == 0))  {
		if (thisHMI->pageNumber != _HMI_PAGE_06) {
			thisHMI->pageNumber = _HMI_PAGE_06;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_1;
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "PIN DA SAC DAY|Vpin ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%.2f|%.2f|%.2f|%4.1fV",
				(float)thisBattery.cellVoltage[0]*0.001f,
				(float)thisBattery.cellVoltage[1]*0.001f,
				(float)thisBattery.cellVoltage[2]*0.001f,
				(float)thisBattery.batVoltage*0.001f);
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%.2f|%.2f|%.2f|Isac ", \
				(float)thisBattery.cellVoltage[3]*0.001f,
				(float)thisBattery.cellVoltage[4]*0.001f,
				(float)thisBattery.cellVoltage[5]*0.001f);
		snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%.2f|%.2f|%.2f|%-4.1fA", \
				(float)thisBattery.cellVoltage[6]*0.001f,
				(float)thisBattery.cellVoltage[7]*0.001f,
				(float)thisBattery.cellVoltage[8]*0.001f,
				(float)thisBattery.batCurrent*0.001f);
		setSpeaker_Config(&thisSpeaker, SPEAKER_LONG_BEEP, 1);
		return;
	}

	if ((!(thisBMS.Status1.Shadow & BMS_STT_CHARGE_BALANCE_BUTTON_PRESSED)) && (thisHMI->showTime == 0)){
		if ((thisHMI->pageNumber != _HMI_PAGE_07) && (thisHMI->showTime == 0)) {
			thisHMI->pageNumber = _HMI_PAGE_07;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_4;
			setSpeaker_Config(&thisSpeaker, SPEAKER_SHORT_BEEP, 1);
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "       TBS-19       ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "NGUON:  DA KET NOI  ");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%s", "PIN  :  DA KET NOI  ");
		snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%s", "BAM NUT DE SAC      ");
		return;
	}

	if ((!(thisBMS.Status1.Shadow & BMS_STT_STOP_BUTTON_PRESSED)) && (thisHMI->showTime == 0))  {
		if (thisHMI->pageNumber != _HMI_PAGE_08) {
			thisHMI->pageNumber = _HMI_PAGE_08;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_1;
			setSpeaker_Config(&thisSpeaker, SPEAKER_SHORT_BEEP, 1);
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1), "%s", "DANG SAC...   |Vpin ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%.2f|%.2f|%.2f|%4.1fV",
				(float)thisBattery.cellVoltage[0]*0.001f,
				(float)thisBattery.cellVoltage[1]*0.001f,
				(float)thisBattery.cellVoltage[2]*0.001f,
				(float)thisBattery.batVoltage*0.001f);
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "%.2f|%.2f|%.2f|Isac ", \
				(float)thisBattery.cellVoltage[3]*0.001f,
				(float)thisBattery.cellVoltage[4]*0.001f,
				(float)thisBattery.cellVoltage[5]*0.001f);
		snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "%.2f|%.2f|%.2f|%-4.1fA", \
				(float)thisBattery.cellVoltage[6]*0.001f,
				(float)thisBattery.cellVoltage[7]*0.001f,
				(float)thisBattery.cellVoltage[8]*0.001f,
				(float)thisBattery.batCurrent*0.001f);
		return;
	}

	if (((thisBMS.Status1.Shadow & BMS_STT_STOP_BUTTON_PRESSED)) && (thisHMI->showTime == 0))  {
		if (thisHMI->pageNumber != _HMI_PAGE_09) {
			thisHMI->pageNumber = _HMI_PAGE_09;
			thisHMI->showTime	= _HMI_SHOW_TIME;
			thisHMI->lineBlink  = _HMI_BLINK__ONLY_LINE_1;
			setSpeaker_Config(&thisSpeaker, SPEAKER_SHORT_BEEP, 1);
		}
		snprintf(thisHMI->strLine1, sizeof(thisHMI->strLine1),"%s", "DUNG SAC! ");
		snprintf(thisHMI->strLine2, sizeof(thisHMI->strLine2), "%s", "HAY RUT ADAPTOR");
		snprintf(thisHMI->strLine3, sizeof(thisHMI->strLine3), "Vdc=%.1fV", (float)thisBMS.adaptorVoltage*0.001f);
		snprintf(thisHMI->strLine4, sizeof(thisHMI->strLine4), "Vbat=%.1fV", (float)thisBattery.batVoltage*0.001f);
		return;
	}
}

/**
 * @brief Update the HMI display.
 * 
 * This function updates the LCD display with the current strings in the HMI structure.
 * It also handles blinking of specific lines based on the `lineBlink` configuration.
 * 
 * @param thisHMI Pointer to the HMI structure.
 */
_Bool	_lineBlinked = false;
void hmiUpdatedisplay(HMI_TypeDef *thisHMI){
// Update HMI by showTime count
	if (thisHMI->showTime > 0)
		thisHMI->showTime--;

// Blink lines simultaneously based on requirements
	if (_lineBlinked) {
		if (thisHMI->lineBlink & _HMI_BLINK_LINE_1) lcdXYprintf(0, 0, "                    ");
		else lcdXYprintf(0, 0, thisHMI->strLine1);

		if (thisHMI->lineBlink & _HMI_BLINK_LINE_2) lcdXYprintf(1, 0, "                    ");
		else lcdXYprintf(1, 0, thisHMI->strLine2);

		if (thisHMI->lineBlink & _HMI_BLINK_LINE_3) lcdXYprintf(2, 0, "                    ");
		else lcdXYprintf(2, 0, thisHMI->strLine3);

		if (thisHMI->lineBlink & _HMI_BLINK_LINE_4) lcdXYprintf(3, 0, "                    ");
		else lcdXYprintf(3, 0, thisHMI->strLine4);

		_lineBlinked = false;
	} else {
		if (thisHMI->lineBlink & _HMI_BLINK_LINE_1) lcdXYprintf(0, 0, thisHMI->strLine1);
		if (thisHMI->lineBlink & _HMI_BLINK_LINE_2) lcdXYprintf(1, 0, thisHMI->strLine2);
		if (thisHMI->lineBlink & _HMI_BLINK_LINE_3) lcdXYprintf(2, 0, thisHMI->strLine3);
		if (thisHMI->lineBlink & _HMI_BLINK_LINE_4) lcdXYprintf(3, 0, thisHMI->strLine4);

		_lineBlinked = true;
	}
	return;
}
