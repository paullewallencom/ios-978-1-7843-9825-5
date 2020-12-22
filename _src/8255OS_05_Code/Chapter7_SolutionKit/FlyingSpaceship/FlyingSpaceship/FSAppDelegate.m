//
//  FSAppDelegate.m
//  FlyingSpaceship
//
//  Created by Rahul on 9/13/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import "FSAppDelegate.h"

@interface FSAppDelegate()
{
    id currentiCloudToken;
}

@end
@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    currentiCloudToken = fileManager.ubiquityIdentityToken;
    
    if (currentiCloudToken)
    {
        NSData *newTokenData =
        [NSKeyedArchiver archivedDataWithRootObject:currentiCloudToken];

        [[NSUserDefaults standardUserDefaults]
         setObject:newTokenData
         forKey:@"com.mb.FlyingSpaceship.UbiquityIdentityToken"];
        
        BOOL firstLaunchWithiCloudAvailable =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchWithiCloudAvailable"];

        if (firstLaunchWithiCloudAvailable == NO)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                      forKey:@"FirstLaunchWithiCloudAvailable"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]
         removeObjectForKey: @"com.mb.FlyingSpaceship.UbiquityIdentityToken"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudAccountAvailabilityChanged:)
                                                 name:NSUbiquityIdentityDidChangeNotification
                                               object:nil];
    [self showiCloudInviteAlertView];
    return YES;
}

- (void)iCloudAccountAvailabilityChanged:(NSNotification*)notification
{
    // Handle Accordingly
}

- (void)showiCloudInviteAlertView
{
    BOOL firstLaunchWithiCloudAvailable =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchWithiCloudAvailable"];

    if (currentiCloudToken && firstLaunchWithiCloudAvailable)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc]  initWithTitle: @"Choose Storage Option"
                                    message: @"Should documents be stored in iCloud and available on all your devices?"
                                   delegate: self
                          cancelButtonTitle: @"Local Only"
                          otherButtonTitles: @"Use iCloud", nil];
        [alertView show];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
