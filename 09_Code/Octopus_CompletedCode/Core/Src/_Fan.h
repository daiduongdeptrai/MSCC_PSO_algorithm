/*
 * _Fan.h
 *
 *  Created on: Feb 17, 2025
 *      Author: ADMIN
 */

#ifndef SRC__FAN_H_
#define SRC__FAN_H_

#include "stm32f1xx.h"
#include "stm32f1xx_hal_tim.h"
#include "stdint.h"
#include "stdbool.h"
#include "_BMS.h"
#include "_Battery.h"
#define FAN_UPDATE_PERIOD	600U
#define FAN_TEMP_LOWTHRESHOLD	50.0f
#define FAN_TEMP_HIGHTHRESHOLD	80.0f

extern TIM_HandleTypeDef htim4;
#define htim_FAN 		htim4
extern TIM_HandleTypeDef htim2;
#define htim_timcal 	htim2
#define MY_FAN_START()            ( htim_FAN.Instance->CCER |= (1 << 12 | 1 << 8), 	\
									htim_FAN.Instance->BDTR |= TIM_BDTR_MOE,         	\
									htim_FAN.Instance->CR1 |= TIM_CR1_CEN )

#define MY_FAN_STOP()             ( htim_FAN.Instance->CCER &= ~(1 << 12 | 1 << 8), 	\
									htim_FAN.Instance->BDTR &= ~TIM_BDTR_MOE,         	\
									htim_FAN.Instance->CR1 &= ~TIM_CR1_CEN )

typedef struct {
	uint16_t	updateCounter;
	uint16_t	updatePeriod;
	_Bool		updateFlag;
	FlagStatus	status;

	uint32_t 	timebase;
	uint32_t 	frequency;
	uint32_t 	duty;
} FAN_TypeDef;

void _fan_Init(FAN_TypeDef *pconfig);
void _fan_Updatespeed(FAN_TypeDef *pconfig);
void _fan_Setspeed(FAN_TypeDef pconfig);
#endif /* SRC__FAN_H_ */
