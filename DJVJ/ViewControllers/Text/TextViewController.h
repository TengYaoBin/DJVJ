//
//  TextViewController.h
//  DJVJ
//
//  Created by Bin on 2018/12/19.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "BYColorWheel.h"
#import "BYGradientSlider.h"
NS_ASSUME_NONNULL_BEGIN

@interface TextViewController : UIViewController
@property (nonatomic,strong) MainViewController *root_viewController;
@property double font_size;
@property (nonatomic, strong) NSString *textString;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UIColor *fontColor;


@property (weak, nonatomic) IBOutlet UIView *view_containner;
@property (weak, nonatomic) IBOutlet UILabel *lbl_createText;
@property (weak, nonatomic) IBOutlet UIImageView *img_ok;
@property (weak, nonatomic) IBOutlet UIButton *btn_ok;

@property (weak, nonatomic) IBOutlet UIView *view_imgBackground;
@property (weak, nonatomic) IBOutlet UIView *view_imgContent;

@property (weak, nonatomic) IBOutlet UILabel *lbl_size;
@property (weak, nonatomic) IBOutlet HeightSlider *slider_size;
@property (weak, nonatomic) IBOutlet UIView *view_slider;

@property (weak, nonatomic) IBOutlet UILabel *lbl_text;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)textSize_valueChanged:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *view_font;

@property (weak, nonatomic) IBOutlet UILabel *lbl_editText;
- (IBAction)onclick_editText:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lbl_titleFontFamily;

@property (weak, nonatomic) IBOutlet UIImageView *img_fontFamily;
@property (weak, nonatomic) IBOutlet UIImageView *img_upIcon;
@property (weak, nonatomic) IBOutlet UIImageView *img_downIcon;

@property (weak, nonatomic) IBOutlet UILabel *lbl_fontFamily;
- (IBAction)onclick_selectFontFamily:(id)sender;



@property (weak, nonatomic) IBOutlet UIView *view_color;
@property (nonatomic, weak) IBOutlet BYColorWheel *colorWheel;

@property (weak, nonatomic) IBOutlet UILabel *lbl_saturation;
@property (nonatomic, weak) IBOutlet BYGradientSlider *saturationSlider;

@property (weak, nonatomic) IBOutlet UILabel *lbl_brightness;
@property (nonatomic, weak) IBOutlet BYGradientSlider *brightnessSlider;



@property (weak, nonatomic) IBOutlet UIView *view_keyboard;
@property (weak, nonatomic) IBOutlet UIImageView *img_keyboardOk;
@property (weak, nonatomic) IBOutlet UIButton *btn_keyboardOk;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_keyboardBottom;


- (IBAction)onclick_finish:(id)sender;
- (IBAction)onclick_setText:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tbl_fontList;
@property (weak, nonatomic) IBOutlet UIView *view_selectFont;
@property (weak, nonatomic) IBOutlet UIView *content_tableView;



@end

NS_ASSUME_NONNULL_END
