/*
 * myUART.c
 *
 *  Created on: Jan 9, 2025
 *      Author: ADMIN
 */

#include "myUART.h"

char BufTxUart[UART_TX_BUFFER_SIZE];
volatile char BufRxUart[UART_RX_BUFFER_SIZE];
volatile char BufRXChar[1];

void uart_txInit(UartTypeDef *puart){
    strcpy(puart->chargerState, "BC");
    strcpy(puart->protectionMode, "NOPT");
    strcpy(puart->chargerMode, "NOC");
	return;
}

/**
  * @brief Pause the DMA Transfer.
  * @param huart UART handle.
  * @retval HAL status
  */

HAL_StatusTypeDef UART_DMAPause(UART_HandleTypeDef *huart)
{
  const HAL_UART_StateTypeDef gstate = huart->gState;
  const HAL_UART_StateTypeDef rxstate = huart->RxState;

  if ((HAL_IS_BIT_SET(huart->Instance->CR3, USART_CR3_DMAT)) &&
      (gstate == HAL_UART_STATE_BUSY_TX))
  {
    /* Disable the UART DMA Tx request */
    ATOMIC_CLEAR_BIT(huart->Instance->CR3, USART_CR3_DMAT);
  }
  if ((HAL_IS_BIT_SET(huart->Instance->CR3, USART_CR3_DMAR)) &&
      (rxstate == HAL_UART_STATE_BUSY_RX))
  {
    /* Disable PE and ERR (Frame error, noise error, overrun error) interrupts */
    ATOMIC_CLEAR_BIT(huart->Instance->CR1, USART_CR1_PEIE);
    ATOMIC_CLEAR_BIT(huart->Instance->CR3, USART_CR3_EIE);

    /* Disable the UART DMA Rx request */
    ATOMIC_CLEAR_BIT(huart->Instance->CR3, USART_CR3_DMAR);
  }

  return HAL_OK;
}

/**
  * @brief Resume the DMA Transfer.
  * @param huart UART handle.
  * @retval HAL status
  */
HAL_StatusTypeDef UART_DMAResume(UART_HandleTypeDef *huart)
{
	  if (huart->gState == HAL_UART_STATE_BUSY_TX)
	  {
	    /* Enable the UART DMA Tx request */
	    ATOMIC_SET_BIT(huart->Instance->CR3, USART_CR3_DMAT);
	  }

	  if (huart->RxState == HAL_UART_STATE_BUSY_RX)
	  {
	    /* Clear the Overrun flag before resuming the Rx transfer*/
	    __HAL_UART_CLEAR_OREFLAG(huart);

	    /* Re-enable PE and ERR (Frame error, noise error, overrun error) interrupts */
	    if (huart->Init.Parity != UART_PARITY_NONE)
	    {
	      ATOMIC_SET_BIT(huart->Instance->CR1, USART_CR1_PEIE);
	    }
	    ATOMIC_SET_BIT(huart->Instance->CR3, USART_CR3_EIE);

	    /* Enable the UART DMA Rx request */
	    ATOMIC_SET_BIT(huart->Instance->CR3, USART_CR3_DMAR);
	  }

	  return HAL_OK;
}

