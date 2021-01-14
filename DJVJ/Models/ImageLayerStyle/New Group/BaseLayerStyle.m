//
//  LayserStyle.m
//  Test
//
//  Created by Bin on 2018/12/21.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "BaseLayerStyle.h"
#import "BlackAndWhiteThresholdFilter.h"

@implementation BaseLayerStyle
//image filter function

+(CIImage *)normalImage:(CIImage*)originImage;
{
    return originImage;
}
+(CIImage *)posterizeImage:(CIImage*)originImage
{
    CIFilter *posterizeFilter = [CIFilter filterWithName:@"CIColorPosterize"];
    [posterizeFilter setValue:[NSNumber numberWithDouble:3.0] forKey:@"inputLevels"];
    [posterizeFilter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [posterizeFilter outputImage];
    return outputImage;
}
+(CIImage *)desaturateImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:[NSNumber numberWithDouble:0.0] forKey:@"inputSaturation"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)saturateImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:[NSNumber numberWithDouble:2.0] forKey:@"inputSaturation"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)thresholdImage:(CIImage*)originImage
{
    BlackAndWhiteThresholdFilter *filter = [[BlackAndWhiteThresholdFilter alloc] init];
    [filter setValue:[NSNumber numberWithDouble:0.065] forKey:@"inputThreshold"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)negativeImage:(CIImage*)originImage
{
    CIFilter *invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
    [invertFilter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [invertFilter outputImage];
    return outputImage;
}
+(CIImage *)guassianBlurImage:(CIImage*)originImage
{
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setValue:[NSNumber numberWithDouble:10.0] forKey:@"inputRadius"];
    [gaussianBlurFilter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[originImage extent]];
    outputImage = [CIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return outputImage;
}

+(CIImage *)colorizeRedImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[1.0 0.0 0.0 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)colorizeGreenImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[0.0 1.0 0.0 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)colorizeBlueImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[0.0 0.0 1.0 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)colorizeCyanImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[0.0 1.0 1.0 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)colorizeMagentaImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[1.0 0.0 1.0. 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}
+(CIImage *)colorizeYellowImage:(CIImage*)originImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setValue:[CIColor colorWithString:@"[1.0 1.0 0.0 1.0]"] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputIntensity"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}


+(CIImage *)alphaImage:(CIImage*)originImage :(double)opacity
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    [filter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:opacity]forKey:@"inputAVector"];
    [filter setValue:originImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}

+(CIImage *)zoomImage:(UIImage*)originImage :(double)scale
{
    if (originImage) {
        CIImage *beginImg = [CIImage imageWithCGImage:[originImage CGImage]];
        CIFilter *filter1 = [CIFilter filterWithName:@"CICrop"];
        [filter1 setValue:[CIVector vectorWithX:originImage.size.width*(scale - 1)/(2*scale) Y:originImage.size.height*(scale - 1)/(2*scale) Z:originImage.size.width/scale W:originImage.size.height/scale] forKey:@"inputRectangle"];
        [filter1 setValue:beginImg forKey:@"inputImage"];
        CIImage *outputImage1 = filter1.outputImage;
        
        CIContext *context1 = [CIContext contextWithOptions:nil];
        CGImageRef cgimg1 = [context1 createCGImage:outputImage1 fromRect:[outputImage1 extent]];
        outputImage1 = [CIImage imageWithCGImage:cgimg1];
        CGImageRelease(cgimg1);
        CIFilter *filter2 = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        //NSLog(@"%@",[filter2 attributes]);
        [filter2 setValue:outputImage1 forKey:@"inputImage"];
        [filter2 setValue:[NSNumber numberWithDouble:scale] forKey:@"inputScale"];
        CIImage *outputImage = filter2.outputImage;
        return outputImage;
    }else
    {
        return [[CIImage alloc] init];
    }
    
}







@end

