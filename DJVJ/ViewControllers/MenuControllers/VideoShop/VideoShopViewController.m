//
//  VideoShopViewController.m
//  DJVJ
//
//  Created by Bin on 2018/11/28.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "VideoShopViewController.h"
#import "AppDelegate.h"
#import "GlobalData.h"
#import "VideoShopPackageCell.h"
#import "VideoPackage.h"

#import <StoreKit/StoreKit.h>
@interface VideoShopViewController ()<SKPaymentTransactionObserver>
{
    GlobalData *global;
    NSMutableArray *package_array;
    VideoPackage * buyPackage;
    UIButton *buyButton;
}
@end

@implementation VideoShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    self.view_container.layer.cornerRadius = 5.0;
    self.view_container.clipsToBounds = true;
    self.view_close.layer.cornerRadius = self.view_close.layer.bounds.size.height/2;
    self.view_close.clipsToBounds = true;
    _brScrollBarController = [BRScrollBarController setupScrollBarWithScrollView:self.tbl_PackageList inPosition:BRScrollBarPostionRight delegate:self];
    _brScrollBarController.scrollBar.backgroundColor = [UIColor clearColor];
    _brScrollBarController.scrollBar.scrollHandle.backgroundColor = [UIColor colorWithRed:0.0 green:149/255.0 blue:1.0 alpha:1.0];
    _brScrollBarController.scrollBar.hideScrollBar = NO;
    self.tbl_PackageList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.lbl_message setHighlighted:YES];
    
    global = [GlobalData sharedGlobalData];
    [NSTimer scheduledTimerWithTimeInterval: 0.1
                                     target:self
                                   selector:@selector(getVideos:)
                                   userInfo:nil
                                    repeats:YES];
    [self setTheme];
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}
-(void)setTheme{
    if (global.day_mode) {
        //set day mode color
        self.view_container.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_videoShop.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        self.lbl_message.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        self.img_closeIcon.image = [UIImage imageNamed:@"icon_cancel_white.png"];
        
    }else
    {
        //set night mode color
        self.view_container.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.lbl_videoShop.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.lbl_message.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.img_closeIcon.image = [UIImage imageNamed:@"icon_cancel_333333_default.png"];
    }
}
-(void)getVideos:(NSTimer *)videoTimer {
    if (global.availableImagePackageArray.count > 0) {
        if (global.purchageVideoState == 2) {
            [self.lbl_message setHidden:NO];
            self.lbl_message.text = @"There are currently no items available for purchase. Please check back another day for some amazing new content for DJVJ!";
        }else
        {
            package_array = global.shopVideoPackageArray;
            if (package_array.count == 0) {
                [self.lbl_message setHighlighted:NO];
                self.lbl_message.text = @"WOW!!! You've purchased all available Video Loop Packages! You're definitely the DJVJ Video Mixing Master!";
            }
            [self.tbl_PackageList reloadData];
        }        
        [videoTimer invalidate];
        videoTimer = nil;
    }else
    {
        [self.lbl_message setHidden:NO];
        self.lbl_message.text = @"Oops… the content has failed to load. There might be a problem with your connection or our server. Please try again later!";
    }
    
}

- (IBAction)action_close_down:(id)sender {
    self.img_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_active.png"];
}

- (IBAction)action_close:(id)sender {
    self.img_close_background.image = [UIImage imageNamed:@"button_circle_0095FF_glow_default.png"];
    [self dismissViewControllerAnimated:NO completion:Nil];
}


#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath
                                                                               *)indexPath
{
    //ChannelNodeCell *brTableCell = [[ChannelNodeCell alloc] init];
    [tableView registerNib:[UINib nibWithNibName:@"VideoShopPackageCell" bundle:nil] forCellReuseIdentifier:@"VideoShopPackageCell"];
    VideoShopPackageCell *ctTableCell = (VideoShopPackageCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoShopPackageCell" forIndexPath:indexPath];
    
    VideoPackage *videoPackage=[package_array objectAtIndex:indexPath.row];
    ctTableCell.lbl_PackageName.text = videoPackage.name;
    
    ctTableCell.videoPackage = videoPackage;
    ctTableCell.packageIndex = (int)indexPath.row;
    ctTableCell.btn_extend.tag = indexPath.row;
    [ctTableCell.btn_extend addTarget:self action:@selector(extendClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    ctTableCell.lbl_price.text = [global.iapKeyList valueForKey:videoPackage.productID];
    
    [ctTableCell.btn_buy setBackgroundImage:[UIImage imageNamed:@"button_fxpad_menu_0095FF_glow_default_changed.png"] forState:UIControlStateNormal];
    [ctTableCell.btn_buy setBackgroundImage:[UIImage imageNamed:@"button_fxpad_menu_0095FF_glow_active_changed.png"] forState:UIControlStateHighlighted];
    
    ctTableCell.btn_buy.tag = indexPath.row;
    [ctTableCell.btn_buy addTarget:self action:@selector(buyClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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

//in app purchase
- (void)buyClicked:(UIButton *)sender
{
    buyButton = sender;
    buyButton.enabled = NO;
    VideoPackage *videoPackage=[package_array objectAtIndex:sender.tag];
    buyPackage = videoPackage;
    for (SKProduct *validProduct in global.validProducts) {
        if ([validProduct.productIdentifier isEqualToString:videoPackage.productID]) {
            if ([SKPaymentQueue canMakePayments]) {
                SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
                [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            }else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"Purchases are disabled in your device." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            return;
        }
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased");
                buyButton.enabled = YES;
                if ([transaction.payment.productIdentifier isEqualToString:buyPackage.productID]) {
                    //purchased successfully
                    NSManagedObject *purchaseVideo = [NSEntityDescription insertNewObjectForEntityForName:@"PurchageVideo" inManagedObjectContext:[self managedObjectContext]];
                    
                    NSString *str_ID = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970] * 1000)];
                    
                    [purchaseVideo setValue:str_ID forKey:@"id"];
                    [purchaseVideo setValue:buyPackage.package_id forKey:@"package_id"];
                    NSError *error = nil;
                    
                    if (![[self managedObjectContext] save:&error]) {
                        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                    }
                    [global.shopVideoPackageArray removeObject:buyPackage];
                    [global.availableVideoPackageArray addObject:buyPackage];
                    package_array = global.shopVideoPackageArray;
                    [self.tbl_PackageList reloadData];
                    if (package_array.count == 0) {
                        [self.lbl_message setHighlighted:NO];
                        self.lbl_message.text = @"WOW!!! You've purchased all available Video Loop Packages! You're definitely the DJVJ Video Mixing Master!";
                    }
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                buyButton.enabled = YES;
                NSLog(@"Restored");
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed");
                buyButton.enabled = YES;
                break;
                
            default:
                break;
        }
        
    }
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

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}
@end
