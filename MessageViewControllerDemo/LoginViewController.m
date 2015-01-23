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
#import "GeoChatAPIManager.h"

#define kFacebookTokenIdentifier @"facebookToken"

@interface LoginViewController () <FBLoginViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    NSLog(@"Login view loading...");
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLoggingIn:) name:@"didFinishLoggingIn" object:nil];
    
    self.title = @"Welcome to GeoChat!";
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:206.0/255.0f green:237.0/255.0f blue:219.0/255.0f alpha:1.0f];
    
    // Do any additional setup after loading the view from its nib.
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"public_profile", @"email"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, user);
    
    [[GeoChatAPIManager sharedManager] loginWithAssertion:[[[FBSession activeSession] accessTokenData] accessToken]];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didFinishLoggingIn:(NSNotification *)notification
{
    NSLog(@"Should be showing the main view now...");
    NSLog(@"Notification: %@", notification.description);
    MasterViewController *controller = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navController animated:NO completion:nil];
}

@end
