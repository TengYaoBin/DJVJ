//
//  VideoPackage.h
//  DJVJ
//
//  Created by Bin on 2019/1/16.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPackage : NSObject
@property NSString *package_id;
@property NSString *productID;
@property NSString *name;
@property NSString *price;
@property NSString *width;
@property NSString *height;
@property NSMutableArray *videoList;
@property Boolean extend_state;
@end

NS_ASSUME_NONNULL_END
