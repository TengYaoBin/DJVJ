//
//  MainViewController.h
//  DJVJ
//
//  Created by Bin on 2018/12/11.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

#import "WidthSlider.h"
#import "HeightSlider.h"
#import "OneSlider.h"
#import "Sampler.h"


NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController

@property(strong, nonatomic) UIWindow* external_window;//output external window
@property (strong, nonatomic) UIImageView *externalOutPutImageView;

//audio input source
@property(strong, nonatomic) NSObject<Sampler>* sampler;
@property (nonatomic, retain) NSTimer *sampler_timer;//overlay video frame manager timer

//output video properties
@property (nonatomic, retain) NSTimer *video_timer;//overlay video frame manager timer
@property double video_fps;
@property int outputWidth;//output video width
@property int outputHeight;//output video height
@property (nonatomic, retain) CIImage *outputImage;//combined two video channel frame
@property (nonatomic, retain) UIImage *finalImage;//final image
@property double basic_opacity;
@property double overlay_opacity;
@property double audio_amplitude;


//video playing states
@property Boolean video_playing_state;

//basic video frame manager properties
@property (nonatomic, retain) NSTimer *basic_timer;//basic video frame manager timer
@property (nonatomic, retain) NSMutableArray *basic_frame_list;
@property (nonatomic) NSString *basic_videoID;
@property double basic_start_frameNumber;
@property double basic_end_frameNumber;
@property double basic_current_frameNumber;
@property double basic_speed;
@property double basic_scale;

@property (nonatomic, retain) UIImage *basicImageOrigin;//origin basic video frame
@property (nonatomic, retain) CIImage *basicImageFinal;//added effect to origin
@property (nonatomic, retain) NSString *baseLayerName;//base video layer name

//overlay video frame manager properties
@property (nonatomic, retain) NSTimer *overlay_timer;//overlay video frame manager timer
@property (nonatomic, retain) NSMutableArray *overlay_frame_list;
@property (nonatomic) NSString *overlay_videoID;
@property double overlay_start_frameNumber;
@property double overlay_end_frameNumber;
@property double overlay_current_frameNumber;
@property double overlay_speed;
@property double overlay_scale;

@property (nonatomic, retain) UIImage *overlayImageOrigin;//origin overlay video frame
@property (nonatomic, retain) CIImage *overlayImageFinal;//added effect to origin
@property (nonatomic, retain) NSString *overlayLayerName;//overlay video layer name


//image manager properties
@property (nonatomic, retain) NSTimer *image_timer;//image manager timer
@property double image_scale;
@property double image_size;

@property (nonatomic, retain) UIImage *imageOrigin;//origin image
@property (nonatomic, retain) UIImage *imageFinal;//added effect to origin


//text manager properties
@property (nonatomic, retain) NSTimer *text_timer;//image manager timer
@property double text_scale;
@property double font_size;
@property (nonatomic, retain) NSString *textString;
@property (nonatomic, retain) NSString *fontName;
@property (nonatomic, retain) UIColor *fontColor;



@property (weak, nonatomic) IBOutlet UIView *view_savingVideoState;
@property (weak, nonatomic) IBOutlet UILabel * lbl_savingState;


@property (weak, nonatomic) IBOutlet UIView *view_background;

//preview UI elements
@property (weak, nonatomic) IBOutlet UIView *content_preview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_preview_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_preview_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_preview_right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_preview_bottom;
@property(nonatomic, weak) IBOutlet UIButton* select_song_button;
- (IBAction)select_song:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;



@property (weak, nonatomic) IBOutlet UIView *view_menu;
@property (weak, nonatomic) IBOutlet UIImageView *img_menu_icon_background;

@property (weak, nonatomic) IBOutlet UIImageView *img_menu_icon;
@property (weak, nonatomic) IBOutlet UIImageView *img_preview_overlay;//***



@property (weak, nonatomic) IBOutlet UIView *view_record_icon;
@property (weak, nonatomic) IBOutlet UILabel *lbl_record_state;//L
@property (weak, nonatomic) IBOutlet UILabel *lbl_recordingTime;
- (IBAction)action_record_btn_clicked:(id)sender;




@property (weak, nonatomic) IBOutlet UIView *view_preview_back;
@property (weak, nonatomic) IBOutlet UILabel *lbl_preview_back;
@property (weak, nonatomic) IBOutlet UIButton *btn_preview_back;

@property (weak, nonatomic) IBOutlet UIView *view_preview_next;
@property (weak, nonatomic) IBOutlet UILabel *lbl_preview_next;
@property (weak, nonatomic) IBOutlet UIButton *btn_preview_next;




//control UI elements
@property (weak, nonatomic) IBOutlet UIView *content_control;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_control_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_control_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_control_right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_control_bottom;


@property (weak, nonatomic) IBOutlet UIView *view_control_back;
@property (weak, nonatomic) IBOutlet UILabel *lbl_control_back_left;
@property (weak, nonatomic) IBOutlet UILabel *lbl_control_back_right;
@property (weak, nonatomic) IBOutlet UIButton *btn_control_back;

@property (weak, nonatomic) IBOutlet UIView *view_control_next;
@property (weak, nonatomic) IBOutlet UILabel *lbl_control_next_left;
@property (weak, nonatomic) IBOutlet UILabel *lbl_control_next_right;
@property (weak, nonatomic) IBOutlet UIButton *btn_control_next;


//basic video control part
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_select_layer_up;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_select_layer_down;//L
@property (weak, nonatomic) IBOutlet UILabel *lbl_basic_multiplay;//R,//L
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_layer_background;
- (IBAction)action_basic_select_layer_clicked:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *img_basic_edit_video;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_edit_video_background;
- (IBAction)action_basic_video_edit_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_play_video;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_play_video_background;
- (IBAction)action_basic_play_video_clicked:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *view_basic_video;
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_video;//******
@property (weak, nonatomic) IBOutlet UIImageView *img_basic_select_video_icon;//L
- (IBAction)action_basic_select_video_clicked:(id)sender;

@property (weak, nonatomic) IBOutlet HeightSlider *slider_basic_opacity;//R
@property (weak, nonatomic) IBOutlet HeightSlider *slider_basic_speed;//R
@property (weak, nonatomic) IBOutlet HeightSlider *slider_basic_sensor;//R


//overlay video control part
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_select_layer_up;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_select_layer_down;//L
@property (weak, nonatomic) IBOutlet UILabel *lbl_overlay_multiplay;//R,//L
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_layer_background;
- (IBAction)action_overlay_select_layer_clicked:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_edit_video_background;
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_edit_video;//L
- (IBAction)action_overlay_video_edit_clicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_play_video_background;
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_play_video;//L
- (IBAction)action_overlay_play_video_clicked:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *view_overlay_video;
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_video;//******
@property (weak, nonatomic) IBOutlet UIImageView *img_overlay_select_video_icon;//L
- (IBAction)action_overlay_select_video_clicked:(id)sender;

@property (weak, nonatomic) IBOutlet HeightSlider *slider_overlay_opacity;//R
@property (weak, nonatomic) IBOutlet HeightSlider *slider_overlay_speed;//R
@property (weak, nonatomic) IBOutlet HeightSlider *slider_overlay_sensor;//R


//select layer style
@property (weak, nonatomic) IBOutlet UIView *view_selectLayer;
@property (weak, nonatomic) IBOutlet UITableView *tbl_baseLayer;
@property (weak, nonatomic) IBOutlet UITableView *tbl_overlayLayer;




//master video channel slider
@property (weak, nonatomic) IBOutlet OneSlider *slider_video_channel;






//effects UI elements
@property (weak, nonatomic) IBOutlet UIView *content_effects;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_effects_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_effects_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_effects_right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_effects_bottom;

@property (weak, nonatomic) IBOutlet UIView *view_effects_back;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effects_back;
@property (weak, nonatomic) IBOutlet UIButton *btn_effects_back;

@property (weak, nonatomic) IBOutlet UIView *view_effects_next;
@property (weak, nonatomic) IBOutlet UILabel *lbl_effects_next;
@property (weak, nonatomic) IBOutlet UIButton *btn_effects_next;


//video effects part
@property (weak, nonatomic) IBOutlet UIButton *btn_effect1;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect2;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect3;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect4;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect5;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect6;
@property (weak, nonatomic) IBOutlet UIButton *btn_effect7;
@property (weak, nonatomic) IBOutlet UIButton *btn_add_effect;//L
- (IBAction)action_effect1:(id)sender;
- (IBAction)action_effect2:(id)sender;
- (IBAction)action_effect3:(id)sender;
- (IBAction)action_effect4:(id)sender;
- (IBAction)action_effect5:(id)sender;
- (IBAction)action_effect6:(id)sender;
- (IBAction)action_effect7:(id)sender;





- (IBAction)action_effect_close:(id)sender;
- (IBAction)action_add_effect_clicked:(id)sender;



//image layer part
@property (weak, nonatomic) IBOutlet HeightSlider *slider_image_opacity;//R
@property (weak, nonatomic) IBOutlet UIView *view_image_add;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_image_add_icon;//L
@property (weak, nonatomic) IBOutlet UIImageView *img_image_layer;//*****
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_image_Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_image_Height;

- (IBAction)action_image_add:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img_image_close_background;
@property (weak, nonatomic) IBOutlet UIImageView *img_image_close;//L
- (IBAction)action_image_close:(id)sender;
@property (weak, nonatomic) IBOutlet WidthSlider *slider_image_sensor;

//text layer part
@property (weak, nonatomic) IBOutlet HeightSlider *slider_text_opacity;//R
@property (weak, nonatomic) IBOutlet UIView *view_text_add;//L
@property (weak, nonatomic) IBOutlet UILabel *lbl_text;

@property (weak, nonatomic) IBOutlet UIImageView *img_text_add_icon;//L

- (IBAction)action_text_add:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img_text_close_background;
@property (weak, nonatomic) IBOutlet UIImageView *img_text_close;//L
- (IBAction)action_text_close:(id)sender;
@property (weak, nonatomic) IBOutlet WidthSlider *slider_text_sensor;



//actions
- (IBAction)action_menu_clicked:(id)sender;
- (IBAction)btn_preview_back_clicked:(id)sender;
- (IBAction)btn_preview_next_clicked:(id)sender;
- (IBAction)btn_control_back_clicked:(id)sender;
- (IBAction)btn_control_next_clicked:(id)sender;
- (IBAction)btn_effects_back_clicked:(id)sender;
- (IBAction)btn_effects_next_clicked:(id)sender;

//set theme function
-(void)setTheme;

//start&resume video timer
-(void)start_timer;

-(void)resume_timer;

//set audio source
-(void)setInput_mode;

@end

NS_ASSUME_NONNULL_END
