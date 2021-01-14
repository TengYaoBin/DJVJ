//
//  EditVideoViewController.h
//  DJVJ
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "CERangeSlide.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "BRScrollBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditVideoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BRScrollBarControllerDelegate>
@property (nonatomic, readonly, strong) BRScrollBarController *brScrollBarController;


@property NSMutableArray *frame_list;
@property NSString *videoID;
@property int video_type;//0:basic, 1: overlay
@property MainViewController *root_viewController;

@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (weak, nonatomic) IBOutlet UILabel *lbl_edit;
@property (weak, nonatomic) IBOutlet UIButton *btn_ok;
@property (weak, nonatomic) IBOutlet UIImageView *img_ok_background;


@property (weak, nonatomic) IBOutlet UIView *view_preview;
@property (weak, nonatomic) IBOutlet UIImageView *img_preview;

@property (weak, nonatomic) IBOutlet UIView *view_crop;
@property (weak, nonatomic) IBOutlet CERangeSlide *slider_crop;

@property (weak, nonatomic) IBOutlet UIImageView *img_cancel_background;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;

@property (weak, nonatomic) IBOutlet UIImageView *img_play_background;
@property (weak, nonatomic) IBOutlet UIImageView *img_play;


@property (weak, nonatomic) IBOutlet UIImageView *img_save_background;
@property (weak, nonatomic) IBOutlet UIButton *btn_save;

@property (weak, nonatomic) IBOutlet UITableView *tbl_croplist;



- (IBAction)action_ok_clicked:(id)sender;
- (IBAction)action_crop_valueChanged:(id)sender;
- (IBAction)action_cancel_clicked:(id)sender;
- (IBAction)action_play_clicked:(id)sender;
- (IBAction)action_save_clicked:(id)sender;






@end

NS_ASSUME_NONNULL_END
