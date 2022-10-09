#include "intc.h"

XStatus InitInterruptController(INTC* intc) {
   int Status;
   // Start the interrupt controller
#ifdef XPAR_INTC_0_DEVICE_ID
   // Initialize the driver instance
   RETURN_ON_FAILURE(XIntc_Initialize(intc, INTC_DEVICE_ID));
   RETURN_ON_FAILURE(XIntc_Start(intc, XIN_REAL_MODE));

#else
   XScuGic_Config *GicConfig;
   GicConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
   XScuGic_CfgInitialize(intc, GicConfig, GicConfig->CpuBaseAddress);
   Status = XScuGic_SelfTest(intc);
   if (Status != XST_SUCCESS) {
      return XST_FAILURE;
   }
#endif

   Xil_ExceptionInit();

   /*
    * register the interrupt controller handler with the exception table.
    * This is in fact the ISR dispatch routine, calling our ISRs
    */
   Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
         (Xil_ExceptionHandler) INTC_HANDLER, intc);
   Xil_ExceptionEnable();

   return XST_SUCCESS;
}

/*
 * This function enables interrupts and connects interupt service routines
 * declared in and interrupt vector table
 */
void EnableInterrupts(INTC *intc, const ivt_t *ivt, unsigned int IVectors) {
   unsigned int isIVector;

   Xil_AssertVoid(intc != NULL);
   //Xil_assertVoid(intc != NULL);
   Xil_AssertVoid(intc->IsReady == XIL_COMPONENT_IS_READY);

   // Hook up interrupt service routines from the passed ivt
   for (isIVector = 0; isIVector < IVectors; isIVector++) {

#ifdef XPAR_INTC_0_DEVICE_ID
      // Initialize the driver instance
      XIntc_Connect(intc, ivt[isIVector].id, ivt[isIVector].handler,
            ivt[isIVector].CallbackRef);
      XIntc_Enable(intc, ivt[isIVector].id);

#else
      XScuGic_Connect(intc, ivt[isIVector].id, ivt[isIVector].handler,
            ivt[isIVector].CallbackRef);
      XScuGic_Enable(intc, ivt[isIVector].id);
#endif
   }
}
