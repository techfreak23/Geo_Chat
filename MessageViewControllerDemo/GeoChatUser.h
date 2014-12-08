//
//  GeoChatUser.h
//  GeoChatManager
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoChatUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic, strong) NSString *fbName;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;

- (void)configureUserForDictionary:(NSMutableDictionary *)userInfo;

@end
