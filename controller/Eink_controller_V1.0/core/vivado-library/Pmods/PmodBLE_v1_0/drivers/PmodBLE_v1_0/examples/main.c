/******************************************************************************/
/*                                                                            */
/* main.c -- Example program using the PmodBLE IP                            */
/*                                                                            */
/******************************************************************************/
/* Author: Arthur Brown                                                       */
/*                                                                            */
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo continuously polls the Pmod BLE and host development board's     */
/* UART connections and forwards each character from each to the other.       */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    10/04/2017(artvvb):  Created                                            */
/*	  01/16/2017(Tommyk):  Modified to work for PmodBLE						  */
/*                                                                            */
/******************************************************************************/

#include "xil_cache.h"
#include "xparameters.h"
#include "PmodBLE.h"

//required definitions for sending & receiving data over the host board's UART port
#ifdef __MICROBLAZE__
#include "xuartlite.h"
typedef XUartLite SysUart;
#define SysUart_Send            XUartLite_Send
#define SysUart_Recv            XUartLite_Recv
#define SYS_UART_DEVICE_ID      XPAR_AXI_UARTLITE_0_DEVICE_ID
#define BLE_UART_AXI_CLOCK_FREQ XPAR_CPU_M_AXI_DP_FREQ_HZ
#else
#include "xuartps.h"
typedef XUartPs SysUart;
#define SysUart_Send            XUartPs_Send
#define SysUart_Recv            XUartPs_Recv
#define SYS_UART_DEVICE_ID      XPAR_PS7_UART_1_DEVICE_ID
#define BLE_UART_AXI_CLOCK_FREQ 100000000
#endif

PmodBLE myDevice;
SysUart myUart;

void DemoInitialize();
void DemoRun();
void SysUartInit();
void EnableCaches();
void DisableCaches();

int main()
{
    DemoInitialize();
    DemoRun();
    DisableCaches();
    return XST_SUCCESS;
}

void DemoInitialize()
{
    EnableCaches();
    SysUartInit();
    BLE_Begin (
        &myDevice,
        XPAR_PMODBLE_0_S_AXI_GPIO_BASEADDR,
        XPAR_PMODBLE_0_S_AXI_UART_BASEADDR,
        BLE_UART_AXI_CLOCK_FREQ,
        115200
    );
}

void DemoRun()
{
    u8 buf[1];
    int n;

    xil_printf("Initialized PmodBLE Demo, received data will be echoed here, type to send data\r\n");

    while(1) {
        //echo all characters received from both BLE and terminal to terminal
        //forward all characters received from terminal to BLE
        n = SysUart_Recv(&myUart, buf, 1);
        if (n != 0) {
            SysUart_Send(&myUart, buf, 1);
            BLE_SendData(&myDevice, buf, 1);
        }

        n = BLE_RecvData(&myDevice, buf, 1);
        if (n != 0) {
            SysUart_Send(&myUart, buf, 1);
        }
    }
}

//initialize the system uart device, AXI uartlite for microblaze, uartps for Zynq
void SysUartInit()
{
#ifdef __MICROBLAZE__
    XUartLite_Initialize(&myUart, SYS_UART_DEVICE_ID);
#else
    XUartPs_Config *myUartCfgPtr;
    myUartCfgPtr = XUartPs_LookupConfig(SYS_UART_DEVICE_ID);
    XUartPs_CfgInitialize(&myUart, myUartCfgPtr, myUartCfgPtr->BaseAddress);
#endif
}

void EnableCaches()
{
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_ICACHE
    Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
    Xil_DCacheEnable();
#endif
#endif
}

void DisableCaches()
{
#ifdef __MICROBLAZE__
#ifdef XPAR_MICROBLAZE_USE_DCACHE
    Xil_DCacheDisable();
#endif
#ifdef XPAR_MICROBLAZE_USE_ICACHE
    Xil_ICacheDisable();
#endif
#endif
}
