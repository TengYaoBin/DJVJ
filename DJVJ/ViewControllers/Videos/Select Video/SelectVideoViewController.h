//
//  SelectVideoViewController.h
//  DJVJ
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"
#import "BRScrollBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectVideoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BRScrollBarControllerDelegate>

@property (nonatomic, readonly, strong) BRScrollBarController *brScrollBarController;

@property int outputWidth;
@property int outputHeight;
@property int video_type;//0:basic video, 1: overlay video
@property (nonatomic,strong) MainViewController *root_viewController;

@property (weak, nonatomic) IBOutlet UIView *view_container;
@property (weak, nonatomic) IBOutlet UIView *view_close;
@property (weak, nonatomic) IBOutlet UILabel *lbl_selectVideo;
@property (weak, nonatomic) IBOutlet UIImageView *img_close_background;

@property (weak, nonatomic) IBOutlet UIImageView *img_closeIcon;

@property (weak, nonatomic) IBOutlet UIView *view_loading;
@property (weak, nonatomic) IBOutlet UIView *content_loading;
@property (weak, nonatomic) IBOutlet UILabel *lbl_loadingResult;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator_loading;

@property (weak, nonatomic) IBOutlet UITableView *tbl_PackageList;
- (void)selectVideo:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIImageView *img_buy_background;
@property (weak, nonatomic) IBOutlet UIButton *btn_buy;
@property (weak, nonatomic) IBOutlet UIImageView *img_import_background;

@property (weak, nonatomic) IBOutlet UIButton *btn_import;
- (IBAction)action_buy_clicked:(id)sender;
- (IBAction)action_import_clicked:(id)sender;
- (IBAction)action_close:(id)sender;

@end

NS_ASSUME_NONNULL_END
