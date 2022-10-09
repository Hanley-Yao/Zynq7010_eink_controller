//-------------------------------------------------------------------------------
//--
//-- File: hls_saturation_enhanche.cpp
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
//-- Purpose:
//-- This core has been written in order to perform a saturation enhancement
//-- on a input image stream (RGB 24 bits, 8 bits/color) and output it to a stream
//-- (RGB 24 bits, 8 bits/color). The enhancement is done by applying the formula
//-- dst.sat = src.sat + src.sat*fact and a non-linear adaptation for over saturation.
//-- In order to reduce the resource consumption of the IP the actual transformation
//-- has been implemented using lookup tables with predefined coefficients.
//-- If new LUTs have to be implemented please refer to the hls_saturation_enhanche_test.cpp
//-- test bench which contains the elaborated formula of the saturation enhancement
//-- algorithm
//--
//-------------------------------------------------------------------------------


/***************************** Include Files ********************************/
#include "hls_saturation_enhanche.h"


/************************** Constant Definitions ****************************/
const unsigned char lut_s_n0_2[256] = {0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12,13,14,14,15,16,17,18,18,19,20,21,22,22,23,24,25,26,26,27,28,29,30,30,31,32,33,34,34,35,36,37,38,38,39,40,41,42,42,43,44,45,46,46,47,48,49,50,50,51,52,53,54,54,55,56,57,58,58,59,60,61,62,62,63,64,65,66,66,67,68,69,70,70,71,72,73,74,74,75,76,77,78,78,79,80,81,82,82,83,84,85,86,86,87,88,89,90,90,91,92,93,94,94,95,96,97,98,98,99,100,101,102,102,103,104,105,106,106,107,108,109,110,110,111,112,113,114,114,115,116,117,118,118,119,120,121,122,122,123,124,125,126,126,127,128,129,130,130,131,132,133,134,134,135,136,137,138,138,139,140,141,142,142,143,144,145,146,146,147,148,149,150,150,151,152,153,154,154,155,156,157,158,158,159,160,161,162,162,163,164,165,166,166,167,168,169,170,170,171,172,173,174,174,175,176,177,178,178,179,180,181,182,182,183,184,185,186,186,187,188,189,190,190,191,192,193,194,194,195,196,197,198,198,199,200,201,202,202,203,204};
const unsigned char lut_s_0_2[256]  = {0,1,2,4,5,6,7,8,10,11,12,13,14,15,17,18,19,20,21,23,24,25,26,27,28,30,31,32,33,34,35,36,38,39,40,41,42,43,44,46,47,48,49,50,51,52,54,55,56,57,58,59,60,61,63,64,65,66,67,68,69,70,71,72,74,75,76,77,78,79,80,81,82,83,85,86,87,88,89,90,91,92,93,94,95,96,97,98,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,179,180,181,182,183,184,185,186,187,188,189,190,191,192,192,193,194,195,196,197,198,199,200,201,201,202,203,204,205,206,207,208,209,210,210,211,212,213,214,215,216,217,217,218,219,220,221,222,223,223,224,225,226,227,228,229,229,230,231,232,233,234,235,235,236,237,238,239,240,240,241,242,243,244,244,245,246,247,248,249,249,250,251,252,253,253,254,255};
const unsigned char lut_s_0_4[256]  = {0,1,3,4,6,7,8,10,11,12,14,15,17,18,19,21,22,23,25,26,27,29,30,31,33,34,35,37,38,39,41,42,43,44,46,47,48,50,51,52,53,55,56,57,59,60,61,62,64,65,66,67,69,70,71,72,73,75,76,77,78,80,81,82,83,84,86,87,88,89,90,91,93,94,95,96,97,98,100,101,102,103,104,105,107,108,109,110,111,112,113,114,116,117,118,119,120,121,122,123,124,125,126,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,177,178,179,180,181,182,183,184,185,186,187,187,188,189,190,191,192,193,194,194,195,196,197,198,199,199,200,201,202,203,204,204,205,206,207,208,209,209,210,211,212,213,213,214,215,216,216,217,218,219,220,220,221,222,223,223,224,225,226,226,227,228,228,229,230,231,231,232,233,233,234,235,236,236,237,238,238,239,240,240,241,242,242,243,244,244,245,246,246,247,248,248,249,249,250,251,251,252,253,253,254,254,255};
const unsigned char lut_s_0_6[256]  = {0,2,3,5,6,8,10,11,13,14,16,17,19,20,22,23,25,27,28,30,31,33,34,36,37,39,40,41,43,44,46,47,49,50,52,53,55,56,57,59,60,62,63,64,66,67,69,70,71,73,74,75,77,78,80,81,82,84,85,86,88,89,90,91,93,94,95,97,98,99,100,102,103,104,106,107,108,109,110,112,113,114,115,117,118,119,120,121,123,124,125,126,127,128,130,131,132,133,134,135,136,138,139,140,141,142,143,144,145,146,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,183,184,185,186,187,188,189,190,191,191,192,193,194,195,196,197,197,198,199,200,201,202,202,203,204,205,206,206,207,208,209,209,210,211,212,213,213,214,215,215,216,217,218,218,219,220,220,221,222,223,223,224,225,225,226,227,227,228,228,229,230,230,231,232,232,233,233,234,235,235,236,236,237,238,238,239,239,240,240,241,241,242,242,243,244,244,245,245,246,246,247,247,248,248,248,249,249,250,250,251,251,252,252,253,253,253,254,254,255,255};
const unsigned char lut_s_0_8[256]  = {0,2,4,5,7,9,11,12,14,16,18,19,21,23,25,26,28,30,31,33,35,36,38,40,41,43,45,46,48,50,51,53,54,56,58,59,61,62,64,65,67,69,70,72,73,75,76,78,79,81,82,84,85,87,88,90,91,92,94,95,97,98,100,101,102,104,105,107,108,109,111,112,113,115,116,117,119,120,121,123,124,125,127,128,129,130,132,133,134,135,137,138,139,140,141,143,144,145,146,147,149,150,151,152,153,154,156,157,158,159,160,161,162,163,164,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,191,192,193,194,195,196,197,198,199,199,200,201,202,203,204,204,205,206,207,208,208,209,210,211,212,212,213,214,215,215,216,217,218,218,219,220,220,221,222,222,223,224,224,225,226,226,227,228,228,229,229,230,231,231,232,232,233,233,234,235,235,236,236,237,237,238,238,239,239,240,240,241,241,242,242,242,243,243,244,244,245,245,245,246,246,247,247,247,248,248,248,249,249,249,250,250,250,251,251,251,252,252,252,252,253,253,253,253,254,254,254,254,255,255,255};
const unsigned char lut_s_1_0[256]  = {0,2,4,6,8,10,12,14,16,18,20,22,23,25,27,29,31,33,35,37,38,40,42,44,46,48,49,51,53,55,56,58,60,62,63,65,67,69,70,72,74,75,77,79,80,82,84,85,87,89,90,92,93,95,97,98,100,101,103,104,106,107,109,110,112,113,115,116,118,119,121,122,124,125,127,128,129,131,132,134,135,136,138,139,140,142,143,144,146,147,148,150,151,152,153,155,156,157,158,160,161,162,163,164,166,167,168,169,170,171,173,174,175,176,177,178,179,180,181,182,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,199,200,201,202,203,204,205,206,207,208,208,209,210,211,212,213,213,214,215,216,217,217,218,219,220,220,221,222,223,223,224,225,225,226,227,227,228,229,229,230,231,231,232,232,233,234,234,235,235,236,236,237,237,238,238,239,239,240,240,241,241,242,242,243,243,244,244,244,245,245,246,246,246,247,247,247,248,248,248,249,249,249,250,250,250,250,251,251,251,251,252,252,252,252,253,253,253,253,253,253,254,254,254,254,254,254,254,254,255,255,255,255,255,255,255,255,255,255,255,255};
const unsigned char lut_s_1_2[256]  = {0,2,4,7,9,11,13,15,17,19,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,67,69,71,73,75,77,79,80,82,84,86,88,89,91,93,95,97,98,100,102,103,105,107,108,110,112,113,115,117,118,120,122,123,125,126,128,129,131,132,134,136,137,139,140,141,143,144,146,147,149,150,152,153,154,156,157,159,160,161,163,164,165,167,168,169,170,172,173,174,175,177,178,179,180,182,183,184,185,186,187,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,218,219,220,221,222,223,223,224,225,226,226,227,228,229,229,230,231,232,232,233,234,234,235,236,236,237,237,238,239,239,240,240,241,241,242,242,243,244,244,245,245,245,246,246,247,247,248,248,249,249,249,250,250,250,251,251,251,252,252,252,253,253,253,254,254,254,254,254,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};

/****************************************************************************/
/**
 * Applies the saturation enhanced coefficients to the input matrix HLS_8UC3,
 * form the desired LUT. the selection is done using sat variable as a simple
 * switch between LUTs
 *
 * @param src is the input matrix on 3 channels with each color on 8 bits
 * @param dst is the output matrix on 3 channels with each color on 8 bits
 * @param sat is a 8 bit parameter which selects between saturation factors
 * 		which should be applied.
 * 		sat == 0 =>  dst.sat = src.sat
 * 		sat == 1 =>  dst.sat = src.sat - 0.2*src.sat
 * 		sat == 2 =>  dst.sat = src.sat + 0.2*src.sat
 * 		sat == 3 =>  dst.sat = src.sat + 0.4*src.sat
 * 		sat == 4 =>  dst.sat = src.sat + 0.6*src.sat
 * 		sat == 5 =>  dst.sat = src.sat + 0.8*src.sat
 * 		sat == 6 =>  dst.sat = src.sat + 1.0*src.sat
 * 		sat == 7 =>  dst.sat = src.sat + 1.2*src.sat
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version
 *
*****************************************************************************/
void sat_e(rgb_img_t &src, rgb_img_t &dst, unsigned char sat)
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
			//assuming that the format is HLS(hue lightness saturation)
			//leave hue and lightness unchanged
			d.val[0] = s.val[0];
			d.val[1] = s.val[1];
			//based on the sat value implement the desired saturation
			//coefficient
			switch(sat)
			{
				case 0:
					d.val[2] = s.val[2];
					break;
				case 1:
					d.val[2] = lut_s_n0_2[s.val[2]];
					break;
				case 2:
					d.val[2] = lut_s_0_2[s.val[2]];
					break;
				case 3:
					d.val[2] = lut_s_0_4[s.val[2]];
					break;
				case 4:
					d.val[2] = lut_s_0_6[s.val[2]];
					break;
				case 5:
					d.val[2] = lut_s_0_8[s.val[2]];
					break;
				case 6:
					d.val[2] = lut_s_1_0[s.val[2]];
					break;
				case 7:
					d.val[2] = lut_s_1_2[s.val[2]];
					break;
				default:
					d.val[2] = s.val[2];
					break;
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
 * and busses while converting the RGB image in to HLS and calling the sat_e
 * function.
 *
 * @param stream_in is the input Axi-Stream for video format
 * @param stream_out is the output Axi-Stream for video format
 * @param height parameter defines the height of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 * @param width parameter defines the width of the input image. This parameter can
 * 		be edited using the Axi-Light interface.
 * @param sat slects which saturation factor will be applied to the image based on the
 * 		predefined LUTs which are available. This parameter can be edited using the
 * 		Axi-Light interface.
 *
 * @return None
 *
 * @note The pragmas are part of the HLS optimization flow and should be
 * 		researched before using them in other functions. Please refer to
 * 		UG902 of your current Vivado version.
 *
*****************************************************************************/
void hls_saturation_enhance(stream_t &stream_in, stream_t &stream_out, u_int16_t height, u_int16_t width, unsigned char sat)
{
#pragma HLS INTERFACE ap_ctrl_none port=return //disables the ctrl interface
#pragma HLS DATAFLOW
#pragma HLS INTERFACE s_axilite port=sat
#pragma HLS INTERFACE s_axilite port=width
#pragma HLS INTERFACE s_axilite port=height
#pragma HLS INTERFACE axis register both port=stream_out
#pragma HLS INTERFACE axis register both port=stream_in

	u_int16_t rows = height;
	u_int16_t cols = width;

	rgb_img_t img0(rows, cols);
	rgb_img_t img1(rows, cols);
	rgb_img_t img2(rows, cols);
	rgb_img_t img3(rows, cols);

	//transforms stream to matrix
	hls::AXIvideo2Mat(stream_in, img0);
	//converts rgb to hls
	hls::CvtColor<HLS_RGB2HLS>(img0,img1);
	//apply saturation enhancement
	sat_e(img1, img2, sat);
	//convert hls to rgb
	hls::CvtColor<HLS_HLS2RGB>(img2,img3);
	//transform resulting matrix to output stream
	hls::Mat2AXIvideo(img3, stream_out);

}
