//
//  MessagesViewController.h
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/4/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "JSQMessages.h"
#import "GeoChatManager.h"

@interface MessagesViewController : JSQMessagesViewController

@property (nonatomic, strong) NSMutableDictionary *roomInfo;
@property (nonatomic, strong) GeoChatUser *currentUser;

@end
