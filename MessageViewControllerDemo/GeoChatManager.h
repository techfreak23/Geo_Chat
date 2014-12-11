//
//  GeoChatManager.h
//  GeoChatManager
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoChatUser.h"

typedef void (^RequestCompletion)(id responseItem, NSURLResponse *response, NSError *error);


@interface GeoChatManager : NSObject

@property (nonatomic, strong) GeoChatUser *currentUser;

+ (GeoChatManager *)sharedManager;

- (void)loginWithFacebookID:(NSString *)fbToken;
- (void)fetchRoomsWithLatitude:(NSString *)latitude longitude:(NSString *)longitude offset:(NSString *)offset size:(NSString *)size radius:(NSString *)radius;
- (void)createRoomWithName:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void)fetchRoomForID:(NSString *)roomID;
- (void)sendMessageWithText:(NSString *)message forChatRoomID:(NSString *)roomID;
- (void)listChatroomsForUser;
- (void)fetchNewMessagesForRoom:(NSString *)roomID index:(NSString *)index;
- (void)addUserToRoom:(NSString *)roomID;


@end
