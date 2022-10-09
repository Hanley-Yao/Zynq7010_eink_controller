/*
 * main.c
 *
 *  Created on: Jun 11, 2018
 *      Author: arthur
 */

#include "xparameters.h"
#include "xil_printf.h"
#include "sleep.h"

#include "PmodESP32.h"

#ifdef __MICROBLAZE__
#define HOST_UART_DEVICE_ID XPAR_AXI_UARTLITE_0_BASEADDR
#define HostUart XUartLite
#define HostUart_Config XUartLite_Config
#define HostUart_CfgInitialize XUartLite_CfgInitialize
#define HostUart_LookupConfig XUartLite_LookupConfig
#define HostUart_Recv XUartLite_Recv
#define HostUartConfig_GetBaseAddr(CfgPtr) (CfgPtr->RegBaseAddr)
#include "xuartlite.h"
#include "xil_cache.h"
#else
#define HOST_UART_DEVICE_ID XPAR_PS7_UART_1_DEVICE_ID
#define HostUart XUartPs
#define HostUart_Config XUartPs_Config
#define HostUart_CfgInitialize XUartPs_CfgInitialize
#define HostUart_LookupConfig XUartPs_LookupConfig
#define HostUart_Recv XUartPs_Recv
#define HostUartConfig_GetBaseAddr(CfgPtr) (CfgPtr->BaseAddress)
#include "xuartps.h"
#endif

#define PMODESP32_UART_BASEADDR XPAR_PMODESP32_0_AXI_LITE_UART_BASEADDR
#define PMODESP32_GPIO_BASEADDR XPAR_PMODESP32_0_AXI_LITE_GPIO_BASEADDR

void EnableCaches();
void DisableCaches();
void DemoInitialize();
void DemoRun();
void DemoCleanup();

PmodESP32 myESP32;
HostUart myHostUart;

void DemoInitialize () {
	HostUart_Config *CfgPtr;
	EnableCaches();
	ESP32_Initialize(&myESP32, PMODESP32_UART_BASEADDR, PMODESP32_GPIO_BASEADDR);
	CfgPtr = HostUart_LookupConfig(HOST_UART_DEVICE_ID);
	HostUart_CfgInitialize(&myHostUart, CfgPtr, HostUartConfig_GetBaseAddr(CfgPtr));
}

void DemoRun() {
	u8 recv_buffer;
	u32 num_received;

	xil_printf("Entering Pmod ESP32 Command Line Interface!\r\n");
	xil_printf("Enter AT commands to interact with the ESP32\r\n");

	while (1) {
		// TODO: add exit functionality (ctrl-Z?)
		num_received = ESP32_Recv(&myESP32, &recv_buffer, 1);
		if (num_received > 0) {
			xil_printf("%c", recv_buffer);
		}

		num_received = HostUart_Recv(&myHostUart, &recv_buffer, 1);
		if (num_received > 0) {
			xil_printf("%c", recv_buffer);
			while (0 == ESP32_Send(&myESP32, &recv_buffer, 1));
		}
	}
}

void DemoCleanup() {
	DisableCaches();
}


int main() {
	DemoInitialize();
	DemoRun();
	DemoCleanup();
	return 0;
}

void EnableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheEnable();
#endif
#endif
}

void DisableCaches() {
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
   Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
   Xil_ICacheDisable();
#endif
#endif
}
