//
//  FontNameTableViewCell.h
//  DJVJ
//
//  Created by Bin on 2018/12/20.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FontNameTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_fontName;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;

@end

NS_ASSUME_NONNULL_END
