//
//  CropTableViewCell.h
//  DJVJ
//
//  Created by Bin on 2018/12/10.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CERangeSlide.h"

NS_ASSUME_NONNULL_BEGIN

@interface CropTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet CERangeSlide *slider_range;

@property (weak, nonatomic) IBOutlet UIView *view_edit;
@property (weak, nonatomic) IBOutlet UIImageView *img_edit;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;

@property (weak, nonatomic) IBOutlet UIView *view_delete;
@property (weak, nonatomic) IBOutlet UIImageView *img_delete;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete;


@end

NS_ASSUME_NONNULL_END
