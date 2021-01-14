//
//  BlendModeLayerStyle.h
//  Test
//
//  Created by Bin on 2018/12/22.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BlendModeLayerStyle : NSObject
+(CIImage *)normalBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)multiplyBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)lightenBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)differenceBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)subtractBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)divideBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)hueBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)saturationBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)colorBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
+(CIImage *)luminosityBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage;
@end

NS_ASSUME_NONNULL_END
