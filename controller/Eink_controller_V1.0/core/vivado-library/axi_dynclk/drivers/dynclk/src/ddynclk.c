

/***************************** Include Files *******************************/
#include "ddynclk.h"
#include "xil_types.h"

/* Back-ported from Linux driver */
#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))

#define CLK_BIT_WEDGE 13
#define CLK_BIT_NOCOUNT 12

/* This value is used to signal an error */
#define ERR_CLKCOUNTCALC 0xFFFFFFFF
#define ERR_CLKDIVIDER (1 << CLK_BIT_WEDGE | 1 << CLK_BIT_NOCOUNT)

#define DYNCLK_DIV_1_REGMASK 0x1041
/* 25 MHz (125 KHz / 5) */
#define DYNCLK_DEFAULT_FREQ 125000

#define MMCM_FREQ_VCOMIN 600000
#define MMCM_FREQ_VCOMAX 1200000
#define MMCM_FREQ_PFDMIN 10000
#define MMCM_FREQ_PFDMAX 450000
#define MMCM_FREQ_OUTMIN 4000
#define MMCM_FREQ_OUTMAX 800000
#define MMCM_DIV_MAX 106
#define MMCM_FB_MIN 2
#define MMCM_FB_MAX 64
#define MMCM_CLKDIV_MAX 128
#define MMCM_CLKDIV_MIN 1

/************************** Type Definitions ***************************/
struct dglnt_dynclk_reg {
	uint32_t clk0L;
	uint32_t clkFBL;
	uint32_t clkFBH_clk0H;
	uint32_t divclk;
	uint32_t lockL;
	uint32_t fltr_lockH;
};

struct dglnt_dynclk_mode {
	uint32_t freq;
	uint32_t fbmult;
	uint32_t clkdiv;
	uint32_t maindiv;
};

/************************** Constant Definitions ***************************/

static const uint64_t lock_lookup[64] = {
	0b0011000110111110100011111010010000000001,
	0b0011000110111110100011111010010000000001,
	0b0100001000111110100011111010010000000001,
	0b0101101011111110100011111010010000000001,
	0b0111001110111110100011111010010000000001,
	0b1000110001111110100011111010010000000001,
	0b1001110011111110100011111010010000000001,
	0b1011010110111110100011111010010000000001,
	0b1100111001111110100011111010010000000001,
	0b1110011100111110100011111010010000000001,
	0b1111111111111000010011111010010000000001,
	0b1111111111110011100111111010010000000001,
	0b1111111111101110111011111010010000000001,
	0b1111111111101011110011111010010000000001,
	0b1111111111101000101011111010010000000001,
	0b1111111111100111000111111010010000000001,
	0b1111111111100011111111111010010000000001,
	0b1111111111100010011011111010010000000001,
	0b1111111111100000110111111010010000000001,
	0b1111111111011111010011111010010000000001,
	0b1111111111011101101111111010010000000001,
	0b1111111111011100001011111010010000000001,
	0b1111111111011010100111111010010000000001,
	0b1111111111011001000011111010010000000001,
	0b1111111111011001000011111010010000000001,
	0b1111111111010111011111111010010000000001,
	0b1111111111010101111011111010010000000001,
	0b1111111111010101111011111010010000000001,
	0b1111111111010100010111111010010000000001,
	0b1111111111010100010111111010010000000001,
	0b1111111111010010110011111010010000000001,
	0b1111111111010010110011111010010000000001,
	0b1111111111010010110011111010010000000001,
	0b1111111111010001001111111010010000000001,
	0b1111111111010001001111111010010000000001,
	0b1111111111010001001111111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001,
	0b1111111111001111101011111010010000000001
};

static const uint32_t filter_lookup_low[64] = {
	0b0001011111,
	0b0001010111,
	0b0001111011,
	0b0001011011,
	0b0001101011,
	0b0001110011,
	0b0001110011,
	0b0001110011,
	0b0001110011,
	0b0001001011,
	0b0001001011,
	0b0001001011,
	0b0010110011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001010011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0001100011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010010011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011,
	0b0010100011
};

/************************** Function Definitions ***************************/
static uint32_t dglnt_dynclk_divider(uint32_t divide)
{
	uint32_t output = 0;
	uint32_t highTime = 0;
	uint32_t lowTime = 0;

	if ((divide < 1) || (divide > 128))
		return ERR_CLKDIVIDER;

	if (divide == 1)
		return DYNCLK_DIV_1_REGMASK;

	highTime = divide / 2;
	/* if divide is odd */
	if (divide & 0x1) {
		lowTime = highTime + 1;
		output = 1 << CLK_BIT_WEDGE;
	} else {
		lowTime = highTime;
	}

	output |= 0x03F & lowTime;
	output |= 0xFC0 & (highTime << 6);
	return output;
}

static uint32_t dglnt_dynclk_count_calc(uint32_t divide)
{
	uint32_t output = 0;
	uint32_t divCalc = 0;

	divCalc = dglnt_dynclk_divider(divide);
	if (divCalc == ERR_CLKDIVIDER)
		output = ERR_CLKCOUNTCALC;
	else
		output = (0xFFF & divCalc) | ((divCalc << 10) & 0x00C00000);
	return output;
}


static int dglnt_dynclk_find_reg(struct dglnt_dynclk_reg *regValues,
			  struct dglnt_dynclk_mode *clkParams)
{
	if ((clkParams->fbmult < 2) || clkParams->fbmult > 64)
		return XST_FAILURE;

	regValues->clk0L = dglnt_dynclk_count_calc(clkParams->clkdiv);
	if (regValues->clk0L == ERR_CLKCOUNTCALC)
		return XST_FAILURE;

	regValues->clkFBL = dglnt_dynclk_count_calc(clkParams->fbmult);
	if (regValues->clkFBL == ERR_CLKCOUNTCALC)
		return XST_FAILURE;

	regValues->clkFBH_clk0H = 0;

	regValues->divclk = dglnt_dynclk_divider(clkParams->maindiv);
	if (regValues->divclk == ERR_CLKDIVIDER)
		return XST_FAILURE;

	regValues->lockL = (uint32_t)(lock_lookup[clkParams->fbmult - 1] &
				 0xFFFFFFFF);

	regValues->fltr_lockH = (uint32_t)((lock_lookup[clkParams->fbmult - 1] >>
				       32) & 0x000000FF);
	regValues->fltr_lockH |= ((filter_lookup_low[clkParams->fbmult - 1] <<
				   16) & 0x03FF0000);

	return 0;
}

static void dglnt_dynclk_write_reg(struct dglnt_dynclk_reg *regValues,
			    uintptr_t baseaddr)
{
	DDynClk_WriteReg(baseaddr, (DDYNCLK_CLK_L), regValues->clk0L);
	DDynClk_WriteReg(baseaddr, (DDYNCLK_FB_L), regValues->clkFBL);
	DDynClk_WriteReg(baseaddr, (DDYNCLK_FB_H_CLK_H), regValues->clkFBH_clk0H);
	DDynClk_WriteReg(baseaddr, (DDYNCLK_DIV), regValues->divclk);
	DDynClk_WriteReg(baseaddr, (DDYNCLK_LOCK_L), regValues->lockL);
	DDynClk_WriteReg(baseaddr, (DDYNCLK_FLTR_LOCK_H), regValues->fltr_lockH);
}

static uint32_t dglnt_dynclk_find_mode(uint32_t freq, uint32_t parentFreq,
			   struct dglnt_dynclk_mode *bestPick)
{
	uint32_t bestError = MMCM_FREQ_OUTMAX;
	uint32_t curError;
	uint32_t curClkMult;
	uint32_t curFreq;
	uint32_t divVal;
	uint32_t curFb, curClkDiv;
	uint32_t minFb = 0;
	uint32_t maxFb = 0;
	uint32_t curDiv = 1;
	uint32_t maxDiv;
	int freq_found = 0;

	bestPick->freq = 0;
	if (parentFreq == 0)
		return 0;

	/* minimum frequency is actually dictated by VCOmin */
	if (freq < MMCM_FREQ_OUTMIN)
		freq = MMCM_FREQ_OUTMIN;
	if (freq > MMCM_FREQ_OUTMAX)
		freq = MMCM_FREQ_OUTMAX;

	if (parentFreq > MMCM_FREQ_PFDMAX)
		curDiv = 2;
	maxDiv = parentFreq / MMCM_FREQ_PFDMIN;
	if (maxDiv > MMCM_DIV_MAX)
		maxDiv = MMCM_DIV_MAX;

	while (curDiv <= maxDiv && !freq_found) {
		minFb = curDiv * DIV_ROUND_UP(MMCM_FREQ_VCOMIN, parentFreq);
		maxFb = curDiv * (MMCM_FREQ_VCOMAX / parentFreq);
		if (maxFb > MMCM_FB_MAX)
			maxFb = MMCM_FB_MAX;
		if (minFb < MMCM_FB_MIN)
			minFb = MMCM_FB_MIN;

		divVal = curDiv * freq;
		/*
		 * This multiplier is used to find the best clkDiv value for
		 * each FB value
		 */
		curClkMult = ((parentFreq * 1000) + (divVal / 2)) / divVal;

		curFb = minFb;
		while (curFb <= maxFb && !freq_found) {
			curClkDiv = ((curClkMult * curFb) + 500) / 1000;
			if (curClkDiv > MMCM_CLKDIV_MAX)
				curClkDiv = MMCM_CLKDIV_MAX;
			if (curClkDiv < MMCM_CLKDIV_MIN)
				curClkDiv = MMCM_CLKDIV_MIN;
			curFreq = (((parentFreq * curFb) / curDiv) / curClkDiv);
			if (curFreq >= freq)
				curError = curFreq - freq;
			else
				curError = freq - curFreq;
			if (curError < bestError) {
				bestError = curError;
				bestPick->clkdiv = curClkDiv;
				bestPick->fbmult = curFb;
				bestPick->maindiv = curDiv;
				bestPick->freq = curFreq;
			}
			if (!curError)
				freq_found = 1;
			curFb++;
		}
		curDiv++;
	}
	return bestPick->freq;
}

static int dglnt_dynclk_enable(DDynClk* drv_inst)
{
	unsigned int clock_state;

	if (drv_inst->IsReady == XIL_COMPONENT_IS_READY && drv_inst->freq) {
		DDynClk_WriteReg(drv_inst->Config.BaseAddress, DDYNCLK_CTRL, 1);
		do {
			clock_state = DDynClk_ReadReg(drv_inst->Config.BaseAddress,
					    DDYNCLK_STATUS);
		} while (!clock_state);
	}
	return 0;
}

static void dglnt_dynclk_disable(DDynClk* drv_inst)
{
	DDynClk_WriteReg(drv_inst->Config.BaseAddress, DDYNCLK_CTRL, 0);
}

static int dglnt_dynclk_set_rate(DDynClk* drv_inst,
	unsigned long rate, unsigned long parent_rate)
{
	struct dglnt_dynclk_reg clkReg;
	struct dglnt_dynclk_mode clkMode;

	if (parent_rate == 0 || rate == 0)
		return XST_FAILURE;
	if (rate == drv_inst->freq)
		return 0;

	/*
	 * Convert from Hz to KHz, then multiply by five to account for
	 * BUFR division
	 */
	rate = (rate + 100) / 200;
	/* convert from Hz to KHz */
	parent_rate = (parent_rate + 500) / 1000;
	if (!dglnt_dynclk_find_mode(rate, parent_rate, &clkMode))
		return XST_FAILURE;

	/*
	 * Write to the PLL dynamic configuration registers to configure it
	 * with the calculated parameters.
	 */
	dglnt_dynclk_find_reg(&clkReg, &clkMode);
	dglnt_dynclk_write_reg(&clkReg, drv_inst->Config.BaseAddress);
	drv_inst->freq = clkMode.freq * 200;
	dglnt_dynclk_disable(drv_inst);
	dglnt_dynclk_enable(drv_inst);

	return 0;
}

int DDynClk_CfgInitialize(DDynClk *InstancePtr, DDynClk_Config *CfgPtr,
				UINTPTR EffectiveAddr)
{
	/* Verify arguments */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(CfgPtr != NULL);
	Xil_AssertNonvoid((u32 *)EffectiveAddr != NULL);

	/* Setup the instance */
	memset((void *)InstancePtr, 0, sizeof(DDynClk));

	memcpy((void *)&(InstancePtr->Config), (const void *)CfgPtr,
			   sizeof(DDynClk_Config));
	InstancePtr->Config.BaseAddress = EffectiveAddr;

	// Read the reference clock frequency from RO register (maybe a Config parameter would be better?)
	InstancePtr->RefClkFreqHz = DDynClk_ReadReg(EffectiveAddr, DDYNCLK_REF_CLK_FREQ);
	if (InstancePtr->RefClkFreqHz == 0)
		return XST_FAILURE;

	/* Set the flag to indicate the driver is ready */
	InstancePtr->IsReady = (u32)(XIL_COMPONENT_IS_READY);

	return XST_SUCCESS;
}

int DDynClk_Enable(DDynClk *InstancePtr)
{
	if (dglnt_dynclk_enable(InstancePtr) != 0)
		return XST_FAILURE;
	return XST_SUCCESS;
}

int DDynClk_Disable(DDynClk *InstancePtr)
{
	dglnt_dynclk_disable(InstancePtr);

	return XST_SUCCESS;
}

int DDynClk_SetRate(DDynClk *InstancePtr, uint32_t RateInHz)
{
	if (0 != dglnt_dynclk_set_rate(InstancePtr, RateInHz, InstancePtr->RefClkFreqHz))
		return XST_FAILURE;

	return XST_SUCCESS;

}
