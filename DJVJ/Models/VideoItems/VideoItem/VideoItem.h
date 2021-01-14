//
//  VideoItem.h
//  DJVJ
//
//  Created by Bin on 2019/1/16.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoItem : NSObject
@property NSString *video_id;
@property NSString *video_url;
@property NSString *package_id;
@property NSString *thumb_url;
@end

NS_ASSUME_NONNULL_END
