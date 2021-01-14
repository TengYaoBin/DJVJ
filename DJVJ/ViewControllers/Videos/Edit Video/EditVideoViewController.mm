//
//  EditVideoViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "EditVideoViewController.h"
#import "CropTableViewCell.h"
#import "GlobalData.h"
#import "AppDelegate.h"
#define IDIOM UI_USER_INTERFACE_IDIOM()
#define IPAD UIUserInterfaceIdiomPad

@interface EditVideoViewController ()
{
    NSTimer *timer;
    int current_frameNum;
    int min_frameNum;
    int max_frameNum;
    Boolean playing_state;
    UIImage *backgroundImg;
    NSMutableArray *array_cropList;
    GlobalData *global;
    UIImage *playImage;
    UIImage *stopImage;
}

@end

@implementation EditVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    
    global = [GlobalData sharedGlobalData];
    //setting radius.
    self.view_content.layer.cornerRadius = 5.0;
    self.view_content.clipsToBounds = true;    
    
    self.view_preview.layer.cornerRadius = 5.0;
    self.view_preview.clipsToBounds = true;
    self.img_preview.layer.cornerRadius = 10.0;
    self.img_preview.clipsToBounds = true;
    self.view_crop.layer.cornerRadius = 5.0;
    self.view_crop.clipsToBounds = true;
    
    min_frameNum = 0;
    current_frameNum = 0;
    max_frameNum = (int)self.frame_list.count -1;
    playing_state = true;
    
    //generate background image.
    backgroundImg = [self getBackgroundImage];
    UIImage *min_image = [UIImage imageNamed:@"videocrop_0095FF_left_glow_default.png"];
    UIImage *max_image = [UIImage imageNamed:@"videocrop_0095FF_right_glow_default.png"];
    UIImage *content_image = [UIImage imageNamed:@"videocrop_0095FF_center_glow_default.png"];
    [self.slider_crop setImages:min_image :max_image :content_image :backgroundImg];
    [self.slider_crop setSliderValue:0.0 :1.0];
    
    self.tbl_croplist.separatorStyle = UITableViewCellSeparatorStyleNone;
    //set custome scrollbar of tableview
    _brScrollBarController = [BRScrollBarController setupScrollBarWithScrollView:self.tbl_croplist inPosition:BRScrollBarPostionRight delegate:self];
    _brScrollBarController.scrollBar.backgroundColor = [UIColor clearColor];
    _brScrollBarController.scrollBar.scrollHandle.backgroundColor = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    _brScrollBarController.scrollBar.hideScrollBar = NO;
    //self.tbl_croplist.layer.masksToBounds = NO;
    [self setTheme];
    _img_play.image = playImage;
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.03
                                             target:self
                                           selector:@selector(showImage:)
                                           userInfo:nil
                                            repeats:YES];
    
    // Do any additional setup after loading the view.
}
-(void)setTheme{
    if (global.day_mode) {
        //set day mode color
        self.view_content.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_edit.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_preview.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        
        self.view_crop.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        [self.btn_cancel setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_save setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        playImage = [UIImage imageNamed:@"icon_play_white.png"];
        stopImage = [UIImage imageNamed:@"icon_play_white_stop.png"];
    }else{
        //set night mode color
        self.view_content.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_edit.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_preview.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];

        self.view_crop.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        
        [self.btn_cancel setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_save setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        playImage = [UIImage imageNamed:@"icon_play_333333_default.png"];
        stopImage = [UIImage imageNamed:@"icon_play_333333_stop.png"];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];    
    [self.tbl_croplist reloadData];
    [self.view layoutIfNeeded];
}

-(void)showImage:(NSTimer *)timer {
    //[self.slider_crop updateView];
    [self.tbl_croplist reloadData];
    if (playing_state) {
        if (!self.slider_crop.maxThumbOn && !self.slider_crop.minThumbOn) {
            if (current_frameNum >max_frameNum) {
                _img_play.image = playImage;
                current_frameNum = min_frameNum;
            }
            NSManagedObject * frame = [self.frame_list objectAtIndex:current_frameNum];
            NSString *imgUrl = [frame valueForKey:@"imageUrl"];
            self.img_preview.image = [UIImage imageWithContentsOfFile:imgUrl];
            current_frameNum = current_frameNum + 1;
        }        
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [self loadCropData];
}


- (IBAction)action_crop_valueChanged:(id)sender {
    if (self.slider_crop.minThumbOn) {
        min_frameNum = self.slider_crop.lowerValue*(self.frame_list.count - 1);
        NSLog(@"frame number : %d",min_frameNum);
        NSManagedObject * frame = [self.frame_list objectAtIndex:min_frameNum];
        NSString *imgUrl = [frame valueForKey:@"imageUrl"];
        self.img_preview.image = [UIImage imageWithContentsOfFile:imgUrl];
        current_frameNum = min_frameNum;
    }else if (self.slider_crop.maxThumbOn) {
        max_frameNum = self.slider_crop.upperValue*(self.frame_list.count - 1);
        NSManagedObject * frame = [self.frame_list objectAtIndex:max_frameNum];
        NSString *imgUrl = [frame valueForKey:@"imageUrl"];        
        self.img_preview.image = [UIImage imageWithContentsOfFile:imgUrl];
        current_frameNum = min_frameNum;
        NSLog(@"frame number : %d",max_frameNum);
    }
}


- (IBAction)action_cancel_down:(id)sender {
    self.img_cancel_background.image = [UIImage imageNamed:@"button_cancel_active.png"];
}

- (IBAction)action_cancel_clicked:(id)sender {
    self.img_cancel_background.image = [UIImage imageNamed:@"button_cancel.png"];
    [timer invalidate];
    timer = nil;
//    [self.root_viewController start_timer];
    [self dismissViewControllerAnimated:NO completion:Nil];
}
- (IBAction)action_play_down:(id)sender {
    self.img_play_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}

- (IBAction)action_play_clicked:(id)sender {
    self.img_play_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    if (playing_state) {
        _img_play.image = playImage;
        playing_state = false;
    }else
    {
        _img_play.image = stopImage;
        playing_state = true;
    }
}


- (IBAction)action_save_down:(id)sender {
    self.img_save_background.image = [UIImage imageNamed:@"button_cancel_active.png"];
}


- (IBAction)action_save_clicked:(id)sender {
    self.img_save_background.image = [UIImage imageNamed:@"button_cancel.png"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Would you like to give your new loop a name to save as?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"LOOP NAME";
        textField.textColor = [self->global backgroundColor1];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField *codeField = textfields[0];
        NSString *loop_name = codeField.text;
        //save min & max frame number.
        NSManagedObject *crop;
        crop = [NSEntityDescription insertNewObjectForEntityForName:@"Crop" inManagedObjectContext:[self managedObjectContext]];
        [crop setValue:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"cropID"];
        [crop setValue:self.videoID forKey:@"videoID"];
        [crop setValue:loop_name forKey:@"name"];
        NSError *error = nil;
        [crop setValue:[NSString stringWithFormat:@"%lu",(unsigned long)self.frame_list.count] forKey:@"size"];
        [crop setValue:[NSString stringWithFormat:@"%d",self->min_frameNum] forKey:@"start"];
        [crop setValue:[NSString stringWithFormat:@"%d",self->max_frameNum] forKey:@"end"];
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self loadCropData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)action_ok_down:(id)sender {
    self.img_ok_background.image = [UIImage imageNamed:@"button_ok_active.png"];
}

- (IBAction)action_ok_clicked:(id)sender {
    self.img_ok_background.image = [UIImage imageNamed:@"button_ok.png"];
    [timer invalidate];
    timer = nil;
    if (_video_type == 0) {
        //set basic start and end frame number;
        self.root_viewController.basic_start_frameNumber = min_frameNum;
        self.root_viewController.basic_end_frameNumber = max_frameNum;
    } else
    {
        //set overlay start and end frame number
        self.root_viewController.overlay_start_frameNumber = min_frameNum;
        self.root_viewController.overlay_end_frameNumber = max_frameNum;
    }
//    [self.root_viewController start_timer];
    [self dismissViewControllerAnimated:NO completion:Nil];
}


//generate background image from framelist
-(UIImage*) getBackgroundImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(650, 70), FALSE, 0.0);
    for (int i = 0;i < 5; i++) {
        int frame_index = round(i*(self.frame_list.count-1)/4.0);
        NSManagedObject * frame = [self.frame_list objectAtIndex:frame_index];
        NSString *imgUrl = [frame valueForKey:@"imageUrl"];
        UIImage *node_image = [UIImage imageWithContentsOfFile:imgUrl];
        [node_image drawInRect:CGRectMake(i*130, 0, 130, 70)];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



//load video crop loops list from core data database
-(void)loadCropData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Crop"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID =  %@", self.videoID];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"cropID" ascending:true];
    
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    array_cropList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tbl_croplist reloadData];
}

//crop loops table view delegate & data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CropTableViewCell *cell = (CropTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CropTableViewCell" forIndexPath:indexPath];
    if (global.day_mode) {
        //set day mode color
        cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        cell.view_content.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        cell.lbl_name.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        cell.lbl_time.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        [cell.btn_edit setBackgroundImage:[UIImage imageNamed:@"button_edit_white_default.png"] forState:UIControlStateNormal];
        [cell.btn_edit setBackgroundImage:[UIImage imageNamed:@"button_edit_white_active.png"] forState:UIControlStateHighlighted];
        [cell.btn_delete setBackgroundImage:[UIImage imageNamed:@"button_delete_white_default.png"] forState:UIControlStateNormal];
        [cell.btn_delete setBackgroundImage:[UIImage imageNamed:@"button_delete_white_active.png"] forState:UIControlStateHighlighted];
    }else
    {
        //set night mode color
        cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        cell.view_content.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        cell.lbl_name.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        cell.lbl_time.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [cell.btn_edit setBackgroundImage:[UIImage imageNamed:@"button_edit_333333_default.png"] forState:UIControlStateNormal];
        [cell.btn_edit setBackgroundImage:[UIImage imageNamed:@"button_edit_333333_active.png"] forState:UIControlStateHighlighted];
        [cell.btn_delete setBackgroundImage:[UIImage imageNamed:@"button_delete_333333_default.png"] forState:UIControlStateNormal];
        [cell.btn_delete setBackgroundImage:[UIImage imageNamed:@"button_delete_333333_active.png"] forState:UIControlStateHighlighted];
        
    }
    NSManagedObject * crop;
    crop = [array_cropList objectAtIndex:indexPath.row];
    cell.lbl_name.text = [crop valueForKey:@"name"];
    
    int size = [[crop valueForKey:@"size"] intValue];
    int start_number = [[crop valueForKey:@"start"] intValue];
    int end_number = [[crop valueForKey:@"end"] intValue];
    
    int duration = (end_number -start_number)/20;
    int time_min = duration/60;
    NSString *min_str = [NSString stringWithFormat:@"%d",time_min];
    if (time_min<10) {
        min_str = [NSString stringWithFormat:@"0%d",time_min];
    }
    int time_sec = duration - 60*time_min;
    NSString *sec_str = [NSString stringWithFormat:@"%d",time_sec];
    if (time_sec<10) {
        sec_str = [NSString stringWithFormat:@"0%d",time_sec];
    }
    
    cell.lbl_time.text = [NSString stringWithFormat:@"%@:%@",min_str,sec_str];
    UIImage *min_image = [UIImage imageNamed:@"videocrop_666666_left_glow.png"];
    UIImage *max_image = [UIImage imageNamed:@"videocrop_666666_right_glow.png"];
    UIImage *content_image = [UIImage imageNamed:@"content_grey.png"];
    [cell.slider_range setImages:min_image :max_image :content_image :backgroundImg];
    [cell.slider_range setSliderValue:start_number/(double)(size-1) :end_number/(double)(size-1)];
    [cell.slider_range setBackgroundRound];
    
    cell.btn_edit.tag = indexPath.row;
    [cell.btn_edit addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn_delete.tag = indexPath.row;
    [cell.btn_delete addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.contentView.layer.masksToBounds = NO;
    return cell;
}

//edit clicked action of crop loop cell
- (void)editClicked:(UIButton *)sender
{
    NSManagedObject * crop = [array_cropList objectAtIndex:sender.tag];
    int size = (int)self.frame_list.count;
    min_frameNum = [[crop valueForKey:@"start"] intValue];
    current_frameNum = min_frameNum;
    max_frameNum= [[crop valueForKey:@"end"] intValue];
    [self.slider_crop setSliderValue:min_frameNum/(double)(size-1) :max_frameNum/(double)(size-1)];
    NSManagedObject * frame = [self.frame_list objectAtIndex:current_frameNum];
    NSString *imgUrl = [frame valueForKey:@"imageUrl"];    
    self.img_preview.image = [UIImage imageWithContentsOfFile:imgUrl];
}

//delete clicked action of crop loop cell
- (void)deleteClicked:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to delete this Loop?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSManagedObject * crop = [self->array_cropList objectAtIndex:sender.tag];
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:crop];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        [self loadCropData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array_cropList.count;
}

- (void)viewDidLayoutSubviews
{
    //call function when device orientation is changed.
    [self.slider_crop updateView];
    [self.tbl_croplist reloadData];
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}
-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

@end
