//
//  UIView+SDExtension.m
//  DJVJ
//
//  Created by Bin on 2018/11/30.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "UIView+SDExtension.h"

@implementation UIView (SDExtension)

- (void) removeAllSubViews
{
    for (int i = 0; i < [[self subviews] count]; i++ ) {
        [[[self subviews] objectAtIndex:i] removeFromSuperview];
    }
}
- (void) roundLeftCorner:(double)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
- (void) roundRightCorner:(double)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
@end
