//
//  ChangeNicknameViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/8/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "ChangeNicknameViewController.h"
#import "GeoChatAPIManager.h"

@interface ChangeNicknameViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) UITextField *nicknameField;
@property (nonatomic, strong) UIButton *updateButton;

@end

@implementation ChangeNicknameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = @[@"new nickname", @"update nickname"];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.title = @"Change nickname";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChange)];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.updateButton.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)updateNickname
{
    NSLog(@"Updating with new nickname: %@", self.nicknameField.text);
    
    [[GeoChatAPIManager sharedManager] updateUsername:self.nicknameField.text];
}

- (void)cancelChange
{
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
    return self.menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    //CGRect frame = [[UIScreen mainScreen] bounds];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView sizeToFit];
    frame.size.height = cell.frame.size.height;
    frame.origin = cell.frame.origin;
    cell.frame = frame;
    cell.contentView.frame = frame;
    
    CGRect cellFrame = cell.frame;
    
    //frame.size.height = cell.frame.size.height;
    //cell.frame = frame;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (indexPath.row) {
        case 0: {
            
            self.nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width, cellFrame.size.height)];
            self.nicknameField.translatesAutoresizingMaskIntoConstraints = NO;
            self.nicknameField.textAlignment = NSTextAlignmentCenter;
            self.nicknameField.placeholder = [self.menuItems objectAtIndex:indexPath.row];
            self.nicknameField.delegate = self;
            self.nicknameField.tintColor = [UIColor whiteColor];
            self.nicknameField.backgroundColor = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:0.30f];
            [cell.contentView addSubview:self.nicknameField];
            
            /*
            self.nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            self.nicknameField.delegate = self;
            self.nicknameField.textAlignment = NSTextAlignmentCenter;
            self.nicknameField.textColor = [UIColor blackColor];
            self.nicknameField.placeholder = [self.menuItems objectAtIndex:indexPath.row];
            self.nicknameField.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:self.nicknameField];
            */
        }
            break;
            
        case 1: {
            self.updateButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            self.updateButton.backgroundColor = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:0.85f];
            self.updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.updateButton.titleLabel.textColor = [UIColor whiteColor];
            self.updateButton.titleLabel.text = [self.menuItems objectAtIndex:indexPath.row];
            [self.updateButton addTarget:self action:@selector(updateNickname) forControlEvents:UIControlEventTouchUpInside];
            self.updateButton.enabled = NO;
            [cell.contentView addSubview:self.updateButton];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 4) {
        self.updateButton.enabled = YES;
    } else {
        self.updateButton.enabled = NO;
    }
    
    return YES;
}

@end
