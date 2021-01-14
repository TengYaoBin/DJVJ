//
//  UIView+SDExtension.h
//  DJVJ
//
//  Created by Bin on 2018/11/30.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SDExtension)

- (void) removeAllSubViews;

//set left corner ladius
- (void) roundLeftCorner:(double)radius;

//set right corner ladius
- (void) roundRightCorner:(double)radius;

@end

NS_ASSUME_NONNULL_END
