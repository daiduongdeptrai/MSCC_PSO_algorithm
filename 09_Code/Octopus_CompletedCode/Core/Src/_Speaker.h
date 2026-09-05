/*
 * _Speaker.h
 *
 *  Created on: Dec 31, 2024
 *      Author: Duy-Dinh Nguyen
 */

#ifndef SRC__SPEAKER_H_
#define SRC__SPEAKER_H_

#define SPEAKER_UPDATE_PERIOD	100U		// 100ms
#define _speakerOn()	HAL_GPIO_WritePin(userSpeaker_GPIO_Port, userSpeaker_Pin, GPIO_PIN_SET)
#define _speakerOff()	HAL_GPIO_WritePin(userSpeaker_GPIO_Port, userSpeaker_Pin, GPIO_PIN_RESET)
typedef enum speaker_enum_typedef {
	SPEAKER_MUTE 				= 0x0000, // 0b0000 0000 0000 0000
	SPEAKER_SHORT_BEEP			= 0x0001, // 0b0000 0000 0000 0001
	SPEAKER_DOUBLE_BEEP			= 0x0009, // 0b0000 0000 0000 1001
	SPEAKER_LONG_BEEP			= 0x0007, // 0b0000 0000 0000 0111
	SPEAKER_FAST_BEEP			= 0x0101, // 0b0000 0001 0000 0001
	SPEAKER_FAST_LONG_BEEP		= 0x0707, // 0b0000 0111 0000 0111
	SPEAKER_LONG_BEEP5S			= 0x001F, // 0b0000 0000 0001 1111
} Speaker_Sound_TypeDef;

typedef struct {
	Speaker_Sound_TypeDef	BeepType;
	uint16_t				BeepQty;
	uint16_t				Index;					// index to bit in the .BeepType
	uint16_t	updateCounter;		// counter to update period
	uint16_t	updatePeriod;		// update period
	_Bool		updateFlag;		// = true if cnt >= prd
} Speaker_TypeDef;

void speakerInit(Speaker_TypeDef *thisSpeaker);
void speakerUpdate(Speaker_TypeDef *thisSpeaker);
uint8_t setSpeaker_Config(Speaker_TypeDef *thisSpeaker, Speaker_Sound_TypeDef BeepType, uint16_t BeepQty);

#endif /* SRC__SPEAKER_H_ */
