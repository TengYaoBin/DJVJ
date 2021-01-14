//
//  SelectImageViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/19.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "SelectImageViewController.h"
#import "AppDelegate.h"
#import "GlobalData.h"
#import "ImagePackageCell.h"

#import "ImageShopViewController.h"
@interface SelectImageViewController ()
{
    NSTimer *getImagetimer;
    GlobalData *global;
    NSMutableArray *package_array;
}

@end

@implementation SelectImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    //load image from server
    global = [GlobalData sharedGlobalData];
    package_array = global.availableImagePackageArray;
    
    self.view_containner.layer.cornerRadius = 5.0;
    self.view_containner.clipsToBounds = YES;
    self.view_imgBackground.layer.cornerRadius = 5.0;
    self.view_imgBackground.clipsToBounds = YES;
    self.img_content.image = self.selected_image;
    
    if (!CGSizeEqualToSize(self.selected_image.size, CGSizeZero)) {
        self.constraint_img_content_width.constant = self.view_imgContent.frame.size.width * self.image_size;
        self.constraint_img_content_height.constant = self.view_imgContent.frame.size.width * self.image_size * self.selected_image.size.height/self.selected_image.size.width;
    }else
    {
        self.constraint_img_content_width.constant = 0.0;
        self.constraint_img_content_height.constant = 0.0;
    }
    
    
    self.view_imgContent.layer.cornerRadius = 8.0;
    self.view_imgContent.clipsToBounds = YES;
    [self.view layoutIfNeeded];
    
    //height slider
    UIImage *topImage = [UIImage imageNamed:@"slider_0095FF_top_glow_default.png"];
    UIImage *topTintImage = [UIImage imageNamed:@"slider_0095FF_top_glow_active.png"];
    UIImage *bottomImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_default.png"];
    UIImage *bottomTintImage = [UIImage imageNamed:@"slider_0095FF_bottom_glow_active.png"];
    UIImage *contentImage = [UIImage imageNamed:@"slider_0095FF_center_glow_default.png"];
    UIImage *contentTintImage = [UIImage imageNamed:@"slider_0095FF_center_glow_active.png"];
    UIImage *trackImage = [UIImage imageNamed:@"slider_track_333333.png"];
    [self.slider_size setSliderImage:topImage :bottomImage :contentImage :topTintImage :bottomTintImage :contentTintImage];
    [self.slider_size setSliderTrackImage:trackImage];
    [self.slider_size setValue:self.image_size];
    
    _brScrollBarController = [BRScrollBarController setupScrollBarWithScrollView:self.tbl_packageList inPosition:BRScrollBarPostionRight delegate:self];
    _brScrollBarController.scrollBar.backgroundColor = [UIColor clearColor];
    _brScrollBarController.scrollBar.scrollHandle.backgroundColor = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    _brScrollBarController.scrollBar.hideScrollBar = NO;
    self.tbl_packageList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    getImagetimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                     target:self
                                                   selector:@selector(getImages:)
                                                   userInfo:nil
                                                    repeats:YES];
    [self setTheme];
    // Do any additional setup after loading the view.
}
-(void)getImages:(NSTimer *)videoTimer {
    package_array = global.availableImagePackageArray;
    if (package_array.count > 0) {
        [self.tbl_packageList reloadData];
        [videoTimer invalidate];
        videoTimer = nil;
    }
}
-(void)setTheme
{
    if (global.day_mode) {
        //set day mode color
        self.view_containner.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_selectImage.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_imgBackground.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.view_imgContent.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_size.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        
        [self.btn_buy setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_import setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
    }else
    {
        //set night mode color
        self.view_containner.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_selectImage.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        [self.btn_ok setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        self.view_imgBackground.backgroundColor = [UIColor colorWithRed:71.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        self.view_imgContent.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_size.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        [self.btn_buy setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btn_import setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
}
-(void)viewWillLayoutSubviews
{
    [self.view layoutIfNeeded];
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
    self.constraint_img_content_width.constant = self.view_imgContent.frame.size.width * self.slider_size.value;
    self.constraint_img_content_height.constant = self.view_imgContent.frame.size.height * self.slider_size.value;
    [self.slider_size updateView];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}
- (IBAction)onclick_ok_down:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok_active.png"];
}

- (IBAction)onclick_ok:(id)sender {
    self.img_ok.image = [UIImage imageNamed:@"button_ok.png"];
    self.root_viewController.image_size = self.slider_size.value;
    
    //self.root_viewController.imageOrigin = self.selected_image;
    if (self.selectedImage != nil && self.selectedPackage != nil && self.selected_image != nil) {
        
        NSData *pngData = UIImagePNGRepresentation(self.selected_image);
        NSString *str_ID = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
        NSLog(@"%@",str_ID);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.PNG",str_ID]];
        [pngData writeToFile:filePath atomically:YES];
        self.root_viewController.imageOrigin = [UIImage imageWithContentsOfFile:filePath];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadImage"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id =  %@", self.selectedImage.image_id];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSMutableArray *array_downloadimageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        if (array_downloadimageList.count == 0) {
            NSManagedObject *downloadVideo = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadImage" inManagedObjectContext:[self managedObjectContext]];
            [downloadVideo setValue:self.selectedImage.image_id forKey:@"id"];
            [downloadVideo setValue:self.selectedPackage.package_id forKey:@"package_id"];
            [downloadVideo setValue:self.selectedImage.image_url forKey:@"image_url"];
            [downloadVideo setValue:filePath forKey:@"downloadUrl"];
        }else
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSManagedObject *imageNode = [array_downloadimageList objectAtIndex:0];
            NSString *imgUrl = [imageNode valueForKey:@"downloadUrl"];
            if ([fileManager fileExistsAtPath:imgUrl])
            {
                [fileManager removeItemAtPath:imgUrl  error:NULL];
            }
            [imageNode setValue:filePath forKey:@"downloadUrl"];
        }
        
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadImagePackage"];
        predicate = [NSPredicate predicateWithFormat:@"id =  %@", self.selectedPackage.package_id];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSMutableArray *array_packageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        if (array_packageList.count == 0) {
            NSManagedObject *imagePackageObject = [NSEntityDescription insertNewObjectForEntityForName:@"DownloadImagePackage" inManagedObjectContext:[self managedObjectContext]];
            [imagePackageObject setValue:self.selectedPackage.package_id forKey:@"id"];
            [imagePackageObject setValue:self.selectedPackage.name forKey:@"name"];
        }
        
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
    }else
    {
        self.root_viewController.imageOrigin = self.img_content.image;
    }
    
    
    
    
    
    
    
//    [self.root_viewController start_timer];
    [self dismissViewControllerAnimated:NO completion:Nil];
}
- (void)setSelectImage:(UIImage *)image
{
    self.selected_image = image;
    self.img_content.image = self.selected_image;
}
- (IBAction)size_valuechanged:(id)sender {    
    if (!CGSizeEqualToSize(self.selected_image.size, CGSizeZero)) {
        self.constraint_img_content_width.constant = self.view_imgContent.frame.size.width * self.slider_size.value;
        self.constraint_img_content_height.constant = self.view_imgContent.frame.size.width * self.slider_size.value * self.selected_image.size.height/self.selected_image.size.width;
    }
    [self.view layoutIfNeeded];
}
- (IBAction)btn_buy_down:(id)sender {
    self.img_buy_background.image = [UIImage imageNamed:@"button_normal_active.png"];
}
- (IBAction)btn_buyClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    ImageShopViewController *imageShopViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"ImageShopViewController"];
    imageShopViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.root_viewController presentViewController:imageShopViewController animated:NO completion:nil];
}
- (IBAction)btn_import_down:(id)sender {
    self.img_import_background.image = [UIImage imageNamed:@"button_normal_active.png"];
}
- (IBAction)btn_import_clicked:(id)sender {
    self.img_import_background.image = [UIImage imageNamed:@"button_normal.png"];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"This feature is a Premium Add-on and it will be available very soon!" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alertController animated:YES completion:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"This option is coming soon! Look out for the next update of DJVJ." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath
                                                                               *)indexPath
{
    //ChannelNodeCell *brTableCell = [[ChannelNodeCell alloc] init];
    [tableView registerNib:[UINib nibWithNibName:@"ImagePackageCell" bundle:nil] forCellReuseIdentifier:@"ImagePackageCell"];
    ImagePackageCell *ctTableCell = (ImagePackageCell *)[tableView dequeueReusableCellWithIdentifier:@"ImagePackageCell" forIndexPath:indexPath];
    
    ImagePackage *imagePackage=[package_array objectAtIndex:indexPath.row];
    ctTableCell.lbl_PackageName.text = imagePackage.name;
    ctTableCell.lbl_counts.text = [NSString stringWithFormat:@"- X %d IMAGES",(int)imagePackage.imageList.count];
    ctTableCell.superController = self;
    ctTableCell.imagePackage = imagePackage;
    ctTableCell.packageIndex = (int)indexPath.row;
    ctTableCell.btn_extend.tag = indexPath.row;
    [ctTableCell.btn_extend addTarget:self action:@selector(extendClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!imagePackage.extend_state) {
        ctTableCell.img_extend.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        [ctTableCell.view_extend setHidden:YES];
    }else
    {
        ctTableCell.img_extend.image = [UIImage imageNamed:@"icon_arrowup_0095FF_default.png"];
        ctTableCell.lbl_countsBottom.text = [NSString stringWithFormat:@"X %d IMAGES",(int)imagePackage.imageList.count];
        [ctTableCell.view_extend setHidden:NO];
    }
    ctTableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [ctTableCell reloadInputViews];
    return ctTableCell;
}
- (void)extendClicked:(UIButton *)sender
{
    ImagePackage *imagePackage=[package_array objectAtIndex:sender.tag];
    if (imagePackage.extend_state) {
        imagePackage.extend_state = NO;
    }else
    {
        imagePackage.extend_state = YES;
    }
    [self.tbl_packageList reloadData];
}

//tableview delegate, datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return package_array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath
                                                                       *)indexPath
{
    ImagePackage *imagePackage=[package_array objectAtIndex:indexPath.row];
    
    if (!imagePackage.extend_state) {
        return 50;
    }else
    {
        int height_size = ((int)imagePackage.imageList.count + 1)/2;
        return 100 + (self.tbl_packageList.frame.size.width - 35)/3*height_size;
    }
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
