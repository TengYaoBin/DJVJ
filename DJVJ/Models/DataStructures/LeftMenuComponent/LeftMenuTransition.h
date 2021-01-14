//
//  LeftMenuTransition.h
//  LeftSideMenuControllerDemo

#import <UIKit/UIKit.h>

@interface LeftMenuTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPercentDriven;
@property (nonatomic, assign) BOOL isPresent;   // is present or dismiss

-(instancetype)initWithIsPresent:(BOOL)isPresent;

@end
