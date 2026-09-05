/*
 * I2C_BQ769x2_cfg.c
 *
 *  Created on: Dec 23, 2024
 *      Author: ADMIN
 */

#include "_CellBalancing.h"

#include "stdint.h"
#include "stdbool.h"

/* Define the parameters of Slave - BQ769x2 */
extern I2C_HandleTypeDef hi2c1;

/* BQ769x2 I2C Address and Index */
#define BQ769x2_ADDRESS			0x08
#define BQ796x2_Index			1
#define BQ769x2_ADDRESS_Write	BQ769x2_ADDRESS << 1
#define BQ769x2_ADDRESS_Read    BQ769x2_ADDRESS << 1

/* Configuration parameters for I2C communication with BQ769x2 */
const I2C_BQ796x2_CfgType I2C_BQ796x2_CfgParam =
{
		/*  Configuration Parameter For I2C_LCD Instance #1   */
		BQ796x2_Index,				/* Index of I2C_LCD Instance #1           		*/
		&hi2c1,						/* Hardware I2C Module's Handle           		*/
		BQ769x2_ADDRESS_Write,		/* Hardware I2C_LCD Device Address for write   	*/
		BQ769x2_ADDRESS_Read,		/* Hardware I2C_LCD Device Address for read    	*/
};

/* Define the update period for cell balancing (in milliseconds) */
#define CellBalancing_UPDATE_PERIOD	150U	// 100ms

/* Cell balancing structure instance */
CellBalancing_TypeDef	thisCellBalancing = {	.updateCounter = 0,
												.updatePeriod  = 0,
												.updateFlag = false
											};

/**
  * @brief  Initializes the cell balancing parameters.
  * @param  thisCellBalancing: Pointer to the cell balancing structure.
  * @retval None
  */
void cellbalancingInit(CellBalancing_TypeDef	*thisCellBalancing) {
	thisCellBalancing->updateCounter	= 0;
	thisCellBalancing->updateFlag 	= false;
	thisCellBalancing->updatePeriod	= CellBalancing_UPDATE_PERIOD;
	return;
}
