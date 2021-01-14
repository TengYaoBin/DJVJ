//
//  PortraitViewController.m
//  DJVJ
//
//  Created by Bin on 2018/12/10.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "PortraitViewController.h"
#import "AppDelegate.h"

@interface PortraitViewController ()

@end

@implementation PortraitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UINavigationController attemptRotationToDeviceOrientation];
    [self restrictRotation:YES];
    
    //in case of ipad, fix device orientation as portrait mode.
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        //ipad
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
        [self restrictRotation:YES];
    }
    
    // Do any additional setup after loading the view.
}
-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self restrictRotation:NO];
}


@end
