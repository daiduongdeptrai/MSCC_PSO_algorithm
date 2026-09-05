/*
 * myADC.h
 *
 *  Created on: Jan 24, 2025
 *      Author: ADMIN
 */

#ifndef SRC_MYADC_H_
#define SRC_MYADC_H_

#include "GlobalDefine.h"
#include "stdint.h"
#include "fastMath.h"
#include "stm32f1xx_hal.h"
#include "stm32f1xx_ll_adc.h"

extern ADC_HandleTypeDef hadc1;
#define hadc			hadc1
#define ADC_BUF_MAX_ELEMENTS	4

#define GET_ADC_POSITIVE(value) (((value) > 0) ? ((value)) : 0)
#define SAFE_SUBTRACT(a, b) ((a) > (b) ? ((a) - (b)) : 0)
#define	CURRENT_OFFSET			3103U		// 2,5/3,3 * 65520 ADC left Alignment
extern uint16_t g_BufAdc1[ADC_BUF_MAX_ELEMENTS];

/*
 * BufAdc1		[0]				[1]				[2]
 * 				adcVdcfb		adcVbatfb		adcIbatfb
 */
typedef struct{
	uint16_t BufAdc[4];
	uint16_t BufAdcDcVoltage;
	uint16_t BufAdcTemp;
	uint16_t BufAdcBattVoltage;
	uint16_t BufAdcBattCurrent;
} AdcTypeDef;

void adcInit(AdcTypeDef *pAdc);
void adcRead(AdcTypeDef *pAdc);
void adcWaitforconversion();
void adcResumeconversion();

#endif /* SRC_MYADC_H_ */
