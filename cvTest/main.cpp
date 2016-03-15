#include <iostream>
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <sstream>
#include <string>

using namespace cv;
using namespace std;

int main()
{
    VideoCapture stream1(0);

    while (true) {
        Mat cameraFrame;
        stream1.read(cameraFrame);
        namedWindow( "Original image");

        Mat gray, edge, draw, detect;

        cvtColor(cameraFrame, gray, CV_BGR2GRAY);
        blur(gray, detect, Size(3,3));
        imshow( "Original image", detect);

        Canny( detect, gray, 0, 100, 3);

        vector<vector<Point> > contours;
        vector<Vec4i> hierarchy;
        RNG rng(1);
        findContours( gray, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE, Point(0, 0) );
        /// Draw contours
        Mat drawing = Mat::zeros( gray.size(), CV_8UC3 );
        for( int i = 0; i< contours.size(); i++ )
        {
            Scalar color = Scalar(255, 255, 255);
            drawContours( drawing, contours, i, color, 5, 8, hierarchy, 0, Point() );
        }

        imshow( "Result window", drawing);

        //edge.convertTo(draw, CV_8U);
        //namedWindow("image", CV_WINDOW_AUTOSIZE);
        //imshow( "Canny", draw);

        if (waitKey(30) >= 0)
            break;
    }

    return 0;
}




