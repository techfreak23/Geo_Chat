//
//  ChangeNicknameViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/8/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "ChangeNicknameViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNickname:(id)sender
{
    NSLog(@"Updating with new nickname: %@", self.nicknameField.text);
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
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    frame.size.height = cell.frame.size.height;
    cell.frame = frame;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (indexPath.row) {
        case 0: {
            self.nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            self.nicknameField.delegate = self;
            self.nicknameField.textAlignment = NSTextAlignmentCenter;
            self.nicknameField.textColor = [UIColor blackColor];
            self.nicknameField.placeholder = [self.menuItems objectAtIndex:indexPath.row];
            self.nicknameField.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:self.nicknameField];
        }
            break;
            
        case 1: {
            self.updateButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            self.updateButton.backgroundColor = [UIColor lightGrayColor];
            self.updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.updateButton.titleLabel.textColor = [UIColor blackColor];
            self.updateButton.titleLabel.text = [self.menuItems objectAtIndex:indexPath.row];
            [self.updateButton addTarget:self action:@selector(updateNickname:) forControlEvents:UIControlEventTouchUpInside];
            self.updateButton.enabled = NO;
            [cell.contentView addSubview:self.updateButton];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

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
