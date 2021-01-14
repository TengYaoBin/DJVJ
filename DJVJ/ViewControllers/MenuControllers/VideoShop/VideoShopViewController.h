//
//  VideoShopViewController.h
//  DJVJ
//
//  Created by Bin on 2018/11/28.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRScrollBarController.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoShopViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BRScrollBarControllerDelegate>

@property (nonatomic, readonly, strong) BRScrollBarController *brScrollBarController;
@property (weak, nonatomic) IBOutlet UIView *view_container;
@property (weak, nonatomic) IBOutlet UIView *view_close;
@property (weak, nonatomic) IBOutlet UILabel *lbl_videoShop;
@property (weak, nonatomic) IBOutlet UIImageView *img_close_background;

@property (weak, nonatomic) IBOutlet UIImageView *img_closeIcon;
@property (weak, nonatomic) IBOutlet UITableView *tbl_PackageList;
@property (weak, nonatomic) IBOutlet UILabel *lbl_message;
- (IBAction)action_close:(id)sender;
@end

NS_ASSUME_NONNULL_END
