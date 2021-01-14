//
//  BYGradientSlider.h
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 26/12/2016.
//  Copyright © 2016 Berk Yuksel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYGradientSlider : UISlider
- (void)updateGradientLayerWithStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor;
@end
