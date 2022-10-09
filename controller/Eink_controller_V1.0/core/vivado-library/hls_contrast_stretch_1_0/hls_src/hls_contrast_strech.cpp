//-------------------------------------------------------------------------------
//--
//-- File: hls_saturation_enhanche.cpp
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
//-- Purpose:
//-- This core has been written in order to perform a contrast stretch
//-- on a input image stream (RGB 24 bits, 8 bits/color) and output it to a stream
//-- (RGB 24 bits, 8 bits/color). The stretching is done by remapping the pixels of
//-- histogram so that the min threshold is set to 0 and the max threshold is set to
//-- 255. The remapping is done by applying the formula
//-- dst.cont = ((src.cont-min)*255)/(max-min).
//--
//-------------------------------------------------------------------------------


/***************************** Include Files ********************************/
#include "hls_contrast_strech.h"

/****************************************************************************/
/**
 * Applies the remapping of the contrast on a input matrix HLS_8UC3 based on
 * the threshold min and max. Remapping is done in real time based on a simple
 * remapping formula
 *
 * @param src is the input matrix on 3 channels with each component on 8 bits
 * @param dst is the output matrix on 3 channels with each component on 8 bits
 * @param min the low threshold which will be set to 0
 * @param max the high threshold which will be set to 255
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version
 *
*****************************************************************************/
void contrast_stretch(rgb_img_t &src, rgb_img_t &dst, unsigned char min, unsigned char max)
{
#pragma HLS INLINE

	HLS_SIZE_T rows = dst.rows;
	HLS_SIZE_T cols = dst.cols;

	hls::Scalar<HLS_MAT_CN(HLS_8UC3), HLS_TNAME(HLS_8UC3)> s;
	hls::Scalar<HLS_MAT_CN(HLS_8UC3), HLS_TNAME(HLS_8UC3)> d;

	//loop trough the matrix
	loop_height: for (HLS_SIZE_T i = 0; i < rows; i++) {
	   loop_width: for (HLS_SIZE_T j = 0; j < cols; j++) {
	#pragma HLS loop_flatten off
	#pragma HLS pipeline II=1
		   //dumping the input stream pixel in to a single
		   //24 bit variable (8 bits with 3 values)
			src >> s;
			if(s.val[0] > max)
			{
				//set everything grater then max to 255
				d.val[0] = 255;
			}
			else
			{
				if(s.val[0] < min)
				{
					//set everything less then min to 0
					d.val[0] = 0;
				}
				else
				{
					//remapping the rest of the values
					d.val[0] = (unsigned char)(((s.val[0]-min)*255)/(max-min));
				}
			}
			//assuming that the format is yCbCr
			//leave Cb and Cr unchanged
			d.val[1] = s.val[1];
			d.val[2] = s.val[2];
			//dump the pixel in to the destination matrix
			dst << d;
	       }
	   }

}

/****************************************************************************/
/**
 * This is the main function of the core, this function will be synthesized
 * and packaged as an IP core. Its main purpose is to define the IP ports
 * and busses while converting the RGB image in to HLS and calling the contrast_strech
 * function.
 *
 * @param stream_in is the input Axi-Stream for video format
 * @param stream_out is the output Axi-Stream for video format
 * @param height parameter defines the height of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 * @param width parameter defines the width of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 * @param min sets the low threshold for the contrast stretch in absolute terms. This
 * 		parameter can be edited using the Axi-Light interface
 * @param max sets the high threshold for the contrast stretch in absolute terms. This
 * 		parameter can be edited using the Axi-Light interface
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version.
 *
*****************************************************************************/
void hls_contrast_stretch(stream_t &stream_in, stream_t &stream_out, u_int16_t height, u_int16_t width, unsigned char min, unsigned char max)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS DATAFLOW
#pragma HLS INTERFACE s_axilite port=max
#pragma HLS INTERFACE s_axilite port=width
#pragma HLS INTERFACE s_axilite port=height
#pragma HLS INTERFACE s_axilite port=min
#pragma HLS INTERFACE axis register both port=stream_in
#pragma HLS INTERFACE axis register both port=stream_out

	u_int16_t rows = height;
	u_int16_t cols = width;


	rgb_img_t img0(rows, cols);
	rgb_img_t img1(rows, cols);
	rgb_img_t img2(rows, cols);
	rgb_img_t img3(rows, cols);

	float scale, offset;

	//transforms stream to matrix
	hls::AXIvideo2Mat(stream_in, img0);
	//convert RGB to YCbCr
	hls::CvtColor<HLS_RGB2YCrCb>(img0,img1);
	//perform contrast stretch
	contrast_stretch(img1, img2, min, max);
	//convert YCbCr to RGB
	hls::CvtColor<HLS_YCrCb2RGB>(img2,img3);
	//transform resulting matrix to output stream
	hls::Mat2AXIvideo(img3, stream_out);

}
