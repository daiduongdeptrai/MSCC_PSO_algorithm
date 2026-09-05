/*
 * myADC.c
 *
 *  Created on: Jan 24, 2025
 *      Author: ADMIN
 */

#include "myADC.h"
uint16_t g_BufAdc1[ADC_BUF_MAX_ELEMENTS];

/**
 * @brief  Initialize the ADC with the specified configuration.
 * @param  pAdc: Pointer to an AdcTypeDef structure that contains the configuration information.
 * @retval None
 */
void adcInit(AdcTypeDef *pAdc){
	/* Initial values for ADC buffer */
	pAdc->BufAdc[0]				= 0;
	pAdc->BufAdc[1]				= 0;
	pAdc->BufAdc[2]				= 0;
	pAdc->BufAdc[3]				= 0;

	pAdc->BufAdcDcVoltage		= 0;
	pAdc->BufAdcTemp			= 0;
	pAdc->BufAdcBattVoltage		= 0;
	pAdc->BufAdcBattCurrent		= 0;
	return;
};

/**
 * @brief  Read the ADC values.
 * @param  pAdc: Pointer to an AdcTypeDef structure that contains the ADC values.
 * @retval None
 */
void adcRead(AdcTypeDef *pAdc){
	/* ADC BUFFER without any conversion*/
	pAdc->BufAdcDcVoltage	= pAdc->BufAdc[0];
	pAdc->BufAdcTemp		= pAdc->BufAdc[1];
	pAdc->BufAdcBattVoltage	= pAdc->BufAdc[2];
	//pAdc->BufAdcBattCurrent	= GET_ADC_POSITIVE(CURRENT_OFFSET - pAdc->BufAdc[3]);
	pAdc->BufAdcBattCurrent = SAFE_SUBTRACT(CURRENT_OFFSET, pAdc->BufAdc[3]);
	return;
}

/**
 * @brief  Wait for ADC conversion to complete.
 * @retval None
 */
void adcWaitforconversion() {
	if (HAL_ADC_PollForConversion(&hadc, HAL_MAX_DELAY) != HAL_OK)
		__NOP();
	return;
}

/**
 * @brief  Resume ADC conversion.
 * @retval None
 */
void adcResumeconversion() {\
	LL_ADC_REG_StartConversionSWStart(hadc.Instance);
}





