//
//  VideoCollectionViewCell.h
//  CollectionViewInTableView
//
//  Created by Bin on 2019/1/8.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *view_container;
@property (weak, nonatomic) IBOutlet UIImageView *img_view;
@property (weak, nonatomic) IBOutlet UIImageView *img_highlighted;
@property (weak, nonatomic) IBOutlet UIButton *btn_item;

@end

NS_ASSUME_NONNULL_END
