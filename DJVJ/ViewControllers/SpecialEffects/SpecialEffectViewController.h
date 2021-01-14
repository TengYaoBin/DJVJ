//
//  SpecialEffectViewController.h
//  DJVJ
//
//  Created by Bin on 2019/1/4.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "BRScrollBarController.h"
NS_ASSUME_NONNULL_BEGIN

@interface SpecialEffectViewController : UIViewController<BRScrollBarControllerDelegate>
@property (nonatomic, readonly, strong) BRScrollBarController *brScrollBarController;
@property (nonatomic,strong) MainViewController *root_viewController;


@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (weak, nonatomic) IBOutlet UIImageView *img_ok;
@property (weak, nonatomic) IBOutlet UIButton *btn_ok;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effectsTitle;
@property (weak, nonatomic) IBOutlet UIView *view_preview;
@property (weak, nonatomic) IBOutlet UIView *view_preview_content;
@property (weak, nonatomic) IBOutlet UIImageView *img_preview;

@property (weak, nonatomic) IBOutlet UIView *view_effects_container;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview_effects;
@property (weak, nonatomic) IBOutlet UIView *view_effects;




@property (weak, nonatomic) IBOutlet UIView *container_current_effects;
@property (weak, nonatomic) IBOutlet UIView *view_effect1;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect1;
@property (weak, nonatomic) IBOutlet UILabel *lbl_1;

@property (weak, nonatomic) IBOutlet UIView *view_effect2;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect2;
@property (weak, nonatomic) IBOutlet UILabel *lbl_2;

@property (weak, nonatomic) IBOutlet UIView *view_effect3;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect3;
@property (weak, nonatomic) IBOutlet UILabel *lbl_3;

@property (weak, nonatomic) IBOutlet UIView *view_effect4;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect4;
@property (weak, nonatomic) IBOutlet UILabel *lbl_4;

@property (weak, nonatomic) IBOutlet UIView *view_effect5;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect5;
@property (weak, nonatomic) IBOutlet UILabel *lbl_5;

@property (weak, nonatomic) IBOutlet UIView *view_effect6;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect6;
@property (weak, nonatomic) IBOutlet UILabel *lbl_6;

@property (weak, nonatomic) IBOutlet UIView *view_effect7;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effect7;
@property (weak, nonatomic) IBOutlet UILabel *lbl_7;


@property (weak, nonatomic) IBOutlet UIButton *btn_effect1;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect2;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect3;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect4;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect5;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect6;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect7;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect8;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect9;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect10;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect11;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect12;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect13;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect14;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect15;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect16;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect17;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect18;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect19;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect20;

@property (weak, nonatomic) IBOutlet UIImageView *img_effect1;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect2;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect3;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect4;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect5;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect6;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect7;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect8;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect9;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect10;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect11;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect12;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect13;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect14;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect15;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect16;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect17;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect18;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect19;
@property (weak, nonatomic) IBOutlet UIImageView *img_effect20;



@property (weak, nonatomic) IBOutlet UIButton *btn_holding;


@end

NS_ASSUME_NONNULL_END
