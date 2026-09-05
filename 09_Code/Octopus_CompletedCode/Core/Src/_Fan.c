/*
 * _Fan.c
 *
 *  Created on: Feb 17, 2025
 *      Author: ADMIN
 */

#include "_Fan.h"

extern Battery_TypeDef	thisBattery;
extern BMS_TypeDef		thisBMS;

/**
 * @brief Initialize the fan configuration.
 * 
 * This function initializes the fan configuration structure with default values.
 * It sets the update counter, update flag, status, update period, timebase, duty cycle,
 * and frequency to their initial states.
 * 
 * @param pconfig Pointer to the fan configuration structure.
 */
void _fan_Init(FAN_TypeDef *pconfig){
	pconfig->updateCounter 	= 0;
	pconfig->updateFlag 	= false;
	pconfig->status			= RESET;
	pconfig->updatePeriod	= FAN_UPDATE_PERIOD;
	pconfig->timebase		= 1600;
	pconfig->duty			= 0;
	pconfig->frequency		= 0;
	return;
}

/**
 * @brief Update the fan speed based on battery temperature.
 * 
 * This function adjusts the fan speed (duty cycle) based on the battery temperature.
 * If the temperature is below the low threshold, the fan is turned off.
 * If the temperature is above the high threshold, the fan runs at medium speed.
 * Otherwise, the fan runs at high speed.
 * 
 * @param pconfig Pointer to the fan configuration structure.
 */
void _fan_Updatespeed(FAN_TypeDef *pconfig){
	if( (thisBattery.batTemperature[1] < FAN_TEMP_LOWTHRESHOLD) || (thisBattery.batTemperature[2] \
			< FAN_TEMP_LOWTHRESHOLD) || (thisBattery.batTemperature[3] < FAN_TEMP_LOWTHRESHOLD) ){
		pconfig->duty 		= 0;
		_fan_Setspeed(*pconfig);
	}
	else if( (thisBattery.batTemperature[1] > FAN_TEMP_HIGHTHRESHOLD) || (thisBattery.batTemperature[2] \
			> FAN_TEMP_HIGHTHRESHOLD) || (thisBattery.batTemperature[3] > FAN_TEMP_HIGHTHRESHOLD) ){
		pconfig->duty 		= 400;
		_fan_Setspeed(*pconfig);
	}
	else {
		pconfig->duty 		= 800;
		_fan_Setspeed(*pconfig);
	}
	return;
}

/**
 * @brief Set the fan speed.
 * 
 * This function sets the fan speed by updating the PWM duty cycle.
 * The duty cycle is written to the CCR4 register of the timer controlling the fan.
 * 
 * @param pconfig Fan configuration structure containing the duty cycle.
 */
void _fan_Setspeed(FAN_TypeDef pconfig){
    htim_FAN.Instance->CCR4 = pconfig.duty;														// Compare capture of PWM -> Duty of PWM
    return;
}
