//
//  CropTableViewCell.m
//  DJVJ
//
//  Created by Bin on 2018/12/10.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "CropTableViewCell.h"

@implementation CropTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.view_content.layer.cornerRadius = 5.0;
    self.view_content.clipsToBounds = true;    
    [self.slider_range updateView];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewDidLayoutSubviews
{
    //call function when device orientation is changed.
    [self.slider_range updateView];
}


@end
