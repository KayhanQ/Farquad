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

cv::Point2f botLeft;
cv::Point2f topLeft;
cv::Point2f topRight;
cv::Point2f botRight;

float screenWidth;
float screenHeight;

cv::Rect quadRect;
cv::Mat warpAffineMatrix;


struct yComparator
{
    inline bool operator() (cv::Point2f p1, cv::Point2f p2)
    {
        return (p1.y < p2.y);
    }
};

struct xComparator
{
    inline bool operator() (cv::Point2f p1, cv::Point2f p2)
    {
        return (p1.x < p2.x);
    }
};

void detectMarkers() {
    VideoCapture stream1(0);

    vector<Point> markers;
    vector<float> radi;
    
    bool markersDetected = false;
    while (!markersDetected) {
        Mat cameraFrame, gray,
        threshWhite, threshBlack, \
        blurWhite, blurBlack, \
        cannyWhite, cannyBlack;
        
        // read webcam
        stream1.read(cameraFrame);
        
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
        HoughCircles(red_hue_image, circles, CV_HOUGH_GRADIENT, 1, red_hue_image.rows/8, 100, 30, 0, 0);
        

        // Loop over all detected circles and outline them on the original image
        if(circles.size() >= 4 && circles.size() <= 4) {
            markersDetected = true;
            
            for(size_t current_circle = 0; current_circle < circles.size(); ++current_circle) {
                cv::Point point(std::round(circles[current_circle][0]), std::round(circles[current_circle][1]));
            
                markers.push_back(point);
                radi.push_back(float(std::round(circles[current_circle][2])));
            }
        }
        
        for(size_t current_circle = 0; current_circle < circles.size(); ++current_circle) {
            cv::Point point(std::round(circles[current_circle][0]), std::round(circles[current_circle][1]));
            int radius = std::round(circles[current_circle][2]);
            cv::circle(cameraFrame, point, radius, cv::Scalar(0, 255, 0), 5);
        }
        
        
        namedWindow("Detected red circles on the input image", CV_WINDOW_AUTOSIZE);
        imshow("Detected red circles on the input image", cameraFrame);

        if (waitKey(30) >= 0)
            break;
    }
    
    fprintf(stderr, "originals: %d, %d, %d, %d \n", markers[0].x, markers[0].y, markers[1].x, markers[1].y);

    std::stable_sort(markers.begin(), markers.end(), yComparator());
    std::stable_sort(markers.begin(), markers.end(), xComparator());
    
    for (int i = 0; i < markers.size(); i++) {
        printf("x: %d, y: %d\n", markers[i].x, markers[i].y);
    }
  
    botLeft = markers[0];
    topLeft = markers[1];
    topRight = markers[2];
    botRight = markers[3];
    
//
//    vector<Point> skewedPoints;
//    skewedPoints.push_back(topLeft);
//    skewedPoints.push_back(topRight);
//    skewedPoints.push_back(botLeft);
//    skewedPoints.push_back(botRight);
//    
//    vector<Point> realPoints;
//    realPoints.push_back(Point(0, 0));
//    realPoints.push_back(Point(1024, 0));
//    realPoints.push_back(Point(0, 768));
//    realPoints.push_back(Point(1024, 768));
//    
//    warpAffineMatrix = getPerspectiveTransform(skewedPoints, realPoints);
//

    screenWidth = botRight.x - botLeft.x;
    screenHeight = botRight.y - topRight.y;
    
    fprintf(stderr, "Successfuly detected markers\n");
    fprintf(stderr, "%f, %f, %f, %f \n", topLeft.x, topLeft.y, screenWidth, screenHeight);
    
}

cv::Point2f getRelativeCoordinate(cv::Point2f point) {
    float m1 = (topLeft.y - botLeft.y) / (topLeft.x - botLeft.x);
    float m2 = (topRight.y - botRight.y) / (topRight.x - botRight.x);

    float x1 = topLeft.x + point.y / m1;
    float x2 = topRight.x + point.y / m2;

    float width = x2 - x1;
    
    Point2f relPoint = Point2f((point.x - x1)/width, 1.0f - ((point.y - topLeft.y)/screenHeight));
    
    //Point2f relPoint = Point2f((point.x - topLeft.x)/screenWidth, 1.0f - ((point.y - topLeft.y)/screenHeight));
    return relPoint;
}

float getRelativeWidth(float width) {
    return width/screenWidth;
}

float getRelativeHeight(float height) {
    return height/screenHeight;
}


void sendData() {    
    cv::Point2f p = getRelativeCoordinate(cv::Point2f(quadRect.x, quadRect.y));
    
    //std::string string = std::to_string(p.x) + " " + std::to_string(p.y) + " " + std::to_string(getRelativeWidth(quadRect.width)) + " " +  std::to_string(getRelativeHeight(quadRect.height));
    
    std::string string;
    
    string += std::to_string(p.x);
    string += " ";
    string += std::to_string(p.y);
    string += " ";
    string += std::to_string(getRelativeWidth(quadRect.width));
    string += " ";
    string += std::to_string(getRelativeHeight(quadRect.height));
    string += "\0";

    printf("%s\n", string.c_str());
}

void detectQuad() {
    VideoCapture stream1(0);
    
    while (true) {
        
        Mat cameraFrame, gray, threshBlack, \
        blurBlack, \
        cannyBlack;
        
        // read webcam
        stream1.read(cameraFrame);
//        namedWindow( "Original");
//        imshow( "Original", cameraFrame);
        
        cvtColor(cameraFrame, gray, CV_BGR2GRAY); // greyscale
        
        threshold( gray, threshBlack, 50, 255, THRESH_BINARY); //img in 1 or 0
        
        blur( threshBlack, blurBlack, Size(5,5) ); // odd number or 3x3
        
        Canny( blurBlack, cannyBlack, cutBlack, cutBlack*3, 3 ); //* 3 or 2
        
//        namedWindow( "ThreshBlack");
//        imshow( "ThreshBlack", cannyBlack);
        
        vector<vector<Point> > contoursBlack;
        
        findContours( cannyBlack, contoursBlack, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );// tree and external
        
        float contour_length_threshold = 5.0f;
        
        for (vector<vector<Point> >::iterator it = contoursBlack.begin(); it!=contoursBlack.end(); )
        {
            if (it->size()<contour_length_threshold)
                it=contoursBlack.erase(it);
            else
                ++it;
        }
        
        vector<vector<Point> > contours_poly2( contoursBlack.size() );
        vector<Rect> boundRects( contoursBlack.size() );
        
        Mat boxesBlack = Mat::zeros(cannyBlack.size(), CV_8UC3 );

        for( int i = 0; i < contoursBlack.size(); i++ )
        {
            approxPolyDP( Mat(contoursBlack[i]), contours_poly2[i], 1, true );
            
            boundRects[i] = boundingRect( Mat(contours_poly2[i]) );

            if (isContourConvex(contours_poly2[i])) {
                cv::rectangle(boxesBlack, boundRects[i], Scalar(255, 255, 255 ));
            }
            else {
                cv::rectangle(boxesBlack, boundRects[i], Scalar(0, 0, 255 ));
            }
            

        }
        
        // get the biggest Rect
        for( int i = 0; i < contoursBlack.size(); i++ )
        {
            Rect curRect = boundRects[i];
            if (i == 0) quadRect = curRect;
            else if (quadRect.area() < curRect.area()) quadRect = curRect;
        }
        
        //display
        
        Scalar color(0, 255, 255 );
        
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
    detectMarkers();
    detectQuad();    
}






