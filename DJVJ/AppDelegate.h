//
//  AppDelegate.h
//  DJVJ
//
//  Created by Bin on 2018/11/28.
//  Copyright © 2018 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL restrictRotation;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

