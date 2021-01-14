//
//  BYGradientSlider.m
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 26/12/2016.
//  Copyright © 2016 Berk Yuksel. All rights reserved.
//

#import "BYGradientSlider.h"

#pragma mark - Private Interface

@interface BYGradientSlider (){
    CAGradientLayer *_gradientLayer;
}

@end

@implementation BYGradientSlider

#pragma mark - Initilization Methods

- (id)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super initWithCoder:aDecoder]) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = CGRectZero;
        UIColor *startColor = [UIColor whiteColor];
        UIColor *endColor = [UIColor blackColor];
        _gradientLayer.colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
        _gradientLayer.cornerRadius = self.frame.size.height/2;
        _gradientLayer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6].CGColor;
        _gradientLayer.shadowOffset = CGSizeMake(0, 1.0f);
        _gradientLayer.shadowRadius = 2.0f;
        _gradientLayer.shadowOpacity = 0.6f;
        [_gradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
        [_gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
        
        [self.layer insertSublayer:_gradientLayer atIndex:1];
        [self setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
        [self setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];

    }
    return self;
}

#pragma mark - Public Methods

- (void)updateGradientLayerWithStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor{

    [_gradientLayer setColors:[NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil]];
    [self setNeedsDisplay];
}

#pragma  mark - Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _gradientLayer.frame = rect;
}


@end
