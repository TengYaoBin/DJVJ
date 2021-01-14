//
//  InputTableViewCell.h
//  DJVJ
//
//  Created by Bin on 2019/1/17.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_type;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;

@end

NS_ASSUME_NONNULL_END
