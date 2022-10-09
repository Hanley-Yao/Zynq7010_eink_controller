/*******************************************************************************
    The drivers defined here are intended for using the Pmod ESP32 in
	UART mode. AT command helper functions can be found in the
	drivers/examples/src subdirectory of this IP.
*******************************************************************************/

/*******************************************************************************
    Revision History

    01/26/18 (mitchell orsucci): Initial Release
	06/13/18 (arthur brown): Package with PmodESP32 IP

*******************************************************************************/

#ifndef PMODESP32_H
#define PMODESP32_H

#include "xil_types.h"
#include "xuartlite.h"
#include "xgpio.h"
#include "xstatus.h"

typedef struct {
	XGpio ESP32_Gpio;
	XUartLite ESP32_Uart;
} PmodESP32;

#define ESP32_Recv(InstancePtr, buffer, count) XUartLite_Recv(&((InstancePtr)->ESP32_Uart), (buffer), (count))
#define ESP32_Send(InstancePtr, buffer, count) XUartLite_Send(&((InstancePtr)->ESP32_Uart), (buffer), (count))

XStatus ESP32_Initialize(PmodESP32 *InstancePtr, u32 UartBaseAddr, u32 GpioBaseAddr);
void ESP32_SendBuffer(PmodESP32 *InstancePtr, u8 *buffer, u32 count);
void ESP32_HardwareReset(PmodESP32 *InstancePtr);
void ESP32_HardwareEnable(PmodESP32 *InstancePtr);
void ESP32_HardwareDisable(PmodESP32 *InstancePtr);

#endif
