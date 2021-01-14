//
//  SelectImageViewController.h
//  DJVJ
//
//  Created by Bin on 2018/12/19.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeightSlider.h"
#import "MainViewController.h"
#import "BRScrollBarController.h"
#import "ImagePackage.h"
#import "ImageItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectImageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BRScrollBarControllerDelegate>

@property (nonatomic, readonly, strong) BRScrollBarController *brScrollBarController;
@property (nonatomic,strong) MainViewController *root_viewController;
@property (nonatomic,strong) UIImage *selected_image;
@property (nonatomic,strong) ImagePackage *selectedPackage;
@property (nonatomic,strong) ImageItem *selectedImage;

@property double image_size;
@property (weak, nonatomic) IBOutlet UIView *view_containner;
@property (weak, nonatomic) IBOutlet UILabel *lbl_selectImage;
@property (weak, nonatomic) IBOutlet UIImageView *img_ok;

@property (weak, nonatomic) IBOutlet UIButton *btn_ok;

@property (weak, nonatomic) IBOutlet UIView *view_imgBackground;
@property (weak, nonatomic) IBOutlet UIView *view_imgContent;
@property (weak, nonatomic) IBOutlet UIImageView *img_content;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_img_content_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_img_content_height;
@property (weak, nonatomic) IBOutlet HeightSlider *slider_size;
@property (weak, nonatomic) IBOutlet UIView *view_slider;
@property (weak, nonatomic) IBOutlet UITableView *tbl_packageList;
@property (weak, nonatomic) IBOutlet UILabel *lbl_size;

@property (weak, nonatomic) IBOutlet UIImageView *img_buy_background;
@property (weak, nonatomic) IBOutlet UIButton *btn_buy;
@property (weak, nonatomic) IBOutlet UIImageView *img_import_background;
@property (weak, nonatomic) IBOutlet UIButton *btn_import;



- (void)setSelectImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
