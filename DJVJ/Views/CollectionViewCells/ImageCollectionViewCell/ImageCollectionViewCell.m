//
//  ImageCollectionViewCell.m
//  DJVJ
//
//  Created by Bin on 2019/2/7.
//  Copyright © 2019 Bin. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>

@implementation ImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.img_view.layer.masksToBounds = YES;
    self.img_view.layer.cornerRadius = 10;
    
    self.img_highlighted.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:149/255.0 blue:251.0/255.0 alpha:1.0].CGColor;
    self.img_highlighted.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.img_highlighted.layer.shadowRadius = 10.0;
    self.img_highlighted.layer.shadowOpacity = 1.0;
    self.img_highlighted.layer.masksToBounds = NO;
}
@end
