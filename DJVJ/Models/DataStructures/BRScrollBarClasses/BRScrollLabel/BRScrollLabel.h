//
//  BRScrollLabel.h
//  BRScrollBarDemo

#import <UIKit/UIKit.h>
#import "BRCommonMethods.h"

@interface BRScrollLabel : UIView

@property (nonatomic, copy)   NSString *text;
@property (nonatomic, assign) CGFloat labelWidth;

- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)resetText;
- (void)showLabel;
- (void)hideLabel;
@end
