/*
 * globalDefine.c
 *
 *  Created on: Mar 6, 2021
 *      Author: Duy-Dinh Nguyen
 */

#include "globalDefine.h"
#include "_HMI.h"

blinkPeriod_TypeDef blinkPeriod = LED_MED;
uint16_t 			cnt_Led_Update 	= 0;
uint16_t 	cnt_Indicator_Update 		= 0U;
_Bool 		flg_Indicator_Update		= false;

uint16_t	cnt_SeriesComm_Update		= 0U;
_Bool		flg_SeriesComm_Update		= false;
uint16_t 	g_cnt_stateSW = 0;
uint16_t 	g_checkCode = 0;
_Bool 		FETONFlag = false;

