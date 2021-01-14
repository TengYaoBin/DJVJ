//
//  BYColorWheel.m
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 26/12/2016.
//  Copyright © 2016 Berk Yuksel. All rights reserved.
//

#import "BYColorWheel.h"
#import "BYGfxUtility.h"

#pragma mark - Global Constants

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

#pragma mark - Private Interface

@interface BYColorWheel (){
    UIImageView *_wheelImgView;
    UIImageView *_crossHairImgView;
    float _indicatorAngle;
    BOOL _touching;
}

@end

@implementation BYColorWheel
@synthesize delegate;

#pragma mark - Initialization Methods

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    
    _touching = false;
    
    _wheelImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _wheelImgView.image = [self colorWheelImage];
    [self addSubview:_wheelImgView];
    
    UIImage *crossHairImg = [self crossHairImage];
    _crossHairImgView = [[UIImageView alloc] initWithImage:crossHairImg];
    [self addSubview:_crossHairImgView];
    
    _indicatorAngle = 0;
    [self placeCrosshair:5*MIN(self.bounds.size.width, self.bounds.size.height)/12.0];
}

#pragma mark - Public Methods

- (void)prepare{
    
    _wheelImgView.frame = self.bounds;
    _crossHairImgView.frame = [self getCrossHairFrameFromCurrentRadius];
    [self placeCrosshair:5*MIN(self.bounds.size.width, self.bounds.size.height)/12.0];
}

- (void)placeCrosshairByHue:(float)hue{
    
    _indicatorAngle = hue*360.0f;
    [self placeCrosshair:5*MIN(self.bounds.size.width, self.bounds.size.height)/12.0];
}

#pragma  mark - Touch Event Handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    float distance = sqrtf(powf(touchLocation.x-center.x, 2) + powf(touchLocation.y-center.y, 2));
    CGSize radius = [self getRadiusSizeFromCurrentBounds];
    
    if (distance > 0 && distance <= radius.height) {
        [self touchedWheelAt:touchLocation];
        _touching = true;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!_touching) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self touchedWheelAt:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    _touching = false;
}

- (void)touchedWheelAt:(CGPoint)touchLocation{
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    float distance = sqrtf(powf(touchLocation.x-center.x, 2) + powf(touchLocation.y-center.y, 2));
    CGFloat f = [self pointPairToBearingDegrees:center secondPoint:touchLocation];
    if ([self.delegate respondsToSelector:@selector(setHueFromColorWheel:)]) {
        [self.delegate setHueFromColorWheel:f/360.0f];
    }
    _indicatorAngle = f;
    [self placeCrosshair:distance];
}

#pragma mark - Private Methods

- (void)placeCrosshair:(float)distance{
    
    float radians = DEGREES_TO_RADIANS(_indicatorAngle);
    CGSize radius = [self getRadiusSizeFromCurrentBounds];
    distance = MAX(1, MIN(distance, 5*MIN(self.bounds.size.width, self.bounds.size.height)/12.0));
    //float distance = radius.width + (radius.height-radius.width)/2;
    CGPoint target = CGPointMake(distance*cosf(radians), distance*sinf(radians));
    CGPoint wheelCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _crossHairImgView.center = CGPointMake(wheelCenter.x+target.x, wheelCenter.y+target.y);
}

#pragma  mark - Helpers

- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

- (CGSize) getRadiusSizeFromCurrentBounds{
    
    CGSize size = self.bounds.size;
    float bigRadius = MIN(size.width, size.height)/2;
    return CGSizeMake(bigRadius/1.5f, bigRadius-1);
}

- (CGRect) getCrossHairFrameFromCurrentRadius{
    
    CGSize radius = [self getRadiusSizeFromCurrentBounds];
    float crossHairWH = radius.width/3.0f;
    return CGRectMake(0, 0, crossHairWH, crossHairWH);
}

#pragma  mark - Visual Object Generation methods

- (UIImage*)crossHairImage{
    CGFloat lineWidth = 2.0f;    
    
    CGRect crossHairFrame = [self getCrossHairFrameFromCurrentRadius];
    UIGraphicsBeginImageContextWithOptions(crossHairFrame.size, NO, 0.0);
    
    UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(crossHairFrame, lineWidth, lineWidth)];
    
    [innerCircle setLineWidth:lineWidth];
    [[UIColor whiteColor] setStroke];
    [innerCircle stroke];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)colorWheelImage{
    
    CGSize size = self.bounds.size;
    double radius = MIN(self.bounds.size.width, self.bounds.size.height)/2-2;
    //CGSize radius = [self getRadiusSizeFromCurrentBounds];
    
    int sectors = 180;
    float angle = 2 * M_PI/sectors;
    
    UIBezierPath *bezierPath;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0);
    
    for (int i=0; i<sectors; i++) {
        
        
        bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:i * angle endAngle:(i + 1) * angle clockwise:YES];
        [bezierPath addArcWithCenter:center radius:1 startAngle:(i+1)*angle endAngle:i*angle clockwise:NO];
        [bezierPath closePath];
        UIColor *color = [UIColor colorWithHue:((float)i)/sectors saturation:1. brightness:1. alpha:1];
        [color setFill];
        [color setStroke];
        [bezierPath fill];
        [bezierPath stroke];
    }
    
//    UIColor *shadowColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    
    float circleInset = radius-1;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, CGSizeMake(0, 4), 6, shadowColor.CGColor);
//    CGContextAddRect(context, self.bounds);
    CGContextAddEllipseInRect(context, CGRectInset(self.bounds, circleInset, circleInset));
   // CGContextEOClip(context);
    //CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.6f].CGColor);
   // CGContextFillEllipseInRect(context, CGRectInset(self.bounds, circleInset, circleInset));
    CGContextRestoreGState(context);
    
 //   CGPathRef innerShadowPath = CGPathCreateWithEllipseInRect(self.bounds, nil);
//    [BYGfxUtility drawInnerShadowInContext:context withPath:innerShadowPath shadowColor:shadowColor.CGColor offset:CGSizeMake(0, 4) blurRadius:6];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
