#include "PmodESP32.h"
#include "sleep.h"

XGpio_Config ESP32_GpioConfig = {
	0, //	DeviceId
	0, //	BaseAddress
	1, //	InterruptPresent
	1  //	IsDual
};
XUartLite_Config ESP32_UartConfig = {
	0, //	DeviceId
	0, //	RegBaseAddr
	115200, //	BaudRate
	0, //	UseParity
	0, //	ParityOdd
	8  //	DataBits
};

XStatus ESP32_Initialize(PmodESP32 *InstancePtr, u32 UartBaseAddr, u32 GpioBaseAddr) {
	XStatus Status;
	XUartLite *UartPtr = &(InstancePtr->ESP32_Uart);
	XGpio *GpioPtr = &(InstancePtr->ESP32_Gpio);

	ESP32_UartConfig.RegBaseAddr = UartBaseAddr;
	ESP32_GpioConfig.BaseAddress = GpioBaseAddr;

	Status = XUartLite_CfgInitialize(UartPtr, &ESP32_UartConfig, ESP32_UartConfig.RegBaseAddr);
	if (XST_SUCCESS != Status) {
		return Status;
	}
	XUartLite_DisableInterrupt(UartPtr);

	Status = XGpio_CfgInitialize(GpioPtr, &ESP32_GpioConfig, ESP32_GpioConfig.BaseAddress);
	if (XST_SUCCESS != Status) {
		return Status;
	}
	
	//Set top row RTS/CTS pins to all input
	XGpio_SetDataDirection(GpioPtr, 1, 0b11);
	// Set bottom row SELECT and ENABLE pins to output, INT and GPIO pins to input
	XGpio_SetDataDirection(GpioPtr, 2, 0b1001);
	// Set ENABLE low then reenable to reboot the ESP32. Set SELECT low to enter UART mode of operation
	XGpio_DiscreteWrite(GpioPtr, 2, 0b0000);
	
	ESP32_HardwareEnable(InstancePtr);

	return XST_SUCCESS;
}

void ESP32_SendBuffer(PmodESP32 *InstancePtr, u8 *buffer, u32 length) {
	u32 num;
	while (length > 0) {
		num = XUartLite_Send(&(InstancePtr->ESP32_Uart), buffer, length);
		buffer += num;
		length -= num;
	}
}

void ESP32_HardwareReset(PmodESP32 *InstancePtr) {
	ESP32_HardwareDisable(InstancePtr);
	ESP32_HardwareEnable(InstancePtr);
}

void ESP32_HardwareEnable(PmodESP32 *InstancePtr) {
	XGpio *GpioPtr = &(InstancePtr->ESP32_Gpio);
	u32 data;
	
	data = XGpio_DiscreteRead(GpioPtr, 2);
	XGpio_DiscreteWrite(GpioPtr, 2, data | 2);
}

void ESP32_HardwareDisable(PmodESP32 *InstancePtr) {
	XGpio *GpioPtr = &(InstancePtr->ESP32_Gpio);
	u32 data;
	
	data = XGpio_DiscreteRead(GpioPtr, 2);
	XGpio_DiscreteWrite(GpioPtr, 2, data & ~2);
}
