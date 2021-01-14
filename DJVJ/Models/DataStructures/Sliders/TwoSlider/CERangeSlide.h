//
//  CERangeSlide.h
//  TwoSlider
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CERangeSlide : UIControl
    @property (nonatomic) float maximumValue;
    @property (nonatomic) float minimumValue;
    @property (nonatomic) float upperValue;
    @property (nonatomic) float lowerValue;

    @property (nonatomic) UIImage *minThumb;
    @property (nonatomic) UIImage *maxThumb;
    @property (nonatomic) UIImage *contentImage;
    @property (nonatomic) UIImage *backgroundImage;
    @property (nonatomic) BOOL maxThumbOn;
    @property (nonatomic) BOOL minThumbOn;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)setImages:(UIImage*)min_image  :(UIImage*)max_image :(UIImage*)content_image :(UIImage*)background_image;
-(void) setSliderValue:(float)lowerValue :(float)upperValue;
- (void) updateView;
-(void)setBackgroundRound;
@end

NS_ASSUME_NONNULL_END
