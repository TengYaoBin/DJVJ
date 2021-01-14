//
//  HeightSlider.m
//  Horizontal Slider
//
//  Created by Bin on 2018/12/9.
//  Copybottom © 2018 Bin. All bottoms reserved.
//

#import "HeightSlider.h"

@implementation HeightSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleToFill;
        self.value = 0.0;        
        self.topImageView = [[UIImageView alloc] init];
        self.contentImageView = [[UIImageView alloc] init];
        self.bottomImageView = [[UIImageView alloc] init];
        self.trackImageView = [[UIImageView alloc] init];
        [self addSubview:self.trackImageView];
        [self addSubview:self.topImageView];
        [self addSubview:self.contentImageView];
        [self addSubview:self.bottomImageView];
        [self updateView];
    }
    return self;
}
-(void)setSliderImage:(UIImage*)topImage :(UIImage*)bottomImage :(UIImage*)contentImage :(UIImage*)topTintImage :(UIImage*)bottomTintImage :(UIImage*)contentTintImage
{
    self.topImage = topImage;
    self.bottomImage= bottomImage;
    self.contentImage = contentImage;
    self.topTintImage = topTintImage;
    self.bottomTintImage = bottomTintImage;
    self.contentTintImage = contentTintImage;
    self.topImageView.image = self.topImage;
    self.contentImageView.image = self.contentImage;
    self.bottomImageView.image = self.bottomImage;
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
    double content_height = height - 2*width/3;
    double background_width = width/22.0;
    
    self.trackImageView.frame = CGRectMake((width-background_width)/2, width/6, background_width, content_height);
    
    double distance = self.value * content_height;
    self.topImageView.frame = CGRectMake(width/6, content_height-distance, 2*width/3, width/3);
    self.contentImageView.frame = CGRectMake(width/6, content_height-distance+width/3, 2*width/3, distance);
    self.bottomImageView.frame = CGRectMake(width/6, width/3 + content_height, 2*width/3, width/3);
    [self layoutIfNeeded];
}


-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_height = height - 2*width/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, height - touchPoint.y - width/3), content_height);
    self.value = distance/content_height;
    self.topImageView.image = self.topTintImage;
    self.contentImageView.image = self.contentTintImage;
    self.bottomImageView.image = self.bottomTintImage;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.topImageView.image = self.topImage;
    self.contentImageView.image = self.contentImage;
    self.bottomImageView.image = self.bottomImage;
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double content_height = height - 2*width/3;
    CGPoint touchPoint = [touch locationInView:self];
    double distance = MIN(MAX(0, height - touchPoint.y - width/3), content_height);
    self.value = distance/content_height;
    self.topImageView.image = self.topTintImage;
    self.contentImageView.image = self.contentTintImage;
    self.bottomImageView.image = self.bottomTintImage;
    [self updateView];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}


@end
