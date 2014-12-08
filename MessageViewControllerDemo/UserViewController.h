//
//  UserViewController.h
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/7/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoChatManager.h"

@interface UserViewController : UITableViewController

@property (nonatomic, strong) GeoChatUser *currentUser;

@end
