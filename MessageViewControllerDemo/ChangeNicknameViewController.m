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
    
    _menuItems = @[@"new nickname", @"update nickname"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNickname:(id)sender
{
    NSLog(@"Updating with new nickname: %@", _nicknameField.text);
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (indexPath.row) {
        case 0: {
            _nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            _nicknameField.delegate = self;
            _nicknameField.textAlignment = NSTextAlignmentCenter;
            _nicknameField.textColor = [UIColor blackColor];
            _nicknameField.placeholder = [_menuItems objectAtIndex:indexPath.row];
            _nicknameField.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:_nicknameField];
        }
            break;
            
        case 1: {
            _updateButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            _updateButton.backgroundColor = [UIColor lightGrayColor];
            _updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            _updateButton.titleLabel.textColor = [UIColor blackColor];
            _updateButton.titleLabel.text = [_menuItems objectAtIndex:indexPath.row];
            [_updateButton addTarget:self action:@selector(updateNickname:) forControlEvents:UIControlEventTouchUpInside];
            _updateButton.enabled = NO;
            [cell.contentView addSubview:_updateButton];
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
        _updateButton.enabled = YES;
    } else {
        _updateButton.enabled = NO;
    }
    
    return YES;
}

@end
