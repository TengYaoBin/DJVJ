//
//  SpecialEffectLayerStyle.m
//  DJVJ
//
//  Created by Bin on 2019/1/5.
//  Copyright © 2019 Bin. All rights reserved.
//

#import "SpecialEffectLayerStyle.h"
#import "BlackAndWhiteThresholdFilter.h"

@implementation SpecialEffectLayerStyle
+(UIImage *)whiteStrobe:(UIImage*)originImage :(int)frame_num{
    if (frame_num%6 == 0 || frame_num%6 == 1) {
        int count = (frame_num/6) % 4;
        double alpha_value = 0.0;
        switch (count) {
            case 0:
                alpha_value = 1.0;
                break;
            case 1:
                alpha_value = 0.66;
                break;
            case 2:
                alpha_value = 0.33;
                break;
            case 3:
                alpha_value = 0.0;
                break;
            default:
                break;
        }
        
        CGSize newSize = originImage.size;
        UIGraphicsBeginImageContext(newSize);
        [originImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *img_white = [UIImage imageNamed:@"white.png"];
        [img_white drawInRect:CGRectMake(0, 0, newSize.width, newSize.height) blendMode:kCGBlendModeNormal alpha:alpha_value];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return finalImage;
    }else
    {
        return originImage;
    }
    
}
+(UIImage *)blackStrobe:(UIImage*)originImage :(int)frame_num{
    if (frame_num%6 == 0 || frame_num%6 == 1) {
        int count = (frame_num/6) % 4;
        double alpha_value = 0.0;
        switch (count) {
            case 0:
                alpha_value = 1.0;
                break;
            case 1:
                alpha_value = 0.66;
                break;
            case 2:
                alpha_value = 0.33;
                break;
            case 3:
                alpha_value = 0.0;
                break;
            default:
                break;
        }
        
        CGSize newSize = originImage.size;
        UIGraphicsBeginImageContext(newSize);
        [originImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *img_black = [UIImage imageNamed:@"black.png"];
        [img_black drawInRect:CGRectMake(0, 0, newSize.width, newSize.height) blendMode:kCGBlendModeNormal alpha:alpha_value];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return finalImage;
    }else
    {
        return originImage;
    }
}
+(UIImage *)fadeToWhite:(UIImage*)originImage :(int)frame_num{
    double alpha_value = MIN(1.0, frame_num/100.0);
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [originImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *img_white = [UIImage imageNamed:@"white.png"];
    [img_white drawInRect:CGRectMake(0, 0, newSize.width, newSize.height) blendMode:kCGBlendModeNormal alpha:alpha_value];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)fadeToBlack:(UIImage*)originImage :(int)frame_num{
    double alpha_value = MIN(1.0, frame_num/100.0);
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [originImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *img_black = [UIImage imageNamed:@"black.png"];
    [img_black drawInRect:CGRectMake(0, 0, newSize.width, newSize.height) blendMode:kCGBlendModeNormal alpha:alpha_value];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)gaussianBlur:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setValue:[NSNumber numberWithDouble:10.0] forKey:@"inputRadius"];
    [gaussianBlurFilter setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)zoom:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *zoomBlurFilter = [CIFilter filterWithName:@"CIZoomBlur"];
    [zoomBlurFilter setValue:[CIVector vectorWithX:originImage.size.width/2 Y:originImage.size.height/2] forKey:@"inputCenter"];
    [zoomBlurFilter setValue:[NSNumber numberWithDouble:30.0] forKey:@"inputAmount"];
    [zoomBlurFilter setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [zoomBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)posterize:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *posterizeFilter = [CIFilter filterWithName:@"CIColorPosterize"];
    [posterizeFilter setValue:[NSNumber numberWithDouble:2.0] forKey:@"inputLevels"];
    [posterizeFilter setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [posterizeFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)solarize:(UIImage*)originImage{
    
    CIImage *inputImage = [CIImage imageWithCGImage:[originImage CGImage]];
    
    UIImage *keyImage = [UIImage imageNamed:@"colorCube_solarize.png"];
    
    CGImageRef keyCgImage = keyImage.CGImage;
    int sizeOfCube = floor(CGImageGetWidth(keyCgImage));
    NSData *colorCubeNSData = [self colorCubeDataForCGImageRef:keyCgImage];
    CGColorSpaceRef colorSpace;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CIFilter *colorcubeFilter = [CIFilter filterWithName:@"CIColorCubeWithColorSpace"];
    [colorcubeFilter setValue:inputImage forKey:@"inputImage"];
    [colorcubeFilter setValue:[NSNumber numberWithInt:sizeOfCube] forKey:@"inputCubeDimension"];
    [colorcubeFilter setValue:colorCubeNSData forKey:@"inputCubeData"];
    [colorcubeFilter setValue:(__bridge id) colorSpace forKey:@"inputColorSpace"];
    
    CIImage *outputImage = colorcubeFilter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return resultImage;
}
+(UIImage *)pixellate:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixellateFilter setValue:[CIVector vectorWithX:originImage.size.width/2 Y:originImage.size.height/2] forKey:@"inputCenter"];
    int inputScale = originImage.size.width/96;
    [pixellateFilter setValue:inputImage forKey:@"inputImage"];
    [pixellateFilter setValue:[NSNumber numberWithInt:inputScale] forKey:@"inputScale"];
    CIImage *outputImage = [pixellateFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)superpixellate:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixellateFilter setValue:[CIVector vectorWithX:originImage.size.width/2 Y:originImage.size.height/2] forKey:@"inputCenter"];
    int inputScale = originImage.size.width*3/80;
    [pixellateFilter setValue:inputImage forKey:@"inputImage"];
    [pixellateFilter setValue:[NSNumber numberWithInt:inputScale] forKey:@"inputScale"];
    CIImage *outputImage = [pixellateFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)caleidoTL:(UIImage*)originImage{
    CIImage *beginImg = [CIImage imageWithCGImage:[originImage CGImage]];
    CIFilter *filter1 = [CIFilter filterWithName:@"CICrop"];
    [filter1 setValue:[CIVector vectorWithX:0 Y:originImage.size.height/2 Z:originImage.size.width/2 W:originImage.size.height/2] forKey:@"inputRectangle"];
    [filter1 setValue:beginImg forKey:@"inputImage"];
    CIImage *outputImage1 = filter1.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    UIImage *startImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    UIImage *top_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationUpMirrored];
    UIImage *bottom_left_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDownMirrored];
    UIImage *bottom_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDown];
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [startImage drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [top_right_img drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [bottom_left_img drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [bottom_right_img drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)caleidoTR:(UIImage*)originImage{
    CIImage *beginImg = [CIImage imageWithCGImage:[originImage CGImage]];
    CIFilter *filter1 = [CIFilter filterWithName:@"CICrop"];
    [filter1 setValue:[CIVector vectorWithX:originImage.size.width/2 Y:originImage.size.height/2 Z:originImage.size.width/2 W:originImage.size.height/2] forKey:@"inputRectangle"];
    [filter1 setValue:beginImg forKey:@"inputImage"];
    CIImage *outputImage1 = filter1.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    UIImage *startImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    UIImage *top_left_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationUpMirrored];
    UIImage *bottom_left_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDown];
    UIImage *bottom_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDownMirrored];
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [top_left_img drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [startImage drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [bottom_left_img drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [bottom_right_img drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)caleidoBL:(UIImage*)originImage{
    CIImage *beginImg = [CIImage imageWithCGImage:[originImage CGImage]];
    CIFilter *filter1 = [CIFilter filterWithName:@"CICrop"];
    [filter1 setValue:[CIVector vectorWithX:0 Y:0 Z:originImage.size.width/2 W:originImage.size.height/2] forKey:@"inputRectangle"];
    [filter1 setValue:beginImg forKey:@"inputImage"];
    CIImage *outputImage1 = filter1.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    UIImage *startImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    UIImage *top_left_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDownMirrored];
    UIImage *top_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDown];
    UIImage *bottom_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationUpMirrored];
    
    
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [top_left_img drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [top_right_img drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [startImage drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [bottom_right_img drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)caleidoBR:(UIImage*)originImage{
    CIImage *beginImg = [CIImage imageWithCGImage:[originImage CGImage]];
    CIFilter *filter1 = [CIFilter filterWithName:@"CICrop"];
    [filter1 setValue:[CIVector vectorWithX:originImage.size.width/2 Y:0 Z:originImage.size.width/2 W:originImage.size.height/2] forKey:@"inputRectangle"];
    [filter1 setValue:beginImg forKey:@"inputImage"];
    CIImage *outputImage1 = filter1.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage1 fromRect:[outputImage1 extent]];
    UIImage *startImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    UIImage *top_left_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDown];
    UIImage *top_right_img = [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationDownMirrored];
    UIImage * bottom_left_img= [UIImage imageWithCGImage:startImage.CGImage scale:startImage.scale orientation:UIImageOrientationUpMirrored];
   
    
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [top_left_img drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [top_right_img drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [bottom_left_img drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [startImage drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)times4:(UIImage*)originImage{
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [originImage drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [originImage drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [originImage drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [originImage drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)times9:(UIImage*)originImage{
    UIImage *originImage1 = [UIImage imageWithCGImage:originImage.CGImage scale:originImage.scale orientation:UIImageOrientationUpMirrored];
    UIImage *originImage2 = [UIImage imageWithCGImage:originImage.CGImage scale:originImage.scale orientation:UIImageOrientationDownMirrored];
    UIImage *originImage3 = [UIImage imageWithCGImage:originImage.CGImage scale:originImage.scale orientation:UIImageOrientationDown];
    NSMutableArray *img_array = [[NSMutableArray alloc] init];
    [img_array addObject:originImage];
    [img_array addObject:originImage1];
    [img_array addObject:originImage2];
    [img_array addObject:originImage3];
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(0, 0, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(newSize.width/3, 0, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(2*newSize.width/3, 0, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(0, newSize.height/3, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(newSize.width/3, newSize.height/3, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(2*newSize.width/3, newSize.height/3, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(0, 2*newSize.height/3, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(newSize.width/3, 2*newSize.height/3, newSize.width/3, newSize.height/3)];
    [[img_array objectAtIndex:rand()%4] drawInRect:CGRectMake(2*newSize.width/3, 2*newSize.height/3, newSize.width/3, newSize.height/3)];
    
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}
+(UIImage *)warhol:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *posterizeFilter = [CIFilter filterWithName:@"CIColorPosterize"];
    [posterizeFilter setValue:[NSNumber numberWithDouble:5.0] forKey:@"inputLevels"];
    [posterizeFilter setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [posterizeFilter outputImage];
    
    CIFilter *hueFilter = [CIFilter filterWithName:@"CIHueAdjust"];
    [hueFilter setValue:outputImage forKey:@"inputImage"];
    [hueFilter setValue:[NSNumber numberWithDouble:1.5708] forKey:@"inputAngle"];
    CIImage *outputImage1 = [hueFilter outputImage];
    
    [hueFilter setValue:[NSNumber numberWithDouble:-1.5708] forKey:@"inputAngle"];
    CIImage *outputImage2 = [hueFilter outputImage];
    
    [hueFilter setValue:[NSNumber numberWithDouble:3.141593] forKey:@"inputAngle"];
    CIImage *outputImage3 = [hueFilter outputImage];
    
    CGSize newSize = originImage.size;
    UIGraphicsBeginImageContext(newSize);
    [[UIImage imageWithCIImage:outputImage] drawInRect:CGRectMake(0, 0, newSize.width/2, newSize.height/2)];
    [[UIImage imageWithCIImage:outputImage2] drawInRect:CGRectMake(newSize.width/2, 0, newSize.width/2, newSize.height/2)];
    [[UIImage imageWithCIImage:outputImage1] drawInRect:CGRectMake(0, newSize.height/2, newSize.width/2, newSize.height/2)];
    [[UIImage imageWithCIImage:outputImage3] drawInRect:CGRectMake(newSize.width/2, newSize.height/2, newSize.width/2, newSize.height/2)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;    
}
+(UIImage *)threshold:(UIImage*)originImage{    
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    BlackAndWhiteThresholdFilter *filter = [[BlackAndWhiteThresholdFilter alloc] init];
    [filter setValue:[NSNumber numberWithDouble:0.065] forKey:@"inputThreshold"];
    [filter setValue:inputImage forKey:@"inputImage"];
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}
+(UIImage *)oldTimes:(UIImage*)originImage{
    CIImage *inputImage = [CIImage imageWithCGImage:originImage.CGImage];
    CIFilter *filter1 = [CIFilter filterWithName:@"CIColorControls"];
    [filter1 setValue:[NSNumber numberWithDouble:0.0] forKey:@"inputSaturation"];
    [filter1 setValue:inputImage forKey:@"inputImage"];
    CIImage *greyImage = [filter1 outputImage];
    
    CIFilter *filter2 = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage *noise = filter2.outputImage;
    
    int noise_width = rand()%2+1;
    
    CGAffineTransform xForm = CGAffineTransformMakeScale(noise_width, noise_width);
    CIFilter *filter5 = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter5 setValue:[NSValue valueWithBytes:&xForm objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    [filter5 setValue:noise forKey:@"inputImage"];
    CIImage *noise1 = [filter5 outputImage];
    
    CIFilter *filter3 = [CIFilter filterWithName:@"CIColorMatrix"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0.1 Z:0 W:0] forKey:@"inputRVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0.1 Z:0 W:0] forKey:@"inputGVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0.1 Z:0 W:0] forKey:@"inputBVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    [filter3 setValue:noise1 forKey:@"inputImage"];
    CIImage *whiteNoise = filter3.outputImage;
    CIFilter *filter4 = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [filter4 setValue:greyImage forKey:@"inputBackgroundImage"];
    [filter4 setValue:whiteNoise forKey:@"inputImage"];
    
    CIImage *outputImg1 = filter4.outputImage;
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgimg = [context createCGImage:outputImg1 fromRect:[inputImage extent]];
//    outputImg1 = [CIImage imageWithCGImage:cgimg];
//    CGImageRelease(cgimg);
    
    int affine_width = rand()%3+1;
    int affine_height = rand()%10+20;
    xForm = CGAffineTransformMakeScale(affine_width, affine_height);
    [filter5 setValue:[NSValue valueWithBytes:&xForm objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    [filter5 setValue:noise forKey:@"inputImage"];
    CIImage *affineImage = [filter5 outputImage];
    [filter3 setValue:[CIVector vectorWithX:4 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputAVector"];
    [filter3 setValue:[CIVector vectorWithX:0 Y:1 Z:1 W:1] forKey:@"inputBiasVector"];
    [filter3 setValue:affineImage forKey:@"inputImage"];
    CIImage *cyanScratch = filter3.outputImage;
    CIFilter *filter6 = [CIFilter filterWithName:@"CIMinimumComponent"];
    [filter6 setValue:cyanScratch forKey:@"inputImage"];
    CIImage *darkScratch = filter6.outputImage;
    
    CIFilter *filter7 = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [filter7 setValue:outputImg1 forKey:@"inputBackgroundImage"];
    [filter7 setValue:darkScratch forKey:@"inputImage"];
    CIImage *outputImg2 = filter7.outputImage;
    
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImg2 fromRect:[inputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return finalImage;
}



//subfunctions for solarize effects
+(NSData *) colorCubeDataForCGImageRef:(CGImageRef)imageRef {
    
    NSData *cubeNSData;
    const unsigned int size = floor(CGImageGetWidth(imageRef));
    
    NSUInteger cubeDataSize = ( size * size * size * sizeof(char) * 4);
    char *cubeCharData = [self convertCGImageRefToBitmapRGBA8CharData:imageRef];
    
    cubeNSData = [NSData dataWithBytesNoCopy:cubeCharData length:cubeDataSize freeWhenDone:YES];
    
    return cubeNSData;
}
+(char *) convertCGImageRefToBitmapRGBA8CharData:(CGImageRef)imageRef {
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    char *bitmapData = ( char *)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = ( char *)malloc(sizeof( char) * bytesPerRow * height);
        
        if(newBitmap) {    // Copy the data
            for(size_t i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
        
        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
        free(bitmapData);
    }
    
    CGContextRelease(context);
    
    return newBitmap;
}
+(CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}




@end
