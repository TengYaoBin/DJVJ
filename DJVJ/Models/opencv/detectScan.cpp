//
//  detectLane.cpp
//  IOS-Lane-Detection
//
//  Created by geoffrey on 11/27/15.
//  Copyright © 2015 geoffrey. All rights reserved.
//

#include "detectScan.hpp"
#include <vector>
#include <string>
#include <unistd.h>
#include <iostream>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <fstream>
#include <sstream>


#import <opencv2/highgui/highgui.hpp>


using namespace std;
using namespace cv;

cv::Mat detectedMat(cv::Mat mat)
{
    Mat im_11,im_12, im, im4;
    Mat im0 = mat;
    cvtColor(im0, im, CV_RGB2HSV);
    inRange(im, Scalar(140, 0, 50), Scalar(180, 255, 255), im_11);
    
    GaussianBlur(im_11, im_11, Size(305, 305), 0);
    
    threshold(im_11, im_11, 90, 255, THRESH_BINARY);

    
    
    im0.copyTo(im4, im_11);
    
    return im4;
    
}
