//
//  OneSlider.h
//  Horizontal Slider
//
//  Created by Bin on 2018/12/9.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OneSlider : UIControl
@property (nonatomic) float value;
@property (nonatomic) UIImage* basicImage;
@property (nonatomic) UIImage* tintImage;
@property (nonatomic) UIImage* trackImage;
@property (nonatomic) UIImageView *trackImageView;
@property (nonatomic) UIImageView *contentImageView;


- (instancetype)initWithCoder:(NSCoder *)aDecoder;

-(void) setImage:(UIImage*)basicImage  :(UIImage*)tintImage;
-(void)setSliderTrackImage:(UIImage*)trackImage;
-(void) setSliderValue:(float)init_value;
- (void) updateView;

@end

NS_ASSUME_NONNULL_END
