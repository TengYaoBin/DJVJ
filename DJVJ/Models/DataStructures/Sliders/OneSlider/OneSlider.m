//
//  OneSlider.m
//  Horizontal Slider
//
//  Created by Bin on 2018/12/9.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "OneSlider.h"

@implementation OneSlider
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleToFill;
        self.value = 0.0;
        self.contentImageView = [[UIImageView alloc] init];
        self.trackImageView = [[UIImageView alloc] init];
        [self addSubview:self.trackImageView];
        [self addSubview:self.contentImageView];
        [self updateView];
    }
    return self;
}


-(void) setImage:(UIImage*)basicImage  :(UIImage*)tintImage
{
    self.basicImage = basicImage;
    self.tintImage = tintImage;
    self.contentImageView.image = self.basicImage;
}
-(void)setSliderTrackImage:(UIImage*)trackImage
{
    self.trackImage = trackImage;
    self.trackImageView.image = self.trackImage;
}
-(void) setSliderValue:(float)init_value
{
    self.value = init_value;
    [self updateView];
}
- (void) updateView
{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double background_height = height/22.0;
    double content_width = width - 2*height/3;
    self.trackImageView.frame = CGRectMake(height/6, (height-background_height)/2, width-height/3, background_height);
    double distance = self.value * content_width;
    self.contentImageView.frame = CGRectMake(distance, height/6, 2*height/3, 2*height/3);
    [self layoutIfNeeded];
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.contentImageView.image = self.tintImage;
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_width = width - 2*height/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, touchPoint.x - height/3), content_width);
    self.value = distance/content_width;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.contentImageView.image = self.basicImage;
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.contentImageView.image = self.tintImage;
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_width = width - 2*height/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, touchPoint.x - height/3), content_width);
    self.value = distance/content_width;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}


@end
