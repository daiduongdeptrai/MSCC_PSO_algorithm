/*
 * _SystemState.c
 *
 *  Created on: Mar 3, 2025
 *      Author: ADMIN
 */

#include "_SystemState.h"
extern PwmConfig 	thisPWM;
extern AdcTypeDef 	thisADC;
extern Controller_FixPoint_TypeDef	CC_Controller;
extern Controller_FixPoint_TypeDef	CV_Controller;

void _statechargerInit(ChargerTypeDef	*pCharger){
	/*
	 * Initializing state
	 */
	pCharger->ChargerState			= STATE_BATTERY_CHECK;
	pCharger->ProtectionMode		= PROTECT_MODE_NONE;
	pCharger->ChargerMode 			= CHARGER_NO_CHARGE;
	pCharger->State					= DISABLE;
	pCharger->RelayState			= DISABLE;
	pCharger->RelayisON				= false;
	pCharger->UpdateChargeCount		= false;
	pCharger->ReadyCharging			= false;
	pCharger->Temperature			= 0.0f;

	/*
	 * Initializing threshold parameters
	 */
	pCharger->ChgThrd.imax_ADC 		= (uint16_t)(IMAX/IBAT_GAIN);
	pCharger->ChgThrd.vmax_ADC 		= (uint16_t)(VMAX/VBAT_GAIN);
	pCharger->ChgThrd.tempmax_ADC 	= (uint16_t)(2000);
	pCharger->ChgThrd.tempmax		= (float) (TEMPMAX);

	pCharger->ChgThrd.vbulk_ADC 	= (uint16_t)(VBULK/VBAT_GAIN);
	pCharger->ChgThrd.vfull_ADC		= (uint16_t)(VFULL/VBAT_GAIN);
	pCharger->ChgThrd.ipre_ADC 		= (uint16_t)(IPRE/IBAT_GAIN);
	pCharger->ChgThrd.vddchg_ADC 	= (uint16_t)(VDDCHRG/VBAT_GAIN);
	pCharger->ChgThrd.vmin_ADC   	= (uint16_t)(VMIN/VBAT_GAIN);
	pCharger->ChgThrd.imin_ADC   	= (uint16_t)(IMIN/IBAT_GAIN);
	return;
}

/**
 * @brief Update the state of the charger.
 *
 * This function updates the state of the charger based on the ADC and comparator values.
 * It processes the current state and transitions to the next state if necessary.
 *
 * @param pCharger Pointer to the charger structure.
 * @param adc The ADC structure containing the current ADC values.
 * @param comp The comparator structure containing the current comparator values.
 */
void _statechargerUpdate(ChargerTypeDef	*pCharger, AdcTypeDef adc, Battery_TypeDef batParam)
{
    /*--------------- Update for Charger State ---------------------------------------- */
    if (adc.BufAdcBattCurrent > pCharger->ChgThrd.imax_ADC){     		/* Over Power Protect */
    	pCharger->ProtectionMode = PROTECT_MODE_OCP2;
    }
    else if (adc.BufAdcBattVoltage > pCharger->ChgThrd.vmax_ADC){      		/* Over Output Voltage Protect */
    	pCharger->ProtectionMode = PROTECT_MODE_OVP;
    }
    else if (pCharger->Temperature > pCharger->ChgThrd.tempmax){      	/* Over Temperature Protect */
    	pCharger->ProtectionMode = PROTECT_MODE_OTP;
    }
    else {pCharger->ProtectionMode = PROTECT_MODE_NONE;}

    /*--------------- Update for Charger State ---------------------------------------- */
    if (pCharger->ProtectionMode != PROTECT_MODE_NONE){
    	pCharger->ChargerState = STATE_PROTECTION;
    }
    else if ( (batParam.ADCbatVoltage < pCharger->ChgThrd.vmin_ADC) && !(pCharger->ChargerState == STATE_SOFT_START) \
    		&& !(pCharger->ChargerState == STATE_HAND_SHAKE) && !(pCharger->ChargerState == STATE_PROTECTION)){
    	pCharger->ChargerState = STATE_BATTERY_CHECK;
    }
    else if ( (pCharger->ChargerState == STATE_BATTERY_CHECK) && (batParam.ADCbatVoltage < pCharger->ChgThrd.vbulk_ADC)\
    		&& (batParam.ADCbatVoltage >= pCharger->ChgThrd.vmin_ADC)){
    	pCharger->ChargerState = STATE_CHARGING_REQUEST;
    }
    else if ( pCharger->ChargerState == STATE_CHARGING_REQUEST ){
    	pCharger->ChargerState = STATE_SOFT_START;
    }
    else if ( (pCharger->ChargerState == STATE_SOFT_START) && (adc.BufAdcBattVoltage >= batParam.ADCbatVoltage + OFFSET_HANDSHAKE) ){
        pCharger->ChargerState = STATE_HAND_SHAKE;
    }
    else if ( (pCharger->ChargerState == STATE_HAND_SHAKE) && (pCharger->RelayisON == true)){
    	pCharger->ChargerState = STATE_CHARGING;
    }
    else if ( (pCharger->ChargerState == STATE_CHARGING) &&  (pCharger->ChargerMode == CHARGER_FUL_CHARGE)){
    	pCharger->ChargerState = STATE_FULCHARGED;
    }

    /*--------------- Update for Charger Mode---------------------------------------- */
    if (  (adc.BufAdcBattVoltage >= pCharger->ChgThrd.vfull_ADC) && (adc.BufAdcBattCurrent < pCharger->ChgThrd.ipre_ADC)  ){
        	pCharger->ChargerMode = CHARGER_FUL_CHARGE;
        }
    else if (  (adc.BufAdcBattVoltage >= pCharger->ChgThrd.vbulk_ADC) && (adc.BufAdcBattCurrent > pCharger->ChgThrd.ipre_ADC)  ){
    		pCharger->ChargerMode = CHARGER_CV_CHARGE;
    }
    else if (  (adc.BufAdcBattVoltage < pCharger->ChgThrd.vbulk_ADC) && (adc.BufAdcBattVoltage > pCharger->ChgThrd.vddchg_ADC)  ){
    		pCharger->ChargerMode = CHARGER_CC_CHARGE;
    }
    else{
        	pCharger->ChargerMode = CHARGER_NO_CHARGE;
        }
    return;
}

/**
 * @brief Perform battery check during the charging process.
 * 
 * This function resets the PWM and controller parameters to ensure the system
 * is in a safe state before starting or continuing the charging process.
 * It is typically used when the battery needs to be checked or re-initialized.
 * 
 * @param CCcontrol Pointer to the CC (Constant Current) controller structure.
 * @param CVcontrol Pointer to the CV (Constant Voltage) controller structure.
 * @param adc ADC structure containing the latest readings.
 * @param thisPWM Pointer to the PWM configuration structure.
 */
void _Charging_BatteryCheck(Controller_FixPoint_TypeDef	*CCcontrol, Controller_FixPoint_TypeDef	*CVcontrol, AdcTypeDef adc, PwmConfig *thisPWM){
	// Turn off PWM, re-initialize PWM parameters

	// Reset SoftStart parameters
	_Charging_SoftStart_UpdateDuty(thisPWM, DISABLE);

	// Reset Controller parameters
	_Controller_CV_CC_Reuse(&CV_Controller, &CC_Controller, adc, thisPWM, DISABLE);
	CCcontrol->State = DISABLE;
	CVcontrol->State = DISABLE;
	_Controller_CC(CCcontrol, adc);
	_Controller_CV(CVcontrol, adc);
	MY_PWM_STOP();
	pwmInit(thisPWM);
	return;
}

/**
 * @brief Delay function for soft start.
 * 
 * This function provides a delay in microseconds using a software counter.
 * 
 * @param delay Desired delay in microseconds.
 * @retval _Bool Returns 1 when the delay is complete, otherwise 0.
 */

_Bool _Charging_Delay_us(const uint32_t delay)
{
    static uint32_t delayCycleCnt = 0;
    const uint32_t endDelayCnt = delay;
    if (delayCycleCnt < endDelayCnt)
    {
        delayCycleCnt++;
        return 0;
    }
    else
    {
        delayCycleCnt = 0;
        return 1;
    }
}

/**
 * @brief Update the duty cycle during the soft start process.
 * 
 * This function gradually increases the PWM duty cycle during the soft start process.
 * If the state is disabled, it resets the duty cycle to the initial value.
 * 
 * @param thisPWM Pointer to the PWM configuration structure.
 * @param State Functional state (ENABLE or DISABLE).
 */
void _Charging_SoftStart_UpdateDuty(PwmConfig *thisPWM, FunctionalState State)
{
    static uint16_t instantPeriod = 30; 	// Maximum frequency = 500 kHz		Frequency = 64e6/EndPeriod
    const uint16_t EndPeriod = 392; 		// Minimum frequency = 100 kHz		Frequency = 64e6/EndPeriod

    if (State == DISABLE){
    	instantPeriod = 30;
    }
    else {
        if( _Charging_Delay_us(300))
        {
            if (instantPeriod < EndPeriod)
            {
                instantPeriod++;
                thisPWM->duty = instantPeriod;
            }
       }
    }
}

/**
 * @brief Turn off the charging relay.
 * 
 * This function disables the relay to disconnect the charger from the battery.
 * 
 * @param pCharger Pointer to the charger structure.
 */
void _Charging_Relay_OFF(ChargerTypeDef	*pCharger){
	pCharger->RelayState = DISABLE;
	return;
}

/**
 * @brief Turn on the charging relay.
 * 
 * This function enables the relay to connect the charger to the battery.
 * 
 * @param pCharger Pointer to the charger structure.
 */
void _Charging_Relay_ON(ChargerTypeDef	*pCharger){
	pCharger->RelayState = ENABLE;
	return;
}

/**
 * @brief Perform the soft start process.
 * 
 * This function gradually increases the PWM duty cycle to ensure a smooth start
 * of the charging process. It updates the duty cycle and starts the PWM.
 */
void _Charging_Soft_Start(){
    _Charging_SoftStart_UpdateDuty(&thisPWM, ENABLE);
	pwmSetpfm(&thisPWM);
	MY_PWM_START();
    return;
}

/**
 * @brief Perform the handshake process for charging.
 * 
 * This function stops the PWM and turns on the relay to establish a connection
 * between the charger and the battery.
 * 
 * @param pCharger Pointer to the charger structure.
 */
void _Charging_HandShake(ChargerTypeDef	*pCharger){
   MY_PWM_STOP();
   _Charging_Relay_ON(pCharger);
   return;
}

/**
 * @brief Handle the full charge state.
 * 
 * This function stops the PWM and turns off the relay when the battery is fully charged.
 * 
 * @param pCharger Pointer to the charger structure.
 */
void _Charging_FulCharged(ChargerTypeDef	*pCharger){
	MY_PWM_STOP();
	_Charging_Relay_OFF(pCharger);
	return;
}

/**
 * @brief Handle the protection state.
 * 
 * This function stops the PWM and turns off the relay when a protection condition is triggered.
 * 
 * @param pCharger Pointer to the charger structure.
 */
void _Charging_Protection(ChargerTypeDef	*pCharger){
	MY_PWM_STOP();
	_Charging_Relay_OFF(pCharger);
}

