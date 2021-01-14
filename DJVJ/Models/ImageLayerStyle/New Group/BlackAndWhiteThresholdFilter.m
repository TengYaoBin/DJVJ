//
//  BlackAndWhiteThresholdFilter.m
//  Test
//
//  Created by Bin on 2018/12/22.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "BlackAndWhiteThresholdFilter.h"

@interface  BlackAndWhiteThresholdFilter()
{
    CIKernel *_kernel;
}

@end

@implementation BlackAndWhiteThresholdFilter {
    NSNumber *inputThreshold;
    CIImage *inputImage;
}


//more https://developer.apple.com/library/ios/documentation/graphicsimaging/Conceptual/CoreImaging/ci_image_units/ci_image_units.html#//apple_ref/doc/uid/TP30001185-CH7-SW8
+ (void)registerFilter
{
    
    
    
    NSDictionary *attributes = @{
                                 kCIAttributeFilterCategories: @[
                                         kCICategoryVideo,
                                         kCICategoryStillImage,
                                         kCICategoryCompositeOperation,
                                         kCICategoryInterlaced,
                                         kCICategoryNonSquarePixels
                                         ],
                                 kCIAttributeFilterDisplayName: @"Black & White Threshold",
                                 
                                 };
    
    [CIFilter registerFilterName:@"BlackAndWhiteThreshold"
                     constructor:(id <CIFilterConstructor>)self
                 classAttributes:attributes];
}


+ (CIFilter *)filterWithName:(NSString *)aName
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    
    return filter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *kernelText = @"kernel vec4 thresholdKernel(sampler image, float inputThreshold)\n"
        "{\n"
        "  float pass = 1.0;\n"
        "  float fail = 0.0;\n"
        "  const vec4    vec_Y = vec4( 0.299, 0.587, 0.114, 0.0 );\n"
        "  vec4        src = unpremultiply( sample(image, samplerCoord(image)) );\n"
        "  float        Y = dot( src, vec_Y );\n"
        "  src.rgb = vec3( compare( Y - inputThreshold, fail, pass));\n"
        "  return premultiply(src);\n"
        "}";
        
        _kernel = [[CIKernel kernelsWithString:kernelText] objectAtIndex:0];
    }
    
    return self;
}

- (NSArray *)inputKeys {
    return @[@"inputImage",@"inputThreshold"];
}

- (NSArray *)outputKeys {
    return @[@"outputImage"];
}


//Recipe https://developer.apple.com/library/ios/documentation/graphicsimaging/Conceptual/CoreImaging/ci_custom_filters/ci_custom_filters.html#//apple_ref/doc/uid/TP30001185-CH6-CJBEDHHH
+ (NSDictionary *)customAttributes
{
    NSDictionary *thresholDictionary = @{
                                         kCIAttributeType: kCIAttributeTypeScalar,
                                         kCIAttributeMin: @0.0f,
                                         kCIAttributeMax: @1.0f,
                                         kCIAttributeIdentity : @0.00,
                                         kCIAttributeDefault: @0.5f,
                                         };
    
    return @{
             @"inputThreshold": thresholDictionary,
             // This is needed because the filter is registered under a different name than the class.
             kCIAttributeFilterName : @"BlackAndWhiteThreshold"
             };
}

- (CIImage *)outputImage {
    if (inputImage == nil) {
        return nil;
    }
    
    CISampler *sampler;
    
    sampler = [CISampler samplerWithImage:inputImage];
    
    CIImage * outputImage = [_kernel applyWithExtent:[inputImage extent]
                                         roiCallback:^CGRect(int index, CGRect destRect) {
                                             return CGRectMake(0, 0, CGRectGetWidth(self->inputImage.extent), CGRectGetHeight(self->inputImage.extent));
                                         } arguments:@[ inputImage, inputThreshold]];
    return outputImage;
}

@end
