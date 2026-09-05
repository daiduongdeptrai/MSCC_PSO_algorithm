/*
 * Battery.c
 *
 *  Created on: Dec 20, 2024
 *      Author: Duy-Dinh Nguyen
 */

#include "_Battery.h"
#include "globalDefine.h"

Battery_TypeDef	thisBattery;
_Bool 	flagCellVoltageError = false;
/**
  * @brief  Initialize battery parameters.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void batteryInit(Battery_TypeDef *thisBattery) {
	thisBattery->Status 		= BATTERY_NULL;
	thisBattery->cellUnbalance	= 0U;
	thisBattery->numberOfCharge	= 0U;
	thisBattery->numberOfCell 	= 9U;
	thisBattery->batCurrent 	= 0;
	thisBattery->batVoltage 	= 27000U;			// 9 x 3650 mV
	thisBattery->IDcharge		= 0U;
	thisBattery->CodeCharge		= 0U;
	thisBattery->numberOfCell 	= 9U;
	thisBattery->batTemperature[1]	= 0.0f;
	thisBattery->batTemperature[2]	= 0.0f;
	thisBattery->batTemperature[3]	= 0.0f;
	thisBattery->minCellposition	= 0;
	for (int i = 0; i < thisBattery->numberOfCell; i++)
		thisBattery->cellVoltage[i] = 0;	// 3650 mV
	thisBattery->minCellVoltage	= 0U;
	thisBattery->maxCellVoltage	= 0U;
	for (int i = 0; i < thisBattery->numberOfCell; i++)
		thisBattery->previouscellVoltage[i] = thisBattery->cellVoltage[i];	// 3650 mV

	thisBattery->updateFlag 	= false;
	thisBattery->updateCounter  = 0;
	thisBattery->updatePeriod   = BATTERY_TIME_LIMIT;
	return;
}

//************************************Command with input variables******************************************
/**
  * @brief  Reads all cell voltages.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_cellVoltage(Battery_TypeDef *thisBattery)
// Reads all cell voltages, Stack voltage, PACK pin voltage, and LD pin voltage
{
    unsigned char x;
    int cellvoltageholder = Cell1Voltage;  //Cell1Voltage is 0x14
    for (x = 0; x < thisBattery->numberOfCell; x++) {             //Reads all cell voltages
        thisBattery->cellVoltage[x]    = BQ769x2_ReadVoltage(cellvoltageholder);
        cellvoltageholder = cellvoltageholder + 2;
    }
}

/**
  * @brief  Reads charger voltage.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_chargerVoltage(Battery_TypeDef *thisBattery)
// Reads all cell voltages, Stack voltage, PACK pin voltage, and LD pin voltage
{
    thisBattery->chargerVoltage  = BQ769x2_ReadVoltage(PACKPinVoltage);
}

/**
  * @brief  Reads total battery voltage.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_batVoltage(Battery_TypeDef *thisBattery)
// Reads all cell voltages, Stack voltage, PACK pin voltage, and LD pin voltage
{
//	thisBattery->batVoltage = BQ769x2_ReadVoltage(StackVoltage);
	thisBattery->batVoltage = thisBattery->cellVoltage[0] +  thisBattery->cellVoltage[1] + thisBattery->cellVoltage[2] + thisBattery->cellVoltage[3] + thisBattery->cellVoltage[4] +  thisBattery->cellVoltage[5] + thisBattery->cellVoltage[6] + thisBattery->cellVoltage[7] + thisBattery->cellVoltage[8];
}

/**
  * @brief  Reads current through the battery.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_batCurrent(Battery_TypeDef *thisBattery)
// Reads all cell voltages, Stack voltage, PACK pin voltage, and LD pin voltage
{
    thisBattery->batCurrent = BQ769x2_ReadCurrent();
}

/**
  * @brief  Reads all temperatures in the BMS circuit.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_batTemperature(Battery_TypeDef *thisBattery)
{
    thisBattery->batTemperature[0] = BQ769x2_ReadTemperature(TS1Temperature);
    thisBattery->batTemperature[1] = BQ769x2_ReadTemperature(TS2Temperature);
    thisBattery->batTemperature[2] = BQ769x2_ReadTemperature(TS3Temperature);
}


/**
  * @brief  Finds the maximum and minimum cell voltages.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_cellVoltageMaxMin(Battery_TypeDef *thisBattery){
    uint16_t cellVoltage_max = thisBattery->cellVoltage[5]; // Khởi tạo max bằng phần tử đầu tiên
    uint16_t cellVoltage_min = thisBattery->cellVoltage[5]; // Khởi tạo min bằng phần tử đầu tiên

    for (int i = 1; i < thisBattery->numberOfCell-1; i++) {
        if (thisBattery->cellVoltage[i] > cellVoltage_max) {
        	cellVoltage_max = thisBattery->cellVoltage[i]; // Cập nhật max nếu phần tử lớn hơn
        }
        if (thisBattery->cellVoltage[i] < cellVoltage_min) {
            cellVoltage_min = thisBattery->cellVoltage[i]; // Cập nhật min nếu phần tử nhỏ hơn
        }
    }
    thisBattery->maxCellVoltage = cellVoltage_max;
    thisBattery->minCellVoltage = cellVoltage_min;
}

/**
  * @brief  Calculates the maximum delta between cell voltages.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_deltacellVoltageMax(Battery_TypeDef *thisBattery){
	thisBattery->deltaCellVoltage = thisBattery->maxCellVoltage - thisBattery->minCellVoltage;
}

/**
  * @brief  Reads all battery parameters.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_Reading_AllParameters(Battery_TypeDef *thisBattery){
	_Battery_Reading_cellVoltage(thisBattery);
	//_Battery_ResetParamIfError(thisBattery);
	_Battery_Reading_chargerVoltage(thisBattery);
	_Battery_Reading_batVoltage(thisBattery);
	_Battery_Reading_batCurrent(thisBattery);
	_Battery_Reading_batTemperature(thisBattery);
	_Battery_Reading_cellVoltageMaxMin(thisBattery);
	_Battery_Reading_deltacellVoltageMax(thisBattery);
	return;
}

/**
  * @brief  Resets battery parameters if an error is detected.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
void _Battery_ResetParamIfError(Battery_TypeDef *thisBattery){
	for (int i = 0; i < thisBattery->numberOfCell; i++)
		if(thisBattery->cellVoltage[i] > CELL_VOLTAGE_ERROR_I2C){
			flagCellVoltageError = true;
		}
	if (flagCellVoltageError == true){
		flagCellVoltageError = false;
		thisBattery->batCurrent 	= 0;
		thisBattery->batVoltage 	= 0U;			// 9 x 3650 mV
		thisBattery->batTemperature[1]	= 0.0f;
		thisBattery->batTemperature[2]	= 0.0f;
		thisBattery->batTemperature[3]	= 0.0f;
		thisBattery->numberOfCharge = 0U;
		for (int i = 0; i < thisBattery->numberOfCell; i++)
			thisBattery->cellVoltage[i] = 0U;	// 3650 mV
		thisBattery->minCellVoltage	= 0U;
	}
}

/**
  * @brief  Finds the maximum and minimum cell voltages.
  * @param  thisBattery: Pointer to the battery structure.
  * @retval None
  */
 void _Battery_Reading_deltacellVoltageMaxFulChg(Battery_TypeDef *thisBattery){
  uint16_t cellVoltage_max = thisBattery->cellVoltage[5]; // Khởi tạo max bằng phần tử đầu tiên
  uint16_t cellVoltage_min = thisBattery->cellVoltage[5]; // Khởi tạo min bằng phần tử đầu tiên

  for (int i = 0; i < thisBattery->numberOfCell; i++) {
      if (thisBattery->cellVoltage[i] > cellVoltage_max) {
        cellVoltage_max = thisBattery->cellVoltage[i]; // Cập nhật max nếu phần tử lớn hơn
      }
      if (thisBattery->cellVoltage[i] < cellVoltage_min) {
          cellVoltage_min = thisBattery->cellVoltage[i]; // Cập nhật min nếu phần tử nhỏ hơn
          thisBattery->minCellposition = i;
      }
  }
  thisBattery->maxCellVoltageFulchg = cellVoltage_max;
  thisBattery->minCellVoltageFulchg = cellVoltage_min;
  thisBattery->deltaCellVoltageFulchg = cellVoltage_max - cellVoltage_min;
}
