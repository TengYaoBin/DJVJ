//
//  SpecialEffectViewController.m
//  DJVJ
//
//  Created by Bin on 2019/1/4.
//  Copyright © 2019 Bin. All rights reserved.
//

#import "SpecialEffectViewController.h"
#import "SpecialEffectLayerStyle.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "GlobalData.h"

@interface SpecialEffectViewController ()
{
    UIColor *background_color;
    UIColor *default_color;
    UIColor *active_color;
    int selected_index;
    Boolean holding_state;
    int holding_index;
    NSMutableArray *effectBtn_array;
    NSMutableArray *imgEffect_array;
    UIImage *defaultImage;
    UIImage *activeImage;
    
    NSMutableArray *firstPoint_array;
    NSMutableArray *effectView_array;
    NSMutableArray *effectLayer_array;
    
    NSMutableArray *effectLabel_array;
    int include_index;
    double btn_height;
    double btn_width;
    NSTimer *include_timer;
    CGPoint current_pos;
    
    int running_frame;//for white&black strobe, fade to white&black
    NSTimer *effect_timer;
    UIImage *originImage;
}

@end

@implementation SpecialEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    
    originImage = [UIImage imageNamed:@"fxpreview_poster_image.png"];
    default_color = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    active_color = [UIColor colorWithRed:179/255.0 green:224/255.0 blue:1.0 alpha:1.0];
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        background_color = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        defaultImage = [UIImage imageNamed:@"drag_stadium_0095ff_glow_default_day.png"];
        activeImage = [UIImage imageNamed:@"drag_stadium_0095ff_glow_active_day.png"];
    }else{
        background_color = [UIColor colorWithRed:71/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
        defaultImage = [UIImage imageNamed:@"drag_stadium_0095ff_glow_default.png"];
        activeImage = [UIImage imageNamed:@"drag_stadium_0095ff_glow_active.png"];
    }
    [self.btn_holding setBackgroundImage:activeImage forState:UIControlStateNormal];
    [self setDefaultBackgroundImageToButtons];
    
    
    selected_index = 0;
    holding_index = 0;
    holding_state = false;
    current_pos = CGPointMake(0.0, 0.0);
    include_index = -1;
    
    firstPoint_array = [[NSMutableArray alloc] init];
    for (int i = 0; i<20; i++) {
        CGPoint pos = CGPointMake(0.0, 0.0);
        [firstPoint_array addObject:[NSValue valueWithCGPoint:pos]];
    }
    
    
    effectBtn_array = [[NSMutableArray alloc] init];
    [effectBtn_array addObject:self.btn_effect1];
    [effectBtn_array addObject:self.btn_effect2];
    [effectBtn_array addObject:self.btn_effect3];
    [effectBtn_array addObject:self.btn_effect4];
    [effectBtn_array addObject:self.btn_effect5];
    [effectBtn_array addObject:self.btn_effect6];
    [effectBtn_array addObject:self.btn_effect7];
    [effectBtn_array addObject:self.btn_effect8];
    [effectBtn_array addObject:self.btn_effect9];
    [effectBtn_array addObject:self.btn_effect10];
    [effectBtn_array addObject:self.btn_effect11];
    [effectBtn_array addObject:self.btn_effect12];
    [effectBtn_array addObject:self.btn_effect13];
    [effectBtn_array addObject:self.btn_effect14];
    [effectBtn_array addObject:self.btn_effect15];
    [effectBtn_array addObject:self.btn_effect16];
    [effectBtn_array addObject:self.btn_effect17];
    [effectBtn_array addObject:self.btn_effect18];
    [effectBtn_array addObject:self.btn_effect19];
    [effectBtn_array addObject:self.btn_effect20];
    
    for (UIButton *button in effectBtn_array) {
        UILongPressGestureRecognizer *objGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:objGesture];
    }
    imgEffect_array = [NSMutableArray arrayWithObjects:self.img_effect1, self.img_effect2, self.img_effect3, self.img_effect4, self.img_effect5, self.img_effect6, self.img_effect7, self.img_effect8, self.img_effect8, self.img_effect10, self.img_effect11, self.img_effect12, self.img_effect13, self.img_effect14, self.img_effect15, self.img_effect16, self.img_effect17, self.img_effect18, self.img_effect19, self.img_effect20, nil];
    
    
    effectView_array = [[NSMutableArray alloc] init];
    [effectView_array addObject:self.view_effect1];
    [effectView_array addObject:self.view_effect2];
    [effectView_array addObject:self.view_effect3];
    [effectView_array addObject:self.view_effect4];
    [effectView_array addObject:self.view_effect5];
    [effectView_array addObject:self.view_effect6];
    [effectView_array addObject:self.view_effect7];
    
    
    
    effectLayer_array = [[NSMutableArray alloc] init];
    for (int i = 0; i<7; i++) {
        UIView *effectView = [effectView_array objectAtIndex:i];
        CAShapeLayer *shapeLayer = [self drawBorderAroundView:effectView :background_color];
        [effectView.layer addSublayer:shapeLayer];
        effectView.layer.cornerRadius = 5.0;
        [effectLayer_array addObject:shapeLayer];
    }
    
    
    
    
    
    
    
    self.lbl_effect1.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_1"];
    self.lbl_effect2.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_2"];
    self.lbl_effect3.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_3"];
    self.lbl_effect4.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_4"];
    self.lbl_effect5.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_5"];
    self.lbl_effect6.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_6"];
    self.lbl_effect7.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_7"];
    
    effectLabel_array = [[NSMutableArray alloc] init];
    [effectLabel_array addObject:self.lbl_effect1];
    [effectLabel_array addObject:self.lbl_effect2];
    [effectLabel_array addObject:self.lbl_effect3];
    [effectLabel_array addObject:self.lbl_effect4];
    [effectLabel_array addObject:self.lbl_effect5];
    [effectLabel_array addObject:self.lbl_effect6];
    [effectLabel_array addObject:self.lbl_effect7];
    //set effect label as glow
    for (UILabel *effectLabel in effectLabel_array) {
        effectLabel.layer.shadowColor = [effectLabel.textColor CGColor];
        effectLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        effectLabel.layer.shadowRadius = 4.0;
        effectLabel.layer.shadowOpacity = 0.5;
        effectLabel.layer.masksToBounds = NO;
    }
    NSMutableArray *titleLabel_array = [NSMutableArray arrayWithObjects:self.lbl_1,self.lbl_2,self.lbl_3,self.lbl_4,self.lbl_5,self.lbl_6,self.lbl_7, nil];
    for (UILabel *titleLabel in titleLabel_array) {
        titleLabel.layer.shadowColor = [titleLabel.textColor CGColor];
        titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        titleLabel.layer.shadowRadius = 4.0;
        titleLabel.layer.shadowOpacity = 0.5;
        titleLabel.layer.masksToBounds = NO;
    }
    
    
    self.view_content.layer.cornerRadius = 5.0;
    self.view_content.clipsToBounds = true;
    self.view_preview.layer.cornerRadius = 5.0;
    self.view_preview.clipsToBounds = true;
    self.view_preview_content.layer.cornerRadius = 8.0;
    self.view_preview_content.clipsToBounds = true;
    
    
    
    self.view_effects_container.layer.cornerRadius = 5.0;
    self.view_effects_container.clipsToBounds = true;
    
    self.container_current_effects.layer.cornerRadius = 5.0;
    self.container_current_effects.clipsToBounds = true;
    
    _brScrollBarController = [BRScrollBarController setupScrollBarWithScrollView:self.scrollview_effects inPosition:BRScrollBarPostionRight delegate:self];
    _brScrollBarController.scrollBar.backgroundColor = [UIColor clearColor];
    _brScrollBarController.scrollBar.scrollHandle.backgroundColor = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    _brScrollBarController.scrollBar.hideScrollBar = NO;
    
    [self.btn_holding setHidden:YES];
    

    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    btn_width = self.btn_effect1.frame.size.width;
    btn_height = self.btn_effect1.frame.size.height;
    include_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(running) userInfo:nil repeats:YES];
    effect_timer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(running_effect) userInfo:nil repeats:YES];    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setTheme];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
    
}
-(void)setTheme
{
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        //set day mode
        self.view_content.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_effectsTitle.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_preview.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        
        self.view_effects_container.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
        for (UIImageView *item_image in imgEffect_array) {
            item_image.image = [UIImage imageNamed:@"drag_stadium_484649_glow_default_day.png"];
        }
        
        for (UIButton *button in effectBtn_array) {
            [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
        
        for (UIView *item_view in effectView_array) {
            item_view.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        }
        
        if (self.view.frame.size.width > self.view.frame.size.height) {
            //landscape mode
            self.container_current_effects.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        }else
        {
            //portrait mode
            self.container_current_effects.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        }
    }else
    {
        //set night mode
        self.view_content.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_effectsTitle.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_preview.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        self.view_effects_container.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        
        for (UIImageView *item_image in imgEffect_array) {
            item_image.image = [UIImage imageNamed:@"drag_stadium_484649_glow_default.png"];
        }
        
        for (UIButton *button in effectBtn_array) {
            [button setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
        
        for (UIView *item_view in effectView_array) {
            item_view.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        }
        
        if (self.view.frame.size.width > self.view.frame.size.height) {
            //landscape mode
            self.container_current_effects.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        }else
        {
            //portrait mode
            self.container_current_effects.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        }
    }
    
    
}
-(void)running
{
    if (holding_state) {
        if (include_index >= 0) {
            CAShapeLayer *prev_layer = [effectLayer_array objectAtIndex:include_index];
            UIView *effectView = [effectView_array objectAtIndex:include_index];
            [prev_layer removeFromSuperlayer];
            CAShapeLayer *sub_layer = [self drawDashedBorderAroundView:effectView :default_color];
            [effectView.layer addSublayer:sub_layer];
            effectView.layer.cornerRadius = 5.0;
            [effectLayer_array replaceObjectAtIndex:include_index withObject:sub_layer];
            
            include_index = -1;
        }
        for (UIView *effect_view in effectView_array) {
            CGRect innner_frame = [self.view convertRect:effect_view.frame fromView:[effect_view superview]];
            if (CGRectContainsPoint(innner_frame, current_pos))
            {
                int index = (int)[effectView_array indexOfObject:effect_view];
                CAShapeLayer *prev_layer = [effectLayer_array objectAtIndex:index];
                [prev_layer removeFromSuperlayer];
                CAShapeLayer *sub_layer = [self drawDashedBorderAroundView:effect_view :active_color];
                [effect_view.layer addSublayer:sub_layer];
                effect_view.layer.cornerRadius = 5.0;
                [effectLayer_array replaceObjectAtIndex:index withObject:sub_layer];
                include_index = index;
                break;
            }
        }
    }else
    {
        [self setBackgroundBorderColor];
    }
}
-(void)running_effect
{
    switch (selected_index) {
        case 0:
            self.img_preview.image = originImage;
            break;
        case 1:
            //white strobe
            self.img_preview.image = [SpecialEffectLayerStyle whiteStrobe:originImage :running_frame];
            running_frame = running_frame + 1;
            break;
        case 2:
            //black strobe
            self.img_preview.image = [SpecialEffectLayerStyle blackStrobe:originImage :running_frame];
            running_frame = running_frame + 1;
            break;
        case 3:
            //fade to white
            self.img_preview.image = [SpecialEffectLayerStyle fadeToWhite:originImage :running_frame];
            running_frame = running_frame + 1;
            break;
        case 4:
            //fade to black
            self.img_preview.image = [SpecialEffectLayerStyle fadeToBlack:originImage :running_frame];
            running_frame = running_frame + 1;
            break;
        case 5:
            //gaussian blur
            self.img_preview.image = [SpecialEffectLayerStyle gaussianBlur:originImage];
            break;
        case 6:
            //zoom
            self.img_preview.image = [SpecialEffectLayerStyle zoom:originImage];
            break;
        case 7:
            //posterize
            self.img_preview.image = [SpecialEffectLayerStyle posterize:originImage];
            break;
        case 8:
            //solarize
            self.img_preview.image = [SpecialEffectLayerStyle solarize:originImage];
            break;
        case 9:
            //pixellate
            self.img_preview.image = [SpecialEffectLayerStyle pixellate:originImage];
            break;
        case 10:
            //superpizellate
            self.img_preview.image = [SpecialEffectLayerStyle superpixellate:originImage];
            break;
        case 11:
            //caleido TL
            self.img_preview.image = [SpecialEffectLayerStyle caleidoTL:originImage];
            break;
        case 12:
            //caleido TR
            self.img_preview.image = [SpecialEffectLayerStyle caleidoTR:originImage];
            break;
        case 13:
            //caleido BL
            self.img_preview.image = [SpecialEffectLayerStyle caleidoBL:originImage];
            break;
        case 14:
            //caleido BR
            self.img_preview.image = [SpecialEffectLayerStyle caleidoBR:originImage];
            break;
        case 15:
            //times * 4
            self.img_preview.image = [SpecialEffectLayerStyle times4:originImage];
            break;
        case 16:
            //times * 9
            self.img_preview.image = [SpecialEffectLayerStyle times9:originImage];
            break;
        case 17:
            //warhol
            self.img_preview.image = [SpecialEffectLayerStyle warhol:originImage];
            break;
        case 18:
            //threshold
            self.img_preview.image = [SpecialEffectLayerStyle threshold:originImage];
            break;
        case 19:
            //old times
            self.img_preview.image = [SpecialEffectLayerStyle oldTimes:originImage];
            break;
        case 20:
            //freeze
            self.img_preview.image = originImage;
            break;
            
        default:
            break;
    }
    
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        holding_state = true;
        UIButton *draggedButton = (UIButton *)gesture.view;
        CGPoint translation = [gesture locationInView:gesture.view];
        
        int index = (int)draggedButton.tag - 101;
        NSValue *point_value = [NSValue valueWithCGPoint:translation];
        [firstPoint_array replaceObjectAtIndex:index withObject:point_value];
        
        CGRect frame = [self.view convertRect:draggedButton.frame fromView:[draggedButton superview]];
        self.btn_holding.frame = frame;
        [self.btn_holding setTitle:draggedButton.titleLabel.text forState:UIControlStateNormal];
        [self.btn_holding setHidden:NO];
        [draggedButton setHidden:YES];
        [self setDefaultBorderColor];
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        UIButton *draggedButton = (UIButton *)gesture.view;
        int index = (int)draggedButton.tag - 101;
        NSValue *val_firstPos = [firstPoint_array objectAtIndex:index];
        CGPoint firstPos = [val_firstPos CGPointValue];
        CGPoint translation = [gesture locationInView:gesture.view];
        
        CGRect frame = [self.view convertRect:draggedButton.frame fromView:[draggedButton superview]];
        self.btn_holding.frame = CGRectMake(frame.origin.x+translation.x - firstPos.x, frame.origin.y+translation.y - firstPos.y, frame.size.width, frame.size.height);
        current_pos = [gesture locationInView:self.view];
        
        
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        current_pos = CGPointMake(0.0, 0.0);
        include_index = -1;
        holding_state = false;
        UIButton *draggedButton = (UIButton *)gesture.view;
        int index = (int)draggedButton.tag - 101;
        NSValue *point_value = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
        [firstPoint_array replaceObjectAtIndex:index withObject:point_value];
        [draggedButton setHidden:NO];
        [self.btn_holding setHidden:YES];
        [self.btn_holding setTitle:@"" forState:UIControlStateNormal];
        //[self setBackgroundBorderColor];
        
        for (UIView *effect_view in effectView_array) {
            CGRect innner_frame = [self.view convertRect:effect_view.frame fromView:[effect_view superview]];
            CGPoint end_pos = [gesture locationInView:self.view];
            if (CGRectContainsPoint(innner_frame, end_pos))
            {
                int index = (int)[effectView_array indexOfObject:effect_view];
                UILabel *lbl_current_effect = [effectLabel_array objectAtIndex:index];
                lbl_current_effect.text = draggedButton.titleLabel.text;
                break;
            }
        }
    }
}





- (IBAction)select_effectBtn1:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 1) {
        selected_index = 1;
        [self.btn_effect1 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}


- (IBAction)select_effectBtn2:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 2) {
        selected_index = 2;
        [self.btn_effect2 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn3:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 3) {
        selected_index = 3;
        [self.btn_effect3 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn4:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 4) {
        selected_index = 4;
        [self.btn_effect4 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn5:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 5) {
        selected_index = 5;
        [self.btn_effect5 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn6:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 6) {
        selected_index = 6;
        [self.btn_effect6 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn7:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 7) {
        selected_index = 7;
        [self.btn_effect7 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn8:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 8) {
        selected_index = 8;
        [self.btn_effect8 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn9:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 9) {
        selected_index = 9;
        [self.btn_effect9 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn10:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 10) {
        selected_index = 10;
        [self.btn_effect10 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn11:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 11) {
        selected_index = 11;
        [self.btn_effect11 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn12:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 12) {
        selected_index = 12;
        [self.btn_effect12 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn13:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 13) {
        selected_index = 13;
        [self.btn_effect13 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn14:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 14) {
        selected_index = 14;
        [self.btn_effect14 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn15:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 15) {
        selected_index = 15;
        [self.btn_effect15 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn16:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 16) {
        selected_index = 16;
        [self.btn_effect16 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn17:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 17) {
        selected_index = 17;
        [self.btn_effect17 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn18:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 18) {
        selected_index = 18;
        [self.btn_effect18 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn19:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 19) {
        selected_index = 19;
        [self.btn_effect19 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)select_effectBtn20:(id)sender {
    [self setDefaultBackgroundImageToButtons];
    if (selected_index != 20) {
        selected_index = 20;
        [self.btn_effect20 setBackgroundImage:activeImage forState:UIControlStateNormal];
    }else
    {
        selected_index = 0;
    }
}
- (IBAction)action_finish_down:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok_active.png"];
}
- (IBAction)action_finish:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok.png"];
    [effect_timer invalidate];
    effect_timer = nil;
    [include_timer invalidate];
    include_timer = nil;
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect1.text forKey:@"effect_1"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect2.text forKey:@"effect_2"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect3.text forKey:@"effect_3"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect4.text forKey:@"effect_4"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect5.text forKey:@"effect_5"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect6.text forKey:@"effect_6"];
    [[NSUserDefaults standardUserDefaults] setObject:self.lbl_effect7.text forKey:@"effect_7"];
    [self dismissViewControllerAnimated:NO completion:Nil];
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




-(void)clearLayers
{
    for (UIView *effect_view in effectView_array) {
//        for (CALayer *layer in effect_view.layer.sublayers) {
//            [layer removeFromSuperlayer];
//        }
        effect_view.layer.sublayers = nil;
    }
}

-(void)setBackgroundBorderColor
{
    for (int i = 0; i<7; i++) {
        UIView *effectView = [effectView_array objectAtIndex:i];
        CAShapeLayer *prevLayer = [effectLayer_array objectAtIndex:i];
        [prevLayer removeFromSuperlayer];
        CAShapeLayer *shapeLayer = [self drawBorderAroundView:effectView :background_color];
        [effectView.layer addSublayer:shapeLayer];
        effectView.layer.cornerRadius = 5.0;
        [effectLayer_array replaceObjectAtIndex:i withObject:shapeLayer];
    }
}

-(void)setDefaultBorderColor
{
    for (int i = 0; i<7; i++) {
        UIView *effectView = [effectView_array objectAtIndex:i];
        CAShapeLayer *prevLayer = [effectLayer_array objectAtIndex:i];
        [prevLayer removeFromSuperlayer];
        CAShapeLayer *shapeLayer = [self drawDashedBorderAroundView:effectView :default_color];
        [effectView.layer addSublayer:shapeLayer];
        effectView.layer.cornerRadius = 5.0;
        [effectLayer_array replaceObjectAtIndex:i withObject:shapeLayer];
    }
}

//draw dashed border
- (CAShapeLayer *)drawDashedBorderAroundView:(UIView *)v :(UIColor *)lineColor
{
    NSInteger dashPattern1 = 4;
    NSInteger dashPattern2 = 3;
    
    //drawing
    CGRect frame = v.bounds;
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - 5.0);
    CGPathAddLineToPoint(path, NULL, 0, 5.0);
    CGPathAddArc(path, NULL, 5.0, 5.0, 5.0, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - 5.0, 0);
    CGPathAddArc(path, NULL, frame.size.width - 5.0, 5.0, 5.0, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - 5.0);
    CGPathAddArc(path, NULL, frame.size.width - 5.0, frame.size.height - 5.0, 5.0, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, 5.0, frame.size.height);
    CGPathAddArc(path, NULL, 5.0, frame.size.height - 5.0, 5.0, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [lineColor CGColor];
    _shapeLayer.lineWidth = 2.0;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:dashPattern1], [NSNumber numberWithInt:dashPattern2], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    return _shapeLayer;
    
    //_shapeLayer is added as a sublayer of the view, the border is visible
//    [v.layer addSublayer:_shapeLayer];
//    v.layer.5.0 = 5.0;
}
//draw border
- (CAShapeLayer *)drawBorderAroundView:(UIView *)v :(UIColor *)lineColor
{
    NSInteger dashPattern1 = 2;
    NSInteger dashPattern2 = 0;
    
    //drawing
    CGRect frame = v.bounds;
    
    CAShapeLayer *_shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - 5.0);
    CGPathAddLineToPoint(path, NULL, 0, 5.0);
    CGPathAddArc(path, NULL, 5.0, 5.0, 5.0, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - 5.0, 0);
    CGPathAddArc(path, NULL, frame.size.width - 5.0, 5.0, 5.0, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - 5.0);
    CGPathAddArc(path, NULL, frame.size.width - 5.0, frame.size.height - 5.0, 5.0, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, 5.0, frame.size.height);
    CGPathAddArc(path, NULL, 5.0, frame.size.height - 5.0, 5.0, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    _shapeLayer.frame = frame;
    _shapeLayer.masksToBounds = NO;
    [_shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _shapeLayer.strokeColor = [lineColor CGColor];
    _shapeLayer.lineWidth = 1.0;
    _shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:dashPattern1], [NSNumber numberWithInt:dashPattern2], nil];
    _shapeLayer.lineCap = kCALineCapRound;
    
    return _shapeLayer;
    
    //_shapeLayer is added as a sublayer of the view, the border is visible
//    [v.layer addSublayer:_shapeLayer];
//    v.layer.5.0 = 5.0;
}







-(void)setDefaultBackgroundImageToButtons{
    running_frame = 0;
    for (UIButton *button in effectBtn_array) {
        [button setBackgroundImage:defaultImage forState:UIControlStateNormal];
    }
}
-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}
@end
