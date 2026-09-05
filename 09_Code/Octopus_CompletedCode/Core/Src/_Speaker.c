/*
 * _Speaker.c
 *
 *  Created on: Dec 31, 2024
 *      Author: Duy-Dinh Nguyen
 */

#include "main.h"
#include "stdint.h"
#include "stdbool.h"

#include "_Speaker.h"

#define __READ_BIT(REG, BIT)    ((REG) & (1 << (BIT)))

/* Speaker configuration structure */
Speaker_TypeDef	thisSpeaker = {	.BeepType 	= SPEAKER_MUTE,
								.BeepQty	= 0,
								.Index 		= 0,
								.updateCounter = 0,
								.updatePeriod  = 0,
								.updateFlag = false};

/**
 * @brief Initialize the speaker module.
 * 
 * This function initializes the speaker configuration structure with default values
 * and sets the speaker to produce a short beep as a test.
 * 
 * @param thisSpeaker Pointer to the speaker configuration structure.
 */
void speakerInit(Speaker_TypeDef *thisSpeaker) {
	thisSpeaker->updateCounter	= 0;
	thisSpeaker->updateFlag 	= false;
	thisSpeaker->updatePeriod	= SPEAKER_UPDATE_PERIOD;

	setSpeaker_Config(thisSpeaker, SPEAKER_SHORT_BEEP, 1);
	return;
}

/**
 * @brief Update the speaker state.
 * 
 * This function updates the speaker's state based on the current beep type and quantity.
 * It turns the speaker on or off depending on the bit pattern of the beep type.
 * 
 * @param thisSpeaker Pointer to the speaker configuration structure.
 */
void speakerUpdate(Speaker_TypeDef *thisSpeaker) {

	if (thisSpeaker->BeepQty) {
		if (__READ_BIT(thisSpeaker->BeepType, thisSpeaker->Index))
			_speakerOn();
		else
			_speakerOff();

		if (++thisSpeaker->Index > 16U) {
			thisSpeaker->Index 	= 0;
			thisSpeaker->BeepQty --;
		}

		__NOP();
	}
	return;
}

/**
 * @brief Configure the speaker.
 * 
 * This function configures the speaker with a specific beep type and quantity.
 * It checks if the speaker is free (not busy) before applying the new configuration.
 * 
 * @param thisSpeaker Pointer to the speaker configuration structure.
 * @param BeepType The type of beep to configure (e.g., short, long, double).
 * @param BeepQty The number of beeps to produce.
 * @retval uint8_t Returns 1 if the speaker is free and the configuration is applied,
 *                 otherwise returns 0 if the speaker is busy.
 */
uint8_t setSpeaker_Config(Speaker_TypeDef *thisSpeaker, Speaker_Sound_TypeDef BeepType, uint16_t BeepQty) {

	if (thisSpeaker->BeepQty == 0) {	// if Speaker is NOT busy
		thisSpeaker->BeepQty 	= BeepQty;
		thisSpeaker->BeepType 	= BeepType;
		thisSpeaker->Index 		= 0;
		return 1;
	}
	return 0;
}
