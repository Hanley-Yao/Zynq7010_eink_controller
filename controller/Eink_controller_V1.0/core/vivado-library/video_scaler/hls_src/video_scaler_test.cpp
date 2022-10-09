#include "video_scaler.h"

#include <string>

#include "hls_video.h"
#include "hls_opencv.h"

char const* test_file_in = "fox.bmp";
int const ERROR_THRESHOLD = 0; // acceptable error threshold range 0 to 255

int main(void)
{
	cv::Size const out_sizes[] = {
			{10, 10},
			{4096, 4096},
			{640, 480},
			{1080, 1920},
	};

	// Read in test image
	cv::Mat img_in = cv::imread(test_file_in, CV_LOAD_IMAGE_COLOR);

	for (int i=0; i < sizeof(out_sizes)/sizeof(out_sizes[0]); ++i)
	{
		// input and output test size pairs

		// output image matrices
		cv::Mat sw_result(out_sizes[i], img_in.type());
		cv::Mat hw_result(out_sizes[i], img_in.type());

		//DUT
		stream_t stream_in, stream_out;
		cvMat2AXIvideo(img_in, stream_in);
		video_scaler(stream_in, stream_out, hls::Size(img_in.size().width, img_in.size().height), hls::Size(out_sizes[i].width, out_sizes[i].height));
		AXIvideo2cvMat(stream_out, hw_result);

		// Software reference
		cv::resize(img_in, sw_result, out_sizes[i], 0, 0, cv::INTER_LINEAR);

		// Compare the two
		cv::Mat diff;
		cv::absdiff(sw_result, hw_result, diff);
		double minval=256,maxval=0;
		int cnt = 0;
		for (int i = 0; i < sw_result.rows; i++)
		{
			for(int j = 0; j < sw_result.cols; j++)
			{
				cv::Vec3b v = diff.at<cv::Vec3b>(i,j);
				for (int c=0; c < 3; ++c)
				{
					if (minval > v[c] )
						minval = v[c];
					if (maxval < v[c])
						maxval = v[c];
					if (v[c]>ERROR_THRESHOLD)
					{
						cnt++;
						v[c] = 255;
					}
				}

				diff.at<cv::Vec3b>(i,j) = v;
			}
		}
		std::ostringstream s;
		s << "error" << i << ".bmp";
		cv::imwrite(s.str(), diff); // Save the difference image for debugging purpose
		s.str(""); s.clear();
		s << "sw_result" << i << ".bmp";
		cv::imwrite(s.str(), sw_result); // Save the difference image for debugging purpose
		s.str(""); s.clear();
		s << "hw_result" << i << ".bmp";
		cv::imwrite(s.str(), hw_result); // Save the difference image for debugging purpose

		float err_per = 100.0*(float)cnt/(sw_result.rows * sw_result.cols * 3);
		std::cout << "Minimum error in intensity = " << minval << std::endl;
		std::cout << "Maximum error in intensity = " << maxval << std::endl;
		std::cout << "Percentage of pixels above error threshold = " << err_per  << " Count: " << cnt << std::endl;
		if(maxval > 1)
		{
			return 1;
		}
	}
	return 0;
}
