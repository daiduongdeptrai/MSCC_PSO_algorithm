/*
 * _SystemState.h
 *
 *  Created on: Mar 3, 2025
 *      Author: ADMIN
 */

#ifndef SRC__SYSTEMSTATE_H_
#define SRC__SYSTEMSTATE_H_

#include "GlobalDefine.h"
#include "cal_FixedPointMath.h"
#include "myADC.h"
#include "myPWM.h"
#include "_controller.h"
#include "_Battery.h"

#define OFFSET_HANDSHAKE 0

typedef enum{
    /*--------------Normal Operating Modes---------------*/
    CHARGER_CC_CHARGE             	= 0x00,
	CHARGER_CV_CHARGE				= 0X01,
	CHARGER_FUL_CHARGE				= 0x02,
	CHARGER_PRE_CHARGE				= 0x03,
	CHARGER_NO_CHARGE				= 0x04,
} 	ChargerModeTypeDef;

typedef struct{
	uint16_t vmax_ADC;
	uint16_t imax_ADC;
	uint16_t tempmax_ADC;
	uint16_t vbulk_ADC;
	uint16_t vfull_ADC;
	uint16_t ipre_ADC;
	uint16_t vddchg_ADC;
	uint16_t vmin_ADC;
	uint16_t imin_ADC;

	float 	 vmax;
	float	 imax;
	float    tempmax;
	float 	 vbulk;
	float    ipre;
	float    vddchg;
	float	 vmin;
	float 	 imin;
}	ChargerThresholdTypeDef;

typedef enum{
    /*--------------------Operating Protection Modes--------------------*/
    PROTECT_MODE_OCP1              = 0xA0,
	PROTECT_MODE_OCP2              = 0xA1,
	PROTECT_MODE_OVP               = 0xA2,
	PROTECT_MODE_OTP               = 0xA3,
	PROTECT_MODE_OT                = 0xA4,
	PROTECT_MODE_IVP               = 0xA5,
	PROTECT_MODE_OFP               = 0xA6,
	PROTECT_MODE_NONE			   = 0xA7,
}	ProtectionMode_TypeDef;

typedef enum{
    /*--------------Normal Operating Modes---------------*/
    STATE_BATTERY_CHECK     = 0x01,
    STATE_CHARGING_REQUEST  = 0x02,
    STATE_SOFT_START        = 0x03,
    STATE_HAND_SHAKE        = 0x04,
	STATE_CHARGING			= 0x05,
	STATE_PROTECTION		= 0x06,
	STATE_FULCHARGED		= 0x07,
} 	State_TypeDef;

typedef struct{
	State_TypeDef 				ChargerState;
	ChargerModeTypeDef			ChargerMode;
	ChargerThresholdTypeDef		ChgThrd;
	FunctionalState 			State;
	FunctionalState				RelayState;
	ProtectionMode_TypeDef		ProtectionMode;
	_Bool						UpdateChargeCount;
	_Bool						RelayisON;
	_Bool						ReadyCharging;
	float 						Temperature;
}	ChargerTypeDef;

void _statechargerInit(ChargerTypeDef	*pCharger);
void _statechargerUpdate(ChargerTypeDef	*pCharger, AdcTypeDef adc, Battery_TypeDef batParam);

/*
 * Charger Functions for controlling CC/CV charging profile
 */
void _Charging_BatteryCheck(Controller_FixPoint_TypeDef	*CCcontrol, Controller_FixPoint_TypeDef	*CVcontrol, AdcTypeDef adc, PwmConfig *thisPWM);
_Bool _Charging_Delay_us(const uint32_t delay);
void _Charging_SoftStart_UpdateDuty(PwmConfig *thisPWM, FunctionalState State);
void _Charging_Soft_Start();
void _Charging_Relay_OFF(ChargerTypeDef	*pCharger);
void _Charging_Relay_ON(ChargerTypeDef	*pCharger);
void _Charging_HandShake(ChargerTypeDef	*pCharger);
void _Charging_FulCharged(ChargerTypeDef	*pCharger);
void _Charging_Protection(ChargerTypeDef	*pCharger);

#endif /* SRC__SYSTEMSTATE_H_ */
