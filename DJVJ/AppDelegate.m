//
//  AppDelegate.m
//  DJVJ
//
//  Created by Bin on 2018/11/28.
//  Copyright © 2018 Bin. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "GlobalData.h"

@import Firebase;
@interface AppDelegate ()
{
    NSTimer *timer;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"alreadyOpened"])
    {
        //set default spectial effects
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"alreadyOpened"];
        [[NSUserDefaults standardUserDefaults] setObject:@"white strobe" forKey:@"effect_1"];
        [[NSUserDefaults standardUserDefaults] setObject:@"black strobe" forKey:@"effect_2"];
        [[NSUserDefaults standardUserDefaults] setObject:@"fade to black" forKey:@"effect_3"];
        [[NSUserDefaults standardUserDefaults] setObject:@"zoom" forKey:@"effect_4"];
        [[NSUserDefaults standardUserDefaults] setObject:@"caleido tl" forKey:@"effect_5"];
        [[NSUserDefaults standardUserDefaults] setObject:@"threshold" forKey:@"effect_6"];
        [[NSUserDefaults standardUserDefaults] setObject:@"freeze" forKey:@"effect_7"];
        
        //set default output width and height
        [[NSUserDefaults standardUserDefaults] setObject:@"640" forKey:@"width"];
        [[NSUserDefaults standardUserDefaults] setObject:@"360" forKey:@"height"];
        
        //set default audio input source
        [[NSUserDefaults standardUserDefaults] setObject:@"mic" forKey:@"audio_input"];
        
        //set default output resize type
        [[NSUserDefaults standardUserDefaults] setObject:@"Crop" forKey:@"output_resize"];
        
        //set default output frame rate
        [[NSUserDefaults standardUserDefaults] setObject:@"30" forKey:@"output_rate"];
        
        //set IAP variable
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"iap_watermark"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"iap_watermark_output"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"iap_extend"];
    }
    GlobalData *global = [GlobalData sharedGlobalData];
    [global get_localFile];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target:self
                                           selector:@selector(running:)
                                           userInfo:nil
                                            repeats:YES];
    
    return YES;    
}

-(void)running:(NSTimer *)timer {
    NSLog(@"%ld",(long)[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]);
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] ==  NotReachable) {
        NSLog(@"No internet connection");
    }else
    {
        GlobalData *global = [GlobalData sharedGlobalData];
        [global get_videoList];
        [global get_imageList];
        [timer invalidate];
        timer = nil;
    }    
}
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DJVJ"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
