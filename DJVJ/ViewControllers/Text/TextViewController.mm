//
//  TextViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/19.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "TextViewController.h"
#import "MainViewController.h"
#import "FontNameTableViewCell.h"
#import "AppDelegate.h"
#import "GlobalData.h"

@interface TextViewController ()<BYColorWheelDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CGFloat hue_value;
    CGFloat brightness;
    CGFloat saturation;
    CGFloat alpha;
    double MaxFontSize;
    NSMutableArray *fontname_list;
}
@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view_keyboard setHidden:YES];
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    
    //set fontname list array
    fontname_list = [[NSMutableArray alloc] initWithObjects:
                     @"AbrilFatface-Regular",
                     @"AmaticSC-Bold",
                     @"AmaticSC-Regular",
                     @"Audiowide-Regular",
                     @"CabinSketch-Regular",
                     @"CabinSketch-Bold",
                     @"Chunkfive",
                     @"FascinateInline-Regular",
                     @"Monoton-Regular",
                     @"PressStart2P-Regular",
                     @"Raleway-Thin",
                     @"Raleway-ThinItalic",
                     @"Raleway-ExtraLight",
                     @"Raleway-ExtraLightItalic",
                     @"Raleway-Light",
                     @"Raleway-LightItalic",
                     @"Raleway-Regular",
                     @"Raleway-Italic",
                     @"Raleway-Medium",
                     @"Raleway-MediumItalic",
                     @"Raleway-SemiBold",
                     @"Raleway-SemiBoldItalic",
                     @"Raleway-Bold",
                     @"Raleway-BoldItalic",
                     @"Raleway-ExtraBold",
                     @"Raleway-ExtraBoldItalic",
                     @"Raleway-Black",
                     @"Raleway-BlackItalic",
                     @"Shadows Into Light",
                     @"Posterama2001W04-Thin",
                     @"Posterama2001W04-Light",
                     @"Posterama2001W04-Regular",
                     @"Posterama2001W04-SemiBold",
                     @"Posterama2001W04-Bold",
                     @"Posterama2001W04-Black",
                     @"Posterama2001W04-UltraBlack", nil];
    
    
    self.tbl_fontList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tbl_fontList reloadData];
    MaxFontSize = 20.0;
    
    self.view_containner.layer.cornerRadius = 5.0;
    self.view_containner.clipsToBounds = YES;
    self.view_imgBackground.layer.cornerRadius = 5.0;
    self.view_imgBackground.clipsToBounds = YES;
    self.view_imgContent.layer.cornerRadius = 8.0;
    self.view_imgContent.clipsToBounds = YES;
    
    self.view_font.layer.cornerRadius = 5.0;
    self.view_font.clipsToBounds = YES;
    
    self.view_color.layer.cornerRadius = 5.0;
    self.view_color.clipsToBounds = YES;
    
    self.content_tableView.layer.cornerRadius = 6.0;
    self.content_tableView.clipsToBounds = YES;
    self.content_tableView.layer.borderColor = [UIColor colorWithRed:0.0 green:149.0/255.0 blue:1.0 alpha:1.0].CGColor;
    self.content_tableView.layer.borderWidth = 2;
    
    [self.view_selectFont setHidden:YES];
    
    
    //initialize color picker value
    BOOL success = [self.fontColor getHue:&hue_value saturation:&saturation brightness:&brightness alpha:&alpha];
    
    [self.saturationSlider setThumbImage:[self getCircleImage:2*self.saturationSlider.frame.size.height/3.0] forState:UIControlStateNormal];
    
    [self.brightnessSlider setThumbImage:[self getCircleImage:2*self.brightnessSlider.frame.size.height/3.0] forState:UIControlStateNormal];
    
    //Place crosshair position of colorWheel object.
    [self.colorWheel placeCrosshairByHue:hue_value];
    
    
    
    //initialize fond size slider (height slider)
    UIImage *topImage = [UIImage imageNamed:@"slider_0095FF_top_glow_default.png"];
    UIImage *topTintImage = [UIImage imageNamed:@"slider_0095FF_top_glow_active.png"];
    UIImage *bottomImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_default.png"];
    UIImage *bottomTintImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_active.png"];
    UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_center_glow_default.png"];
    UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_center_glow_active.png"];
    GlobalData *global = [GlobalData sharedGlobalData];
    UIImage *trackImage;
    if (global.day_mode) {
        //set day mode track image
        trackImage = [UIImage imageNamed:@"slider_track_ffffff.png"];
    }else
    {
        //set night mode track image
        trackImage = [UIImage imageNamed:@"slider_track_333333.png"];
    }
    
    [self.slider_size setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
    [self.slider_size setSliderTrackImage:trackImage];
    [self.slider_size setValue:self.font_size];
    
    
    //initialize font text
    self.lbl_text.text = self.textString;
    self.textView.text = self.textString;
    [self.lbl_text setFont:[UIFont fontWithName:self.fontName size:self.view_imgContent.frame.size.width*self.font_size/4]];
    
    self.lbl_text.textColor = self.fontColor;
    NSLog(@"%@",self.fontName);
    [self setTheme];
    
    
    //set keyboard shown notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)setTheme{
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        //set day mode color
        self.view_containner.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_createText.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_imgBackground.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.view_imgContent.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_size.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        
        self.view_font.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.lbl_titleFontFamily.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        self.img_upIcon.image = [UIImage imageNamed:@"icon_arrowup_white.png"];
        self.img_downIcon.image = [UIImage imageNamed:@"icon_arrowdown_white.png"];
        self.lbl_fontFamily.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_editText.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.view_color.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.lbl_saturation.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        self.lbl_brightness.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        
        self.content_tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        [self.btn_keyboardOk setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else
    {
        //set night mode color
        self.view_containner.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_createText.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_imgBackground.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        self.view_imgContent.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_size.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.view_font.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        self.lbl_titleFontFamily.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.img_upIcon.image = [UIImage imageNamed:@"icon_arrowup_333333_default.png"];
        self.img_downIcon.image = [UIImage imageNamed:@"icon_arrowdown_333333_default.png"];
        self.lbl_fontFamily.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_editText.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
        self.view_color.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        self.lbl_saturation.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_brightness.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.content_tableView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
        [self.btn_keyboardOk setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}
- (void)viewDidLayoutSubviews{
    double screen_width = self.view.frame.size.width;
    double screen_height = self.view.frame.size.height;
    if (screen_width < screen_height) {
        //portrait mode
        [self.view_slider setTransform:CGAffineTransformMakeRotation(0)];
    }else
    {
        //landscape mode
        [self.view_slider                                                                                                                                                                           setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    }
    
    [self.view layoutIfNeeded];
    [self.colorWheel prepare];
    [self updateColors];
    //Set initial state for IB objects after the have been layed out.
    
    //Set initial value for Saturation Brightness Slider
    [self.saturationSlider setValue:saturation];
    [self.brightnessSlider setValue:brightness];
    [self.slider_size updateView];
    [self.lbl_fontFamily setFont:[UIFont fontWithName:self.fontName size:self.lbl_fontFamily.font.pointSize]];
    [self.lbl_text setFont:[UIFont fontWithName:self.fontName size: self.view_imgContent.frame.size.width*self.font_size/4]];    
    
    
}



- (IBAction)onclick_editText:(id)sender {
    [self.view_keyboard setHidden:NO];
    self.textView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.0 animations:^{
        [self.textView becomeFirstResponder];
    }];
    
}

- (IBAction)onclick_selectFontFamily:(id)sender {
    [self.view_selectFont setHidden:NO];
    self.img_fontFamily.image = [UIImage imageNamed:@"button_fontName_active.png"];
    [self.tbl_fontList reloadData];
}
- (IBAction)textSize_valueChanged:(id)sender {
    self.font_size = self.slider_size.value;
    self.lbl_text.text = self.textString;
    [self.lbl_text setFont:[UIFont fontWithName:self.fontName size: self.view_imgContent.frame.size.width*self.font_size/4]];
    
}

- (IBAction)onclick_finish_down:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok_active.png"];
}

- (IBAction)onclick_finish:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok.png"];
    self.root_viewController.font_size = self.font_size;
    self.root_viewController.textString = self.textString;
    self.root_viewController.fontName = self.fontName;
    self.root_viewController.fontColor = self.fontColor;
    NSLog(@"%@",self.textString);
//    [self.root_viewController start_timer];
    [self dismissViewControllerAnimated:NO completion:Nil];
}
- (IBAction)onclick_setText_down:(id)sender {
    self.img_keyboardOk.image = [UIImage imageNamed:@"button_ok_active.png"];
}

- (IBAction)onclick_setText:(id)sender {
    self.img_keyboardOk.image = [UIImage imageNamed:@"button_ok.png"];
    [self.view_keyboard setHidden:YES];
    [self.textView setHidden:NO];
    [self.view endEditing:YES];
}


//textview delegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.lbl_text.text = self.textView.text;
    self.textString = self.textView.text;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.textView setHidden:YES];
    [self.view_keyboard setHidden:NO];
}


//get keyboard height
-(void)keyboardWillShow:(NSNotification *)notification
{
    double keyboard_height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.constraint_keyboardBottom.constant = keyboard_height;
        [self.view layoutIfNeeded];
    }];
}

//hide keyboard notification function
-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:1.0 animations:^{
        self.constraint_keyboardBottom.constant = 0;
        [self.view layoutIfNeeded];
    }];
}


/* ---------------------------- Color Picker Part    ----------------------*/

    //get color from color picker
    - (UIColor *)getColor{
        return [UIColor colorWithHue:hue_value saturation:saturation brightness:brightness alpha:1.0];
    }

    //update color when change color picker slider
    - (void)updateColors{
        
        //Assign Color for colorSwatch
        self.fontColor = [self getColor];
        self.lbl_text.textColor = self.fontColor;
        
        //Assign edge colors for saturationSlider
        UIColor  *saturationStartColor = [UIColor colorWithHue:hue_value saturation:0.0f brightness:brightness alpha:1.0f];
        UIColor *saturationEndColor = [UIColor colorWithHue:hue_value saturation:1.0f brightness:brightness alpha:1.0f];
        
        [self.saturationSlider updateGradientLayerWithStartColor:saturationStartColor andEndColor:saturationEndColor];
        
        //Assign edge colors for brightnessSlider
        UIColor *brightnessStartColor = [UIColor colorWithHue:hue_value saturation:saturation brightness:0.0f alpha:1.0f];
        UIColor *brightnessEndColor = [UIColor colorWithHue:hue_value saturation:saturation brightness:1.0f alpha:1.0f];        
        [self.brightnessSlider updateGradientLayerWithStartColor:brightnessStartColor andEndColor:brightnessEndColor];
    }
    #pragma mark - Color Wheel Delegate Methods

    - (void)setHueFromColorWheel:(float)hue{
        //colorWheel object did update hue value, update colors.
        hue_value = hue;
        [self updateColors];
    }
    - (IBAction)saturationValueDidChange:(id)sender{
        
        //Get saturation value from sender BYGradientSlider:UISlider object
        saturation = ((UISlider*)sender).value;
        
        [self updateColors];
    }

    - (IBAction)brightnessValueDidChange:(id)sender{
        
        //Get brightness value from sender BYGradientSlider:UISlider object
        brightness = ((UISlider*)sender).value;
        
        [self updateColors];
    }
    //get white linecircle image
    - (UIImage*)getCircleImage:(double)width{
        CGFloat lineWidth = 1.0f;
        
        CGRect crossHairFrame = CGRectMake(0.0, 0.0, width, width);
        UIGraphicsBeginImageContextWithOptions(crossHairFrame.size, NO, 0.0);
        
        UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(crossHairFrame, lineWidth, lineWidth)];
        
        [innerCircle setLineWidth:lineWidth];
        [[UIColor whiteColor] setStroke];
        [innerCircle stroke];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }

/* -----------------------------------------------------------------*/



/*-------------------------------- select font favorite part--------------------------------*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FontNameTableViewCell *cell = (FontNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FontNameTableViewCell" forIndexPath:indexPath];
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        //set day mode color
        cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        cell.view_bottom.backgroundColor =  [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    }else
    {
        //set night mode color
        cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.view_bottom.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        
    }
    
    
    NSString *font_name = [fontname_list objectAtIndex:indexPath.row];
    
    [cell.lbl_fontName setFont:[UIFont fontWithName:font_name size:cell.lbl_fontName.font.pointSize]];
    if ([font_name isEqualToString:self.fontName]) {
        cell.lbl_fontName.textColor = [UIColor colorWithRed:0.0 green:149.0/255.0 blue:1.0 alpha:1.0];
        cell.lbl_fontName.layer.shadowColor = [cell.lbl_fontName.textColor CGColor];
        cell.lbl_fontName.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        cell.lbl_fontName.layer.shadowRadius = 4.0;
        cell.lbl_fontName.layer.shadowOpacity = 0.5;
        cell.lbl_fontName.layer.masksToBounds = NO;
        
    }else
    {
        cell.lbl_fontName.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        cell.lbl_fontName.layer.shadowRadius = 0.0;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view_selectFont setHidden:YES];
    self.img_fontFamily.image = [UIImage imageNamed:@"button_fontName.png"];
    self.fontName = [fontname_list objectAtIndex:indexPath.row];
    [self.lbl_text setFont:[UIFont fontWithName:self.fontName size:self.view_imgContent.frame.size.width*self.font_size/4]];
    [self.lbl_fontFamily setFont:[UIFont fontWithName:self.fontName size:self.lbl_fontFamily.font.pointSize]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fontname_list.count;
}

/* -----------------------------------------------------------------*/


-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}
@end
