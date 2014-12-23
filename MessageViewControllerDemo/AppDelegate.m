//
//  AppDelegate.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "LoginViewController.h"
#import "GeoChatManager.h"

@interface AppDelegate ()

@end

BOOL loggedIn = NO;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSLog(@"Launch options: %@", launchOptions);
    
    // Override point for customization after application launch.
    [FBLoginView class];
    [MasterViewController class];
    [LoginViewController class];
    
    UIUserNotificationSettings *notifSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notifSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    UIViewController *controller;
    
    /*
    if ([FBSession openActiveSessionWithAllowLoginUI:NO]) {
        NSLog(@"We're good here... app delegate");
        controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        [[GeoChatManager sharedManager] loginWithFacebookID:[[[FBSession activeSession] accessTokenData] accessToken]];
    } else {
        NSLog(@"Please show this joker the login view");
        controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    */
    
    if ([FBSession activeSession].isOpen) {
        NSLog(@"The session is still open...");
        // try to open session with existing valid token
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes",
                                @"read_stream",
                                @"publish_actions",
                                nil];
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
        
        if ([FBSession openActiveSessionWithAllowLoginUI:NO]) {
            NSLog(@"We're good here... app delegate");
            controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        } else {
            NSLog(@"Please show this joker the login view");
            controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        }
    } else {
        NSLog(@"Possibly a first time user.... because the session isnt open?");
        controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    
    /*
    if (loggedIn) {
        MasterViewController *controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
        self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
    } else {
        LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.navController.navigationBarHidden = YES;
    }
     */
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    return wasHandled;
}

- (BOOL)loginStatus
{
    return loggedIn;
}

- (void)setLoginStatus:(BOOL)loginStatus
{
    loggedIn = loginStatus;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
}

@end
