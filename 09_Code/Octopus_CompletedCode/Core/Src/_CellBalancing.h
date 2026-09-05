/*
 * I2C_BQ769x2_cfg.h
 *
 *  Created on: Dec 23, 2024
 *      Author: ADMIN
 */

#ifndef SRC__CELLBALANCING_H_
#define SRC__CELLBALANCING_H_

#include "myBQ76942_I2C.h"

typedef struct
{
	// I2C BQ769x2 Module Instance Index
	uint8_t I2C_BQ796x2_Instance;

	// I2C Hardware Peripheral Handle
	I2C_HandleTypeDef* I2C_BQ796x2_Handler;

	// I2C BQ796x2 Hardware Device Address for Writing
	uint8_t I2C_BQ796x2_Address_Write;

	// I2C BQ796x2 Hardware Device Address for Reading
	uint8_t I2C_BQ796x2_Address_Read;

}I2C_BQ796x2_CfgType;
extern const I2C_BQ796x2_CfgType I2C_BQ796x2_CfgParam;

typedef struct
{
	uint16_t	updateCounter;		// counter to update period
	uint16_t	updatePeriod;		// update period
	_Bool		updateFlag;			// = true if cnt >= prd
}CellBalancing_TypeDef;

void cellbalancingInit(CellBalancing_TypeDef	*thisCellBalancing);
#endif /* SRC__CELLBALANCING_H_ */
