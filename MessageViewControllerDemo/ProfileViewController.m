//
//  ProfileViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/4/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

static NSString *reuseIdentifier = @"Cell";

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"User info";
    if (self.userInfo) {
        NSLog(@"User info count: %lu", (unsigned long)[self.userInfo count]);
    }
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
    return self.userInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    return cell;
}

@end
