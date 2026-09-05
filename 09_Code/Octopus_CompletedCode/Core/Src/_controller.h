/*
 * _Controller.h
 *
 *  Created on: Jan 10, 2025
 *      Author: ADMIN
 */

#ifndef SRC__CONTROLLER_H_
#define SRC__CONTROLLER_H_

#include "stdint.h"
#include "stdbool.h"
#include "stm32f1xx_hal.h"
#include "fastMath.h"
#include "myADC.h"
#include "GlobalDefine.h"
#include "cal_FixedPointMath.h"
#include "myPWM.h"

typedef struct{
	uint16_t	Q_FIX;
	int		Fix_Kp;
	int		Fix_Ki;
	int		Fix_Ki_x_Tz;
	int 	RefVal;
	int 	FeedBackVal;
	int		HighLimit;
	int 	LowLimit;
	int		GainSense;
	int 	Output;
	int     OperatingPoint;
	FunctionalState 	State;
}	Controller_FixPoint_TypeDef;

void _Controller_Init(Controller_FixPoint_TypeDef *CC_Controller, Controller_FixPoint_TypeDef *CV_Controller);
void _Controller_AntiWindUp(Controller_FixPoint_TypeDef	*Controller_Params, int *integral, int proportional);
void _Controller_CV(Controller_FixPoint_TypeDef	*CV_Controller, AdcTypeDef thisADC);
void _Controller_CC(Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC);
void _Controller_CV_CC(Controller_FixPoint_TypeDef	*CV_Controller, Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC, PwmConfig *thisPWM);
void _Controller_CV_CC_Reuse(Controller_FixPoint_TypeDef	*CV_Controller, Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC, PwmConfig *thisPWM, FunctionalState State);

void _Controller_RampUp(uint32_t input, int step, uint32_t *output);
_Bool ISR_Delay_us(const uint32_t delay);
void _Controller_CC_UpdateOperatingPoint(Controller_FixPoint_TypeDef *CC_Controller, AdcTypeDef thisADC);

extern int rampup;
#endif /* SRC__CONTROLLER_H_ */
