//
//  main.cpp
//  CollisionDetector
//
//  Created by Kayhan Qaiser on 2016-03-20.
//  Copyright © 2016 Paddy Crab. All rights reserved.
//

#include <iostream>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <sstream>
#include <string>
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/core/core.hpp"

#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

using namespace cv;
using namespace std;
int cutWhite = 100;
int cutBlack = 100;

cv::Point topLeft;
float screenWidth;
float screenHeight;

cv::Rect quadRect;

void detectMarkers() {
    VideoCapture stream1(0);
    
    vector<Point> markers;

    bool markersDetected = false;
    while (!markersDetected) {
        Mat cameraFrame, gray,
        threshWhite, threshBlack, \
        blurWhite, blurBlack, \
        cannyWhite, cannyBlack;
        
        // read webcam
        stream1.read(cameraFrame);
        namedWindow( "Original");
        
        medianBlur(cameraFrame, cameraFrame, 3);
        
        // Convert input image to HSV
        Mat hsv_image;
        cvtColor(cameraFrame, hsv_image, cv::COLOR_BGR2HSV);
        
        // Threshold the HSV image, keep only the red pixels
        Mat lower_red_hue_range;
        Mat upper_red_hue_range;
        inRange(hsv_image, cv::Scalar(0, 100, 100), cv::Scalar(10, 255, 255), lower_red_hue_range);
        inRange(hsv_image, cv::Scalar(160, 100, 100), cv::Scalar(179, 255, 255), upper_red_hue_range);
        
        // Combine the above two images
        Mat red_hue_image;
        addWeighted(lower_red_hue_range, 1.0, upper_red_hue_range, 1.0, 0.0, red_hue_image);
        
        GaussianBlur(red_hue_image, red_hue_image, cv::Size(9, 9), 2, 2);
        
        // Use the Hough transform to detect circles in the combined threshold image
        std::vector<cv::Vec3f> circles;
        HoughCircles(red_hue_image, circles, CV_HOUGH_GRADIENT, 1, red_hue_image.rows/8, 100, 40, 0, 0);
        

        // Loop over all detected circles and outline them on the original image
        if(circles.size() >= 3) {
            markersDetected = true;
            
            for(size_t current_circle = 0; current_circle < circles.size(); ++current_circle) {
            cv::Point point(std::round(circles[current_circle][0]), std::round(circles[current_circle][1]));
            
            markers.push_back(point);
        
            int radius = std::round(circles[current_circle][2]);
            cv::circle(cameraFrame, point, radius, cv::Scalar(0, 255, 0), 5);
            }
        }
        
        
        namedWindow("Detected red circles on the input image", CV_WINDOW_AUTOSIZE);
        imshow("Detected red circles on the input image", cameraFrame);

        if (waitKey(30) >= 0)
            break;
    }
    

    for (int i = 0; i<markers.size(); i++) {
        cv::Point cur = markers[i];
        if (i == 0) {
            topLeft.x = cur.x;
            topLeft.y = cur.y;
            screenHeight = abs(topLeft.y - markers[1].y);
            screenWidth = abs(topLeft.x - markers[1].x);
        }
        else {
            cv::Point prev = markers[i-1];
            if (cur.x < topLeft.x && cur.y < topLeft.y) {
                topLeft.x = cur.x;
                topLeft.y = cur.y;
            }
            float height = abs(cur.y - prev.y);
            if (height > screenHeight) screenHeight = height;
            float width = abs(cur.x - prev.x);
            if (width > screenWidth) screenWidth = width;
        }
    }
    
    printf("%d, %d, %f, %f \n", topLeft.x, topLeft.y, screenWidth, screenHeight);
    
}

cv::Point getRelativeCoordinate(cv::Point point) {
    Point relPoint = Point((point.x - topLeft.x)/screenWidth, (point.y - topLeft.y)/screenHeight);
    return relPoint;
}

double getRelativeWidth(double width) {
    return width/screenWidth;
}

double getRelativeHeight(double height) {
    return height/screenHeight;
}

const char * exec_path = "./opencv_tracker";

void sendData() {    
    cv::Point p = getRelativeCoordinate(cv::Point(quadRect.x, quadRect.y));
    

    //std::string string = std::to_string(p.x) + " " + std::to_string(p.y) + " " + std::to_string(getRelativeWidth(quadRect.width)) + " " +  std::to_string(getRelativeHeight(quadRect.height));
    
    std::string string;
    
    string += "10";
    string += " 12";
    string += " 15";
    string += " 14";
    string += " 14\0";

    
    printf("%s\n", string.c_str());
    
    int fd;
    const char *myfifo = "/tmp/quadData";
    
    mkfifo(myfifo, 0666);
    
    fd = open(myfifo, O_WRONLY);
    write(fd, string.c_str(), sizeof(char)*string.size());
    close(fd);
    
    /* remove the FIFO */
    unlink(myfifo);
}


FILE * open_tracker_process()
{
    FILE * f = popen(exec_path, "r");
    if(!f) {
        fprintf(stderr, "failed to start opencv_tracker");
        abort();
    }
    
    return f;
}

int read_tracker_frame(FILE * f, float * out, int num_floats_expected)
{
    for(int i = 0; i < num_floats_expected; i++) {
        if(fscanf(f, "%f", out) < 1) {
            return i; // or throw an error
        }
        // check for newline here if you want
        ++out;
    }
    return num_floats_expected;
}

void detectQuad() {
        VideoCapture stream1(0);
    
        while (true) {
    
            Mat cameraFrame, gray, threshBlack, \
            blurBlack, \
            cannyBlack;
    
            // read webcam
            stream1.read(cameraFrame);
            namedWindow( "Original");
            imshow( "Original", cameraFrame);
    
            cvtColor(cameraFrame, gray, CV_BGR2GRAY); // greyscale
    
            threshold( gray, threshBlack, 100, 255 , THRESH_BINARY); //img in 1 or 0
    
            blur( threshBlack, blurBlack, Size(1,1) ); // odd number or 3x3
    
            Canny( blurBlack, cannyBlack, cutBlack, cutBlack*3, 3 ); //* 3 or 2
    
            namedWindow( "ThreshBlack");
            imshow( "ThreshBlack", cannyBlack);
    
            vector<vector<Point> > contoursBlack;
        
            findContours( cannyBlack, contoursBlack, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );// tree and external
    
            vector<vector<Point> > contours_poly2( contoursBlack.size() );
            vector<Rect> boundRects( contoursBlack.size() );

    
            for( int i = 0; i < contoursBlack.size(); i++ )
            {
                approxPolyDP( Mat(contoursBlack[i]), contours_poly2[i], 1, true );
                boundRects[i] = boundingRect( Mat(contours_poly2[i]) );
            }
            
            // get the biggest Rect
            for( int i = 0; i < contoursBlack.size(); i++ )
            {
                Rect curRect = boundRects[i];
                if (i == 0) quadRect = curRect;
                else if (quadRect.area() < curRect.area()) quadRect = curRect;
            }
            
            //display
            Mat boxesBlack = Mat::zeros(cannyBlack.size(), CV_8UC3 );
    
            Scalar color(255, 255, 255 );
    
            for( int i = 0; i< contoursBlack.size(); i++ ){
                drawContours( boxesBlack, contours_poly2, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
            }
            
            cv::rectangle(boxesBlack, quadRect, cv::Scalar(0, 255, 0));
            
            namedWindow( "BoxesBlack", CV_WINDOW_AUTOSIZE );
            imshow( "BoxesBlack", boxesBlack);
            
            sendData();
            
            if (waitKey(30) >= 0)
                break;
        }
}

int main()
{
    //detectMarkers();
    detectQuad();
//
//    VideoCapture stream1(0);
//
//    //detectMarkers();
//    while (true) {
//
//        Mat cameraFrame, gray,
//        threshWhite, threshBlack, \
//        blurWhite, blurBlack, \
//        cannyWhite, cannyBlack;
//        
//        // read webcam
//        stream1.read(cameraFrame);
//        namedWindow( "Original");
//        imshow( "Original", cameraFrame);
//        
//        cvtColor(cameraFrame, gray, CV_BGR2GRAY); // greyscale
//        
//        threshold( gray, threshBlack, 100, 255 , THRESH_BINARY); //img in 1 or 0
//        threshold( gray, threshWhite, 170, 255 , THRESH_BINARY_INV); // img out > 170 is white it's inv
//
//        blur( threshWhite, blurWhite, Size(7,7) ); // odd number or 3x3
//        blur( threshBlack, blurBlack, Size(7,7) );
//        
//        Canny( blurWhite, cannyWhite, cutWhite, cutWhite*2, 3 ); // makes gradient for edges
//        Canny( blurBlack, cannyBlack, cutBlack, cutBlack*2, 3 );
//        
//        namedWindow( "ThreshBlack");
//        imshow( "ThreshBlack", cannyBlack);
//        
//        vector<vector<Point> > contoursWhite;
//        vector<vector<Point> > contoursBlack;
//        
//        vector<Vec4i> hierarchy; // unused
//        
//        findContours( cannyWhite, contoursWhite, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) ); // tree and external
//        findContours( cannyBlack, contoursBlack, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
//        
//        vector<vector<Point> > contours_poly1( contoursWhite.size() ); // list of contours
//        vector<Rect> boundRect1( contoursWhite.size() );
//        
//        vector<vector<Point> > contours_poly2( contoursBlack.size() );
//        vector<Rect> boundRect2( contoursBlack.size() );
//        
//        for( int i = 0; i < contoursWhite.size(); i++ )
//        {
//            approxPolyDP( Mat(contoursWhite[i]), contours_poly1[i], 3, true ); //unused
//            boundRect1[i] = boundingRect( Mat(contours_poly1[i]) );
//        }
//        
//        for( int i = 0; i < contoursBlack.size(); i++ )
//        { approxPolyDP( Mat(contoursBlack[i]), contours_poly2[i], 1, true );
//            boundRect2[i] = boundingRect( Mat(contours_poly2[i]) );
//        }
//        
//        
//        
//        //display
//        Mat boxesWhite = Mat::zeros(cannyWhite.size(), CV_8UC3 );
//        Mat boxesBlack = Mat::zeros(cannyBlack.size(), CV_8UC3 );
//        
//        Scalar color(255, 255, 255 );
//        
//        for( int i = 0; i< contoursWhite.size(); i++ ){
//            drawContours( boxesWhite, contours_poly1, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
//            rectangle( boxesWhite, boundRect1[i].tl(), boundRect1[i].br(), color, 2, 8, 0 );
//        }
//        
//        for( int i = 0; i< contoursBlack.size(); i++ ){
//            drawContours( boxesBlack, contours_poly2, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
//            rectangle( boxesBlack, boundRect2[i].tl(), boundRect2[i].br(), color, 2, 8, 0 );
//        }
//        
//        /// Show in a window
//        namedWindow( "ContoursWhite", CV_WINDOW_AUTOSIZE );
//        imshow( "ContoursWhite", boxesWhite);
//        
//        namedWindow( "ContoursBlack", CV_WINDOW_AUTOSIZE );
//        imshow( "ContoursBlack", boxesBlack);
//        
//        if (waitKey(30) >= 0)
//            break;
//    }
    
    //return 0;
}






