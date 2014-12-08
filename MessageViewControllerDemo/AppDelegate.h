//
//  AppDelegate.h
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navController;

- (BOOL)loginStatus;
- (void)setLoginStatus:(BOOL)loginStatus;

@end

