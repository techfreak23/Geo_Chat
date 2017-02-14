//
//  RoomDetailViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 2/6/15.
//  Copyright (c) 2015 Art Sevilla. All rights reserved.
//

#import "RoomDetailViewController.h"

@interface RoomDetailViewController ()

@end

@implementation RoomDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    return self.roomDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView sizeToFit];
    screenFrame.size.height = cell.frame.size.height;
    screenFrame.origin = cell.frame.origin;
    cell.frame = screenFrame;
    cell.contentView.frame = screenFrame;
    
    CGRect cellFrame = cell.frame;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    
    switch (indexPath.row) {
        case 0: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width, cellFrame.size.height)];
            titleLabel.text = [self.roomDetails objectForKey:@"name"];
            
        }
            break;
            
        case 1: {
            
        }
            break;
            
        case 2: {
            
        }
            break;
            
        case 3: {
            
        }
            break;
            
        case 4: {
            
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


@end
