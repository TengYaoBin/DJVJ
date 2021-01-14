//
//  MainViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/11.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "MainViewController.h"
#import "MicSampler.h"
#import "ITunesSampler.h"
#import "LeftMenuViewController.h"
#import "LeftMenuPresentation.h"
#import "LeftMenuTransition.h"
#import "UIView+SDExtension.h"
#import "SelectVideoViewController.h"
#import "EditVideoViewController.h"
#import "SelectImageViewController.h"
#import "TextViewController.h"
#import "LayerTableViewCell.h"
#import "BaseLayerStyle.h"
#import "BlendModeLayerStyle.h"
#import "SpecialEffectLayerStyle.h"
#import "SpecialEffectViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import <Crashlytics/Crashlytics.h>
#import <StoreKit/StoreKit.h>
//#import <Fabric/Fabric.h>


using namespace std;
@interface MainViewController ()<UIViewControllerTransitioningDelegate,UITableViewDelegate, UITableViewDataSource,MPMediaPickerControllerDelegate,SKProductsRequestDelegate>
{
    GlobalData *global;
    LeftMenuTransition *presentTransition;//left menu present transition
    LeftMenuTransition *dismissTransition;//left menu dismiss transition
    NSTimer *orientation_timer;//it well detect device orientation real time and reset layout
    UIDeviceOrientation current_orientation;
    NSMutableArray *base_layer_list;
    NSMutableArray *overlay_layer_list;
    NSString *special_effect;
    NSMutableArray *specialEffect_array;
    int running_frame;//for white&black strobe, fade to white&black
    
    Boolean recording_state;
    int recording_frameNum;
    NSTimer *save_video_timer;
    int savingVideoState;
    int saving_frameNum;
    int frame_size;
    
    //in app purchase
    SKProductsRequest *productsRequest;
    NSTimer *getting_serverState;
    UIActivityIndicatorView *activityIndicatorView;
    int repeate_count;
}
@end

@implementation MainViewController
//- (IBAction)crashButtonTapped:(id)sender {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    NSString *str = [array objectAtIndex:1];
//    NSLog(@"%@",str);
//}


/* -- get in app purchase products -- */
-(void)running:(NSTimer *)timer {
    repeate_count = repeate_count + 1;
    if (repeate_count > 20) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Oops… the content has failed to load. There might be a problem with your connection or our server. Please try again later!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        [activityIndicatorView stopAnimating];
        [timer invalidate];
        timer = nil;
    }
    if (global.purchageVideoState != 0 && global.purchageImageState != 0) {
        [self fetchAvailableProducts];
        [timer invalidate];
        timer = nil;
    }
}
-(void)fetchAvailableProducts {
    if ([SKPaymentQueue canMakePayments]) {
        NSSet *productIdentifiers = global.productIdentifiers;
        
        NSLog(@"count: %lu",(unsigned long)productIdentifiers.count);
        productsRequest = [[SKProductsRequest alloc]
                           initWithProductIdentifiers:productIdentifiers];
        productsRequest.delegate = self;
        [productsRequest start];
    }
   
}

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@",error.localizedDescription);
}

-(void)productsRequest:(SKProductsRequest *)request
    didReceiveResponse:(SKProductsResponse *)response {    
    int count = (int)[response.products count];
    
    if (count>0) {
        global.validProducts = [response.products mutableCopy];
        for (SKProduct *validProduct in global.validProducts) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:validProduct.priceLocale];
            NSString *formattedPrice = [numberFormatter stringFromNumber:validProduct.price];
            NSLog(@"%@", formattedPrice);
            [global.iapKeyList setValue:[NSString stringWithFormat:@"%@",formattedPrice] forKey:validProduct.productIdentifier];
        }
        NSLog(@"iap keylist : %@",global.iapKeyList);
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"No products to purchase." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    [activityIndicatorView stopAnimating];
}
/* ---------------------------------------- */




- (void)viewDidLoad {
    [super viewDidLoad];
    global = [GlobalData sharedGlobalData];
    
    //Adding activity indicator
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView hidesWhenStopped];
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    repeate_count = 0;
    getting_serverState = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target:self
                                           selector:@selector(running:)
                                           userInfo:nil
                                            repeats:YES];
    
    
//    [Fabric with:@[[Crashlytics class]]];
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(20, 50, 100, 30);
//    [button setTitle:@"Crash" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(crashButtonTapped:)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
    
    // Listen for external screen notifications
    self.externalOutPutImageView = [[UIImageView alloc] init];
    self.externalOutPutImageView.frame = self.view.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(external_screen_connected:)
                                                 name:UIScreenDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(external_screen_disconnected:)
                                                 name:UIScreenDidDisconnectNotification
                                               object:nil];
    
    
    [self restrictRotation:NO];
    
    
    //initialize audio amplitude
    self.audio_amplitude = 0.0;
    
    //initialize recording part
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
    } completionHandler:^(BOOL success, NSError *error) {
        
    }];
    recording_state = NO;
    recording_frameNum = -1;
    [self.lbl_recordingTime setHidden:YES];
    [self.view_savingVideoState setHidden:YES];
    savingVideoState = 0;
    saving_frameNum = 0;
    frame_size = 1000;
    save_video_timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(savingState)
                                                      userInfo:nil
                                                       repeats:YES];
    
    //set menu transition
    presentTransition = [[LeftMenuTransition alloc] initWithIsPresent:YES];
    dismissTransition = [[LeftMenuTransition alloc] initWithIsPresent:NO];
    
    //format layer table view
    [self.view_selectLayer setHidden:YES];
    self.tbl_baseLayer.layer.cornerRadius = 6.0;
    self.tbl_baseLayer.clipsToBounds = YES;
    self.tbl_baseLayer.layer.borderColor = [UIColor colorWithRed:133.0/255.0 green:93.0/255.0 blue:251.0/255.0 alpha:1.0].CGColor;
    self.tbl_baseLayer.layer.borderWidth = 2;
    self.tbl_baseLayer.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tbl_overlayLayer.layer.cornerRadius = 6.0;
    self.tbl_overlayLayer.clipsToBounds = YES;
    self.tbl_overlayLayer.layer.borderColor = [UIColor colorWithRed:43.0/255.0 green:211.0/255.0 blue:212.0/255.0 alpha:1.0].CGColor;
    self.tbl_overlayLayer.layer.borderWidth = 2;
    self.tbl_overlayLayer.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //itunes part
    self.select_song_button.hidden = true;
    self.label.hidden = true;
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(music_player_changed:)
//                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(music_player_changed:)
//                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
//                                               object:nil];
//
//    [[MPMusicPlayerController systemMusicPlayer] beginGeneratingPlaybackNotifications];
//
//    [self music_player_changed:nil];
    
    
    
    
    //initialize video playing state
    self.video_playing_state = false;
    //set audio source
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            if(self.audio_amplitude == 0.0)
            {
                [self setInput_mode];
            }
            sleep(1);
        }
    });
    
    //set outputvideo fps & width, height
    self.video_fps = [[[NSUserDefaults standardUserDefaults] objectForKey:@"output_rate"] intValue];
    
    self.outputWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:@"width"] intValue];
    self.outputHeight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"height"] intValue];
    
    //initialize basic video frame properties
    self.basicImageOrigin = [[UIImage alloc] init];
    self.basic_videoID = @"1";
    self.basic_start_frameNumber = 0;
    self.basic_end_frameNumber = 0;
    self.basic_current_frameNumber = 0;
    self.baseLayerName = @"Normal";
    base_layer_list = [[NSMutableArray alloc] initWithObjects:@"Normal", @"Posterize", @"Desaturate", @"Saturate", @"Threshold", @"Negative", @"Gaussian Blur", @"Colorise Red", @"Colorise Green", @"Colorise Blue", @"Colorise Cyan", @"Colorise Magenta", @"Colorise Yellow", nil];
    
    //initialize overlay video frame properties
    self.basicImageOrigin = [[UIImage alloc] init];
    self.overlay_videoID = @"2";
    self.overlay_start_frameNumber = 0;
    self.overlay_end_frameNumber = 0;
    self.overlay_current_frameNumber = 0;
    self.overlayLayerName = @"Normal";
    overlay_layer_list = [[NSMutableArray alloc] initWithObjects:@"Normal", @"Multiply", @"Lighten", @"Difference", @"Subtract", @"Divide", @"Hue", @"Saturation", @"Color", @"Luminosity", nil];
    
    //initialize image manager properties
    self.imageOrigin = [[UIImage alloc] init];
    self.image_size = 1.0;
    
    //initialize text manager properties
    self.font_size = 1.0;
    self.textString = @"";
    self.fontName = @"Posterama2001W04-Regular";
    self.fontColor = global.backgroundColor20;
    //initialize custom ui sliders colors and values
    {
        //basic sliders
        {
            //height slider
            UIImage *topImage = [UIImage imageNamed:@"slider_855DFB_top_glow_default.png"];
            UIImage *topTintImage = [UIImage imageNamed:@"slider_855DFB_top_glow_active.png"];
            UIImage *bottomImage = [UIImage imageNamed:@"slider_855DFB_bottom_glow_default.png"];
            UIImage *bottomTintImage = [UIImage imageNamed:@"slider_855DFB_bottom_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_855DFB_center_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_855DFB_center_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
            [self.slider_basic_opacity setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_basic_opacity setSliderTrackImage:trackImage];
            [self.slider_basic_speed setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_basic_speed setSliderTrackImage:trackImage];
            [self.slider_basic_sensor setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_basic_sensor setSliderTrackImage:trackImage];
            
            [self.slider_basic_speed setValue:0.5];
            self.basic_speed = 1.0;
            [self.slider_basic_opacity setValue:1.0];
            [self.slider_basic_sensor setValue:0.5];
            self.basic_scale = 1.0;
        }
        
        
        //overlay sliders
        {
            //height slider
            UIImage *topImage = [UIImage imageNamed:@"slider_2BD3D4_top_glow_default.png"];
            UIImage *topTintImage = [UIImage imageNamed:@"slider_2BD3D4_top_glow_active.png"];
            UIImage *bottomImage = [UIImage imageNamed:@"slider_2BD3D4_bottom_glow_default.png"];
            UIImage *bottomTintImage = [UIImage imageNamed:@"slider_2BD3D4_bottom_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_2BD3D4_center_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_2BD3D4_center_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
            [self.slider_overlay_opacity setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_overlay_opacity setSliderTrackImage:trackImage];
            [self.slider_overlay_speed setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_overlay_speed setSliderTrackImage:trackImage];
            [self.slider_overlay_sensor setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_overlay_sensor setSliderTrackImage:trackImage];
            
            [self.slider_overlay_opacity setValue:1.0];
            [self.slider_overlay_speed setValue:0.5];
            self.overlay_speed = 1;
            self.overlay_scale = 1;
        }
        
        
        //video channel slider
        {
            //one slider
            UIImage *contentImage = [UIImage imageNamed:@"crossfader_circle_0095FF_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"crossfader_circle_0095FF_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
            [self.slider_video_channel setImage:contentImage :contentTintImage];
            [self.slider_video_channel setSliderTrackImage:trackImage];
            [self.slider_video_channel setValue:0.5];
            self.basic_opacity = 1;
            self.overlay_opacity = 1;
        }
        
        
        //image filter sliders
        {
            //height slider
            UIImage *topImage = [UIImage imageNamed:@"slider_0095FF_top_glow_default.png"];
            UIImage *topTintImage = [UIImage imageNamed:@"slider_0095FF_top_glow_active.png"];
            UIImage *bottomImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_default.png"];
            UIImage *bottomTintImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_center_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_center_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
            [self.slider_image_opacity setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_image_opacity setSliderTrackImage:trackImage];
            
            [self.slider_image_opacity setValue:1.0];
        }
        {
            //width slider
            UIImage *leftImage = [UIImage imageNamed:@"slider_0095FF_left_glow_default.png"];
            UIImage *leftTintImage = [UIImage imageNamed:@"slider_0095FF_left_glow_active.png"];
            UIImage *rigntImage = [UIImage imageNamed:@"slider_0095FF_right_glow_default.png"];
            UIImage *rightTintImage = [UIImage imageNamed:@"slider_0095FF_right_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_centerV_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_centerV_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_horizontal_track_474646.png"];
            [self.slider_image_sensor setSliderImage:leftImage :rigntImage :contentImage :leftTintImage :rightTintImage :contentTintImage];
            [self.slider_image_sensor setSliderTrackImage:trackImage];
            
            [self.slider_image_sensor setValue:0.5];
        }
        
        //text filter sliders
        {
            //height slider
            UIImage *topImage = [UIImage imageNamed:@"slider_0095FF_top_glow_default.png"];
            UIImage *topTintImage = [UIImage imageNamed:@"slider_0095FF_top_glow_active.png"];
            UIImage *bottomImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_default.png"];
            UIImage *bottomTintImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_center_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_center_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
            [self.slider_text_opacity setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
            [self.slider_text_opacity setSliderTrackImage:trackImage];
            
            [self.slider_text_opacity setValue:1.0];
        }
        
        {
            //width slider
            UIImage *leftImage = [UIImage imageNamed:@"slider_0095FF_left_glow_default.png"];
            UIImage *leftTintImage = [UIImage imageNamed:@"slider_0095FF_left_glow_active.png"];
            UIImage *rigntImage = [UIImage imageNamed:@"slider_0095FF_right_glow_default.png"];
            UIImage *rightTintImage = [UIImage imageNamed:@"slider_0095FF_right_glow_active.png"];
            UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_centerV_glow_default.png"];
            UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_centerV_glow_active.png"];
            UIImage *trackImage = [UIImage imageNamed:@"slider_horizontal_track_474646.png"];
            [self.slider_text_sensor setSliderImage:leftImage :rigntImage :contentImage :leftTintImage :rightTintImage :contentTintImage];
            [self.slider_text_sensor setSliderTrackImage:trackImage];
            
            [self.slider_text_sensor setValue:0.6];
        }        
    }
    
    
    
    //add blend mode effect in background mode
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Background work
        while (YES) {
            @autoreleasepool {
                if (self.basicImageFinal == nil) {
                    if (self.overlayImageFinal != nil) {
                        self.outputImage = [BaseLayerStyle alphaImage:self.overlayImageFinal :self.overlay_opacity];
                    }else{
                        self.outputImage = nil;
                    }
                    
                }else if (self.overlayImageFinal == nil)
                {
                    self.outputImage = [BaseLayerStyle alphaImage:self.basicImageFinal :self.basic_opacity];
                }else
                {
                    int index = (int)[self->overlay_layer_list indexOfObject:self.overlayLayerName];
                    CIImage *basicImage = [BaseLayerStyle alphaImage:self.basicImageFinal :self.basic_opacity];
                    
                    CIImage *overlayImage = [BaseLayerStyle alphaImage:self.overlayImageFinal :self.overlay_opacity];
                    
                    
                    
                    
                    switch (index) {
                        case 0:
                            //Normal
                            self.outputImage = [BlendModeLayerStyle normalBlendImage:basicImage :overlayImage];
                            break;
                        case 1:
                            //Multiply
                            self.outputImage = [BlendModeLayerStyle multiplyBlendImage:basicImage :overlayImage];
                            break;
                        case 2:
                            //Lighten
                            self.outputImage = [BlendModeLayerStyle lightenBlendImage:basicImage :overlayImage];
                            break;
                        case 3:
                            //Difference
                            self.outputImage = [BlendModeLayerStyle differenceBlendImage:basicImage :overlayImage];
                            break;
                        case 4:
                            //Subtract
                            self.outputImage = [BlendModeLayerStyle subtractBlendImage:basicImage :overlayImage];
                            break;
                        case 5:
                            //Divide
                            self.outputImage = [BlendModeLayerStyle divideBlendImage:basicImage :overlayImage];
                            break;
                        case 6:
                            //Hue
                            self.outputImage = [BlendModeLayerStyle hueBlendImage:basicImage :overlayImage];
                            break;
                        case 7:
                            //Saturation
                            self.outputImage = [BlendModeLayerStyle saturationBlendImage:basicImage :overlayImage];
                            break;
                        case 8:
                            //Color
                            self.outputImage = [BlendModeLayerStyle colorBlendImage:basicImage :overlayImage];
                            break;
                        case 9:
                            //Luminosity
                            self.outputImage = [BlendModeLayerStyle luminosityBlendImage:basicImage :overlayImage];
                            break;
                        default:
                            break;
                    }
                }
                usleep(1000);
            }
            
        }
    });
    
    
    //initialize special effect
    special_effect = @"";
    specialEffect_array = [[NSMutableArray alloc] initWithObjects:@"white strobe", @"black strobe", @"fade to white", @"fade to black", @"gaussian blur", @"zoom", @"posterize", @"solarize", @"pixellate", @"superpixellate", @"caleido tl", @"caleido tr", @"caleido bl", @"caleido br", @"times ×4", @"times ×9 flipping", @"warhol", @"threshold", @"old times", @"freeze", nil];
    running_frame = 0;
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeOrientation];
    [self start_timer];    
    [self init_external_screen];
}


//update subviews constraints when device orientation is changed.
- (void)updateSubviewsConstraints
{
    //set round corner
    self.view_record_icon.layer.cornerRadius = self.view_record_icon.frame.size.width/2.0;
    self.view_record_icon.clipsToBounds = true;
    
    self.view_basic_video.layer.cornerRadius = 5.0;
    self.view_basic_video.clipsToBounds = true;
   
    self.view_overlay_video.layer.cornerRadius = 5.0;
    self.view_overlay_video.clipsToBounds = true;
    
    
    self.view_image_add.layer.cornerRadius = 5.0;
    self.view_image_add.clipsToBounds = true;
    
    self.view_text_add.layer.cornerRadius = 5.0;
    self.view_text_add.clipsToBounds = true;    
    
    //update custom ui sliders
    {
        //basic sliders
        [self.slider_basic_opacity updateView];
        [self.slider_basic_speed updateView];
        [self.slider_basic_sensor updateView];
        
        //overlay sliders
        [self.slider_overlay_opacity updateView];
        [self.slider_overlay_speed updateView];
        [self.slider_overlay_sensor updateView];
        
        //video channel slider
        [self.slider_video_channel updateView];
        
        //image filter sliders
        [self.slider_image_opacity updateView];
        [self.slider_image_sensor updateView];
        
        //text filter sliders
        [self.slider_text_opacity updateView];
        [self.slider_text_sensor updateView];
    }
    
    //rotate pane switchers text labels
    [self.lbl_preview_back setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    [self.lbl_preview_next setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.lbl_control_back_left setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.lbl_control_next_left setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.lbl_control_back_right setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    [self.lbl_control_next_right setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    [self.lbl_effects_back setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.lbl_effects_next setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    //rotate 90 degree about "multiplay" labels
    [self.lbl_basic_multiplay setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.lbl_overlay_multiplay setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [orientation_timer invalidate];
    orientation_timer = nil;
}




/*----------------------------------     setting orientation part    -----------------------------------------*/
//updating orientation timer execution function
-(void)updateOrientation
{
    if (UIDevice.currentDevice.orientation != current_orientation) {
        [self setOrientation:UIDevice.currentDevice.orientation];
    }
}

//init theme when user open app at the first time
-(void)initializeOrientation
{
    double screen_width = self.view.frame.size.width;
    double screen_height = self.view.frame.size.height;
    if (screen_width < screen_height) {
        //set portrait constraint
        self.constraint_preview_left.constant = 0;
        self.constraint_preview_right.constant = 0;
        self.constraint_preview_top.constant = 20;
        self.constraint_preview_bottom.constant = 2*screen_height/3;
        self.constraint_control_left.constant = 5;
        self.constraint_control_right.constant = 5;
        self.constraint_control_top.constant = screen_height/3 + 5;
        self.constraint_control_bottom.constant = screen_height/3 - 5;
        self.constraint_effects_left.constant = 0;
        self.constraint_effects_right.constant = 0;
        self.constraint_effects_top.constant = 2*screen_height/3 + 5;
        self.constraint_effects_bottom.constant = 0;
        
        //hide pane switcher buttons and resize width of pan switcher buttons
        [self.view_preview_back setHidden:YES];
        [self.view_preview_next setHidden:YES];
        [self.view_control_back setHidden:YES];
        [self.view_control_next setHidden:YES];
        [self.view_effects_back setHidden:YES];
        [self.view_effects_next setHidden:YES];
        
        //set round of content view
        self.content_preview.layer.cornerRadius = 0.0;
        self.content_preview.clipsToBounds = true;
        self.content_control.layer.cornerRadius = 5.0;
        self.content_control.clipsToBounds = true;
        self.content_effects.layer.cornerRadius = 0.0;
        self.content_effects.clipsToBounds = true;
        
        [UIView animateWithDuration:0.05 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self.view_menu setHidden:NO];
        current_orientation = UIDeviceOrientationPortrait;
    }else
    {
        //set landscape left constraint
        self.constraint_preview_left.constant = -screen_width + 110;
        self.constraint_preview_right.constant = screen_width - 30;
        self.constraint_preview_top.constant = 20;
        self.constraint_preview_bottom.constant = 20;
        self.constraint_control_left.constant = 40;
        self.constraint_control_right.constant = 40;
        self.constraint_control_top.constant = 20;
        self.constraint_control_bottom.constant = 20;
        self.constraint_effects_left.constant = screen_width - 30;
        self.constraint_effects_right.constant = -screen_width + 110;
        self.constraint_effects_top.constant = 20;
        self.constraint_effects_bottom.constant = 20;
        
        //hide pane switcher buttons and resize width of pan switcher buttons
        [self.view_preview_back setHidden:NO];
        [self.view_preview_next setHidden:NO];
        [self.view_control_back setHidden:YES];
        [self.view_control_next setHidden:YES];
        [self.view_effects_back setHidden:NO];
        [self.view_effects_next setHidden:NO];
        
        //hide right style label of pane switcher buttons in control pane
        [self.lbl_control_back_right setHidden:YES];
        [self.lbl_control_next_right setHidden:YES];
        [self.lbl_control_back_left setHidden:NO];
        [self.lbl_control_next_left setHidden:NO];
        
        //set round of content view
        self.content_preview.layer.cornerRadius = 5.0;
        self.content_preview.clipsToBounds = true;
        self.content_control.layer.cornerRadius = 5.0;
        self.content_control.clipsToBounds = true;
        self.content_effects.layer.cornerRadius = 5.0;
        self.content_effects.clipsToBounds = true;
        
        [UIView animateWithDuration:0.05 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self.view_menu setHidden:YES];
        current_orientation = UIDeviceOrientationLandscapeLeft;
    }
    [self setTheme];
    [self updateSubviewsConstraints];
    orientation_timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self
                                                       selector:@selector(updateOrientation)
                                                       userInfo:nil
                                                        repeats:YES];
}
//setting orientation function
-(void)setOrientation:(UIDeviceOrientation)deviceOrientation
{
    double screen_width = self.view.frame.size.width;
    double screen_height = self.view.frame.size.height;
    if (screen_width < screen_height) {
        //set portrait constraint
        self.constraint_preview_left.constant = 0;
        self.constraint_preview_right.constant = 0;
        self.constraint_preview_top.constant = 20;
        self.constraint_preview_bottom.constant = 2*screen_height/3;
        self.constraint_control_left.constant = 5;
        self.constraint_control_right.constant = 5;
        self.constraint_control_top.constant = screen_height/3 + 5;
        self.constraint_control_bottom.constant = screen_height/3 - 5;
        self.constraint_effects_left.constant = 0;
        self.constraint_effects_right.constant = 0;
        self.constraint_effects_top.constant = 2*screen_height/3 + 5;
        self.constraint_effects_bottom.constant = 0;
        
        
        //hide pane switcher buttons and resize width of pan switcher buttons
        [self.view_preview_back setHidden:YES];
        [self.view_preview_next setHidden:YES];
        [self.view_control_back setHidden:YES];
        [self.view_control_next setHidden:YES];
        [self.view_effects_back setHidden:YES];
        [self.view_effects_next setHidden:YES];
        
        //set round of content view
        self.content_preview.layer.cornerRadius = 0.0;
        self.content_preview.clipsToBounds = true;
        self.content_control.layer.cornerRadius = 5.0;
        self.content_control.clipsToBounds = true;
        self.content_effects.layer.cornerRadius = 0.0;
        self.content_effects.clipsToBounds = true;
        
        [UIView animateWithDuration:0.05 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self.view_menu setHidden:NO];
        current_orientation = UIDeviceOrientationPortrait;
        [self updateSubviewsConstraints];
    }else
    {
        if (deviceOrientation == UIDeviceOrientationLandscapeLeft){
            //set landscape left constraint
            self.constraint_preview_left.constant = -screen_width + 110;
            self.constraint_preview_right.constant = screen_width - 30;
            self.constraint_preview_top.constant = 20;
            self.constraint_preview_bottom.constant = 20;
            self.constraint_control_left.constant = 40;
            self.constraint_control_right.constant = 40;
            self.constraint_control_top.constant = 20;
            self.constraint_control_bottom.constant = 20;
            self.constraint_effects_left.constant = screen_width - 30;
            self.constraint_effects_right.constant = -screen_width + 110;
            self.constraint_effects_top.constant = 20;
            self.constraint_effects_bottom.constant = 20;
            
            //hide pane switcher buttons and resize width of pan switcher buttons
            [self.view_preview_back setHidden:NO];
            [self.view_preview_next setHidden:NO];
            [self.view_control_back setHidden:YES];
            [self.view_control_next setHidden:YES];
            [self.view_effects_back setHidden:NO];
            [self.view_effects_next setHidden:NO];
            
            //hide right style label of pane switcher buttons in control pane
            [self.lbl_control_back_right setHidden:YES];
            [self.lbl_control_next_right setHidden:YES];
            [self.lbl_control_back_left setHidden:NO];
            [self.lbl_control_next_left setHidden:NO];
            
            //set round of content view
            self.content_preview.layer.cornerRadius = 5.0;
            self.content_preview.clipsToBounds = true;
            self.content_control.layer.cornerRadius = 5.0;
            self.content_control.clipsToBounds = true;
            self.content_effects.layer.cornerRadius = 5.0;
            self.content_effects.clipsToBounds = true;
            
            [UIView animateWithDuration:0.05 animations:^{
                [self.view layoutIfNeeded];
            }];
            [self.view_menu setHidden:YES];
            current_orientation = deviceOrientation;
            [self updateSubviewsConstraints];
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
            //set landscape right constraint
            self.constraint_preview_left.constant = screen_width - 30;
            self.constraint_preview_right.constant = -screen_width + 110;
            self.constraint_preview_top.constant = 20;
            self.constraint_preview_bottom.constant = 20;
            self.constraint_control_left.constant = 40;
            self.constraint_control_right.constant = 40;
            self.constraint_control_top.constant = 20;
            self.constraint_control_bottom.constant = 20;
            self.constraint_effects_left.constant = -screen_width + 110;
            self.constraint_effects_right.constant = screen_width - 30;
            self.constraint_effects_top.constant = 20;
            self.constraint_effects_bottom.constant = 20;
            
            //hide pane switcher buttons and resize width of pan switcher buttons
            [self.view_preview_back setHidden:NO];
            [self.view_preview_next setHidden:NO];
            [self.view_control_back setHidden:YES];
            [self.view_control_next setHidden:YES];
            [self.view_effects_back setHidden:NO];
            [self.view_effects_next setHidden:NO];
            
            //hide left style label of pane switcher buttons in control pane
            [self.lbl_control_back_right setHidden:NO];
            [self.lbl_control_next_right setHidden:NO];
            [self.lbl_control_back_left setHidden:YES];
            [self.lbl_control_next_left setHidden:YES];
            
            //set round of content view
            self.content_preview.layer.cornerRadius = 5.0;
            self.content_preview.clipsToBounds = true;
            self.content_control.layer.cornerRadius = 5.0;
            self.content_control.clipsToBounds = true;
            self.content_effects.layer.cornerRadius = 5.0;
            self.content_effects.clipsToBounds = true;
            
            [UIView animateWithDuration:0.05 animations:^{
                [self.view layoutIfNeeded];
            }];
            [self.view_menu setHidden:YES];
            current_orientation = deviceOrientation;
            [self updateSubviewsConstraints];
        }
    }
    [self setTheme];
    
}
/*--------------------------------------------------------------------------------------------------------------------*/








/*----------------------------- set theme color style per day/night mode-------------------------------*/
-(void)setTheme
{
    if (global.day_mode) {
        //set day mode
        self.img_menu_icon.image = [UIImage imageNamed:@"icon_menu_0095FF_default.png"];
        [self.view_basic_video setBackgroundColor:global.backgroundColor4];
        self.img_basic_select_layer_up.image = [UIImage imageNamed:@"icon_arrowup_white.png"];
        self.img_basic_select_layer_down.image = [UIImage imageNamed:@"icon_arrowdown_white.png"];
        [self.lbl_basic_multiplay setTextColor:global.backgroundColor9];
        self.img_basic_edit_video.image = [UIImage imageNamed:@"icon_editvideo_white.png"];
        self.img_basic_play_video.image = [UIImage imageNamed:@"icon_play_white.png"];
        self.img_basic_select_video_icon.image = [UIImage imageNamed:@"icon_plus_white.png"];
        
        [self.view_overlay_video setBackgroundColor:global.backgroundColor4];
        self.img_overlay_select_layer_up.image = [UIImage imageNamed:@"icon_arrowup_white.png"];
        self.img_overlay_select_layer_down.image = [UIImage imageNamed:@"icon_arrowdown_white.png"];
        [self.lbl_overlay_multiplay setTextColor:global.backgroundColor9];
        self.img_overlay_edit_video.image = [UIImage imageNamed:@"icon_editvideo_white.png"];
        self.img_overlay_play_video.image = [UIImage imageNamed:@"icon_play_white.png"];
        self.img_overlay_select_video_icon.image = [UIImage imageNamed:@"icon_plus_white.png"];
        
        [self.btn_effect1 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_1_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect1 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_1_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect2 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_2_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect2 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_2_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect3 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_3_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect3 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_3_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect4 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_4_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect4 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_4_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect5 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_5_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect5 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_5_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect6 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_6_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect6 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_6_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect7 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_7_dbdbdb_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect7 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_7_dbdbdb_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_add_effect setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_fx_day_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_add_effect setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_fx_day_glow_active.png"] forState:UIControlStateHighlighted];
        
        
        [self.view_image_add setBackgroundColor:global.backgroundColor4];
        self.img_image_add_icon.image = [UIImage imageNamed:@"icon_plus_white.png"];
        self.img_image_close.image = [UIImage imageNamed:@"icon_cancel_white.png"];
        
        [self.view_text_add setBackgroundColor:global.backgroundColor4];
        self.img_text_add_icon.image = [UIImage imageNamed:@"icon_plus_white.png"];
        self.img_text_close.image = [UIImage imageNamed:@"icon_cancel_white.png"];
        
        [self.content_preview setBackgroundColor:global.backgroundColor4];
        [self.content_control setBackgroundColor:global.backgroundColor9];
        [self.content_effects setBackgroundColor:global.backgroundColor6];
        [self.view_preview_back setBackgroundColor:global.backgroundColor4];
        [self.view_preview_next setBackgroundColor:global.backgroundColor4];
        [self.view_control_back setBackgroundColor:global.backgroundColor9];
        [self.view_control_next setBackgroundColor:global.backgroundColor9];
        [self.view_effects_back setBackgroundColor:global.backgroundColor6];
        [self.view_effects_next setBackgroundColor:global.backgroundColor6];
        [self.lbl_record_state setTextColor:global.backgroundColor9];
        
        //set track images
        UIImage *trackImage = [UIImage imageNamed:@"slider_track_e6e6e6.png"];
        UIImage *trackImage1 = [UIImage imageNamed:@"slider_track_ffffff.png"];
        [self.slider_basic_opacity setSliderTrackImage:trackImage];
        [self.slider_basic_speed setSliderTrackImage:trackImage];
        [self.slider_basic_sensor setSliderTrackImage:trackImage];
        [self.slider_overlay_opacity setSliderTrackImage:trackImage];
        [self.slider_overlay_speed setSliderTrackImage:trackImage];
        [self.slider_overlay_sensor setSliderTrackImage:trackImage];
        [self.slider_video_channel setSliderTrackImage:trackImage];
        [self.slider_image_opacity setSliderTrackImage:trackImage1];
        [self.slider_image_sensor setSliderTrackImage:trackImage1];
        [self.slider_text_opacity setSliderTrackImage:trackImage1];
        [self.slider_text_sensor setSliderTrackImage:trackImage1];
        
        //set layer tableview background
        self.tbl_baseLayer.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.tbl_overlayLayer.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        if (current_orientation == UIDeviceOrientationLandscapeRight || current_orientation == UIDeviceOrientationLandscapeLeft) {
            //landscape mode
            [self.view_background setBackgroundColor:global.backgroundColor8];
        }else{
            //portrait mode
            [self.view_background setBackgroundColor:global.backgroundColor6];
            
        }
        
    }else {
        //set night mode
        
        self.img_menu_icon.image = [UIImage imageNamed:@"icon_menu_333333_default.png"];
        [self.lbl_record_state setTextColor:global.backgroundColor9];
        [self.view_basic_video setBackgroundColor:[UIColor blackColor]];
        self.img_basic_select_layer_up.image = [UIImage imageNamed:@"icon_arrowup_333333_default.png"];
        self.img_basic_select_layer_down.image = [UIImage imageNamed:@"icon_arrowdown_333333_default.png"];
        [self.lbl_basic_multiplay setTextColor:global.backgroundColor1];
        self.img_basic_edit_video.image = [UIImage imageNamed:@"icon_editvideo_333333_default.png"];
        self.img_basic_play_video.image = [UIImage imageNamed:@"icon_play_333333_default.png"];
        self.img_basic_select_video_icon.image = [UIImage imageNamed:@"icon_plus_855dfb_glow_default.png"];
        
        [self.view_overlay_video setBackgroundColor:[UIColor blackColor]];
        self.img_overlay_select_layer_up.image = [UIImage imageNamed:@"icon_arrowup_333333_default.png"];
        self.img_overlay_select_layer_down.image = [UIImage imageNamed:@"icon_arrowdown_333333_default.png"];
        [self.lbl_overlay_multiplay setTextColor:global.backgroundColor1];
        self.img_overlay_edit_video.image = [UIImage imageNamed:@"icon_editvideo_333333_default.png"];
        self.img_overlay_play_video.image = [UIImage imageNamed:@"icon_play_333333_default.png"];
        self.img_overlay_select_video_icon.image = [UIImage imageNamed:@"icon_plus_2BD3D4_glow_default.png"];
        
        [self.btn_effect1 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_1_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect1 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_1_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect2 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_2_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect2 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_2_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect3 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_3_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect3 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_3_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect4 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_4_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect4 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_4_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect5 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_5_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect5 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_5_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect6 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_6_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect6 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_6_333333_glow_active.png"] forState:UIControlStateHighlighted];
        [self.btn_effect7 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_7_333333_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_effect7 setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_7_333333_glow_active.png"] forState:UIControlStateHighlighted];
        
        [self.btn_add_effect setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_fx_night_glow_default.png"] forState:UIControlStateNormal];
        [self.btn_add_effect setBackgroundImage:[UIImage imageNamed:@"button_fxpad_item_fx_night_glow_active.png"] forState:UIControlStateHighlighted];
       
        
        
        [self.view_image_add setBackgroundColor:[UIColor blackColor]];
        self.img_image_add_icon.image = [UIImage imageNamed:@"icon_plus_0095FF_glow_default.png"];
        self.img_image_close.image = [UIImage imageNamed:@"icon_cancel_333333_default.png"];
        
        [self.view_text_add setBackgroundColor:[UIColor blackColor]];
        self.img_text_add_icon.image = [UIImage imageNamed:@"icon_plus_0095FF_glow_default.png"];
        self.img_text_close.image = [UIImage imageNamed:@"icon_cancel_333333_default.png"];
        
        [self.content_preview setBackgroundColor:[UIColor blackColor]];
        [self.content_control setBackgroundColor:global.backgroundColor2];
        [self.content_effects setBackgroundColor:[UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0]];
        [self.view_preview_back setBackgroundColor:global.backgroundColor1];
        [self.view_preview_next setBackgroundColor:global.backgroundColor1];
        [self.view_control_back setBackgroundColor:global.backgroundColor2];
        [self.view_control_next setBackgroundColor:global.backgroundColor2];
        [self.view_effects_back setBackgroundColor:global.backgroundColor1];
        [self.view_effects_next setBackgroundColor:global.backgroundColor1];
        
        //set track images
        UIImage *trackImage = [UIImage imageNamed:@"slider_track_474646.png"];
        UIImage *trackImage1 = [UIImage imageNamed:@"slider_track_333333.png"];
        [self.slider_basic_opacity setSliderTrackImage:trackImage];
        [self.slider_basic_speed setSliderTrackImage:trackImage];
        [self.slider_basic_sensor setSliderTrackImage:trackImage];
        [self.slider_overlay_opacity setSliderTrackImage:trackImage];
        [self.slider_overlay_speed setSliderTrackImage:trackImage];
        [self.slider_overlay_sensor setSliderTrackImage:trackImage];
        [self.slider_video_channel setSliderTrackImage:trackImage];
        [self.slider_image_opacity setSliderTrackImage:trackImage1];
        [self.slider_image_sensor setSliderTrackImage:trackImage1];
        [self.slider_text_opacity setSliderTrackImage:trackImage1];
        [self.slider_text_sensor setSliderTrackImage:trackImage1];
        
        //set layer tableview background
        self.tbl_baseLayer.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.tbl_overlayLayer.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
        if (current_orientation == UIDeviceOrientationLandscapeRight || current_orientation == UIDeviceOrientationLandscapeLeft) {
            //landscape mode
            [self.view_background setBackgroundColor:global.backgroundColor3];
            
        }else{
            //portrait mode
            [self.view_background setBackgroundColor:[UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0]];
        }
    }
}
/*--------------------------------------------------------------------------------------------------------------------*/


- (IBAction)action_menu_down:(id)sender {
    self.img_menu_icon_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}

/*---------------------------------- add menu controller -----------------------------------*/

- (IBAction)action_menu_clicked:(id)sender {
    self.img_menu_icon_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    LeftMenuViewController *leftMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    leftMenu.modalPresentationStyle = UIModalPresentationCustom;
    leftMenu.transitioningDelegate = self;
    leftMenu.mainViewController = self;
    [self presentViewController:leftMenu animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    
    return [[LeftMenuPresentation alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return presentTransition;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return dismissTransition;
}
/*----------------------------------------------------------------------------------------*/










- (IBAction)btn_preview_back_clicked:(id)sender {
    //hide back and next button in preview content
    [self.view_preview_back setHidden:YES];
    [self.view_preview_next setHidden:YES];
    [self.view_control_back setHidden:NO];
    [self.view_control_next setHidden:NO];
    [self.view_effects_back setHidden:NO];
    [self.view_effects_next setHidden:NO];
    
    //decrease left constraint and increase right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant - (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant + (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant - (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant + (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant - (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant + (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)btn_preview_next_clicked:(id)sender {
    //hide back and next button in preview content
    [self.view_preview_back setHidden:YES];
    [self.view_preview_next setHidden:YES];
    [self.view_control_back setHidden:NO];
    [self.view_control_next setHidden:NO];
    [self.view_effects_back setHidden:NO];
    [self.view_effects_next setHidden:NO];
    
    //increase left constraint and decrease right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant + (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant - (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant + (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant - (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant + (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant - (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)btn_control_back_clicked:(id)sender {
    //hide back and next button in control content
    [self.view_preview_back setHidden:NO];
    [self.view_preview_next setHidden:NO];
    [self.view_control_back setHidden:YES];
    [self.view_control_next setHidden:YES];
    [self.view_effects_back setHidden:NO];
    [self.view_effects_next setHidden:NO];
    
    //decrease left constraint and increase right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant - (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant + (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant - (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant + (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant - (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant + (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)btn_control_next_clicked:(id)sender {
    //hide back and next button in control content
    [self.view_preview_back setHidden:NO];
    [self.view_preview_next setHidden:NO];
    [self.view_control_back setHidden:YES];
    [self.view_control_next setHidden:YES];
    [self.view_effects_back setHidden:NO];
    [self.view_effects_next setHidden:NO];
    
    //increase left constraint and decrease right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant + (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant - (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant + (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant - (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant + (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant - (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)btn_effects_back_clicked:(id)sender {
    //hide back and next button in effects content
    [self.view_preview_back setHidden:NO];
    [self.view_preview_next setHidden:NO];
    [self.view_control_back setHidden:NO];
    [self.view_control_next setHidden:NO];
    [self.view_effects_back setHidden:YES];
    [self.view_effects_next setHidden:YES];
    
    //decrease left constraint and increase right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant - (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant + (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant - (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant + (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant - (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant + (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)btn_effects_next_clicked:(id)sender {
    //hide back and next button in effects content
    [self.view_preview_back setHidden:NO];
    [self.view_preview_next setHidden:NO];
    [self.view_control_back setHidden:NO];
    [self.view_control_next setHidden:NO];
    [self.view_effects_back setHidden:YES];
    [self.view_effects_next setHidden:YES];
    
    //increase left constraint and decrease right constraint
    double screen_width = self.view.frame.size.width;
    self.constraint_preview_left.constant = self.constraint_preview_left.constant + (screen_width-70);
    self.constraint_preview_right.constant = self.constraint_preview_right.constant - (screen_width-70);
    self.constraint_control_left.constant = self.constraint_control_left.constant + (screen_width-70);
    self.constraint_control_right.constant = self.constraint_control_right.constant - (screen_width-70);
    self.constraint_effects_left.constant = self.constraint_effects_left.constant + (screen_width-70);
    self.constraint_effects_right.constant = self.constraint_effects_right.constant - (screen_width-70);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}







- (IBAction)action_record_btn_clicked:(id)sender {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"This option is coming very soon! Look out for the next update of DJVJ." preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alertController animated:YES completion:nil];
//    return;
    
    if (recording_state) {
    //stop recording
        
        //set recording state
        recording_state = NO;
        
        self.lbl_record_state.text = @"Press To Record Output";
        //show alert for save
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Would you like to save the video recording in your Photo Gallery?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //save videos to photos album
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusAuthorized) {
                self->frame_size = self->recording_frameNum;
                
                self->savingVideoState = 1;
                self->saving_frameNum = 0;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self saveVideo:self->frame_size];
                });
            }else
            {
                UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:@"" message:@"Photos Access not allowed. \n Please allow to Access Photos" preferredStyle:UIAlertControllerStyleAlert];
                [alertController1 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //go to setting
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                }]];
                [self presentViewController:alertController1 animated:YES completion:nil];
            }
            //initialize recording frame list
            self->recording_frameNum = -1;
            [self.lbl_recordingTime setHidden:YES];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //initialize recording frame list
            self->recording_frameNum = -1;
            [self.lbl_recordingTime setHidden:YES];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else
    {
    //start recording
        self.lbl_recordingTime.text = @"00:00";
        [self.lbl_recordingTime setHidden:NO];
        self.lbl_record_state.text = @"Press To Stop Output";
        
        
        
        //set recording state
        recording_state = YES;
    }
    
    
}

- (IBAction)action_basic_select_layer_clicked:(id)sender {
    [self.view_selectLayer setHidden:NO];
    [self.tbl_overlayLayer setHidden:YES];
    [self.tbl_baseLayer setHidden:NO];
    self.lbl_basic_multiplay.text = @"";
    self.img_basic_layer_background.image = [UIImage imageNamed:@"button_stadium_vertical_855DFB_glow_active.png"];
    [self.tbl_baseLayer reloadData];
}

- (IBAction)action_basic_video_edit_down:(id)sender {
    self.img_basic_edit_video_background.image = [UIImage imageNamed:@"button_circle_855DFB_glow_active.png"];
}

- (IBAction)action_basic_video_edit_clicked:(id)sender {
    self.img_basic_edit_video_background.image = [UIImage imageNamed:@"button_circle_855DFB_glow_default.png"];
    if (self.basic_frame_list.count == 0) {
        return;
    }
//    [self stop_timer];
    EditVideoViewController *editViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"EditVideoViewController"];
    editViewController.frame_list = self.basic_frame_list;
    editViewController.videoID = self.basic_videoID;
    editViewController.video_type = 0;
    editViewController.root_viewController = self;
    editViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //selectViewController.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:editViewController animated:NO completion:nil];
}


- (IBAction)action_basic_play_video_down:(id)sender {
    self.img_basic_play_video_background.image = [UIImage imageNamed:@"button_circle_855DFB_glow_active.png"];
}

- (IBAction)action_basic_play_video_clicked:(id)sender {
    self.img_basic_play_video_background.image = [UIImage imageNamed:@"button_circle_855DFB_glow_default.png"];
    self.basic_current_frameNumber = self.basic_start_frameNumber;
}
- (IBAction)action_basic_select_video_clicked:(id)sender {
//    [self stop_timer];
    SelectVideoViewController *selectViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SelectVideoViewController"];
    selectViewController.root_viewController = self;
    selectViewController.video_type = 0;
    
    selectViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //selectViewController.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:selectViewController animated:NO completion:nil];
}
- (IBAction)basic_opacity_valueChanged:(id)sender {
    self.basic_opacity = MIN(1.0 , 2*(1.0-self.slider_video_channel.value))* self.slider_basic_opacity.value;
}
- (IBAction)basic_speed_valueChanged:(id)sender {
    double speed_slider = self.slider_basic_speed.value;
    if (speed_slider > 0) {
        self.basic_speed = pow(10,speed_slider*2-1);
    }else
    {
        self.basic_speed = 0.0;
    }
}
- (IBAction)basic_sensor_valueChanged:(id)sender {
    double sensor_value = self.slider_basic_sensor.value;
    if (sensor_value > 0.05) {
        double sensitivity = pow(5, 2*sensor_value);
        self.basic_scale = (self.audio_amplitude*sensitivity + 1.0 + self.basic_scale)/2.0;
    }else
    {
        self.basic_scale = 1.0;
    }
}



- (IBAction)action_overlay_select_layer_clicked:(id)sender {
    [self.view_selectLayer setHidden:NO];
    [self.tbl_overlayLayer setHidden:NO];
    [self.tbl_baseLayer setHidden:YES];
    self.lbl_overlay_multiplay.text = @"";
    self.img_overlay_layer_background.image = [UIImage imageNamed:@"button_stadium_vertical_2BD3D4_glow_active.png"];
    [self.tbl_overlayLayer reloadData];
}

- (IBAction)action_overlay_video_edit_down:(id)sender {
    self.img_overlay_edit_video_background.image = [UIImage imageNamed:@"button_circle_2BD3D4_glow_active.png"];
}

- (IBAction)action_overlay_video_edit_clicked:(id)sender {
    self.img_overlay_edit_video_background.image = [UIImage imageNamed:@"button_circle_2BD3D4_glow_default.png"];
    if (self.overlay_frame_list.count == 0) {
        return;
    }
//    [self stop_timer];
    EditVideoViewController *editViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"EditVideoViewController"];
    editViewController.frame_list = self.overlay_frame_list;
    editViewController.videoID = self.overlay_videoID;
    editViewController.video_type = 1;
    editViewController.root_viewController = self;
    editViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //selectViewController.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:editViewController animated:NO completion:nil];
}

- (IBAction)action_overlay_play_video_down:(id)sender {
    self.img_overlay_play_video_background.image = [UIImage imageNamed:@"button_circle_2BD3D4_glow_active.png"];
}

- (IBAction)action_overlay_play_video_clicked:(id)sender {
    self.img_overlay_play_video_background.image = [UIImage imageNamed:@"button_circle_2BD3D4_glow_default.png"];
    self.overlay_current_frameNumber = self.overlay_start_frameNumber;
}

- (IBAction)action_overlay_select_video_clicked:(id)sender {
//    [self stop_timer];
    SelectVideoViewController *selectViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SelectVideoViewController"];
    selectViewController.root_viewController = self;
    selectViewController.video_type = 1;
    
    selectViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //selectViewController.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:selectViewController animated:NO completion:nil];
}
- (IBAction)overlay_opacity_valueChanged:(id)sender {
    self.overlay_opacity = MIN(1.0 , 2*self.slider_video_channel.value)* self.slider_overlay_opacity.value;
}
- (IBAction)overlay_speed_valueChanged:(id)sender {
    double speed_slider = self.slider_overlay_speed.value;
    if (speed_slider > 0) {
        self.overlay_speed = pow(10,speed_slider*2-1);
    }else
    {
        self.overlay_speed = 0.0;
    }
}
- (IBAction)overlay_sensor_valueChanged:(id)sender {
    double sensor_value = self.slider_overlay_sensor.value;
    if (sensor_value > 0.05) {
        double sensitivity = pow(5, 2*sensor_value);
        self.overlay_scale = (self.audio_amplitude*sensitivity + 1.0 + self.overlay_scale)/2.0;
    }else
    {
        self.overlay_scale = 1.0;
    }
    
    
}


- (IBAction)video_channel_valueChanged:(id)sender {
    self.basic_opacity = MIN(1.0 , 2*(1.0-self.slider_video_channel.value))* self.slider_basic_opacity.value;
    self.overlay_opacity = MIN(1.0 , 2*self.slider_video_channel.value)* self.slider_overlay_opacity.value;
}

- (IBAction)action_effect1:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_1"];
}

- (IBAction)action_effect2:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_2"];
}

- (IBAction)action_effect3:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_3"];
}

- (IBAction)action_effect4:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_4"];
}

- (IBAction)action_effect5:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_5"];
}

- (IBAction)action_effect6:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_6"];
}

- (IBAction)action_effect7:(id)sender {
    special_effect = [[NSUserDefaults standardUserDefaults] objectForKey:@"effect_7"];
}

- (IBAction)action_effect_close:(id)sender {
    running_frame = 0;
    special_effect = @"";
}

- (IBAction)action_add_effect_clicked:(id)sender {
    SpecialEffectViewController *effectViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SpecialEffectViewController"];
    effectViewController.root_viewController = self;
    
    effectViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:effectViewController animated:NO completion:nil];
}



- (IBAction)action_image_add:(id)sender {
//    [self stop_timer];
    SelectImageViewController *selectViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SelectImageViewController"];
    selectViewController.root_viewController = self;
    selectViewController.selected_image = self.imageOrigin;
    selectViewController.image_size = self.image_size;
    selectViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;    
    [self presentViewController:selectViewController animated:NO completion:nil];
    
}
- (IBAction)actopm_image_close_down:(id)sender {
    self.img_image_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}
- (IBAction)action_image_close:(id)sender {
    self.img_image_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    self.imageOrigin = [[UIImage alloc] init];
}
- (IBAction)image_opacity_valueChanged:(id)sender {
}
- (IBAction)image_sensor_valueChanged:(id)sender {
    double sensor_value = self.slider_image_sensor.value;
    if (sensor_value > 0.05) {
        double sensitivity = pow(5, 2*sensor_value);
        self.image_scale = (self.audio_amplitude*sensitivity + 1.0 + self.image_scale)/2.0;
    }else
    {
        self.image_scale = 1.0;
    }
    
}



- (IBAction)action_text_add:(id)sender {
//    [self stop_timer];
    TextViewController *textViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewController"];
    textViewController.root_viewController = self;
    textViewController.font_size = self.font_size;
    textViewController.textString = self.textString;
    textViewController.fontName = self.fontName;
    textViewController.fontColor = self.fontColor; 
    
    textViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:textViewController animated:NO completion:nil];
}

- (IBAction)action_text_close_down:(id)sender {
    self.img_text_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}

- (IBAction)action_text_close:(id)sender {
    self.img_text_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    self.textString = @"";
}
- (IBAction)text_opacity_valueChanged:(id)sender {
}
- (IBAction)text_sensor_valueChanged:(id)sender {
    double sensor_value = self.slider_text_sensor.value;
    if (sensor_value > 0.05) {
        double sensitivity = pow(5, 2*sensor_value);
        self.text_scale = (self.audio_amplitude*sensitivity + 1.0 + self.text_scale)/2.0;
    }else
    {
        self.text_scale = 1.0;
    }
    
}


/*--------------------------display output video frame in realtime -------------------------*/
-(void)displayOutputVideoFrame:(NSTimer *)timer {
//    self.img_preview_overlay.image = [UIImage imageWithCIImage:self.outputImage];
    CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
    UIGraphicsBeginImageContext(newSize);
    if (self.outputImage != nil) {
        UIImage *outputImg = [UIImage imageWithCIImage:self.outputImage];
        [outputImg drawInRect:CGRectMake(0, 0, self.outputWidth, self.outputHeight)];
    }
    
    
    //draw image layer image
    if (!CGSizeEqualToSize(self.imageOrigin.size, CGSizeZero)) {
        double scale = self.image_scale * self.image_size;
        double imageWidth = self.outputWidth * scale;
        double imageHeight = self.outputWidth * scale * self.imageOrigin.size.height / self.imageOrigin.size.width;
        
        [self.img_image_layer.image drawInRect:CGRectMake((self.outputWidth - imageWidth)/2.0, (self.outputHeight - imageHeight)/2.0, imageWidth, imageHeight) blendMode:kCGBlendModeNormal alpha:self.slider_image_opacity.value];
    }
    
    
    //draw text layer
    
    UIFont *txtFont = [UIFont fontWithName:self.fontName size:self.outputWidth*self.font_size*self.text_scale/4];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = @{NSFontAttributeName:txtFont, NSForegroundColorAttributeName:[self.fontColor colorWithAlphaComponent:self.slider_text_opacity.value], NSParagraphStyleAttributeName:paragraphStyle};
    
    
    CGRect txtRect = [self.textString boundingRectWithSize:CGSizeZero
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:nil];
    [self.textString drawInRect:CGRectMake((self.outputWidth - txtRect.size.width)/2.0, (self.outputHeight - txtRect.size.height)/2.0, txtRect.size.width, txtRect.size.height) withAttributes:attributes];

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([special_effect isEqualToString:@""]) {
        self.finalImage = resultImage;
    }else
    {
        int special_index = (int)[specialEffect_array indexOfObject:special_effect];
        switch (special_index) {
            case 0:
                //white strobe                
                self.finalImage = [SpecialEffectLayerStyle whiteStrobe:resultImage :running_frame];
                running_frame = running_frame + 1;
                break;
            case 1:
                //black strobe
                self.finalImage = [SpecialEffectLayerStyle blackStrobe:resultImage :running_frame];
                running_frame = running_frame + 1;
                break;
            case 2:
                //fade to white
                self.finalImage = [SpecialEffectLayerStyle fadeToWhite:resultImage :running_frame];
                running_frame = running_frame + 1;
                break;
            case 3:
                //fade to black
                self.finalImage = [SpecialEffectLayerStyle fadeToBlack:resultImage :running_frame];
                running_frame = running_frame + 1;
                break;
            case 4:
                //gaussian blur
                self.finalImage = [SpecialEffectLayerStyle gaussianBlur:resultImage];
                break;
            case 5:
                //zoom
                self.finalImage = [SpecialEffectLayerStyle zoom:resultImage];
                break;
            case 6:
                //posterize
                self.finalImage = [SpecialEffectLayerStyle posterize:resultImage];
                break;
            case 7:
                //solarize
                self.finalImage = [SpecialEffectLayerStyle solarize:resultImage];
                break;
            case 8:
                //pixellate
                self.finalImage = [SpecialEffectLayerStyle pixellate:resultImage];
                break;
            case 9:
                //superpizellate
                self.finalImage = [SpecialEffectLayerStyle superpixellate:resultImage];
                break;
            case 10:
                //caleido TL
                self.finalImage = [SpecialEffectLayerStyle caleidoTL:resultImage];
                break;
            case 11:
                //caleido TR
                self.finalImage = [SpecialEffectLayerStyle caleidoTR:resultImage];
                break;
            case 12:
                //caleido BL
                self.finalImage = [SpecialEffectLayerStyle caleidoBL:resultImage];
                break;
            case 13:
                //caleido BR
                self.finalImage = [SpecialEffectLayerStyle caleidoBR:resultImage];
                break;
            case 14:
                //times * 4
                self.finalImage = [SpecialEffectLayerStyle times4:resultImage];
                break;
            case 15:
                //times * 9
                self.finalImage = [SpecialEffectLayerStyle times9:resultImage];
                break;
            case 16:
                //warhol
                self.finalImage = [SpecialEffectLayerStyle warhol:resultImage];
                break;
            case 17:
                //threshold
                self.finalImage = [SpecialEffectLayerStyle threshold:resultImage];
                break;
            case 18:
                //old times
                self.finalImage = [SpecialEffectLayerStyle oldTimes:resultImage];
                break;
            case 19:
                //freeze
                self.finalImage = resultImage;
                break;
                
            default:
                break;
        }
    }
    self.img_preview_overlay.image = self.finalImage;
    
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_watermark_output"] isEqualToString:@"1"]) {
        //draw logo when not purchased.
        CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
        UIGraphicsBeginImageContext(newSize);
        [self.finalImage drawInRect:CGRectMake(0, 0, self.outputWidth, self.outputHeight)];
        //draw logo image 667,265
        int logoWidth = self.outputWidth/4;
        int logoHeight = logoWidth * 265/667;
        [[UIImage imageNamed:@"logo_splash_screen.png"] drawInRect:CGRectMake((self.outputWidth-logoWidth)/2, (self.outputHeight-logoHeight)/2-8, logoWidth, logoHeight)];
        
        //draw text layer
        
        UIFont *txtFont = [UIFont fontWithName:self.fontName size:self.outputWidth/50];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *attributes = @{NSFontAttributeName:txtFont, NSForegroundColorAttributeName:[[UIColor grayColor] colorWithAlphaComponent:1.0], NSParagraphStyleAttributeName:paragraphStyle};
        
        NSString *addStr = @"TO REMOVE THIS MESSAGE,\nPLEASE PURCHASE THE OUTPUT UPGRADE\n FROM THE DJVJ MAIN MENU";
        CGRect txtRect = [addStr boundingRectWithSize:CGSizeZero
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:attributes
                                                       context:nil];
        [addStr drawInRect:CGRectMake((self.outputWidth - txtRect.size.width)/2.0, (self.outputHeight + logoHeight)/2.0, txtRect.size.width, txtRect.size.height) withAttributes:attributes];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.externalOutPutImageView.image = resultImage;
        
    }else
    {
        self.externalOutPutImageView.image = self.finalImage;
    }
    
    if (recording_state) {
        recording_frameNum = recording_frameNum + 1;
        
        NSData *pngData = UIImagePNGRepresentation(self.finalImage);
        if ([pngData length] > 0)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
            NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.PNG",recording_frameNum]];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//            }
            [pngData writeToFile:filePath atomically:YES];
        }
        
        
        
        //show recording time
        int recording_seconds = recording_frameNum/self.video_fps;
        int time_min = recording_seconds/60;
        NSString *min_str = [NSString stringWithFormat:@"%d",time_min];
        if (time_min<10) {
            min_str = [NSString stringWithFormat:@"0%d",time_min];
        }
        int time_sec = recording_seconds - 60*time_min;
        NSString *sec_str = [NSString stringWithFormat:@"%d",time_sec];
        if (time_sec<10) {
            sec_str = [NSString stringWithFormat:@"0%d",time_sec];
        }
        self.lbl_recordingTime.text = [NSString stringWithFormat:@"%@:%@",min_str,sec_str];
    }    
}
/*------------------------------------------------------------------------------------------------------*/



/*--------------------------display basic video frame in realtime -------------------------*/
-(void)displayBasicNextFrame:(NSTimer *)timer {
    if (![special_effect isEqualToString:@"freeze"]) {
        if (self.basic_frame_list.count > 0) {
//            [self.view_basic_video setBackgroundColor:[UIColor blackColor]];
//            [self.content_preview setBackgroundColor:[UIColor blackColor]];
            
            if (self.basic_current_frameNumber > self.basic_end_frameNumber) {
                self.basic_current_frameNumber = self.basic_start_frameNumber;
            }
            
            NSManagedObject * frame = [self.basic_frame_list objectAtIndex:(int)self.basic_current_frameNumber];
            NSString *imgUrl = [frame valueForKey:@"imageUrl"];
            UIImage *basicImage = [UIImage imageWithContentsOfFile:imgUrl];
            NSString *resize_type = [[NSUserDefaults standardUserDefaults] objectForKey:@"output_resize"];
            UIImage *resultImage = [[UIImage alloc] init];
            if ([resize_type isEqualToString:@"Crop"]) {
                //crop image
                CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
                UIGraphicsBeginImageContext(newSize);
                
                double val_scale = MAX(self.outputWidth/(double)basicImage.size.width, self.outputHeight/(double)basicImage.size.height);
                
                int result_width = val_scale * basicImage.size.width;
                int result_height = val_scale * basicImage.size.height;
                
                [basicImage drawInRect:CGRectMake((self.outputWidth-result_width)/2, (self.outputHeight-result_height)/2, result_width, result_height)];
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }else{
                //stretch image
                CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
                UIGraphicsBeginImageContext(newSize);
                [basicImage drawInRect:CGRectMake(0, 0, self.outputWidth, self.outputHeight)];
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            CIImage *scaledImage = [BaseLayerStyle zoomImage:resultImage :self.basic_scale];
            self.img_basic_video.layer.opacity = self.slider_basic_opacity.value;
            int index = (int)[base_layer_list indexOfObject:self.baseLayerName];
            switch (index) {
                case 0:
                    //Normal
                    self.basicImageFinal = [BaseLayerStyle normalImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 1:
                    //Posterize
                    self.basicImageFinal = [BaseLayerStyle posterizeImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 2:
                    //Desaturate
                    self.basicImageFinal = [BaseLayerStyle desaturateImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 3:
                    //Saturate
                    self.basicImageFinal = [BaseLayerStyle saturateImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 4:
                    //Threshold
                    self.basicImageFinal = [BaseLayerStyle thresholdImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 5:
                    //Negative
                    self.basicImageFinal = [BaseLayerStyle negativeImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 6:
                    //Gaussian Blur
                    self.basicImageFinal = [BaseLayerStyle guassianBlurImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 7:
                    //Colorise Red
                    self.basicImageFinal = [BaseLayerStyle colorizeRedImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 8:
                    //Colorise Green
                    self.basicImageFinal = [BaseLayerStyle colorizeGreenImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 9:
                    //Colorise Blue
                    self.basicImageFinal = [BaseLayerStyle colorizeBlueImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 10:
                    //Colorise Cyan
                    self.basicImageFinal = [BaseLayerStyle colorizeCyanImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 11:
                    //Colorise Magenta
                    self.basicImageFinal = [BaseLayerStyle colorizeMagentaImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                case 12:
                    //Colorise Yellow
                    self.basicImageFinal = [BaseLayerStyle colorizeYellowImage:scaledImage];
                    self.img_basic_video.image = [UIImage imageWithCIImage:self.basicImageFinal];
                    break;
                    
                default:
                    break;
            }
            self.basic_current_frameNumber = self.basic_current_frameNumber + self.basic_speed*30.0/self.video_fps;
        }
    }
    
}
/*------------------------------------------------------------------------------------*/



/*--------------------------display overlay video frame in realtime -------------------------*/
-(void)displayOverlayNextFrame:(NSTimer *)timer {
    if (![special_effect isEqualToString:@"freeze"]) {
        if (self.overlay_frame_list.count > 0) {
//            [self.view_overlay_video setBackgroundColor:[UIColor blackColor]];
//            [self.content_preview setBackgroundColor:[UIColor blackColor]];
            if (self.overlay_current_frameNumber > self.overlay_end_frameNumber) {
                self.overlay_current_frameNumber = self.overlay_start_frameNumber;
            }
            
            NSManagedObject * frame = [self.overlay_frame_list objectAtIndex:self.overlay_current_frameNumber];
            NSString *imgUrl = [frame valueForKey:@"imageUrl"];
            UIImage *overlayImage = [UIImage imageWithContentsOfFile:imgUrl];
            UIImage *resultImage = [[UIImage alloc] init];
            NSString *resize_type = [[NSUserDefaults standardUserDefaults] objectForKey:@"output_resize"];
            
            if ([resize_type isEqualToString:@"Crop"]) {
                //crop image
                CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
                UIGraphicsBeginImageContext(newSize);
                
                double val_scale = MAX(self.outputWidth/(double)overlayImage.size.width, self.outputHeight/(double)overlayImage.size.height);
                int result_width = val_scale * overlayImage.size.width;
                int result_height = val_scale * overlayImage.size.height;
                
                [overlayImage drawInRect:CGRectMake((self.outputWidth-result_width)/2, (self.outputHeight-result_height)/2, result_width, result_height)];
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }else{
                //stretch image
                CGSize newSize = CGSizeMake(self.outputWidth, self.outputHeight);
                UIGraphicsBeginImageContext(newSize);
                [overlayImage drawInRect:CGRectMake(0, 0, self.outputWidth, self.outputHeight)];
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            
            CIImage *scaledImage = [BaseLayerStyle zoomImage:resultImage :self.overlay_scale];
            self.overlayImageFinal = scaledImage;
            
            
            
            self.img_overlay_video.image = [UIImage imageWithCIImage:self.overlayImageFinal];
            self.img_overlay_video.layer.opacity = self.slider_overlay_opacity.value;
            self.overlay_current_frameNumber = self.overlay_current_frameNumber + self.overlay_speed*30.0/self.video_fps;
        }
    }
}
/*----------------------------------------------------------------------------------*/



/*--------------------------display image channel in realtime -------------------------*/
-(void)displayImage:(NSTimer *)timer {
//  [self.view_image_add setBackgroundColor:[UIColor blackColor]];
//  [self.content_preview setBackgroundColor:[UIColor blackColor]];
    if (![special_effect isEqualToString:@"freeze"]) {
        
        
        self.img_image_layer.image = self.imageOrigin;
        self.img_image_layer.alpha = self.slider_image_opacity.value;
        if (CGSizeEqualToSize(self.imageOrigin.size, CGSizeZero)) {
            [self.img_image_add_icon setHidden:NO];
        }else
        {
            double scale = self.image_scale * self.image_size;
            self.constraint_image_Width.constant = self.view_image_add.frame.size.width*scale;
            self.constraint_image_Height.constant = self.view_image_add.frame.size.width*scale * self.imageOrigin.size.height / self.imageOrigin.size.width;
            [self.img_image_add_icon setHidden:YES];
        }
    }
}
/*---------------------------------------------------------------------------------*/


/*--------------------------display text channel in realtime -------------------------*/
-(void)displayText:(NSTimer *)timer {
    if (![special_effect isEqualToString:@"freeze"]) {
        if ([self.textString isEqualToString:@""]) {
            [self.img_text_add_icon setHidden:NO];
        }else
        {
            [self.img_text_add_icon setHidden:YES];
        }
        
        
        self.lbl_text.text = self.textString;
        [self.lbl_text setFont:[UIFont fontWithName:self.fontName size: self.view_text_add.frame.size.width*self.font_size*self.text_scale/4]];
        self.lbl_text.textColor = self.fontColor;
        self.lbl_text.alpha = self.slider_text_opacity.value;
    }
    
}
/*-----------------------------------------------------------------------------------*/




/*-------------------------- get autio amplitude in real time ------------------------*/
- (void)getAmplitude
{
    
    if (![special_effect isEqualToString:@"freeze"])
    {
        if (self.sampler == nil)
        {
            return;
        }
        Float32 total = 0.0;
        while (true)
        {
            SamplerSlice sampler_slice = [self.sampler get_slice];
            if (sampler_slice.samples == nullptr)
            {
                break;
            }
            
            Float32 mul = 1 / (Float32)sampler_slice.sample_count;
            total = 0.0f;
            for (int i = 0; i < sampler_slice.sample_count; ++i)
            {
                total += fabs(sampler_slice.samples[i]) * mul;
            }
        }
        self.audio_amplitude = total;
        double basic_sensor_value = self.slider_basic_sensor.value;
        if (basic_sensor_value > 0.05) {
            double basic_sensitivity = pow(5, 2*basic_sensor_value);
            self.basic_scale = (self.audio_amplitude*basic_sensitivity + 1.0 + self.basic_scale)/2.0;
        }else
        {
            self.basic_scale = 1.0;
        }
        
        
        double overlay_sensor_value = self.slider_overlay_sensor.value;
        if (overlay_sensor_value > 0.05) {
            double overlay_sensitivity = pow(5, 2*overlay_sensor_value);
            self.overlay_scale = (self.audio_amplitude*overlay_sensitivity + 1.0 + self.overlay_scale)/2.0;
        }else
        {
            self.overlay_scale = 1.0;
        }
        
        
        double image_sensor_value = self.slider_image_sensor.value;
        if (image_sensor_value > 0.05) {
            double image_sensitivity = pow(5, 2*image_sensor_value);
            self.image_scale = (self.audio_amplitude*image_sensitivity + 1.0 + self.image_scale)/2.0;
        }else
        {
            self.image_scale = 1.0;
        }
        
        
        
        double text_sensor_value = self.slider_text_sensor.value;
        if (text_sensor_value > 0.05) {
            double text_sensitivity = pow(5, 2*text_sensor_value);
            self.text_scale = (self.audio_amplitude*text_sensitivity + 1.0 + self.text_scale)/2.0;
        }else
        {
            self.text_scale = 1.0;
        }
    }    
}
/*---------------------------------------------------------------------------------*/


-(void)start_timer
{
    self.video_fps = [[[NSUserDefaults standardUserDefaults] objectForKey:@"output_rate"] intValue];
    self.video_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.video_fps target:self selector:@selector(displayOutputVideoFrame:) userInfo:nil repeats:YES];
    self.sampler_timer = [NSTimer scheduledTimerWithTimeInterval:0.02  target:self selector:@selector(getAmplitude) userInfo:nil repeats:YES];
    self.basic_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.video_fps target:self selector:@selector(displayBasicNextFrame:) userInfo:nil repeats:YES];
    self.overlay_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.video_fps target:self selector:@selector(displayOverlayNextFrame:) userInfo:nil repeats:YES];
    self.image_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.video_fps target:self selector:@selector(displayImage:) userInfo:nil repeats:YES];
    self.text_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.video_fps target:self selector:@selector(displayText:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.video_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.sampler_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.basic_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.overlay_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.image_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.text_timer forMode:NSRunLoopCommonModes];
}
-(void)resume_timer
{
    [self.video_timer invalidate];
    [self.basic_timer invalidate];
    [self.overlay_timer invalidate];
    [self.image_timer invalidate];
    [self.sampler_timer invalidate];
    [self.text_timer invalidate];
    [self start_timer];
}



/* --------------------------------- set audio source -----------------------------------*/
-(void)setInput_mode
{
    NSString *input_mode = [[NSUserDefaults standardUserDefaults] objectForKey:@"audio_input"];
    //set default audio source as Mic
    if(self.sampler != nil)
    {
        [self.sampler cleanup];
    }
    self.audio_amplitude = 0.0;
    if ([input_mode isEqualToString:@"mic"]) {
        //set audio source as Mic        
        self.sampler = [[MicSampler alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.select_song_button.hidden = true;
            self.label.hidden = true;
        });
        
        
    }else if ([input_mode isEqualToString:@"itunes"])
   {
       //set audio source as iTunes
       self.sampler = [[ITunesSampler alloc] init];
       dispatch_async(dispatch_get_main_queue(), ^(){
           [self show_itunes_selection];
       });
       
   }    
}


//itunes part
- (IBAction)select_song:(id)sender {
    MPMediaPickerController* picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    
    picker.delegate = self;
    picker.allowsPickingMultipleItems = false;
    picker.prompt = @"Choose a song";
    picker.showsCloudItems = false;
    
    [self presentViewController:picker animated:NO completion:nil];
}
- (void)show_itunes_selection
{
    //show select song button when there is no playing audio
    MPMusicPlayerController* music_player = [MPMusicPlayerController systemMusicPlayer];
    if (music_player.playbackState == MPMusicPlaybackStatePlaying)
    {
        self.select_song_button.hidden = true;
        
        if ([music_player.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL] == nil)
        {
            self.label.hidden = false;
        }
        else
        {
            self.label.hidden = true;
        }
    }
    else
    {
        self.select_song_button.hidden = false;
        self.label.hidden = true;
    }
}

// MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection*)mediaItemCollection
{
    [[MPMusicPlayerController systemMusicPlayer] setQueueWithItemCollection:mediaItemCollection];
    [[MPMusicPlayerController systemMusicPlayer] play];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController*)mediaPicker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}



/*-------------------------------- select video layer part--------------------------------*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 100) {
        //base layer style
        return base_layer_list.count;
    }else
    {
        //overlay video layer style
        return overlay_layer_list.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayerTableViewCell *cell = (LayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LayerCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        cell.view_bottom.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    }else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.view_bottom.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
    }
    
    
    
    if (tableView.tag == 100) {
        //base layer style
        NSString *layerName = [base_layer_list objectAtIndex:indexPath.row];
        cell.lbl_layerName.text = layerName;
        if ([layerName isEqualToString:self.baseLayerName]) {
            cell.lbl_layerName.textColor = [UIColor colorWithRed:133.0/255.0 green:93.0/255.0 blue:251.0/255.0 alpha:1.0];
            cell.lbl_layerName.layer.shadowColor = [cell.lbl_layerName.textColor CGColor];
            cell.lbl_layerName.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_layerName.layer.shadowRadius = 4.0;
            cell.lbl_layerName.layer.shadowOpacity = 0.5;
            cell.lbl_layerName.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_layerName.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_layerName.layer.shadowRadius = 0.0;
        }
    }else
    {
        //overlay layer style
        NSString *layerName = [overlay_layer_list objectAtIndex:indexPath.row];
        cell.lbl_layerName.text = layerName;
        if ([layerName isEqualToString:self.overlayLayerName]) {
            cell.lbl_layerName.textColor = [UIColor colorWithRed:43.0/255.0 green:211.0/255.0 blue:212.0/255.0 alpha:1.0];
            cell.lbl_layerName.layer.shadowColor = [cell.lbl_layerName.textColor CGColor];
            cell.lbl_layerName.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_layerName.layer.shadowRadius = 4.0;
            cell.lbl_layerName.layer.shadowOpacity = 0.5;
            cell.lbl_layerName.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_layerName.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_layerName.layer.shadowRadius = 0.0;
        }
    }    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view_selectLayer setHidden:YES];
    if (tableView.tag == 100) {
        //base layer style
        self.img_basic_layer_background.image = [UIImage imageNamed:@"button_stadium_vertical_855DFB_glow_default.png"];
        self.baseLayerName = [base_layer_list  objectAtIndex:indexPath.row];
        self.lbl_basic_multiplay.text = self.baseLayerName;
    }else
    {
        //overlay layer style
        self.img_overlay_layer_background.image = [UIImage imageNamed:@"button_stadium_vertical_2BD3D4_glow_default.png"];
        self.overlayLayerName = [overlay_layer_list  objectAtIndex:indexPath.row];
        self.lbl_overlay_multiplay.text = self.overlayLayerName;
    }
}

/*-------------------------------- ---------------------------------------------------------*/







-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}


/*-------------------------------- recording video sub functions ---------------------------------------------------------*/


-(void)saveVideo:(int)frame_size{
    NSString *fileNameOut = @"temp.mov";
    NSString *directoryOut = @"tmp/";
    NSString *outFile = [NSString stringWithFormat:@"%@%@",directoryOut,fileNameOut];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", outFile]];
    NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileNameOut]];
    
    // WARNING: AVAssetWriter does not overwrite files for us, so remove the destination file if it already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoTempURL path]  error:NULL];
    [self writeImageAsMovie:frame_size toPath:path size:CGSizeMake(self.outputWidth, self.outputHeight)];
}

-(void)writeImageAsMovie:(int)frame_size toPath:(NSString*)path size:(CGSize)size
{
    
    NSError *error = nil;
    
    // FIRST, start up an AVAssetWriter instance to write your video
    // Give it a destination path (for us: tmp/temp.mov)
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecTypeH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    //Start a SESSION of writing.
    // After you start a session, you will keep adding image frames
    // until you are complete - then you will tell it you are done.
    [videoWriter startWriting];
    // This starts your video at time = 0
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    // This was just our utility class to get screen sizes etc.
    
    
    int i = 0;
    
    
    while (1)
    {
        // Check if the writer is ready for more data, if not, just wait
        
        if(writerInput.readyForMoreMediaData){
            
            CMTime frameTime = CMTimeMake(600/self.video_fps, 600);
            // CMTime = Value and Timescale.
            // Timescale = the number of tics per second you want
            // Value is the number of tics
            // For us - each frame we add will be 1/4th of a second
            // Apple recommend 600 tics per second for video because it is a
            // multiple of the standard video rates 20, 24, 30, 60 fps etc.
            CMTime lastTime=CMTimeMake(i*600/self.video_fps, 600);//for 20fps
            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
            
            if (i == 0) {presentTime = CMTimeMake(0, 600);}
            // This ensures the first frame starts at 0.
            
            
            if (i >= frame_size)
            {
                buffer = NULL;
            }
            else
            {
                // This command grabs the next UIImage and converts it to a CGImage
                saving_frameNum = i;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.PNG",i]];
                
                UIImage *basicImage = [UIImage imageWithContentsOfFile:filePath];
//                buffer = [self pixelBufferFromCGImage:[[array objectAtIndex:i] CGImage]];
                buffer = [self pixelBufferFromCGImage:[basicImage CGImage]];                
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                
            }
            
            
            if (buffer)
            {
                // Give the CGImage to the AVAssetWriter to add to your video
                [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                i++;
                CFRelease(buffer);
                
            }
            else
            {
                //Finish the session:
                // This is important to be done exactly in this order
                [writerInput markAsFinished];
                // WARNING: finishWriting in the solution above is deprecated.
                // You now need to give a completion handler.
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"Finished writing...checking completion status...");
                    if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)
                    {
                        NSLog(@"Video writing succeeded.");
                        
                        // Move video to camera roll
                        // NOTE: You cannot write directly to the camera roll.
                        // You must first write to an iOS directory then move it!
                        NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", path]];
                        [self saveToCameraRoll:videoTempURL];
                        
                    } else
                    {
                        NSLog(@"Video writing failed: %@", videoWriter.error);
                    }
                    
                }]; // end videoWriter finishWriting Block
                
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                break;
            }
        }
    }
}
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    // This again was just our utility class for the height & width of the
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, self.outputWidth,
                                          self.outputHeight, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, self.outputWidth,
                                                 self.outputHeight, 8, 4*self.outputWidth, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, self.outputWidth, self.outputHeight), image);
    
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_watermark"] isEqualToString:@"1"]) {
        //draw logo when not purchased.
        CGImageRef logo_image = [[UIImage imageNamed:@"logo_splash_screen.png"] CGImage];
        CGContextDrawImage(context, CGRectMake(self.outputWidth*35/40, self.outputWidth/67, self.outputWidth/10,self.outputWidth*27/670), logo_image);
    }
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void) saveToCameraRoll:(NSURL *)srcURL
{
    NSLog(@"srcURL: %@", srcURL);
    
    __block PHObjectPlaceholder *placeholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:srcURL];
        placeholder = [createAssetRequest placeholderForCreatedAsset];
        
    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
            self->savingVideoState = 2;
        }
        else
        {
            self->savingVideoState = 3;
        }
        [[NSFileManager defaultManager] removeItemAtURL:srcURL error:nil];
    }];
}
-(void)savingState
{
    if (savingVideoState == 1) {
        //saving video
        [self.view_savingVideoState setHidden:NO];
        self.lbl_savingState.text = [NSString stringWithFormat:@"Saving video...%d %%",100*saving_frameNum/frame_size];
        
    }else if (savingVideoState == 2)
    {
        //success saved
        [self.view_savingVideoState setHidden:YES];        
        self.lbl_savingState.text = @"Saving video...0 %";
        
        savingVideoState = 0;
        saving_frameNum = 0;
        frame_size = 1000;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Recording saved" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (savingVideoState == 3)
    {
        //failed
        [self.view_savingVideoState setHidden:YES];
        savingVideoState = 0;
        saving_frameNum = 0;
        frame_size = 1000;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Saving File is Failed" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}



// output window
- (void)external_screen_connected:(NSNotification*)notification { [self init_external_screen]; }

- (void)external_screen_disconnected:(NSNotification*)notification { [self init_external_screen]; }

- (void)init_external_screen
{
    NSArray* screens = [UIScreen screens];
    if (screens.count > 1)
    {
        if(self.external_window == nil)
        {
            UIScreen* screen = [screens objectAtIndex:1];
            self.external_window = [[UIWindow alloc] initWithFrame:screen.bounds];
            self.external_window.screen = screen;
            
            self.externalOutPutImageView.frame = self.external_window.frame;
            [self.external_window addSubview:self.externalOutPutImageView];
            [self.external_window makeKeyAndVisible];
            
        }
    }
    else
    {
        if (self.external_window != nil)
        {
            self.external_window.hidden = true;
            self.external_window = nil;            
            // Move visuals back to this window
            self.externalOutPutImageView.frame = self.view.frame;            
        }
    }
}


@end
