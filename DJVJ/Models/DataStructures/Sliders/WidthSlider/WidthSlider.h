//
//  HSlider.h
//  Horizontal Slider
//
//  Created by Bin on 2018/12/8.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface WidthSlider : UIControl
@property (nonatomic) float value;
@property (nonatomic) UIImage* leftImage;
@property (nonatomic) UIImage* contentImage;
@property (nonatomic) UIImage* rightImage;

@property (nonatomic) UIImage* leftTintImage;
@property (nonatomic) UIImage* contentTintImage;
@property (nonatomic) UIImage* rightTintImage;

@property (nonatomic) UIImage* trackImage;

@property (nonatomic) UIImageView *trackImageView;
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) UIImageView *contentImageView;
@property (nonatomic) UIImageView *rightImageView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

-(void)setSliderImage:(UIImage*)leftImage :(UIImage*)rightImage :(UIImage*)contentImage :(UIImage*)leftTintImage :(UIImage*)rightTintImage :(UIImage*)contentTintImage;
-(void)setSliderTrackImage:(UIImage*)trackImage;
-(void) setSliderValue:(float)init_value;
- (void) updateView;
@end

NS_ASSUME_NONNULL_END
