/*
 * _NumberofCharge.h
 *
 *  Created on: Feb 22, 2025
 *      Author: ADMIN
 */

#ifndef SRC__NUMBEROFCHARGE_H_
#define SRC__NUMBEROFCHARGE_H_

#include "stm32f1xx.h"
#include "stdint.h"
#include "stdbool.h"
#define NUMBEROFCHARGE_UPDATE_PERIOD	300U
#define NUMBEROFCHARGE_HMI_PERIOD		10000U
#define DELAY_3S						30000U

typedef struct {
	uint16_t	updateCounter;
	uint16_t	updatePeriod;
	_Bool		updateFlag;
	_Bool		IncreasedNum;
	FlagStatus	FullCharged;
	uint16_t 	numcharge;
	uint16_t 	updateButtonCounter;

	uint16_t 	updateCounterHmi;
	uint16_t 	updatePeriodHmi;
	_Bool		updateFlagHmi;
} NumCharge_TypeDef;

void numchargeInit(NumCharge_TypeDef *pconfig);
void numchargeUpdate(NumCharge_TypeDef *pconfig, uint16_t numberofcharge);

#endif /* SRC__NUMBEROFCHARGE_H_ */
