#include "hls_video.h"

typedef ap_axiu<24,1,1,1> interface_t;
typedef hls::stream<interface_t> stream_t;

typedef struct {
	hls::Size input_size;
	hls::Size output_size;
} param_t;

int const max_height = 4096;
int const max_width = 4096;

void video_scaler(stream_t& stream_in, stream_t& stream_out, hls::Size in, hls::Size out);
