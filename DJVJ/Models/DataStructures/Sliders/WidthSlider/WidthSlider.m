//
//  HSlider.m
//  Horizontal Slider
//
//  Created by Bin on 2018/12/8.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "WidthSlider.h"
@implementation WidthSlider
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleToFill;
        self.value = 0.0;
        self.leftImageView = [[UIImageView alloc] init];
        self.contentImageView = [[UIImageView alloc] init];
        self.rightImageView = [[UIImageView alloc] init];
        self.trackImageView = [[UIImageView alloc] init];
        [self addSubview:self.trackImageView];
        [self addSubview:self.leftImageView];
        [self addSubview:self.contentImageView];
        [self addSubview:self.rightImageView];
        [self updateView];       
    }
    return self;
}


-(void)setSliderImage:(UIImage*)leftImage :(UIImage*)rightImage :(UIImage*)contentImage :(UIImage*)leftTintImage :(UIImage*)rightTintImage :(UIImage*)contentTintImage
{
    self.leftImage = leftImage;
    self.rightImage= rightImage;
    self.contentImage = contentImage;
    self.leftTintImage = leftTintImage;
    self.rightTintImage = rightTintImage;
    self.contentTintImage = contentTintImage;
    self.leftImageView.image = self.leftImage;
    self.contentImageView.image = self.contentImage;
    self.rightImageView.image = self.rightImage;
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
    double content_width = width - 2*height/3;
    double background_height = height/22.0;
    
    self.trackImageView.frame = CGRectMake(height/6, (height-background_height)/2, width-height/3, background_height);
    
    double distance = self.value * content_width;
    self.leftImageView.frame = CGRectMake(0, height/6, height/3, 2*height/3);
    self.contentImageView.frame = CGRectMake(height/3, height/6, distance, 2*height/3);
    self.rightImageView.frame = CGRectMake(height/3 + distance, height/6, height/3, 2*height/3);
    [self layoutIfNeeded];
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_width = width - 2*height/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, touchPoint.x - height/3), content_width);
    self.value = distance/content_width;
    self.leftImageView.image = self.leftTintImage;
    self.contentImageView.image = self.contentTintImage;
    self.rightImageView.image = self.rightTintImage;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.leftImageView.image = self.leftImage;
    self.contentImageView.image = self.contentImage;
    self.rightImageView.image = self.rightImage;
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_width = width - 2*height/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, touchPoint.x - height/3), content_width);
    self.value = distance/content_width;
    self.leftImageView.image = self.leftTintImage;
    self.contentImageView.image = self.contentTintImage;
    self.rightImageView.image = self.rightTintImage;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

@end
