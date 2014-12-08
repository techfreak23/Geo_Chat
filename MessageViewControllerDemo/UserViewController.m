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
            cell.textLabel.text = [NSString stringWithFormat:@"Nickname: %@", _currentUser.nickname];
            break;
            
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"id: %@", _currentUser.userID];
            break;
            
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"facebook id: %@", _currentUser.fbID];
            break;
            
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"full name: %@", _currentUser.fbName];
            break;
            
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"created: %@", _currentUser.createdAt];
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end
