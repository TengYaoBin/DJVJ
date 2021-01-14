//
//  BYGfxUtility.m
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 08/01/2017.
//  Copyright © 2017 Berk Yuksel. All rights reserved.
//

#import "BYGfxUtility.h"

@implementation BYGfxUtility

+ (void)drawInnerShadowInContext:(CGContextRef)context
                        withPath:(CGPathRef)path
                     shadowColor:(CGColorRef)shadowColor
                          offset:(CGSize)offset
                      blurRadius:(CGFloat)blurRadius {
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGColorRef opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
    
    CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
    CGContextBeginTransparencyLayer(context, NULL);
    CGContextSetShadowWithColor(context, offset, blurRadius, opaqueShadowColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceOut);
    CGContextSetFillColorWithColor(context, opaqueShadowColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextEndTransparencyLayer(context);
    
    CGContextRestoreGState(context);
    CGColorRelease(opaqueShadowColor);
}


@end
