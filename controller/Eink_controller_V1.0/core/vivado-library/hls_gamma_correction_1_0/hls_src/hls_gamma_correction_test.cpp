//-------------------------------------------------------------------------------
//--
//-- File: hls_gamma_correction_test.cpp
//-- Author: Ciprian Hegbeli
//-- Date: 21 June 2018
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
//-- Purpose: File used to test the gamma enhancement algorithm and for creation
//-- LUT for gamma coefficient
//--
//-------------------------------------------------------------------------------

/***************************** Include Files ********************************/

#include "hls_gamma_correction.h"
#include "hls_opencv.h"

/****************************************************************************/
/**
 * Creates the lookup table for the chosen gamma coefficient. The function
 * applied for gamma correction is dst = (pow((src / 255.0), (1/g)) * 255.0)
 * The function will list the results to the console
 *
 * @param g is a floating point variable which represents the gamma factor
 * 		which will be applied
 *
 * @return None
 *
 * @note
 *
*****************************************************************************/
void gamma_val(float g)
{
	unsigned char lut[256];

	printf("%f = {",g);
	for (int i = 0; i < 256; i++)
	{
		lut[i] = cv::saturate_cast<uchar>(pow((float)(i / 255.0), (1/g)) * 255.0f);
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

	//define the input and output matrix
	cv::Mat src = cv::imread(INPUT_IMAGE);
	cv::Mat dst = src;

	//define the stream variables
	stream_t stream_in, stream_out;

	//perform the stream conversion and saturation operations
	cvMat2AXIvideo(src, stream_in);
	hls_gamma_correction(stream_in, stream_out, 5, rows, cols);
	AXIvideo2cvMat(stream_out, dst);

	//dump the matrix in to the destination image
	cv::imwrite(OUTPUT_IMAGE,dst);

	//functions used to create the LUTs
//	gamma_val(0.4);
//	gamma_val(0.2);
//	gamma_val(1.2);
//	gamma_val(1.4);
//	gamma_val(1.6);
//	gamma_val(1.8);
//	gamma_val(2.0);
//	gamma_val(2.2);
	return 0;
}
