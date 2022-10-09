#ifndef INTC_H_
#define INTC_H_

#include "xparameters.h"
#include "xstatus.h"
#ifdef XPAR_INTC_0_DEVICE_ID
#include "xintc.h"
#else
#include "xScuGic.h"
#endif

#ifdef XPAR_INTC_0_DEVICE_ID
#define INTC           XIntc
#define INTC_HANDLER   XIntc_InterruptHandler
#define INTC_DEVICE_ID XPAR_INTC_0_DEVICE_ID
#else
#define INTC           XScuGic
#define INTC_HANDLER   XScuGic_InterruptHandler
#define INTC_DEVICE_ID XPAR_PS7_SCUGIC_0_DEVICE_ID
#endif

#define RETURN_ON_FAILURE(x) if ((x) != XST_SUCCESS) return XST_FAILURE;

// Structure for interrupt ID, handler and callback reference
typedef struct {
   u8 id;
   XInterruptHandler handler;
   void *CallbackRef;
} ivt_t;

XStatus InitInterruptController(INTC *intc);
void EnableInterrupts(INTC *intc, const ivt_t *ivt, unsigned int IVectors);

#endif /* INTC_H_ */
