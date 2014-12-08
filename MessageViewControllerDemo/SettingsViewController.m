//
//  SettingsViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/1/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "UserViewController.h"
#import "GeoChatManager.h"

@interface SettingsViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSettings)];
    
    _menuItems = @[@"View profile", @"Change nickname", @"Logout"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSettings
{
    NSLog(@"Closing settings...");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [_menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            NSLog(@"Getting user info...");
            UserViewController *controller = [[UserViewController alloc] init];
            controller.currentUser = [[GeoChatManager sharedManager] currentUser];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case 1: {
            NSLog(@"Presenting change nickname view...");
        }
            break;
            
        case 2: {
            NSLog(@"Showing logout sheet...");
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Logout" otherButtonTitles: nil];
            [actionSheet showInView:self.view];
        }
            break;
            
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Logging out...");
    //change loginStatus BOOL values to false and logout of FBSession. then present login view controller
    
    switch (buttonIndex) {
        case 0: {
            [[FBSession activeSession] closeAndClearTokenInformation];
            LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            navController.navigationBarHidden = YES;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
            break;
            
        case 1:
            NSLog(@"Button 1");
            break;
            
        default:
            break;
    }
    
}

@end
