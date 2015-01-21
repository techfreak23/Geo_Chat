//
//  GeoChatAPIManager.h
//  GeoChat
//
//  Created by Art Sevilla on 1/12/15.
//  Copyright (c) 2015 MosRedRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoChatAPIManager : NSObject

+ (GeoChatAPIManager *)sharedManager;

- (void)loginWithAssertion:(NSString *)assertion;
- (void)logout;
- (void)fetchRoomsForLatitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void)fetchRoomForID:(NSString *)roomID;
- (void)createRoom:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void)sendMessage:(NSString *)content room:(NSString *)roomID;

@end
