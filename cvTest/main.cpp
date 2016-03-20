#include <iostream>
#include "opencv2/core/core.hpp"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <sstream>
#include <string>
#include <opencv2/features2d/features2d.hpp>


using namespace cv;
using namespace std;
int cutWhite = 100;
int cutBlack = 200;
RNG rng(12345);


int main()
{
    VideoCapture stream1(0);

    while (true) {
        Mat cameraFrame, gray,
            threshWhite, threshBlack, \
            blurWhite, blurBlack, \
            cannyWhite, cannyBlack;

        // read webcam
        stream1.read(cameraFrame);
        namedWindow( "Original");
        imshow( "Original", cameraFrame);

        cvtColor(cameraFrame, gray, CV_BGR2GRAY);

        threshold( gray, threshBlack, 100, 255 , THRESH_BINARY);
        threshold( gray, threshWhite, 170, 255 , THRESH_BINARY_INV);

        blur( threshWhite, blurWhite, Size(7,7) );
        blur( threshBlack, blurBlack, Size(7,7) );

        Canny( blurWhite, cannyWhite, cutWhite, cutWhite*2, 3 );
        Canny( blurBlack, cannyBlack, cutBlack, cutBlack*2, 3 );

        namedWindow( "ThreshBlack");
        imshow( "ThreshBlack", cannyBlack);


        vector<vector<Point> > contoursWhite;
        vector<vector<Point> > contoursBlack;

        vector<Vec4i> hierarchy;

        findContours( cannyWhite, contoursWhite, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
        findContours( cannyBlack, contoursBlack, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );

        vector<vector<Point> > contours_poly1( contoursWhite.size() );
        vector<Rect> boundRect1( contoursWhite.size() );

        vector<vector<Point> > contours_poly2( contoursBlack.size() );
        vector<Rect> boundRect2( contoursBlack.size() );

        for( int i = 0; i < contoursWhite.size(); i++ )
           { approxPolyDP( Mat(contoursWhite[i]), contours_poly1[i], 3, true );
             boundRect1[i] = boundingRect( Mat(contours_poly1[i]) );
           }

        for( int i = 0; i < contoursBlack.size(); i++ )
           { approxPolyDP( Mat(contoursBlack[i]), contours_poly2[i], 3, true );
             boundRect2[i] = boundingRect( Mat(contours_poly2[i]) );
           }

        Mat boxesWhite = Mat::zeros(cannyWhite.size(), CV_8UC3 );
        Mat boxesBlack = Mat::zeros(cannyBlack.size(), CV_8UC3 );

        Scalar color = Scalar(255, 255, 255 );

        for( int i = 0; i< contoursWhite.size(); i++ )
           {
             drawContours( boxesWhite, contours_poly1, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
             rectangle( boxesWhite, boundRect1[i].tl(), boundRect1[i].br(), color, 2, 8, 0 );
           }

        for( int i = 0; i< contoursBlack.size(); i++ )
           {
             drawContours( boxesBlack, contours_poly2, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
             rectangle( boxesBlack, boundRect2[i].tl(), boundRect2[i].br(), color, 2, 8, 0 );
           }

        /// Show in a window
        namedWindow( "ContoursWhite", CV_WINDOW_AUTOSIZE );
        imshow( "ContoursWhite", boxesWhite);

        namedWindow( "ContoursBlack", CV_WINDOW_AUTOSIZE );
        imshow( "ContoursBlack", boxesBlack);

        if (waitKey(30) >= 0)
            break;
    }

    return 0;
}

/*
Mat cameraFrame, gray, threshed, blurred, canny, bw;

// read webcam
stream1.read(cameraFrame);
namedWindow( "Original");
imshow( "Original", cameraFrame);

// grayscale
cvtColor(cameraFrame, gray, CV_BGR2GRAY);
namedWindow( "Grayscale");
imshow( "Grayscale", gray);

// threshold the grayscale
threshold( gray, threshed, 170, 255 , THRESH_BINARY_INV);
namedWindow( "Thresholded");
imshow( "Thresholded", threshed);

blur( threshed, blurred, Size(7,7) );
Canny( blurred, canny, thresh, thresh*2, 3 );

vector<vector<Point> > contours;
vector<Vec4i> hierarchy;

findContours( canny, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );


vector<vector<Point> > contours_poly( contours.size() );
vector<Rect> boundRect( contours.size() );
vector<Point2f>center( contours.size() );
vector<float>radius( contours.size() );

for( int i = 0; i < contours.size(); i++ )
   { approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
     boundRect[i] = boundingRect( Mat(contours_poly[i]) );
     minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
   }

Mat drawing = Mat::zeros(canny.size(), CV_8UC3 );
for( int i = 0; i< contours.size(); i++ )
   {
     Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
     drawContours( drawing, contours_poly, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
     rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 );
     //circle( drawing, center[i], (int)radius[i], color, 2, 8, 0 );
   }

/// Show in a window
namedWindow( "Contours", CV_WINDOW_AUTOSIZE );
cvtColor(drawing, bw, CV_BGR2GRAY);
threshold( bw, drawing, 1, 255 , THRESH_BINARY);
imshow( "Contours", drawing);*/

