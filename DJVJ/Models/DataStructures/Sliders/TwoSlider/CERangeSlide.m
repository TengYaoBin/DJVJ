//
//  CERangeSlide.m
//  TwoSlider
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "CERangeSlide.h"
@interface CERangeSlide ()
{
    UIImageView *imgBackgroundView;
    UIImageView *minSideView;
    UIImageView *maxSideView;
    
    UIImageView *minImageView;
    UIImageView *maxImageView;
    UIImageView *contentImageView;
    double height;
    double width;
    double content_width;
    double content_height;
    double leading_value;
    double top_value;
    
    UIImage *minTintThumb;
    UIImage *maxTintThumb;
    UIImage *contentTintImage;
}
@end

@implementation CERangeSlide


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _maximumValue = 1.0;
        _minimumValue = 0.0;
        _upperValue = 1.0;
        _lowerValue = 0.0;
        imgBackgroundView = [[UIImageView alloc] init];
        minSideView = [[UIImageView alloc] init];
        [minSideView setAlpha:0.8];
        [minSideView setBackgroundColor:[UIColor blackColor]];
        maxSideView = [[UIImageView alloc] init];
        [maxSideView setAlpha:0.8];
        [maxSideView setBackgroundColor:[UIColor blackColor]];
        minImageView = [[UIImageView alloc] init];
        maxImageView = [[UIImageView alloc] init];
        contentImageView = [[UIImageView alloc] init];
        
        minTintThumb = [UIImage imageNamed:@"videocrop_0095FF_left_glow_active.png"];
        maxTintThumb = [UIImage imageNamed:@"videocrop_0095FF_right_glow_active.png"];
        contentTintImage = [UIImage imageNamed:@"videocrop_0095FF_center_glow_active.png"];
        
        [self addSubview:imgBackgroundView];
        [self addSubview:maxSideView];
        [self addSubview:minSideView];
        [self addSubview:contentImageView];
        [self addSubview:minImageView];
        [self addSubview:maxImageView];
        [self updateView];
    }
    return self;
}

//set rounded background image
-(void)setBackgroundRound
{
    double lower_distance = content_width * _lowerValue;
    double upper_distance = content_width *(1-_upperValue);
    if (lower_distance >= content_height/2) {
        lower_distance = content_height/2;
    }
    if (upper_distance >= content_height/2) {
        upper_distance = content_height/2;
    }
    // set background image round.
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:CGRectMake(imgBackgroundView.bounds.origin.x + lower_distance, imgBackgroundView.bounds.origin.y, content_width-lower_distance-upper_distance, content_height)
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                              cornerRadii:CGSizeMake(0, 0)
                              ];
    UIBezierPath *leftmaskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(imgBackgroundView.bounds.origin.x, imgBackgroundView.bounds.origin.y, 2*lower_distance, content_height)];
    UIBezierPath *rightmaskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(imgBackgroundView.bounds.origin.x + content_width - 2* upper_distance, imgBackgroundView.bounds.origin.y, 2*upper_distance, content_height)];
    [maskPath appendPath:leftmaskPath];
    [maskPath appendPath:rightmaskPath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    imgBackgroundView.layer.mask = maskLayer;
    
    
    // set min mask image round.
    UIBezierPath *minMaskPath = [UIBezierPath
                                 bezierPathWithRoundedRect:CGRectMake(minSideView.bounds.origin.x + lower_distance, minSideView.bounds.origin.y, minSideView.bounds.size.width-lower_distance, content_height)
                                 byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                 cornerRadii:CGSizeMake(0, 0)
                                 ];
    UIBezierPath *leftMinmaskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(minSideView.bounds.origin.x, minSideView.bounds.origin.y, 2*lower_distance, content_height)];
    [minMaskPath appendPath:leftMinmaskPath];
    CAShapeLayer *minmaskLayer = [CAShapeLayer layer];
    minmaskLayer.path = minMaskPath.CGPath;
    minSideView.layer.mask = minmaskLayer;
    
    // set max mask image round.
    UIBezierPath *maxMaskPath = [UIBezierPath
                                 bezierPathWithRoundedRect:CGRectMake(maxSideView.bounds.origin.x, maxSideView.bounds.origin.y, maxSideView.bounds.size.width-upper_distance, content_height)
                                 byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                 cornerRadii:CGSizeMake(0, 0)
                                 ];
    UIBezierPath *rightMaxmaskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(maxSideView.bounds.origin.x + maxSideView.bounds.size.width - 2* upper_distance, maxSideView.bounds.origin.y, 2*upper_distance, content_height)];
    [maxMaskPath appendPath:rightMaxmaskPath];
    CAShapeLayer *maxMaskLayer = [CAShapeLayer layer];
    maxMaskLayer.path = maxMaskPath.CGPath;
    maxSideView.layer.mask = maxMaskLayer;
    [self layoutIfNeeded];
}


- (void)setImages:(UIImage*)min_image  :(UIImage*)max_image :(UIImage*)content_image :(UIImage*)background_image
{
    _minThumb = min_image;
    _maxThumb = max_image;
    _contentImage = content_image;
    _backgroundImage = background_image;
    imgBackgroundView.image = _backgroundImage;
    contentImageView.image = _contentImage;
    minImageView.image = _minThumb;
    maxImageView.image = _maxThumb;
}
-(void) setSliderValue:(float)lowerValue :(float)upperValue
{
    _upperValue = upperValue;
    _lowerValue = lowerValue;
    [self updateView];
}
- (void) updateView
{
    height = self.frame.size.height;
    width = self.frame.size.width;
    content_width = width-119*height/131;
    content_height = 57*height/131;
    leading_value = 60*height/131;
    top_value = 37*height/131;
    
    double lower_width = _lowerValue * content_width;
    minSideView.frame = CGRectMake(leading_value, top_value, lower_width, content_height);
    double upper_width = (1-_upperValue) * content_width;
    double upper_positionX = _upperValue*content_width;
    maxSideView.frame = CGRectMake(leading_value + upper_positionX, top_value, upper_width, content_height);
    
    imgBackgroundView.frame = CGRectMake(leading_value, top_value, content_width, content_height);    
    minImageView.frame = CGRectMake(lower_width, 0, height/2, height);
    maxImageView.frame = CGRectMake(leading_value + upper_positionX - 6*height/131, 0, height/2, height);
    contentImageView.frame = CGRectMake(lower_width+height/2, 0, upper_positionX - lower_width-11*height/131, height);
    [self layoutIfNeeded];
}

- (void) updateLeftView
{
    height = self.frame.size.height;
    width = self.frame.size.width;
    content_width = width-119*height/131;
    content_height = 57*height/131;
    leading_value = 60*height/131;
    top_value = 37*height/131;
    double min_lowerValue = _lowerValue;
    if (_lowerValue > _upperValue - height/(6*content_width)) {
        min_lowerValue = MAX(0.0, _upperValue - height/(6*content_width));
    }
    
    double lower_width = min_lowerValue * content_width;
    minSideView.frame = CGRectMake(leading_value, top_value, lower_width, content_height);
    double upper_width = (1-_upperValue) * content_width;
    double upper_positionX = _upperValue*content_width;
    maxSideView.frame = CGRectMake(leading_value + upper_positionX, top_value, upper_width, content_height);
    
    imgBackgroundView.frame = CGRectMake(leading_value, top_value, content_width, content_height);
    minImageView.frame = CGRectMake(lower_width, 0, height/2, height);
    maxImageView.frame = CGRectMake(leading_value + upper_positionX - 6*height/131, 0, height/2, height);
    contentImageView.frame = CGRectMake(lower_width+height/2, 0, upper_positionX - lower_width-11*height/131, height);
    [self layoutIfNeeded];
}

- (void) updateRightView
{
    height = self.frame.size.height;
    width = self.frame.size.width;
    content_width = width-119*height/131;
    content_height = 57*height/131;
    leading_value = 60*height/131;
    top_value = 37*height/131;
    
    double lower_width = _lowerValue * content_width;
    minSideView.frame = CGRectMake(leading_value, top_value, lower_width, content_height);
    
    double max_upverValue = _upperValue;
    if (_upperValue < _lowerValue + height/(6*content_width)) {
        max_upverValue = MIN(1.0, _lowerValue + height/(6*content_width));
    }
    
    double upper_width = (1-max_upverValue) * content_width;
    double upper_positionX = max_upverValue*content_width;
    maxSideView.frame = CGRectMake(leading_value + upper_positionX, top_value, upper_width, content_height);
    
    imgBackgroundView.frame = CGRectMake(leading_value, top_value, content_width, content_height);
    minImageView.frame = CGRectMake(lower_width, 0, height/2, height);
    maxImageView.frame = CGRectMake(leading_value + upper_positionX - 6*height/131, 0, height/2, height);
    contentImageView.frame = CGRectMake(lower_width+height/2, 0, upper_positionX - lower_width-11*height/131, height);
    [self layoutIfNeeded];
}

//touch events
-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"touched %f",touchPoint.x);
    if(CGRectContainsPoint(minImageView.frame, touchPoint)){
        contentImageView.image = contentTintImage;
        minImageView.image = minTintThumb;
        maxImageView.image = maxTintThumb;
        _minThumbOn = true;
    }else if(CGRectContainsPoint(maxImageView.frame, touchPoint)){
        contentImageView.image = contentTintImage;
        minImageView.image = minTintThumb;
        maxImageView.image = maxTintThumb;
        _maxThumbOn = true;
    }
    return YES;
}
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    imgBackgroundView.image = _backgroundImage;
    contentImageView.image = _contentImage;
    minImageView.image = _minThumb;
    maxImageView.image = _maxThumb;
    _minThumbOn = false;
    _maxThumbOn = false;
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(!_minThumbOn && !_maxThumbOn){
        return YES;
    }
    
    if(_minThumbOn){
        double positionX = touchPoint.x - 46*height/131;        
        if (positionX < 0) {
            positionX = 0;
        }
        if (positionX > content_width) {
            positionX = content_width;
        }
        //_lowerValue = MIN(positionX, content_width*_upperValue - height/6)/content_width;
        _lowerValue = MAX(0.0, MIN(positionX, content_width*_upperValue)/content_width);
        [self updateLeftView];
    }
    if(_maxThumbOn){
        double positionX = touchPoint.x - 74*height/131;
        NSLog(@"touched %f",positionX);
        if (positionX < 0) {
            positionX = 0;
        }
        if (positionX > content_width) {
            positionX = content_width;
        }
        //_upperValue = MAX(positionX, content_width*_lowerValue + height/6)/content_width;
        _upperValue = MIN(1.0, MAX(positionX, content_width*_lowerValue)/content_width) ;
        [self updateRightView];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    
    return YES;
}


@end
