//
//  BlackAndWhiteThresholdFilter.h
//  Test
//
//  Created by Bin on 2018/12/22.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface BlackAndWhiteThresholdFilter : CIFilter
+ (void)registerFilter;
+ (NSDictionary *)customAttributes;
@end

NS_ASSUME_NONNULL_END
