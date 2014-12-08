//
//  LoginViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "MasterViewController.h"
#import "UYLPasswordManager.h"
#import "GeoChatManager.h"

#define kFacebookTokenIdentifier @"facebookToken"

@interface LoginViewController () <FBLoginViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    NSLog(@"Login view loading...");
    
    [super viewDidLoad];
    
    self.title = @"Welcome to GeoChat!";
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // Do any additional setup after loading the view from its nib.
    _loginView.delegate = self;
    _loginView.readPermissions = @[@"public_profile", @"email"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonAction:(id)sender
{
    NSLog(@"Login button pressed...");
    
    MasterViewController *controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, user);
    UYLPasswordManager *manager = [UYLPasswordManager sharedInstance];
    
    if ([manager keyForIdentifier:kFacebookTokenIdentifier]) {
        [manager deleteKeyForIdentifier:kFacebookTokenIdentifier];
        [manager registerKey:[[[FBSession activeSession] accessTokenData] accessToken] forIdentifier:kFacebookTokenIdentifier];
    } else {
        [manager registerKey:[[[FBSession activeSession] accessTokenData] accessToken] forIdentifier:kFacebookTokenIdentifier];
    }
    [[GeoChatManager sharedManager] loginWithFacebookID:[[[FBSession activeSession] accessTokenData] accessToken]];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    MasterViewController *controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navController animated:NO completion:nil];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UYLPasswordManager *manager = [UYLPasswordManager sharedInstance];
    [manager deleteKeyForIdentifier:kFacebookTokenIdentifier];
}

@end
