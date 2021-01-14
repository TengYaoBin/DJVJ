//
//  HeightSlider.h
//  Horizontal Slider
//
//  Created by Bin on 2018/12/9.
//  Copybottom © 2018 Bin. All bottoms reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeightSlider : UIControl
@property (nonatomic) float value;
@property (nonatomic) UIImage* topImage;
@property (nonatomic) UIImage* contentImage;
@property (nonatomic) UIImage* bottomImage;

@property (nonatomic) UIImage* topTintImage;
@property (nonatomic) UIImage* contentTintImage;
@property (nonatomic) UIImage* bottomTintImage;

@property (nonatomic) UIImage* trackImage;

@property (nonatomic) UIImageView *trackImageView;
@property (nonatomic) UIImageView *topImageView;
@property (nonatomic) UIImageView *contentImageView;
@property (nonatomic) UIImageView *bottomImageView;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

-(void)setSliderImage:(UIImage*)topImage :(UIImage*)bottomImage :(UIImage*)contentImage :(UIImage*)topTintImage :(UIImage*)bottomTintImage :(UIImage*)contentTintImage;
-(void)setSliderTrackImage:(UIImage*)trackImage;

-(void) setSliderValue:(float)init_value;
- (void) updateView;
@end

NS_ASSUME_NONNULL_END
