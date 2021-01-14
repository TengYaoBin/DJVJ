//
//  BYColorWheel.h
//  BYColorPickerViewControllerExample
//
//  Created by Berk Yuksel on 26/12/2016.
//  Copyright © 2016 Berk Yuksel. All rights reserved.
//

#import <UIKit/UIKit.h>

//Color wheel delegation
@protocol BYColorWheelDelegate <NSObject>

- (void)setHueFromColorWheel:(float)hue;

@end

@interface BYColorWheel : UIView
@property (nonatomic, weak) IBOutlet id<BYColorWheelDelegate> delegate;
- (void)prepare;
- (void)placeCrosshairByHue:(float)hue;
@end
