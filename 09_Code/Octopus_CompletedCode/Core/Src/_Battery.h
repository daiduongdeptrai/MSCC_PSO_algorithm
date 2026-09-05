/*
 * Battery.h
 *
 *  Created on: Dec 20, 2024
 *      Author: Duy-Dinh Nguyen
 */

#ifndef SRC__BATTERY_H_
#define SRC__BATTERY_H_
#include "stdint.h"
#include "myBQ76942_I2C.h"

#define CELL_VOLTAGE_ERROR_I2C	6000U
#define CELL_VOLTAGE_MIN	2500U
#define CELL_VOLTAGE_MAX	4350U
#define CELL_VOLTAGE_MAX_C1_C9	4650U

#define	CELL_VOLTAGE_DEVIATION_MAX	700U
#define CELL_VOLTAGE_DEVIATION_FLCHG_MAX 30U

#define BATTERY_VOLTAGE_MIN		21600U	//2.4V per cell
#define BATTERY_VOLTAGE_MAX		39150U	// 4.35V per cell -> 9 cells: 39.15 V
#define BATTERY_VOLTAGE_FULL	37350U	// 99% SoC 4,15 V per cells
#define BATTERY_CELL_FULL		4100U	//
#define BATTERY_NOT_PRESENCE	15000U	// 99% SoC

#define BATTERY_CHARGE_TIME_LIMIT	1200U
#define BATTERY_TIME_LIMIT		9000	// Equivalent to 2,5 hours

typedef enum batteryStatus_typedef{
	BATTERY_FULL,
	BATTERY_EMPTY,
	BATTERY_CHARGING,
	BATTERY_DISCHARGING,
	BATTERY_BALANCING,
	BATTERY_NULL,
} BatteryStatus_TypeDef;

typedef struct {
	uint8_t		numberOfCell;
	uint16_t 	cellVoltage[9];	//maximum 16 cells
	uint16_t	previouscellVoltage[9];
	uint16_t 	batVoltage;
	uint16_t 	chargerVoltage;
	int16_t 	batCurrent;
	float 		batTemperature[3];
	uint16_t	maxCellVoltage;
	uint16_t	minCellVoltage;
	uint16_t 	deltaCellVoltage;

	uint16_t	cellUnbalance;
	uint16_t	numberOfCharge;
	uint16_t	IDcharge;
	uint16_t	CodeCharge;
	uint16_t	stateOfCharge;
	uint16_t	ADCbatVoltage;

	uint16_t	maxCellVoltageFulchg;
	uint16_t	minCellVoltageFulchg;
	uint16_t 	deltaCellVoltageFulchg;
	uint16_t 	minCellposition;

	uint16_t	updateFlag;
	uint16_t	updatePeriod;
	uint16_t    updateCounter;
	BatteryStatus_TypeDef Status;
} Battery_TypeDef;

void batteryInit(Battery_TypeDef *thisBattery);
void batteryInitTest(Battery_TypeDef *thisBattery);
/*--------------------- Functions I2C for Updating parameters ---------------------*/
void _Battery_Reading_cellVoltage(Battery_TypeDef *thisBattery);
void _Battery_Reading_chargerVoltage(Battery_TypeDef *thisBattery);
void _Battery_Reading_batVoltage(Battery_TypeDef *thisBattery);
void _Battery_Reading_batCurrent(Battery_TypeDef *thisBattery);
void _Battery_Reading_batTemperature(Battery_TypeDef *thisBattery);
void _Battery_Reading_cellVoltageMaxMin(Battery_TypeDef *thisBattery);
void _Battery_Reading_deltacellVoltageMax(Battery_TypeDef *thisBattery);
void _Battery_Reading_AllParameters(Battery_TypeDef *thisBattery);
void _Battery_ResetParamIfError(Battery_TypeDef *thisBattery);
void _Battery_Reading_deltacellVoltageMaxFulChg(Battery_TypeDef *thisBattery);
#endif /* SRC__BATTERY_H_ */
