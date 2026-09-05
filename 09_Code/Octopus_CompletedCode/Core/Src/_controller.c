/*
 * _Controller.c
 *
 *  Created on: Jan 10, 2025
 *      Author: ADMIN
 */

#include "_controller.h"
int rampup = 0;
/**
 * @brief Initialize the parameters for CV and CC controllers.
 *
 * This function initializes the parameters for both CV (Constant Voltage) and CC (Constant Current) controllers.
 * It sets the proportional gain, integral gain, reference value, feedback value, state, error, proportional term,
 * integral term, high limit, low limit, and output for each controller.
 *
 * @param pcontrollerCV Pointer to the CV controller structure.
 * @param pcontrollerCC Pointer to the CC controller structure.
 */
void _Controller_Init(Controller_FixPoint_TypeDef *CC_Controller, Controller_FixPoint_TypeDef *CV_Controller){
	/* CC Controller Initialization*/
	CC_Controller->Q_FIX		= 15;
	CC_Controller->Fix_Kp		= _TO_FIX(kpI,CC_Controller->Q_FIX);
	CC_Controller->Fix_Ki		= _TO_FIX(kiI,CC_Controller->Q_FIX);
	CC_Controller->Fix_Ki_x_Tz	= _TO_FIX(kiI_x_Tz,CC_Controller->Q_FIX);

	CC_Controller->RefVal 		= _TO_FIX(IBULK ,CC_Controller->Q_FIX);
	CC_Controller->GainSense	= _TO_FIX(IBAT_GAIN, CC_Controller->Q_FIX);						// Use Q15 due to IBAT_GAIN too small - 0.0128
	CC_Controller->FeedBackVal 	= 0;
	CC_Controller->HighLimit 	= _TO_FIX(DUTY_HIGH_LIMIT, CC_Controller->Q_FIX);
	CC_Controller->LowLimit 	= _TO_FIX(DUTY_LOW_LIMIT, CC_Controller->Q_FIX);
	CC_Controller->Output		= 0;
	CC_Controller->State		= DISABLE;
	CC_Controller->OperatingPoint = 0;
	/* CV Controller Initialization*/
	CV_Controller->Q_FIX		= 14;
	CV_Controller->Fix_Kp		= _TO_FIX(kpV,CV_Controller->Q_FIX);
	CV_Controller->Fix_Ki		= _TO_FIX(kiV,CV_Controller->Q_FIX);
	CV_Controller->Fix_Ki_x_Tz	= _TO_FIX(kiV_x_Tz,CV_Controller->Q_FIX);

	CV_Controller->RefVal 		= _TO_FIX(VBULK ,CV_Controller->Q_FIX);
	CV_Controller->GainSense	= _TO_FIX(VBAT_GAIN, CV_Controller->Q_FIX);
	CV_Controller->FeedBackVal 	= 0;
	CV_Controller->HighLimit 	= _TO_FIX(IMAX_CTRL, CV_Controller->Q_FIX);
	CV_Controller->LowLimit 	= _TO_FIX(IMIN, CV_Controller->Q_FIX);
	CV_Controller->Output		= 0;
	CV_Controller->State		= DISABLE;
	CV_Controller->OperatingPoint = 0;
	return;
}

/**
 * @brief Ramp up the output value gradually.
 * 
 * This function increments the output value step by step until it reaches the input value.
 * It is used to prevent sudden changes in the output, ensuring a smooth transition.
 * 
 * @param input Target value to ramp up to.
 * @param step Incremental step size for each ramp-up iteration.
 * @param output Pointer to the current output value to be updated.
 */
void _Controller_RampUp(uint32_t input, int step, uint32_t *output){
    if (input > *output) {
        *output += step;
    }
    return;
}

/**
 * @brief Anti-windup mechanism for the controller.
 * 
 * This function prevents the integral term from exceeding the controller's output limits.
 * If the output exceeds the high or low limit, the integral term is adjusted accordingly.
 * 
 * @param Controller_Params Pointer to the controller structure.
 * @param integral Pointer to the integral term.
 * @param proportional Proportional term of the controller.
 */
void _Controller_AntiWindUp(Controller_FixPoint_TypeDef	*Controller_Params, int *integral, int proportional){
	if (Controller_Params->Output > Controller_Params->HighLimit)
	{
		Controller_Params->Output = Controller_Params->HighLimit;
		*integral = Controller_Params->HighLimit - proportional;
	}
	else if (Controller_Params->Output < Controller_Params->LowLimit)
	{
		Controller_Params->Output = Controller_Params->LowLimit;
		*integral = Controller_Params->LowLimit - proportional;
	}
	else Controller_Params->Output = Controller_Params->Output;
	return;
}

/**
 * @brief CV (Constant Voltage) control loop.
 * 
 * This function implements the control loop for the CV controller. It calculates
 * the error between the reference value and the feedback value, computes the proportional
 * and integral terms, and updates the controller's output.
 * 
 * @param CV_Controller Pointer to the CV controller structure.
 * @param thisADC ADC data structure containing the latest readings.
 */

void _Controller_CV(Controller_FixPoint_TypeDef	*CV_Controller, AdcTypeDef thisADC){
	CV_Controller->FeedBackVal = _FMULI(CV_Controller->GainSense, thisADC.BufAdcBattVoltage);
	static int f_eV_new = 0, f_eV_old = 0;
	static int f_pV = 0, f_iV = 24576;
	if(CV_Controller->State == DISABLE){
		f_eV_new = 0; f_eV_old = 0;
		f_pV = 0; f_iV = 24576;
		CV_Controller->Output = 0;
	}
	else {
		f_eV_new  				= FSUB(CV_Controller->RefVal, CV_Controller->FeedBackVal);
		f_pV 					= FMUL(f_eV_new, CV_Controller->Fix_Kp, CV_Controller->Q_FIX);
		f_iV 					+= FMUL(f_eV_old, CV_Controller->Fix_Ki_x_Tz, CV_Controller->Q_FIX);
		f_eV_old 				= f_eV_new;
		CV_Controller->Output 	= FADD(f_pV, f_iV);
		_Controller_AntiWindUp(CV_Controller, &f_iV, f_pV);
	}
	return;
}

/**
 * @brief CC (Constant Current) control loop.
 * 
 * This function implements the control loop for the CC controller. It calculates
 * the error between the reference value and the feedback value, computes the proportional
 * and integral terms, and updates the controller's output.
 * 
 * @param CC_Controller Pointer to the CC controller structure.
 * @param thisADC ADC data structure containing the latest readings.
 */
void _Controller_CC(Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC){
	CC_Controller->FeedBackVal 	= FMUL(CC_Controller->GainSense, thisADC.BufAdcBattCurrent , 0);
	static int f_eI_new = 0, f_eI_old = 0;
	static int f_pI = 0, f_iI = 0;
	if(CC_Controller->State == DISABLE){
		f_eI_new = 0; f_eI_old = 0;
		f_pI = 0; f_iI = CC_Controller->OperatingPoint;
		CC_Controller->Output = 0;
	}
	else {
		f_eI_new  				= FSUB(CC_Controller->RefVal, CC_Controller->FeedBackVal);
		f_pI 					= FMUL(f_eI_new, CC_Controller->Fix_Kp, CC_Controller->Q_FIX);
		f_iI 					+= FMUL(f_eI_old, CC_Controller->Fix_Ki_x_Tz, CC_Controller->Q_FIX);
		CC_Controller->Output 	= FADD(f_pI, f_iI);
		f_eI_old 				= f_eI_new;
		_Controller_AntiWindUp(CC_Controller, &f_iI, f_pI);
	}
	return;
}

/**
 * @brief Delay function using a software counter.
 * 
 * This function provides a delay in microseconds by incrementing a static counter
 * until it reaches the specified delay value.
 * 
 * @param delay Desired delay in microseconds.
 * @retval _Bool Returns 1 when the delay is complete, otherwise 0.
 */
_Bool ISR_Delay_us(const uint32_t delay)
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
 * @brief Update the operating point for the CC controller.
 * 
 * This function calculates the operating point for the CC controller based on
 * the ADC readings and converts it to a fixed-point value.
 * 
 * @param CC_Controller Pointer to the CC controller structure.
 * @param thisADC ADC data structure containing the latest readings.
 */
void _Controller_CC_UpdateOperatingPoint(Controller_FixPoint_TypeDef *CC_Controller, AdcTypeDef thisADC){
	static float float_OperatingPoint = 0.0f;
 	//float_OperatingPoint = (float)thisADC.BufAdcBattVoltage / thisADC.BufAdcDcVoltage;
	float_OperatingPoint = (float)thisADC.BufAdcBattVoltage/ADC_ADAPTOR;
	CC_Controller->OperatingPoint = _TO_FIX(float_OperatingPoint, CC_Controller->Q_FIX);
	return;
}

/**
 * @brief Combined CV and CC control loop.
 * 
 * This function implements the control loop for both CV (Constant Voltage) and
 * CC (Constant Current) modes. It includes voltage control, current ramp-up,
 * and PWM output adjustment.
 * 
 * @param CV_Controller Pointer to the CV controller structure.
 * @param CC_Controller Pointer to the CC controller structure.
 * @param thisADC ADC data structure containing the latest readings.
 * @param thisPWM PWM configuration structure.
 */
void _Controller_CV_CC(Controller_FixPoint_TypeDef	*CV_Controller, Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC, PwmConfig *thisPWM){
	/*--------------- Voltage Controller -----------*/// 404 cycles
	_Controller_CV(CV_Controller, thisADC);

	/*--------------- Ramp up current values -----------*/// 185 cycles
	static uint32_t f_i_ref_rampup = 0;
	const uint32_t f_IBULK = FCONV(CV_Controller->Output, CV_Controller->Q_FIX, CC_Controller->Q_FIX);
	if (f_i_ref_rampup < f_IBULK){
		_Controller_RampUp(f_IBULK, 1, &f_i_ref_rampup);
	}
	else f_i_ref_rampup = f_IBULK;

	//CC_Controller->RefVal 		= f_IBULK;
	CC_Controller->RefVal 		= f_i_ref_rampup;
	rampup = f_i_ref_rampup;
	/*--------------- Current Controller -----------*/
	_Controller_CC(CC_Controller, thisADC);

	/*--------------- Output Frequency of Controller -----------*/
	float PI_Duty = TOFLT(CC_Controller->Output, CC_Controller->Q_FIX);
	thisPWM->duty = (uint32_t)(PI_Duty*thisPWM->timebase);
	pwmSetpfm(thisPWM);
	return;
}

/**
 * @brief Reusable CV and CC control loop with state management.
 * 
 * This function is similar to `_Controller_CV_CC` but includes state management
 * to enable or disable the control loop.
 * 
 * @param CV_Controller Pointer to the CV controller structure.
 * @param CC_Controller Pointer to the CC controller structure.
 * @param thisADC ADC data structure containing the latest readings.
 * @param thisPWM PWM configuration structure.
 * @param State Functional state (ENABLE or DISABLE).
 */
void _Controller_CV_CC_Reuse(Controller_FixPoint_TypeDef	*CV_Controller, Controller_FixPoint_TypeDef	*CC_Controller, AdcTypeDef thisADC, PwmConfig *thisPWM, FunctionalState State){
	/*--------------- Voltage Controller -----------*/// 404 cycles
	_Controller_CV(CV_Controller, thisADC);

	/*--------------- Ramp up current values -----------*/// 185 cycles
	const uint32_t f_IBULK = FCONV(CV_Controller->Output, CV_Controller->Q_FIX, CC_Controller->Q_FIX);
	static uint32_t f_i_ref_rampup = 0;
	if (State == DISABLE){
		f_i_ref_rampup = 0;
	}
	else if (State == ENABLE){
		if (f_i_ref_rampup < f_IBULK){
			_Controller_RampUp(f_IBULK, 1, &f_i_ref_rampup);
		}
		else f_i_ref_rampup = f_IBULK;
		//CC_Controller->RefVal 		= f_IBULK;
		CC_Controller->RefVal 		= f_i_ref_rampup;
		/*--------------- Current Controller -----------*/
		_Controller_CC(CC_Controller, thisADC);
		/*--------------- Output Frequency of Controller -----------*/
		float PI_Duty = TOFLT(CC_Controller->Output, CC_Controller->Q_FIX);
		thisPWM->duty = (uint32_t)(PI_Duty*thisPWM->timebase);
		pwmSetpfm(thisPWM);
	}
	rampup = f_i_ref_rampup;
	return;
}
