//
//  ImagePackage.h
//  DJVJ
//
//  Created by Bin on 2019/2/6.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagePackage : NSObject
@property NSString *package_id;
@property NSString *productID;
@property NSString *name;
@property NSString *price;
@property NSMutableArray *imageList;
@property Boolean extend_state;
@end

NS_ASSUME_NONNULL_END
