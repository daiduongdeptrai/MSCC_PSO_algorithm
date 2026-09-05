/*
 * globalDefine.h
 *
 *  Created on: Mar 20, 2020
 *      Author: powersystem
 */

#ifndef SRC_GLOBALDEFINE_H_
#define SRC_GLOBALDEFINE_H_

#include "main.h"
#include "stdbool.h"

#define max(a,b)		(((a)>(b)) ? (a):(b))
#define min(a,b)		(((a)<(b)) ? (a):(b))
#define abs(X)          ((X) > 0 ? (X) : -(X))

typedef enum ledStatusTypeDef {
	LED_SLOW	= 1000U,
	LED_MED		= 500U,
	LED_FAST	= 125U
} blinkPeriod_TypeDef;

extern blinkPeriod_TypeDef 	blinkPeriod;
extern uint16_t 			cnt_Led_Update;
extern uint16_t 			State_CNT_Check;
extern uint16_t 			g_cnt_stateSW;
#define getTimeStamp()		(TIM2->CNT)	// Get the current timer count

/*
 * Threshold parameters for charger
 */
/* Float: Controller's threshold and State Charger's threshold*/
#define Tz_INT		100e-6f
#define FCLK		64000000U

#define kpI			0.0005f*0.8f
#define kiI 		40000000.0f
#define kiI_x_Tz 	0.000138f*0.8f

#define kpV			0.0377f
#define kiV 		285.766f
#define kiV_x_Tz 	kiV*Tz_INT

#define VADAPTOR	43.8f

#define VMAX        42.0f
#define VBULK       37.8	//37.35f	// 4,15 V
#define VFULL		37.6	//37.25f	// 4,12 V
#define VDDCHRG     22.5f
#define VMIN        10.0f

#define IMAX        3.0f
#define IMAX_CTRL	1.5f
#define IBULK       1.5f
#define IPRE        0.1f
#define IMIN		0.1f

#define TEMPMAX		90.0f

#define VO_GAIN      0.01276918117f
#define VBAT_GAIN    0.01276918117f
#define IBAT_GAIN    0.001568254f
#define ADC_ADAPTOR  3430U

#define VBAT_GAIN_MV 	12.6662946f
#define VBAT_GAIN_ADC 	0.07858f

#define TEMP_GAIN    0.39842717
#define OFFSET_TEMP	 1087.02710280

#define DUTY_MAX			1.0f
#define DUTY_HIGH_LIMIT  	0.93f
#define DUTY_LOW_LIMIT  	0.05f


#endif /* SRC_GLOBALDEFINE_H_ */
