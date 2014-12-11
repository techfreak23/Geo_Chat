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
    self.userID = [userInfo objectForKey:@"id"];
    self.nickname = [userInfo objectForKey:@"nick_name"];
    self.fbID = [userInfo objectForKey:@"fb_id"];
    self.fbName = [userInfo objectForKey:@"fb_name"];
    self.createdAt = [userInfo objectForKey:@"created_at"];
    self.updatedAt = [userInfo objectForKey:@"updated_at"];
}

@end
