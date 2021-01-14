//
//  BYGfxUtility.h
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 08/01/2017.
//  Copyright © 2017 Berk Yuksel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYGfxUtility : NSObject

+ (void)drawInnerShadowInContext:(CGContextRef)context
                        withPath:(CGPathRef)path
                     shadowColor:(CGColorRef)shadowColor
                          offset:(CGSize)offset
                      blurRadius:(CGFloat)blurRadius;
@end
