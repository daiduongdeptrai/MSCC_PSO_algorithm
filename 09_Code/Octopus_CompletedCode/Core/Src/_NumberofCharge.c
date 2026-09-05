/*
 * _NumberofCharge.c
 *
 *  Created on: Feb 22, 2025
 *      Author: ADMIN
 */

#include "_NumberofCharge.h"

/**
 * @brief Initialize the Number of Charge module.
 * 
 * This function initializes the Number of Charge configuration structure with default values.
 * It resets the update counter, flags, and the number of charges.
 * 
 * @param pconfig Pointer to the Number of Charge configuration structure.
 */
void numchargeInit(NumCharge_TypeDef *pconfig){
	pconfig->updateCounter 	= 0;
	pconfig->updateFlag 	= false;
	pconfig->IncreasedNum	= false;
	pconfig->FullCharged	= RESET;
	pconfig->updatePeriod	= NUMBEROFCHARGE_UPDATE_PERIOD;
	pconfig->numcharge		= 0;

	pconfig->updateCounterHmi 	= 0;
	pconfig->updatePeriodHmi 	= NUMBEROFCHARGE_HMI_PERIOD;
	pconfig->updateFlagHmi		= false;
	return;
}

/**
 * @brief Update the number of charges.
 * 
 * This function updates the number of charges in the configuration structure.
 * It is used to keep track of the total number of full charge cycles.
 * 
 * @param pconfig Pointer to the Number of Charge configuration structure.
 * @param numberofcharge The updated number of charges.
 */
void numchargeUpdate(NumCharge_TypeDef *pconfig, uint16_t numberofcharge){
	pconfig->numcharge		= numberofcharge;
	return;
}
