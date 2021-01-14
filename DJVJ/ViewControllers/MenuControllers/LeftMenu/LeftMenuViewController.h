//
//  LeftMenuViewController.h
//  LeftSideMenuControllerDemo
//
//  Created by tomfriwel on 02/03/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalData.h"
#import "MainViewController.h"
#import "PortraitViewController.h"

@interface LeftMenuViewController : PortraitViewController

@property (strong, nonatomic) MainViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UIView *view_top;
@property (weak, nonatomic) IBOutlet UIScrollView *view_body;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline1;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline2;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline3;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline4;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline5;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline6;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline7;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline8;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline9;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline10;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline11;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline12;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline13;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline14;
@property (weak, nonatomic) IBOutlet UIImageView *img_underline15;



@property (weak, nonatomic) IBOutlet UIView *view_sub_setting;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_constraint_sub_setting;
@property (weak, nonatomic) IBOutlet UILabel *lbl_output_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_output_value;
@property (weak, nonatomic) IBOutlet UIImageView *img_outputSize;

@property (weak, nonatomic) IBOutlet UILabel *lbl_audioInput_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_audioInput_value;
@property (weak, nonatomic) IBOutlet UIImageView *img_audioInput;

@property (weak, nonatomic) IBOutlet UILabel *lbl_outputResize_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_outputResize_value;
@property (weak, nonatomic) IBOutlet UIImageView *img_outputResize;

@property (weak, nonatomic) IBOutlet UILabel *lbl_outputRate_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_outputRate_value;
@property (weak, nonatomic) IBOutlet UIImageView *img_outputRate;


@property (weak, nonatomic) IBOutlet UIView *view_sub_support;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_constraint_sub_support;
@property (weak, nonatomic) IBOutlet UILabel *lbl_email;
@property (weak, nonatomic) IBOutlet UILabel *lbl_faq;
@property (weak, nonatomic) IBOutlet UILabel *lbl_credit;


@property (weak, nonatomic) IBOutlet UIImageView *img_dayMode;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dayMode;


@property (weak, nonatomic) IBOutlet UIView *view_select;

@property (weak, nonatomic) IBOutlet UITableView *tbl_outputSize;
@property (weak, nonatomic) IBOutlet UITableView *tbl_inputAudio;
@property (weak, nonatomic) IBOutlet UITableView *tbl_outputResize;
@property (weak, nonatomic) IBOutlet UITableView *tbl_outputRate;

@property (weak, nonatomic) IBOutlet UIView *view_sub_upgrades;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_constraint_sub_upgrades;
@property (weak, nonatomic) IBOutlet UILabel *lbl_extend_output;
@property (weak, nonatomic) IBOutlet UILabel *lbl_no_watermark;
@property (weak, nonatomic) IBOutlet UILabel *lbl_no_watermark_output;





- (IBAction)btn_setting_clicked:(id)sender;

- (IBAction)action_select_output:(id)sender;
- (IBAction)action_select_audio_input_type:(id)sender;
- (IBAction)action_select_outputResize:(id)sender;
- (IBAction)action_select_outputRate:(id)sender;


- (IBAction)action_support:(id)sender;
- (IBAction)action_email:(id)sender;
- (IBAction)action_fac:(id)sender;
- (IBAction)action_credit:(id)sender;



- (IBAction)action_go_videoShop:(id)sender;
- (IBAction)action_go_imageShop:(id)sender;

- (IBAction)action_upgrade:(id)sender;
- (IBAction)action_extend_output:(id)sender;
- (IBAction)action_no_watermark:(id)sender;

- (IBAction)action_change_dayMode:(id)sender;

@end
