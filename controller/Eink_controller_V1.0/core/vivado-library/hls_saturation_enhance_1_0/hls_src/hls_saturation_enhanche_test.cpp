//-------------------------------------------------------------------------------
//--
//-- File: hls_saturation_enhanche_test.cpp
//-- Author: Ciprian Hegbeli
//-- Date: 19 June 2018
//--
//-------------------------------------------------------------------------------
//-- MIT License
//
//-- Copyright (c) 2018 Digilent
//
//-- Permission is hereby granted, free of charge, to any person obtaining a copy
//-- of this software and associated documentation files (the "Software"), to deal
//-- in the Software without restriction, including without limitation the rights
//-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//-- copies of the Software, and to permit persons to whom the Software is
//-- furnished to do so, subject to the following conditions:
//
//-- The above copyright notice and this permission notice shall be included in all
//-- copies or substantial portions of the Software.
//
//-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//-- SOFTWARE.
//--
//-------------------------------------------------------------------------------
//--
//-- Purpose: File used to test the saturation enhancement algorithm and for creation
//-- LUT for saturation coefficient
//--
//-------------------------------------------------------------------------------

/***************************** Include Files ********************************/

#include "hls_saturation_enhanche.h"
#include "hls_opencv.h"


/****************************************************************************/
/**
 * Creates the lookup table for the chosen saturation coefficient. The chosen
 * Implementation for enhancing saturation is dst.sat = src.sat + s*src.sat;
 * in order to avoid over saturation and false colors a couple of safeguards
 * have been implemented. If the the saturation value is greater then 0
 * a gray factor is calculated to that the unsaturated colors don't get
 * saturated gray_factor = src.sat/255, also the upper limit must be defined so that
 * the max value of the saturation can be remaped to 255 by using
 * var_interval = 255-src.sat. If the factor is less then 0 then no safe guards
 * have been applied.
 * The function will list the results to the console
 *
 * @param s is a floating point variable which represents the saturation factor
 * 		which will be applied
 *
 * @return None
 *
 * @note
 *
*****************************************************************************/
void sat_lut_creator(float s)
{
	unsigned char lut[256];

	printf("%f = {",s);
	//calculate the sat value for each possible input value [0;255]
	for (int i = 0; i < 256; i++)
	{
		if(s >= 0)
		{
			//var_interval = 255-src.sat
			//gray_factor = src.sat/255,
			//dst.sat = src.sat + gray_factor * src.sat * var_interval
			lut[i] = cv::saturate_cast<uchar>(i + (s*(i/255.0)*(255.0-i)) );
		}
		else
		{
			//dst.sat = src.sat + s*src.sat
			lut[i] = cv::saturate_cast<uchar>(i+(s*i));
		}
		printf("%d,", lut[i]);
	}
	printf("};\n");

}

/****************************************************************************/
/**
* Main test bench
*
* @param None
* @return None
*
*
*****************************************************************************/
int main()
{
	//define the test resolution constants
	int const rows = 720;
	int const cols = 1280;

	//define the input and aoutput matrix
	cv::Mat src = cv::imread(INPUT_IMAGE);
	cv::Mat dst = src;

	//define the stream variables
	stream_t stream_in, stream_out;

	//perform the stream conversion and saturation operations
	cvMat2AXIvideo(src, stream_in);
	hls_saturation_enhance(stream_in, stream_out, rows, cols, 5);
	AXIvideo2cvMat(stream_out, dst);

	//dump the matrix in to the destination image
	cv::imwrite(OUTPUT_IMAGE,dst);

	//functions used to create the LUTs

//	sat_lut_creator(-0.2);
//	sat_lut_creator(0.2);
//	sat_lut_creator(0.4);
//	sat_lut_creator(0.6);
//	sat_lut_creator(0.8);
//	sat_lut_creator(1.0);
//	sat_lut_creator(1.2);

	return 0;
}
