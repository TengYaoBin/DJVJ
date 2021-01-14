//
//  LayerTableViewCell.h
//  DJVJ
//
//  Created by Bin on 2018/12/23.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LayerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_layerName;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;

@end

NS_ASSUME_NONNULL_END
