//-------------------------------------------------------------------------------
//--
//-- File: hls_contrast_strech.h
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
//-- Purpose: header file for the contrast enhancement function file
//--
//-------------------------------------------------------------------------------

#ifndef HLS_CONTRAST_STRETCH_H_
#define HLS_CONTRAST_STRETCH_H_

/***************************** Include Files ********************************/

#include "hls_video.h"
/************************** Constant Definitions ****************************/

#define MAX_WIDTH 	1920
#define MAX_HEIGHT  1080

#define INPUT_IMAGE "rover.bmp"
#define OUTPUT_IMAGE "rover_out.bmp"

/**************************** Type Definitions ******************************/

typedef ap_axiu<24,1,1,1> interface_t;
typedef ap_uint<3> interface_3_bits;
typedef hls::stream<interface_t> stream_t;

typedef hls::Mat<MAX_HEIGHT, MAX_WIDTH, HLS_8UC3> rgb_img_t;
typedef hls::Mat<MAX_HEIGHT, MAX_WIDTH, HLS_8UC1> single_img_t;
typedef hls::Scalar<3, unsigned char> rgb_pix_t;

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

void hls_contrast_stretch(stream_t &stream_in, stream_t &stream_out, u_int16_t height, u_int16_t width, unsigned char min, unsigned char max);

#endif
