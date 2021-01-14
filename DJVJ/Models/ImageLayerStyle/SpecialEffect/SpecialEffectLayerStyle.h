//
//  SpecialEffectLayerStyle.h
//  DJVJ
//
//  Created by Bin on 2019/1/5.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SpecialEffectLayerStyle : NSObject
+(UIImage *)whiteStrobe:(UIImage*)originImage :(int)frame_num;
+(UIImage *)blackStrobe:(UIImage*)originImage :(int)frame_num;
+(UIImage *)fadeToWhite:(UIImage*)originImage :(int)frame_num;
+(UIImage *)fadeToBlack:(UIImage*)originImage :(int)frame_num;
+(UIImage *)gaussianBlur:(UIImage*)originImage;
+(UIImage *)zoom:(UIImage*)originImage;
+(UIImage *)posterize:(UIImage*)originImage;
+(UIImage *)solarize:(UIImage*)originImage;
+(UIImage *)pixellate:(UIImage*)originImage;
+(UIImage *)superpixellate:(UIImage*)originImage;
+(UIImage *)caleidoTL:(UIImage*)originImage;
+(UIImage *)caleidoTR:(UIImage*)originImage;
+(UIImage *)caleidoBL:(UIImage*)originImage;
+(UIImage *)caleidoBR:(UIImage*)originImage;
+(UIImage *)times4:(UIImage*)originImage;
+(UIImage *)times9:(UIImage*)originImage;
+(UIImage *)warhol:(UIImage*)originImage;
+(UIImage *)threshold:(UIImage*)originImage;
+(UIImage *)oldTimes:(UIImage*)originImage;
@end

NS_ASSUME_NONNULL_END
