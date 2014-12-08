//
//  GeoChatUser.m
//  GeoChatManager
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "GeoChatUser.h"

@implementation GeoChatUser

- (void)configureUserForDictionary:(NSMutableDictionary *)userInfo
{
    _userID = [userInfo objectForKey:@"id"];
    _nickname = [userInfo objectForKey:@"nick_name"];
    _fbID = [userInfo objectForKey:@"fb_id"];
    _fbName = [userInfo objectForKey:@"fb_name"];
    _createdAt = [userInfo objectForKey:@"created_at"];
    _updatedAt = [userInfo objectForKey:@"updated_at"];
}

@end
