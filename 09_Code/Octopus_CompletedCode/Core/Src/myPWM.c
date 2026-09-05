/*
 * myPWM.c
 *
 *  Created on: Jan 9, 2025
 *      Author: ADMIN
 */


#include "myPWM.h"

/**
  * @brief  Initialize the PWM with the specified configuration.
  * @param  thisPWM: Pointer to a myPWM_TypeDef structure that contains the configuration information.
  * @retval None
  */

void pwmInit(PwmConfig *pconfig){
	pconfig->timebase = 427;		// Frequency = 64 M Hz / TimeBase ~ 500 kHz
	pconfig->duty	  = 30;		// Duty 	 = 50% - 160
	pconfig->deadtime = 25;		// Dead time = dead time/64 MHz
	return;
}

/**
  * @brief  Set the PWM frequency modulation.
  * @note   Notice the range of Register BDTR, ensure this value does not exceed 0xFFU = 255.
  *         Modify frequency through ARR register and duty through CCR register.
  *         This function uses Channel 3 and dead time through BDTR register.
  * @param  thisPWM: Pointer to a myPWM_TypeDef structure that contains the configuration information.
  * @retval None
  */
void pwmSetpfm(PwmConfig *pconfig){
    htim_PWM.Instance->ARR = pconfig->timebase;														// Time base of PWM -> Frequency
    htim_PWM.Instance->CCR1 = pconfig->duty;														// Compare capture of PWM -> Duty of PWM
    if (pconfig->deadtime <= 0xFFU) {																// Check maximum of dead-time
    	htim_PWM.Instance->BDTR = (htim_PWM.Instance->BDTR & ~TIM_BDTR_DTG) | pconfig->deadtime;		// Pass dead-time value into register: Erase register before passing value
        }
}
/**
 * @brief  Set the PWM duty cycle.
 * 
 * This function sets the PWM duty cycle by updating the CCR1 register of the timer.
 * The duty cycle is calculated as a percentage of the timebase value.
 * 
 * @param  pconfig Pointer to a PwmConfig structure that contains the configuration information.
 * @retval None
 */
void pwmSetpwm(PwmConfig *pconfig){
    htim_PWM.Instance->CCR1 = (uint16_t)((pconfig->duty)*(pconfig->timebase));														// Compare capture of PWM -> Duty of PWM
    return;
}




