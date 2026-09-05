################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (12.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/_BMS.c \
../Core/Src/_Battery.c \
../Core/Src/_CellBalancing.c \
../Core/Src/_Fan.c \
../Core/Src/_HMI.c \
../Core/Src/_NumberofCharge.c \
../Core/Src/_Speaker.c \
../Core/Src/_SystemState.c \
../Core/Src/_controller.c \
../Core/Src/globalDefine.c \
../Core/Src/main.c \
../Core/Src/myADC.c \
../Core/Src/myBQ76942_I2C.c \
../Core/Src/myI2CLCD.c \
../Core/Src/myPWM.c \
../Core/Src/myUART.c \
../Core/Src/stm32f1xx_hal_msp.c \
../Core/Src/stm32f1xx_it.c \
../Core/Src/syscalls.c \
../Core/Src/sysmem.c \
../Core/Src/system_stm32f1xx.c 

OBJS += \
./Core/Src/_BMS.o \
./Core/Src/_Battery.o \
./Core/Src/_CellBalancing.o \
./Core/Src/_Fan.o \
./Core/Src/_HMI.o \
./Core/Src/_NumberofCharge.o \
./Core/Src/_Speaker.o \
./Core/Src/_SystemState.o \
./Core/Src/_controller.o \
./Core/Src/globalDefine.o \
./Core/Src/main.o \
./Core/Src/myADC.o \
./Core/Src/myBQ76942_I2C.o \
./Core/Src/myI2CLCD.o \
./Core/Src/myPWM.o \
./Core/Src/myUART.o \
./Core/Src/stm32f1xx_hal_msp.o \
./Core/Src/stm32f1xx_it.o \
./Core/Src/syscalls.o \
./Core/Src/sysmem.o \
./Core/Src/system_stm32f1xx.o 

C_DEPS += \
./Core/Src/_BMS.d \
./Core/Src/_Battery.d \
./Core/Src/_CellBalancing.d \
./Core/Src/_Fan.d \
./Core/Src/_HMI.d \
./Core/Src/_NumberofCharge.d \
./Core/Src/_Speaker.d \
./Core/Src/_SystemState.d \
./Core/Src/_controller.d \
./Core/Src/globalDefine.d \
./Core/Src/main.d \
./Core/Src/myADC.d \
./Core/Src/myBQ76942_I2C.d \
./Core/Src/myI2CLCD.d \
./Core/Src/myPWM.d \
./Core/Src/myUART.d \
./Core/Src/stm32f1xx_hal_msp.d \
./Core/Src/stm32f1xx_it.d \
./Core/Src/syscalls.d \
./Core/Src/sysmem.d \
./Core/Src/system_stm32f1xx.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/%.o Core/Src/%.su Core/Src/%.cyclo: ../Core/Src/%.c Core/Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Core-2f-Src

clean-Core-2f-Src:
	-$(RM) ./Core/Src/_BMS.cyclo ./Core/Src/_BMS.d ./Core/Src/_BMS.o ./Core/Src/_BMS.su ./Core/Src/_Battery.cyclo ./Core/Src/_Battery.d ./Core/Src/_Battery.o ./Core/Src/_Battery.su ./Core/Src/_CellBalancing.cyclo ./Core/Src/_CellBalancing.d ./Core/Src/_CellBalancing.o ./Core/Src/_CellBalancing.su ./Core/Src/_Fan.cyclo ./Core/Src/_Fan.d ./Core/Src/_Fan.o ./Core/Src/_Fan.su ./Core/Src/_HMI.cyclo ./Core/Src/_HMI.d ./Core/Src/_HMI.o ./Core/Src/_HMI.su ./Core/Src/_NumberofCharge.cyclo ./Core/Src/_NumberofCharge.d ./Core/Src/_NumberofCharge.o ./Core/Src/_NumberofCharge.su ./Core/Src/_Speaker.cyclo ./Core/Src/_Speaker.d ./Core/Src/_Speaker.o ./Core/Src/_Speaker.su ./Core/Src/_SystemState.cyclo ./Core/Src/_SystemState.d ./Core/Src/_SystemState.o ./Core/Src/_SystemState.su ./Core/Src/_controller.cyclo ./Core/Src/_controller.d ./Core/Src/_controller.o ./Core/Src/_controller.su ./Core/Src/globalDefine.cyclo ./Core/Src/globalDefine.d ./Core/Src/globalDefine.o ./Core/Src/globalDefine.su ./Core/Src/main.cyclo ./Core/Src/main.d ./Core/Src/main.o ./Core/Src/main.su ./Core/Src/myADC.cyclo ./Core/Src/myADC.d ./Core/Src/myADC.o ./Core/Src/myADC.su ./Core/Src/myBQ76942_I2C.cyclo ./Core/Src/myBQ76942_I2C.d ./Core/Src/myBQ76942_I2C.o ./Core/Src/myBQ76942_I2C.su ./Core/Src/myI2CLCD.cyclo ./Core/Src/myI2CLCD.d ./Core/Src/myI2CLCD.o ./Core/Src/myI2CLCD.su ./Core/Src/myPWM.cyclo ./Core/Src/myPWM.d ./Core/Src/myPWM.o ./Core/Src/myPWM.su ./Core/Src/myUART.cyclo ./Core/Src/myUART.d ./Core/Src/myUART.o ./Core/Src/myUART.su ./Core/Src/stm32f1xx_hal_msp.cyclo ./Core/Src/stm32f1xx_hal_msp.d ./Core/Src/stm32f1xx_hal_msp.o ./Core/Src/stm32f1xx_hal_msp.su ./Core/Src/stm32f1xx_it.cyclo ./Core/Src/stm32f1xx_it.d ./Core/Src/stm32f1xx_it.o ./Core/Src/stm32f1xx_it.su ./Core/Src/syscalls.cyclo ./Core/Src/syscalls.d ./Core/Src/syscalls.o ./Core/Src/syscalls.su ./Core/Src/sysmem.cyclo ./Core/Src/sysmem.d ./Core/Src/sysmem.o ./Core/Src/sysmem.su ./Core/Src/system_stm32f1xx.cyclo ./Core/Src/system_stm32f1xx.d ./Core/Src/system_stm32f1xx.o ./Core/Src/system_stm32f1xx.su

.PHONY: clean-Core-2f-Src

