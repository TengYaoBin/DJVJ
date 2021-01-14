//
//  LayserStyle.h
//  Test
//
//  Created by Bin on 2018/12/21.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseLayerStyle : NSObject
+(CIImage *)normalImage:(CIImage*)originImage;
+(CIImage *)posterizeImage:(CIImage*)originImage;
+(CIImage *)desaturateImage:(CIImage*)originImage;
+(CIImage *)saturateImage:(CIImage*)originImage;
+(CIImage *)thresholdImage:(CIImage*)originImage;
+(CIImage *)negativeImage:(CIImage*)originImage;
+(CIImage *)guassianBlurImage:(CIImage*)originImage;
+(CIImage *)colorizeRedImage:(CIImage*)originImage;
+(CIImage *)colorizeGreenImage:(CIImage*)originImage;
+(CIImage *)colorizeBlueImage:(CIImage*)originImage;
+(CIImage *)colorizeCyanImage:(CIImage*)originImage;
+(CIImage *)colorizeMagentaImage:(CIImage*)originImage;
+(CIImage *)colorizeYellowImage:(CIImage*)originImage;
+(CIImage *)alphaImage:(CIImage*)originImage :(double)opacity;
+(CIImage *)zoomImage:(UIImage*)originImage :(double)scale;
@end

NS_ASSUME_NONNULL_END

