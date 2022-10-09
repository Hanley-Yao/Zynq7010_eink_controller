//-------------------------------------------------------------------------------
//--
//-- File: hls_contrast_strech_test.cpp
//-- Author: Ciprian Hegbeli
//-- Date: 20 June 2018
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
//-- Purpose: File used to test the contrast enhancement algorithm
//--
//-------------------------------------------------------------------------------

/***************************** Include Files ********************************/

#include "hls_contrast_strech.h"
#include "hls_opencv.h"

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

	//perform the stream conversion and contrast operations
	cvMat2AXIvideo(src, stream_in);
	hls_contrast_stretch(stream_in, stream_out, rows, cols, 15, 230);
	AXIvideo2cvMat(stream_out, dst);

	//dump the matrix in to the destination image
	cv::imwrite(OUTPUT_IMAGE,dst);

	return 0;
}
