//-------------------------------------------------------------------------------
//--
//-- File: hls_gamma_correction.cpp
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
//-- Purpose:
//-- This core has been written in order to perform a gamma correction
//-- on a input image stream (RGB 24 bits, 8 bits/color) and output it to a stream
//-- (RGB 24 bits, 8 bits/color). The correction is done by applying the formula
//-- dst = (pow((src / 255.0), (1/g)) * 255.0) on each RGB component independently.
//-- In order to reduce the resource consumption of the IP the actual transformation
//-- has been implemented using lookup tables with predefined coefficients.
//-- If new LUTs have to be implemented please refer to the hls_gamma_correction_test.cpp
//-- test bench which contains the elaborated formula of the gamma correction
//-- algorithm
//--
//-------------------------------------------------------------------------------


/***************************** Include Files ********************************/

#include "hls_gamma_correction.h"

/************************** Constant Definitions ****************************/

unsigned char lut0_4[256] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,9,9,9,10,10,10,11,11,12,12,12,13,13,14,14,15,15,15,16,16,17,17,18,18,19,19,20,20,21,22,22,23,23,24,25,25,26,26,27,28,28,29,30,30,31,32,33,33,34,35,36,36,37,38,39,40,40,41,42,43,44,45,46,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,67,68,69,70,71,72,73,75,76,77,78,80,81,82,83,85,86,87,89,90,91,93,94,95,97,98,99,101,102,104,105,107,108,110,111,113,114,116,117,119,121,122,124,125,127,129,130,132,134,135,137,139,141,142,144,146,148,150,151,153,155,157,159,161,163,165,166,168,170,172,174,176,178,180,182,184,186,189,191,193,195,197,199,201,204,206,208,210,212,215,217,219,221,224,226,228,231,233,235,238,240,243,245,248,250,253,255};
unsigned char lut0_2[256] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,8,8,9,9,9,10,10,11,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,19,19,20,20,21,22,23,23,24,25,26,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,45,46,47,49,50,51,53,54,56,57,59,60,62,63,65,67,68,70,72,74,76,78,80,82,84,86,88,90,92,94,97,99,101,104,106,109,111,114,116,119,122,125,128,130,133,136,139,143,146,149,152,156,159,162,166,170,173,177,181,184,188,192,196,200,205,209,213,217,222,226,231,236,240,245,250,255};
unsigned char lut1_2[256] = {0,3,4,6,8,10,11,13,14,16,17,19,20,21,23,24,25,27,28,29,31,32,33,34,36,37,38,39,40,42,43,44,45,46,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,65,66,67,68,69,70,71,72,73,74,75,76,77,78,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,145,146,147,148,149,150,151,152,153,154,155,156,157,157,158,159,160,161,162,163,164,165,166,167,168,168,169,170,171,172,173,174,175,176,177,177,178,179,180,181,182,183,184,185,185,186,187,188,189,190,191,192,193,193,194,195,196,197,198,199,200,200,201,202,203,204,205,206,207,207,208,209,210,211,212,213,213,214,215,216,217,218,219,219,220,221,222,223,224,225,225,226,227,228,229,230,231,231,232,233,234,235,236,237,237,238,239,240,241,242,242,243,244,245,246,247,247,248,249,250,251,252,252,253,254,255};
unsigned char lut1_4[256] = {0,5,8,11,13,15,18,20,22,23,25,27,29,30,32,34,35,37,38,40,41,43,44,46,47,49,50,51,53,54,55,57,58,59,60,62,63,64,65,67,68,69,70,72,73,74,75,76,77,78,80,81,82,83,84,85,86,87,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,133,134,135,136,137,138,139,140,141,142,143,143,144,145,146,147,148,149,150,151,151,152,153,154,155,156,157,158,158,159,160,161,162,163,164,164,165,166,167,168,169,170,170,171,172,173,174,175,175,176,177,178,179,180,180,181,182,183,184,184,185,186,187,188,188,189,190,191,192,192,193,194,195,196,196,197,198,199,200,200,201,202,203,204,204,205,206,207,207,208,209,210,211,211,212,213,214,214,215,216,217,217,218,219,220,220,221,222,223,223,224,225,226,226,227,228,229,229,230,231,232,232,233,234,235,235,236,237,238,238,239,240,241,241,242,243,243,244,245,246,246,247,248,249,249,250,251,251,252,253,254,254,255};
unsigned char lut1_6[256] = {0,8,12,16,19,22,24,27,29,32,34,36,38,40,42,43,45,47,49,50,52,54,55,57,58,60,61,63,64,66,67,68,70,71,72,74,75,76,78,79,80,81,83,84,85,86,87,89,90,91,92,93,94,96,97,98,99,100,101,102,103,104,105,106,107,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,125,126,127,128,129,130,131,132,133,134,135,136,137,138,138,139,140,141,142,143,144,145,146,146,147,148,149,150,151,152,152,153,154,155,156,157,158,158,159,160,161,162,162,163,164,165,166,167,167,168,169,170,171,171,172,173,174,175,175,176,177,178,178,179,180,181,181,182,183,184,185,185,186,187,188,188,189,190,191,191,192,193,194,194,195,196,196,197,198,199,199,200,201,202,202,203,204,204,205,206,207,207,208,209,209,210,211,211,212,213,214,214,215,216,216,217,218,218,219,220,220,221,222,222,223,224,225,225,226,227,227,228,229,229,230,231,231,232,233,233,234,235,235,236,236,237,238,238,239,240,240,241,242,242,243,244,244,245,246,246,247,247,248,249,249,250,251,251,252,252,253,254,254,255};
unsigned char lut1_8[256] = {0,12,17,22,25,29,32,35,37,40,42,44,47,49,51,53,55,57,58,60,62,64,65,67,69,70,72,73,75,76,78,79,80,82,83,85,86,87,89,90,91,92,94,95,96,97,98,100,101,102,103,104,105,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,139,140,141,142,143,144,145,146,146,147,148,149,150,151,152,152,153,154,155,156,157,157,158,159,160,161,161,162,163,164,165,165,166,167,168,169,169,170,171,172,172,173,174,175,175,176,177,178,178,179,180,181,181,182,183,183,184,185,186,186,187,188,188,189,190,191,191,192,193,193,194,195,195,196,197,198,198,199,200,200,201,202,202,203,204,204,205,206,206,207,208,208,209,209,210,211,211,212,213,213,214,215,215,216,217,217,218,218,219,220,220,221,222,222,223,223,224,225,225,226,226,227,228,228,229,230,230,231,231,232,233,233,234,234,235,236,236,237,237,238,238,239,240,240,241,241,242,243,243,244,244,245,245,246,247,247,248,248,249,249,250,251,251,252,252,253,253,254,254,255};
unsigned char lut2_0[256] = {0,16,23,28,32,36,39,42,45,48,50,53,55,58,60,62,64,66,68,70,71,73,75,77,78,80,81,83,84,86,87,89,90,92,93,94,96,97,98,100,101,102,103,105,106,107,108,109,111,112,113,114,115,116,117,118,119,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,135,136,137,138,139,140,141,142,143,144,145,145,146,147,148,149,150,151,151,152,153,154,155,156,156,157,158,159,160,160,161,162,163,164,164,165,166,167,167,168,169,170,170,171,172,173,173,174,175,176,176,177,178,179,179,180,181,181,182,183,183,184,185,186,186,187,188,188,189,190,190,191,192,192,193,194,194,195,196,196,197,198,198,199,199,200,201,201,202,203,203,204,204,205,206,206,207,208,208,209,209,210,211,211,212,212,213,214,214,215,215,216,217,217,218,218,219,220,220,221,221,222,222,223,224,224,225,225,226,226,227,228,228,229,229,230,230,231,231,232,233,233,234,234,235,235,236,236,237,237,238,238,239,240,240,241,241,242,242,243,243,244,244,245,245,246,246,247,247,248,248,249,249,250,250,251,251,252,252,253,253,254,254,255};
unsigned char lut2_2[256] = {0,21,28,34,39,43,46,50,53,56,59,61,64,66,68,70,72,74,76,78,80,82,84,85,87,89,90,92,93,95,96,98,99,101,102,103,105,106,107,109,110,111,112,114,115,116,117,118,119,120,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,144,145,146,147,148,149,150,151,151,152,153,154,155,156,156,157,158,159,160,160,161,162,163,164,164,165,166,167,167,168,169,170,170,171,172,173,173,174,175,175,176,177,178,178,179,180,180,181,182,182,183,184,184,185,186,186,187,188,188,189,190,190,191,192,192,193,194,194,195,195,196,197,197,198,199,199,200,200,201,202,202,203,203,204,205,205,206,206,207,207,208,209,209,210,210,211,212,212,213,213,214,214,215,215,216,217,217,218,218,219,219,220,220,221,221,222,223,223,224,224,225,225,226,226,227,227,228,228,229,229,230,230,231,231,232,232,233,233,234,234,235,235,236,236,237,237,238,238,239,239,240,240,241,241,242,242,243,243,244,244,245,245,246,246,247,247,248,248,249,249,249,250,250,251,251,252,252,253,253,254,254,255,255};

/****************************************************************************/
/**
 * Applies the gamma correction coefficients to the input matrix HLS_8UC3,
 * form the desired LUT. the selection is done using sat variable as a simple
 * switch between LUTs
 *
 * @param src is the input matrix on 3 channels with each color on 8 bits
 * @param dst is the output matrix on 3 channels with each color on 8 bits
 * @param g is a 8 bit parameter which selects between gamma factors
 * 		which should be applied.
 * 		sat == 0 =>  dst.sat = src.sat
 * 		sat == 1 =>  dst = (pow((src / 255.0), (1/0.4)) * 255.0)
 * 		sat == 2 =>  dst = (pow((src / 255.0), (1/0.2)) * 255.0)
 * 		sat == 3 =>  dst = (pow((src / 255.0), (1/1.2)) * 255.0)
 * 		sat == 4 =>  dst = (pow((src / 255.0), (1/1.4)) * 255.0)
 * 		sat == 5 =>  dst = (pow((src / 255.0), (1/1.6)) * 255.0)
 * 		sat == 6 =>  dst = (pow((src / 255.0), (1/1.8)) * 255.0)
 * 		sat == 7 =>  dst = (pow((src / 255.0), (1/2.0)) * 255.0)
 * 		sat == 8 =>  dst = (pow((src / 255.0), (1/2.2)) * 255.0)
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version
 *
*****************************************************************************/
void gamma_c(rgb_img_t &src, rgb_img_t &dst, unsigned char g)
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
			   //loop trough the channels and apply the gamma coefficients
			   loop_channels: for (HLS_CHANNEL_T k = 0; k < HLS_MAT_CN(HLS_8UC3); k++) {
				switch(g)
				{
					case 0:
						d.val[k] = s.val[k];
						break;
					case 1:
						d.val[k] = lut0_4[s.val[k]];
						break;
					case 2:
						d.val[k] = lut0_2[s.val[k]];
						break;
					case 3:
						d.val[k] = lut1_2[s.val[k]];
						break;
					case 4:
						d.val[k] = lut1_4[s.val[k]];
						break;
					case 5:
						d.val[k] = lut1_6[s.val[k]];
						break;
					case 6:
						d.val[k] = lut1_8[s.val[k]];
						break;
					case 7:
						d.val[k] = lut2_0[s.val[k]];
						break;
					case 8:
						d.val[k] = lut2_2[s.val[k]];
						break;
					default:
						d.val[k] = s.val[k];
						break;
				}
			   }
			   //dump the pixel in to the destination matrix
			   dst << d;
	       }
	   }

}

/****************************************************************************/
/**
 * This is the main function of the core, this function will be synthesized
 * and packaged as an IP core. Its main purpose is to define the IP ports
 * and busses while applying the gamma correction factor on the image
 *
 * @param stream_in is the input Axi-Stream for video format
 * @param stream_out is the output Axi-Stream for video format
 * @param gamma selects which gamma factor will be applied to the image based on the
 * 		predefined LUTs which are available. This parameter can be edited using the
 * 		Axi-Light interface.
 * @param height parameter defines the height of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 * @param width parameter defines the width of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version.
 *
*****************************************************************************/
void hls_gamma_correction(stream_t &stream_in, stream_t &stream_out, unsigned char gamma, u_int16_t height, u_int16_t width)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS DATAFLOW
#pragma HLS INTERFACE s_axilite port=width
#pragma HLS INTERFACE s_axilite port=height
#pragma HLS INTERFACE s_axilite port=gamma
#pragma HLS INTERFACE axis register both port=stream_in
#pragma HLS INTERFACE axis register both port=stream_out

	u_int16_t rows = height;
	u_int16_t cols = width;

	rgb_img_t img0(rows, cols);
	rgb_img_t img3(rows, cols);

	//transforms stream to matrix
	hls::AXIvideo2Mat(stream_in, img0);
	//apply gamma correction
	gamma_c(img0, img3, gamma);
	//transform resulting matrix to output stream
	hls::Mat2AXIvideo(img3, stream_out);

}
