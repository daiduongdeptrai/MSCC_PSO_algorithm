/*
 * myPWM.h
 *
 *  Created on: Jan 9, 2025
 *      Author: ADMIN
 */

#ifndef SRC_MYPWM_H_
#define SRC_MYPWM_H_
#include "main.h"
#include "GlobalDefine.h"
extern TIM_HandleTypeDef htim1;
#define htim_PWM 		htim1

#define MY_PWM_START_LS()            ( htim_PWM.Instance->CCER |= (1 << 2 | 0 << 0), 	\
                                   htim_PWM.Instance->BDTR |= TIM_BDTR_MOE,     	\
								   htim_PWM.Instance->CR1 |= TIM_CR1_CEN )

#define MY_PWM_START()            ( htim_PWM.Instance->CCER |= (1 << 2 | 1 << 0), 	\
                                   htim_PWM.Instance->BDTR |= TIM_BDTR_MOE,     	\
								   htim_PWM.Instance->CR1 |= TIM_CR1_CEN )

#define MY_PWM_STOP()             ( htim_PWM.Instance->CCER &= ~(1 << 2 | 1 << 0),	\
                                   htim_PWM.Instance->BDTR &= ~TIM_BDTR_MOE,		\
                                   htim_PWM.Instance->CR1 &= ~TIM_CR1_CEN )

/**
 * @brief  PWM configuration structure definition.
 */
typedef struct{
	uint32_t timebase;
	uint32_t frequency;
	uint32_t duty;
	uint32_t deadtime;
} PwmConfig;

void pwmInit(PwmConfig *pconfig);
void pwmSetpfm(PwmConfig *pconfig);
void pwmSetpwm(PwmConfig *pconfig);

#endif /* SRC_MYPWM_H_ */
