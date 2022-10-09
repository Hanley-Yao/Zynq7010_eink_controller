#include "video_scaler.h"

typedef hls::Mat<max_height, max_width, HLS_8UC3> rgb24_img_t;

void video_scaler(stream_t& stream_in, stream_t& stream_out, hls::Size in, hls::Size out)
{
#pragma HLS INTERFACE s_axilite register port=return bundle=ctrl name=s_axi_ctrl
#pragma HLS DATAFLOW
#pragma HLS INTERFACE s_axilite register port=in bundle=ctrl
#pragma HLS INTERFACE s_axilite register port=out bundle=ctrl
#pragma HLS INTERFACE axis register both port=stream_out
#pragma HLS INTERFACE axis register both port=stream_in
	rgb24_img_t img_in(in);
	rgb24_img_t img_out(out);
	hls::AXIvideo2Mat(stream_in, img_in);
	hls::Resize(img_in, img_out, HLS_INTER_LINEAR);
	hls::Mat2AXIvideo(img_out, stream_out);
}
