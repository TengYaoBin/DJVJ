//
//  BlendModeLayerStyle.m
//  Test
//
//  Created by Bin on 2018/12/22.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "BlendModeLayerStyle.h"

@implementation BlendModeLayerStyle


+(CIImage *)normalBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)multiplyBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)lightenBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CILightenBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)differenceBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIDifferenceBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)subtractBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CISubtractBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)divideBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIDivideBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)hueBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIHueBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)saturationBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CISaturationBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)colorBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}
+(CIImage *)luminosityBlendImage:(CIImage*)baseImage :(CIImage*)overlayImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CILuminosityBlendMode"];
    [filter setValue:overlayImage forKey:@"inputImage"];
    [filter setValue:baseImage forKey:@"inputBackgroundImage"];
    CIImage *outputImage = filter.outputImage;
    return outputImage;
}

@end
