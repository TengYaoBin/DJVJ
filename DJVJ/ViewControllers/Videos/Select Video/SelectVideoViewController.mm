//
//  SelectVideoViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/7.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "SelectVideoViewController.h"
#import "VideoFrameExtractor.h"
#import "GlobalData.h"
#import "AppDelegate.h"
#import "VideoPackageCell.h"
#import "VideoPackage.h"
#import "VideoItem.h"
#import "AppDelegate.h"
#import "VideoShopViewController.h"

@interface SelectVideoViewController ()
{
    GlobalData *global;
    NSTimer *getVideotimer;
    
    int total_frameSize;
    VideoFrameExtractor *video;
    int loading_state;//1:finish download, 2: loaded frame;
    NSTimer *timer;
    NSTimer *loading_timer;
    int frame_num;
    NSString *videoID;
    double time;
    NSMutableArray *package_array;
    
    VideoPackage *selectedPackage;
    VideoItem *selectedvideo;
}

@end

@implementation SelectVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    videoID = @"00";
    
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    
    
    frame_num = 0;
    

    global = [GlobalData sharedGlobalData];
    self.view_container.layer.cornerRadius = 5.0;
    self.view_container.clipsToBounds = true;
    self.view_close.layer.cornerRadius = self.view_close.layer.bounds.size.height/2;
    self.view_close.clipsToBounds = true;

    self.content_loading.layer.cornerRadius = 8.0;
    self.content_loading.clipsToBounds = true;
    self.btn_buy.layer.cornerRadius = self.btn_buy.layer.bounds.size.height/2;
    self.btn_buy.clipsToBounds = true;
    self.btn_import.layer.cornerRadius = self.btn_import.layer.bounds.size.height/2;
    self.btn_import.clipsToBounds = true;
    [self.view_loading setHidden:YES];
    loading_state = 0;//default
    self.outputWidth = 640;
    self.outputHeight = 360;
    
    _brScrollBarController = [BRScrollBarController setupScrollBarWithScrollView:self.tbl_PackageList inPosition:BRScrollBarPostionRight delegate:self];
    _brScrollBarController.scrollBar.backgroundColor = [UIColor clearColor];
    _brScrollBarController.scrollBar.scrollHandle.backgroundColor = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    _brScrollBarController.scrollBar.hideScrollBar = NO;
    self.tbl_PackageList.separatorStyle = UITableViewCellSeparatorStyleNone;
    getVideotimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                             target:self
                                           selector:@selector(getVideos:)
                                           userInfo:nil
                                            repeats:YES];
    [self setTheme];
    
    // Do any additional setup after loading the view.
}
-(void)setTheme{
    if (global.day_mode) {
        //set day mode color
        self.view_container.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_selectVideo.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        self.img_closeIcon.image = [UIImage imageNamed:@"icon_cancel_white.png"];
        [self.btn_buy setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_import setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else
    {
        //set night mode color
        self.view_container.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_selectVideo.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.img_closeIcon.image = [UIImage imageNamed:@"icon_cancel_333333_default.png"];
        [self.btn_buy setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_import setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
    }
}
-(void)getVideos:(NSTimer *)videoTimer {
    package_array = global.availableVideoPackageArray;
    if (package_array.count > 0) {
        [self.tbl_PackageList reloadData];
        [videoTimer invalidate];
        videoTimer = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}


- (IBAction)action_buy_down:(id)sender {
    self.img_buy_background.image = [UIImage imageNamed:@"button_normal_active.png"];
}

- (IBAction)action_buy_clicked:(id)sender {
    self.img_buy_background.image = [UIImage imageNamed:@"button_normal.png"];
    
    //go to video shop screen
    [self dismissViewControllerAnimated:NO completion:nil];
    VideoShopViewController *videoShopViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"VideoShopViewController"];
    videoShopViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.root_viewController presentViewController:videoShopViewController animated:NO completion:nil];
}
- (IBAction)action_import_down:(id)sender {
    self.img_import_background.image = [UIImage imageNamed:@"button_normal_active.png"];
}

- (IBAction)action_import_clicked:(id)sender {
    self.img_import_background.image = [UIImage imageNamed:@"button_normal.png"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"This option is coming soon! Look out for the next update of DJVJ." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)loadingFrame:(NSTimer *)timer {
    if (self->loading_state == 1) {
        if (![self->video stepFrame]) {
            [loading_timer invalidate];
            loading_timer = nil;
            self->loading_state = 2;
            return;
        }        
        //get 30 fps frame list
        time = time + 30.0/self->video.fps;
        int count = (int)time;
        time = time - count;
        for (int i = 0; i<count; i++) {
            //                [self->frame_list addObject:[UIImage imageWithData:UIImageJPEGRepresentation(self->video.currentImage, 0.8)]];
            
            //add frame to local database(Core Data)
            NSData *pngData = UIImageJPEGRepresentation(self->video.currentImage, 0.1);
            if ([pngData length] > 0)
            {
                NSManagedObject *frame;
                frame = [NSEntityDescription insertNewObjectForEntityForName:@"Frame" inManagedObjectContext:[self managedObjectContext]];
                
                NSString *str_ID = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
                NSLog(@"%@",str_ID);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG",str_ID]];
                [pngData writeToFile:filePath atomically:YES];
                
                [frame setValue:str_ID forKey:@"frameID"];
                [frame setValue:filePath forKey:@"imageUrl"];
                [frame setValue:self->videoID forKey:@"videoID"];
                [frame setValue:[NSString stringWithFormat:@"%d",self->frame_num] forKey:@"frameNumber"];
                NSError *error = nil;
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                self->frame_num++;
            }
        }
    }
}
-(void)displayLoadingState:(NSTimer *)timer {
    if (loading_state == 2) {
        [self.indicator_loading stopAnimating];
        [timer invalidate];
        timer = nil;
        [self.view_loading setHidden:YES];
        loading_state = 0;
        if (frame_num == 0) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"Oops… the content has failed to load. There might be a problem with your connection or our server. Please try again later!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Frame"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID =  %@", videoID];
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"frameID" ascending:true];
        
        [fetchRequest setSortDescriptors:@[sort]];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        
        NSMutableArray *array_frameList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        
        //save downloaded video info to coredata
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadVideo"];
        predicate = [NSPredicate predicateWithFormat:@"id =  %@", selectedvideo.video_id];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSMutableArray *array_downloadvideoList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        if (array_downloadvideoList.count == 0) {
            NSManagedObject *downloadVideo = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadVideo" inManagedObjectContext:[self managedObjectContext]];
            [downloadVideo setValue:selectedvideo.video_id forKey:@"id"];
            [downloadVideo setValue:selectedPackage.package_id forKey:@"package_id"];
            [downloadVideo setValue:selectedvideo.video_url forKey:@"video_url"];
        }
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadVideoPackage"];
        predicate = [NSPredicate predicateWithFormat:@"id =  %@", selectedPackage.package_id];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSMutableArray *array_packageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        if (array_packageList.count == 0) {
            NSManagedObject *videoPackageObject = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadVideoPackage" inManagedObjectContext:[self managedObjectContext]];
            [videoPackageObject setValue:selectedPackage.package_id forKey:@"id"];
            [videoPackageObject setValue:selectedPackage.name forKey:@"name"];
            [videoPackageObject setValue:selectedPackage.width forKey:@"width"];
            [videoPackageObject setValue:selectedPackage.height forKey:@"height"];
        }
        
        
        if (self.video_type == 0) {
            //set basic video channel parameters
            self.root_viewController.basic_frame_list = array_frameList;
            self.root_viewController.basic_start_frameNumber = 0;
            self.root_viewController.basic_current_frameNumber = 0;
            self.root_viewController.basic_end_frameNumber = array_frameList.count - 1;
            self.root_viewController.basic_videoID = videoID;
//            [self.root_viewController start_timer];
            [self dismissViewControllerAnimated:NO completion:Nil];
        }else
        {
            //set overlay video channel parameters
            self.root_viewController.overlay_frame_list = array_frameList;
            self.root_viewController.overlay_start_frameNumber = 0;
            self.root_viewController.overlay_current_frameNumber = 0;
            self.root_viewController.overlay_end_frameNumber = array_frameList.count - 1;
            self.root_viewController.overlay_videoID = videoID;
//            [self.root_viewController start_timer];
            [self dismissViewControllerAnimated:NO completion:Nil];
        }
    }else if (loading_state == 1){
        self.lbl_loadingResult.text = [NSString stringWithFormat:@"Downloading File to Local Storage... \n(%d %%)",frame_num*100/total_frameSize];
    }
}

- (IBAction)action_close_down:(id)sender {
    self.img_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}

- (IBAction)action_close:(id)sender {
    self.img_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    global.selectedVideoID = @"00";
    [timer invalidate];
    timer = nil;
    [loading_timer invalidate];
    loading_timer = nil;
    
    //remove downloaded data
    if (![videoID isEqualToString:@"00"]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Frame"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID =  %@", videoID];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        
        NSMutableArray *array_frameList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSManagedObject *frame_node in array_frameList) {
            NSString *imgUrl = [frame_node valueForKey:@"imageUrl"];
            if ([fileManager fileExistsAtPath:imgUrl])
            {
                [fileManager removeItemAtPath:imgUrl  error:NULL];
            }
            [[self managedObjectContext] deleteObject:frame_node];
        }
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        }
        
    }

    [self dismissViewControllerAnimated:NO completion:Nil];
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}





#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath
                                                                               *)indexPath
{
    //ChannelNodeCell *brTableCell = [[ChannelNodeCell alloc] init];
    [tableView registerNib:[UINib nibWithNibName:@"VideoPackageCell" bundle:nil] forCellReuseIdentifier:@"VideoPackageCell"];
    VideoPackageCell *ctTableCell = (VideoPackageCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoPackageCell" forIndexPath:indexPath];
    
    VideoPackage *videoPackage=[package_array objectAtIndex:indexPath.row];
    ctTableCell.lbl_PackageName.text = videoPackage.name;
    ctTableCell.lbl_counts.text = [NSString stringWithFormat:@"- X %d VIDEOS",(int)videoPackage.videoList.count];
    ctTableCell.lbl_videoSize.text = [NSString stringWithFormat:@"- %@X%@ PX",videoPackage.width,videoPackage.height];
    ctTableCell.superController = self;
    ctTableCell.videoPackage = videoPackage;
    ctTableCell.packageIndex = (int)indexPath.row;
    ctTableCell.btn_extend.tag = indexPath.row;
    [ctTableCell.btn_extend addTarget:self action:@selector(extendClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!videoPackage.extend_state) {
        ctTableCell.img_extend.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        [ctTableCell.view_extend setHidden:YES];
    }else
    {
        ctTableCell.img_extend.image = [UIImage imageNamed:@"icon_arrowup_0095FF_default.png"];
        ctTableCell.lbl_countsBottom.text = [NSString stringWithFormat:@"X %d VIDEOS",(int)videoPackage.videoList.count];
        ctTableCell.lbl_videoSizeBottom.text = [NSString stringWithFormat:@"- %@X%@ PX",videoPackage.width,videoPackage.height];
        [ctTableCell.view_extend setHidden:NO];
    }
    ctTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [ctTableCell reloadInputViews];
    return ctTableCell;
}
- (void)extendClicked:(UIButton *)sender
{
    VideoPackage *videoPackage=[package_array objectAtIndex:sender.tag];
    if (videoPackage.extend_state) {
        videoPackage.extend_state = NO;
    }else
    {
        videoPackage.extend_state = YES;
    }
    [self.tbl_PackageList reloadData];
}

- (void)selectVideo:(UIButton *)sender
{
    global.selectedVideoID = @"00";
    int Package_index = (int)sender.tag/1000;
    int item_index = (int)sender.tag % 1000;
    VideoPackage *videoPackage=[package_array objectAtIndex:Package_index];
    VideoItem *videoItem = [videoPackage.videoList objectAtIndex:item_index];
    selectedPackage = videoPackage;
    selectedvideo = videoItem;
    
    videoID = videoItem.video_id;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Frame"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID =  %@", videoID];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:@"frameID" ascending:true];
    
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSMutableArray *array_frameList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (array_frameList.count > 0) {
        NSManagedObject * frame = [array_frameList objectAtIndex:array_frameList.count - 1];
        NSString *imgUrl = [frame valueForKey:@"imageUrl"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:imgUrl]) {
            if (self.video_type == 0) {
                //set basic video channel parameters
                self.root_viewController.basic_frame_list = array_frameList;
                self.root_viewController.basic_start_frameNumber = 0;
                self.root_viewController.basic_current_frameNumber = 0;
                self.root_viewController.basic_videoID = videoID;
                self.root_viewController.basic_end_frameNumber = array_frameList.count - 1;
                //            [self.root_viewController start_timer];
                [self dismissViewControllerAnimated:NO completion:Nil];
            }else
            {
                //set overlay video channel parameters
                self.root_viewController.overlay_frame_list = array_frameList;
                self.root_viewController.overlay_start_frameNumber = 0;
                self.root_viewController.overlay_current_frameNumber = 0;
                self.root_viewController.overlay_end_frameNumber = array_frameList.count - 1;
                self.root_viewController.overlay_videoID = videoID;
                //            [self.root_viewController start_timer];
                [self dismissViewControllerAnimated:NO completion:Nil];
            }
            return;
        }else
        {
            NSManagedObjectContext *context = nil;
            AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            context = delegate.persistentContainer.viewContext;
            for (NSManagedObject *frame_node in array_frameList) {
                [context deleteObject:frame_node];
            }
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);            
            }
        }
    }
    
    [self.view_loading setHidden:NO];
    [self.indicator_loading startAnimating];
    self.lbl_loadingResult.text = @"Connecting...";
    time = 0.0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *videoUrl = videoItem.video_url;
        self->video = [[VideoFrameExtractor alloc] initWithVideo:videoUrl];
//        [self->video setOutputWidth:self.outputWidth];
//        [self->video setOutputHeight:self.outputHeight];
        self->total_frameSize = (int)(self->video.duration * 30);
        self->loading_state = 1;
        [self->video seekTime:0.0];
    });
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                             target:self
                                           selector:@selector(displayLoadingState:)
                                           userInfo:nil
                                            repeats:YES];
    loading_timer = [NSTimer scheduledTimerWithTimeInterval: 0.01
                                                     target:self
                                                   selector:@selector(loadingFrame:)
                                                   userInfo:nil
                                                    repeats:YES];
}





//tableview delegate, datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return package_array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath
                                                                       *)indexPath
{
    VideoPackage *videoPackage=[package_array objectAtIndex:indexPath.row];
    
    if (!videoPackage.extend_state) {
        return 50;
    }else
    {
        int height_size = ((int)videoPackage.videoList.count + 1)/2;
        return 100 + (self.tbl_PackageList.frame.size.width - 35)/3*height_size;
    }
}

-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}


@end
