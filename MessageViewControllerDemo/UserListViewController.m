//
//  UserListViewController.m
//  MessageViewControllerDemo
//
//  Created by Arturo Sevilla on 12/27/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

@end

@implementation UserListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Current users";
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
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [[self.userList objectAtIndex:indexPath.row] objectForKey:@"nick_name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
