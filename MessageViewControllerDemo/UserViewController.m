//
//  UserViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/7/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Nickname: %@", self.currentUser.nickname];
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"id: %@", self.currentUser.userID];
            break;
            
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"facebook id: %@", self.currentUser.fbID];
            break;
            
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"full name: %@", self.currentUser.fbName];
            break;
            
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"created: %@", self.currentUser.createdAt];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"Nickname cell");
            break;
            
        case 1:
            NSLog(@"ID cell");
            break;
            
        case 2: {
            NSLog(@"Facebook ID cell");
            
            NSURL *facebookURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", self.currentUser.fbID]];
            if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
                [[UIApplication sharedApplication] openURL:facebookURL];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com"]];
            }
        }
            break;
            
        case 3:
            
            break;
            
        case 4:
            
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
