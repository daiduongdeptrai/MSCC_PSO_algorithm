/*
 * Octopus.c
 *
 *  Created on: Dec 19, 2024
 *      Author: dinhbkvn
 */

#include "_BMS.h"
#include "_HMI.h"
#include "_Battery.h"
#include "_Speaker.h"
#include "_Fan.h"
#include "_NumberofCharge.h"
#include "_SystemState.h"
#include "main.h"
#include "globalDefine.h"
#include "stdio.h"
#include "myADC.h"
#include "myUART.h"
#include "_CellBalancing.h"
#include "myBQ76942_I2C.h"
#include "myI2CLCD.h"
#include "myPWM.h"
#include "_controller.h"

extern Battery_TypeDef	thisBattery;
extern HMI_TypeDef		thisHMI;
extern Speaker_TypeDef	thisSpeaker;
extern CellBalancing_TypeDef	thisCellBalancing;

BMS_TypeDef			thisBMS;
AdcTypeDef			thisADC;
PwmConfig			thisPWM;
FAN_TypeDef			thisFAN;
NumCharge_TypeDef	thisPriMCU;
Controller_FixPoint_TypeDef	CC_Controller;
Controller_FixPoint_TypeDef	CV_Controller;
ChargerTypeDef		thisCharger;

volatile _Bool flgChargingBalancing_Button_Pressed 	= false;
volatile _Bool flgCharging_Button_Pressed 	= false;
volatile _Bool flgBalancing_Button_Pressed 	= false;
volatile _Bool flgStop_Button_Pressed 		= false;
volatile _Bool flgChargeCount_Increased		= false;
volatile _Bool flgNumberOfChargeHMI			= false;

extern char BufTxUart[UART_TX_BUFFER_SIZE];
extern volatile char BufRxUart[UART_RX_BUFFER_SIZE];
extern volatile char BufRXChar[1];
volatile uint16_t uart_rx_index = 0;
volatile uint8_t uart_data_ready = 0;

extern uint16_t g_cnt_stateSW;
extern uint16_t g_starttime;
extern uint16_t g_endtime;
extern uint16_t g_elapsetime;

extern uint8_t CHG;
extern uint8_t DSG;
extern uint32_t AccumulatedCharge_Time;

extern _Bool FETONFlag;



void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart_r){
	if(huart_r == &huart){
		if (BufRXChar[0] == '\n') {
			BufRxUart[uart_rx_index] = '\n'; // end of data
		            uart_data_ready = 1;
		            uart_rx_index = 0;
		        }
		        else if(BufRXChar[0] == '\0'){

		        }
		        else {
		            if (uart_rx_index < UART_RX_BUFFER_SIZE - 1) {
		            	BufRxUart[uart_rx_index++] = BufRXChar[0];
		            } else {
		                uart_rx_index = 0;
		            }
		        }

		HAL_UART_Receive_DMA(&huart, (uint8_t *) &BufRXChar, 1);
	}



}
void handle_uart_command() {
    if (uart_data_ready) {
        uart_data_ready = 0; // Reset flag

        sscanf(BufRxUart, "%hu\n", &thisBattery.numberOfCharge);
        // Clear the buffer after processing
        memset((char*)BufRxUart, '\0', UART_RX_BUFFER_SIZE);
        uart_rx_index = 0;
    }
}

void _system_initialization(){
	HAL_UART_Receive_DMA(&huart, (uint8_t *) &BufRXChar, 1);
	bmsReadnumcharged();
	/*
	 * Initializing user's definition
	 */
	adcInit(&thisADC);
	batteryInit(&thisBattery);
	hmiInit(&thisHMI);
	speakerInit(&thisSpeaker);
	bmsInit();
	cellbalancingInit(&thisCellBalancing);
	numchargeInit(&thisPriMCU);
	_fan_Init(&thisFAN);
	_statechargerInit(&thisCharger);
	_Controller_Init(&CC_Controller, &CV_Controller);
	hmiUpdatedisplay(&thisHMI);
	BQ769x2_Init();
	pwmInit(&thisPWM);
	BQ769x2_BOTHOFF();
	HAL_Delay(1000);
	_fan_Setspeed(thisFAN);
	/*
	 * Initializing peripherals
	 */
	HAL_ADCEx_Calibration_Start(&hadc);
	HAL_ADC_Start_DMA(&hadc, (uint32_t*) &thisADC.BufAdc, ADC_BUF_MAX_ELEMENTS);
	/*
	 * Initializing ADC values to prevent ChargerState go into Protection
	 */
	adcRead(&thisADC);
	adcWaitforconversion();
	/*
	 * End ADC Initialization
	 */
	HAL_TIM_Base_Start_IT(&htim3);
	HAL_TIM_Base_Start(&htim_PWM);
	HAL_TIM_Base_Start(&htim_FAN);
	HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_4);
	HAL_TIM_Base_Start(&htim_timcal);

	return;
}

void _ext_interrupt_service(uint16_t GPIO_Pin) {
	if ((GPIO_Pin == userSW_Pin) && (thisPriMCU.updateFlagHmi)){
		thisPriMCU.updateFlagHmi = false;
		return;
	}
	if( (GPIO_Pin == userSW_Pin) && thisCharger.ReadyCharging == true){
		thisBMS.Status1.Value &= ~BMS_STT_NUMCHARGE_HMI;
		if (g_cnt_stateSW < 2){
			g_cnt_stateSW++;
		}
		if(g_cnt_stateSW == 1){
			flgChargingBalancing_Button_Pressed = true;
			thisCharger.State	= ENABLE;
			bmsIncreasenumcharged();
		}
		if(g_cnt_stateSW == 2){
			flgStop_Button_Pressed = true;
			thisCharger.State	= DISABLE;
			thisCharger.RelayState = DISABLE;
		}
	}
    return;
}

void _main_interrupt_service(){	//100us = 1.8 degrees
	static uint16_t cnt_1ms 			= 0;
	static uint16_t cnt_1s				= 0;
	static uint16_t cnt_10s				= 0;
	/* 1ms clocking tasks */
	/*
	 * Time calculation: Tcy = 248 ~ 248/64e6 = 3,875 us
	 */
	if (cnt_1ms++ >= 10U) { //1ms clock
	  cnt_1ms = 1;

	  if (cnt_Led_Update++ >= blinkPeriod) {
		  cnt_Led_Update = 0;
		  HAL_GPIO_TogglePin(userLED_GPIO_Port, userLED_Pin);
	   }
	  if (thisSpeaker.updateCounter++ > thisSpeaker.updatePeriod) {
		  thisSpeaker.updateCounter  	= 0;
		  thisSpeaker.updateFlag	= true;
	  }
	  if (thisCellBalancing.updateCounter++ > thisCellBalancing.updatePeriod){
		  thisCellBalancing.updateCounter  	= 0;
		  thisCellBalancing.updateFlag	= true;
	  }
	  if (thisPriMCU.updateCounter++ > thisPriMCU.updatePeriod){
		  thisPriMCU.updateCounter  	= 0;
		  thisPriMCU.updateFlag	= true;
	  }
	  if (thisHMI.updateCounter++ > thisHMI.updatePeriod) {
		  thisHMI.updateCounter  	= 0;
		  thisHMI.updateFlag	= true;
	  }
	  if (thisFAN.updateCounter++ > thisFAN.updatePeriod) {
		  thisFAN.updateCounter  	= 0;
		  thisFAN.updateFlag	= true;
	  }
	  if (HAL_GPIO_ReadPin(userSW_GPIO_Port, userSW_Pin) == GPIO_PIN_RESET){
		  if (thisPriMCU.updateCounterHmi++ > thisPriMCU.updatePeriodHmi){
			  thisPriMCU.updateFlagHmi = true;
			  flgNumberOfChargeHMI = true;
		  }
	  }
	  else thisPriMCU.updateCounterHmi = 0;
	}

	  /* 1s clocking tasks */
	  if (cnt_1s++ >= 10000U ){
		  cnt_1s = 1;
		  if (thisBattery.updateCounter++ > thisBattery.updatePeriod) {
			  thisBattery.updateCounter  	= 0;
			  thisBattery.updateFlag		= true;
		  }
	  }

	  /* 10s clocking tasks */
	  if (cnt_10s++ >= 100000U ){
		  cnt_10s = 1;
		  // Thêm các tác vụ 10 giây ở đây
		  // Ví dụ: Log hệ thống, kiểm tra định kỳ, etc.
		  // Dừng sạc và tắt relay
		  	thisCharger.State	= DISABLE;
			thisCharger.RelayState = DISABLE;
	  }

//---------------------------------------------------------
 	 /*
 	  * Time calculation: Tcy = 214 ~ 214/64e6 = 3,34375 us
 	  */
	/*-------------------------- Read ADC here -------------------------------*/
	adcRead(&thisADC);
 	adcWaitforconversion();

	/*-------------------------- Update BMS and Charger ----------------------*/
	 /*
	  * Time calculation: Tcy = 620 ~ 620/64e6 = 9,6875 us
	  */
	bmsUpdatestatus();
	_statechargerUpdate(&thisCharger, thisADC, thisBattery);
	if( (thisCharger.ChargerState == STATE_PROTECTION)){
		_Charging_Protection(&thisCharger);
	}
      /*
       * State Battery Check: 492 cycles
       * State Soft Start: 1070 cycles
       * State Hand Shake: 196 cycles
       * State Charging	: 1170 cycles
       * State Full-Charged	: 204 cycles
       * State Protection: 192 cycles
       */
      g_starttime = TIM2->CNT;
      if ( thisCharger.State == ENABLE )
      {
  	    switch (thisCharger.ChargerState){
  	    	case STATE_BATTERY_CHECK:
  	    		_Charging_BatteryCheck(&CC_Controller, &CV_Controller, thisADC, &thisPWM);
  	    		break;
  	    	case STATE_SOFT_START:
  	    		_Charging_Soft_Start();
  	    		_Controller_CC_UpdateOperatingPoint(&CC_Controller, thisADC);
  	    		_Controller_CC(&CC_Controller, thisADC);
  	    		break;
  	    	case STATE_HAND_SHAKE:
  	    		_Charging_HandShake(&thisCharger);
  	    		break;
  	    	case STATE_CHARGING:
  	    		static uint8_t onetimeCharge = 1;
  	    		if (onetimeCharge == 1){
					MY_PWM_START();
					CC_Controller.State = ENABLE;
					CV_Controller.State = ENABLE;
				}
  	    		_Controller_CV_CC_Reuse(&CV_Controller, &CC_Controller, thisADC, &thisPWM, ENABLE);
  	    		break;
  	    	case STATE_FULCHARGED:
  	    		_Charging_FulCharged(&thisCharger);
  	    		if (thisCharger.UpdateChargeCount == false){
  	    			thisCharger.UpdateChargeCount = true;
  	    		}
  	    		break;
  	    	case STATE_PROTECTION:
  	    		_Charging_Protection(&thisCharger);
  	    		break;
  	    	default:
  	    		break;
  	    }
      }
      else if (thisCharger.State == DISABLE){
    	  _Charging_BatteryCheck(&CC_Controller, &CV_Controller, thisADC, &thisPWM);
    	  thisCharger.ChargerState = STATE_BATTERY_CHECK;
      }
      g_endtime	= TIM2->CNT;
      g_elapsetime = g_endtime - g_starttime;

	 /*
	  * Time calculation: Tcy = 74 ~ 74/64e6 = 1,15625 us
	  */
	adcResumeconversion();
	return;
}

void _main_inf_loop(){
	if ((thisCharger.RelayState == ENABLE) && (thisCharger.RelayisON == false)){
		BQ769x2_EnableAllFETs();
		thisCharger.RelayisON = true;
	}
	if ( (thisCharger.RelayisON == true) && thisCharger.RelayState == DISABLE){
		BQ769x2_BOTHOFF();
		thisCharger.RelayisON = false;
	}
	if ( (thisBMS.adaptorVoltage < 37000) || (thisCharger.ReadyCharging == false) ){
		MY_PWM_STOP();
		BQ769x2_BOTHOFF();
		bmsClearAllFlags();
	}

	if (thisHMI.updateFlag) {
		thisHMI.updateFlag = false;
		hmiUpdatemessageVN(&thisHMI);
		hmiUpdatedisplay(&thisHMI);
	}

	if (thisPriMCU.updateFlag) {
		bmsReadnumcharged();
		thisPriMCU.updateFlag = false;
		if ((thisCharger.ChargerState == STATE_CHARGING ) && (thisPriMCU.FullCharged == SET) && (thisPriMCU.IncreasedNum == false) ){
			thisPriMCU.FullCharged = RESET;
			thisPriMCU.IncreasedNum = true;
		}
	}

	if (thisCellBalancing.updateFlag){
		thisCellBalancing.updateFlag = false;
		_Battery_Reading_cellVoltage(&thisBattery);
		_Battery_Reading_chargerVoltage(&thisBattery);
		_Battery_Reading_batVoltage(&thisBattery);
		_Battery_Reading_batCurrent(&thisBattery);
		_Battery_Reading_batTemperature(&thisBattery);
//		thisBattery.cellVoltage[2] = 3250;
//		thisBattery.cellVoltage[7] = 3300;
//		thisBattery.cellVoltage[1] = 3250;
//		thisBattery.cellVoltage[3] = 3300;
//		thisBattery.cellVoltage[4] = 3250;
//		thisBattery.cellVoltage[5] = 3300;
//		thisBattery.cellVoltage[6] = 3300;
//		thisBattery.cellVoltage[0] = 3000;
//		thisBattery.cellVoltage[8] = 3400;
		_Battery_Reading_cellVoltageMaxMin(&thisBattery);
		_Battery_Reading_deltacellVoltageMax(&thisBattery);
		_Battery_Reading_deltacellVoltageMaxFulChg(&thisBattery);
		thisBattery.ADCbatVoltage	= (uint16_t)thisBattery.batVoltage*VBAT_GAIN_ADC;
		thisBMS.adaptorVoltage = (uint16_t)(thisADC.BufAdcDcVoltage*VBAT_GAIN_MV);
		thisCharger.Temperature = thisADC.BufAdcTemp * TEMP_GAIN - OFFSET_TEMP;
//		if (thisBMS.Status1.Value & BMS_STT_BATTERY_FULL){
//			thisBattery.cellVoltage[thisBattery.minCellposition] = thisBattery.cellVoltage[thisBattery.minCellposition] + thisBattery.cellUnbalance;
//		}
	}

	if (thisSpeaker.updateFlag) {
		thisSpeaker.updateFlag = false;
		//speakerUpdate(&thisSpeaker);
	}
	return;
}

void bmsUpdatestatus(){
	if (thisBMS.Status.Shadow != thisBMS.Status.Value) {
		thisBMS.Status.Shadow = thisBMS.Status.Value;
		thisBMS.Status.flgStatusChanged = true;
	}
	if (thisBMS.Status1.Shadow != thisBMS.Status1.Value) {
		thisBMS.Status1.Shadow = thisBMS.Status1.Value;
		thisBMS.Status1.flgStatusChanged = true;
	}
	/*
	 * Check for system status first
	 */
	 // Under voltage error
	if (thisBMS.adaptorVoltage < ADAPTOR_VOLTAGE_MIN)
		thisBMS.Status.Value |= BMS_STT_ERROR_100;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_100;
	// Over voltage error
	if (thisBMS.adaptorVoltage > ADAPTOR_VOLTAGE_MAX)
		thisBMS.Status.Value |= BMS_STT_ERROR_101;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_101;
	// pack voltage too low
	if ((thisBattery.batVoltage < BATTERY_NOT_PRESENCE))
		thisBMS.Status.Value |= BMS_STT_ERROR_206;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_206;
	// pack voltage too low
	if ((thisBattery.batVoltage < BATTERY_VOLTAGE_MIN) && (thisBattery.batVoltage > BATTERY_NOT_PRESENCE))
		thisBMS.Status.Value |= BMS_STT_ERROR_200;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_200;
	// pack voltage too high
	if (thisBattery.batVoltage > BATTERY_VOLTAGE_MAX)
		thisBMS.Status.Value |= BMS_STT_ERROR_201;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_201;
	// protection for charger
//	if (thisCharger.ChargerState == STATE_PROTECTION)
//		thisBMS.Status.Value |= BMS_STT_ERROR_208;
//	else
//		thisBMS.Status.Value &= ~BMS_STT_ERROR_208;
	if (thisCharger.Temperature > thisCharger.ChgThrd.tempmax)
		thisBMS.Status.Value |= BMS_STT_ERROR_208;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_208;

	if (thisCharger.ChargerState == STATE_PROTECTION)
		thisBMS.Status.Value |= BMS_STT_ERROR_209;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_209;

	// limit reached
	if (thisBattery.numberOfCharge > BATTERY_CHARGE_TIME_LIMIT)
		thisBMS.Status.Value |= BMS_STT_ERROR_202;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_202;
	// cell voltage too small
	if ((thisBattery.minCellVoltage < CELL_VOLTAGE_MIN) || (thisBattery.cellVoltage[0] < CELL_VOLTAGE_MIN) || (thisBattery.cellVoltage[8] < CELL_VOLTAGE_MIN))
		thisBMS.Status.Value |= BMS_STT_ERROR_203;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_203;
	// cell voltage too large
	if ((thisBattery.maxCellVoltage > CELL_VOLTAGE_MAX) || (thisBattery.cellVoltage[0] > CELL_VOLTAGE_MAX_C1_C9) || (thisBattery.cellVoltage[8] > CELL_VOLTAGE_MAX_C1_C9))
		thisBMS.Status.Value |= BMS_STT_ERROR_204;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_204;
	// un-balance too much
	if ((thisBattery.cellUnbalance > CELL_VOLTAGE_DEVIATION_MAX) || (SAFE_SUBTRACT(thisBattery.maxCellVoltage,thisBattery.cellVoltage[0]) > CELL_VOLTAGE_DEVIATION_MAX) \
			|| (SAFE_SUBTRACT(thisBattery.maxCellVoltage,thisBattery.cellVoltage[8]) > CELL_VOLTAGE_DEVIATION_MAX)	\
			|| (SAFE_SUBTRACT(thisBattery.cellVoltage[0], thisBattery.minCellVoltage) > CELL_VOLTAGE_DEVIATION_MAX) \
			|| (SAFE_SUBTRACT(thisBattery.cellVoltage[8], thisBattery.minCellVoltage) > CELL_VOLTAGE_DEVIATION_MAX))
		thisBMS.Status.Value |= BMS_STT_ERROR_205;
	else
		thisBMS.Status.Value &= ~BMS_STT_ERROR_205;

	// Protection for Charger circuit


	// FIXME: Add ERROR 202 after checking
    if (thisBMS.Status.Value & BMS_ERROR_MASK) {
        thisCharger.ReadyCharging = false;  // Have faults or warnings, not ready to charge
    } else {
        thisCharger.ReadyCharging = true;   // No faults or warnings, ready to charge
    }
	/*
	 * battery's charging status
	 */
	// Battery is not connected
	if (thisBattery.batVoltage <= BATTERY_NOT_PRESENCE)
		thisBMS.Status1.Value |= BMS_STT_NO_BATTERY_DETECTED;
	else
		thisBMS.Status1.Value &= ~BMS_STT_NO_BATTERY_DETECTED;

	//&& (thisBattery.deltaCellVoltageFulchg < CELL_VOLTAGE_DEVIATION_FLCHG_MAX)
	if ( (thisBattery.minCellVoltage >= BATTERY_CELL_FULL) && (thisBattery.batCurrent < 50) && (thisBMS.Status1.Value & BMS_STT_CHARGE_BALANCE_BUTTON_PRESSED)
			&& ( (thisBattery.updateFlag == true) || (thisBattery.deltaCellVoltageFulchg < CELL_VOLTAGE_DEVIATION_FLCHG_MAX) ) ){
		thisBMS.Status1.Value |= BMS_STT_BATTERY_FULL;
		thisPriMCU.FullCharged = SET;
		thisBattery.updateFlag = false;
	}
	else
		thisBMS.Status1.Value &= ~BMS_STT_BATTERY_FULL;

	if (flgNumberOfChargeHMI){
		flgNumberOfChargeHMI = false;
		thisBMS.Status1.Value |= BMS_STT_NUMCHARGE_HMI;
	}
	if (flgStop_Button_Pressed) {
		flgStop_Button_Pressed = false; //acknowledge the button
		thisBMS.Status1.Value |= BMS_STT_STOP_BUTTON_PRESSED;
	}

	if (flgChargingBalancing_Button_Pressed) {
		flgChargingBalancing_Button_Pressed = false; //acknowledge the button
		thisBMS.Status1.Value |= BMS_STT_CHARGE_BALANCE_BUTTON_PRESSED;
	}

	/*
	 * Now let us check for operating condition
	 */
	return;
}

void bmsInit(){
	thisBMS.Status.Value		= BMS_STT_SYSTEM_READY;
	thisBMS.fanSpeed			= 0;
	thisBMS.adaptorVoltage		= 38000U;
}

void bmsReadnumcharged(){
	snprintf(BufTxUart, sizeof(BufTxUart), "GET\n");
	HAL_UART_Transmit(&huart1, (uint8_t *)BufTxUart, sizeof(BufTxUart), 100);
}

void bmsIncreasenumcharged(){
	snprintf(BufTxUart, sizeof(BufTxUart), "INC\n");
	HAL_UART_Transmit(&huart1, (uint8_t *)BufTxUart, sizeof(BufTxUart), 100);
	return;
}

void bmsClearAllFlags(){
	thisCharger.RelayisON  = false;
	thisCharger.RelayState = DISABLE;
	thisCharger.State	   = DISABLE;
	thisPriMCU.FullCharged = RESET;
	thisPriMCU.IncreasedNum = false;
	g_cnt_stateSW		   = 0;
	// Erase flags of HMI indicator if Charging not ready
	thisBMS.Status1.Value  &= ~BMS_STT_STOP_BUTTON_PRESSED;
	thisBMS.Status1.Value  &= ~BMS_STT_CHARGE_BALANCE_BUTTON_PRESSED;
	return;
}


