/*
 * myUART.h
 *
 *  Created on: Jan 9, 2025
 *      Author: ADMIN
 */

#ifndef SRC_MYUART_H_
#define SRC_MYUART_H_
#include "stdio.h"
#include "string.h"
#include "stm32f1xx_hal.h"
#include "stm32f1xx_hal_uart.h"
extern UART_HandleTypeDef huart1;
#define huart			huart1
#define UART_RX_BUFFER_SIZE 20U
#define UART_TX_BUFFER_SIZE 10U
// FIXME: change to 2U in case of receiving charge count
//#define UART_TX_BUFFER_SIZE 250U

extern char BufTxUart[UART_TX_BUFFER_SIZE];
extern volatile char BufRxUart[UART_RX_BUFFER_SIZE];

typedef struct {
    char chargerState[10];
    char chargerMode[10];
    char protectionMode[10];
} UartTypeDef;


void uart_txInit(UartTypeDef *puart);
HAL_StatusTypeDef UART_DMAPause(UART_HandleTypeDef *huart);
HAL_StatusTypeDef UART_DMAResume(UART_HandleTypeDef *huart);
HAL_StatusTypeDef UART_DMAStop(UART_HandleTypeDef *huart);


#endif /* SRC_MYUART_H_ */
