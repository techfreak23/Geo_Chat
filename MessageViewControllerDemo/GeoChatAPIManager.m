//
//  GeoChatAPIManager.m
//  GeoChat
//
//  Created by Art Sevilla on 1/12/15.
//  Copyright (c) 2015 MosRedRocket. All rights reserved.
//

#define kGeoChatEndpoint @"https://geochat-v1.herokuapp.com"
#define kOAuthTokenIdentifier @"OAuthTokenIdentifier"

#import <AFNetworking/AFNetworking.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>
#import "GeoChatAPIManager.h"

typedef void (^RequestCompletion)(id responseItem, NSError *error);

@interface GeoChatAPIManager()

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) AFOAuth2Manager *oAuthManager;
@property (nonatomic, strong) NSMutableArray *joinedRooms;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@end

static NSString *ClientID = @"81fc0fd70219e5701f54982262b0f6b3c4bb6643a289581ae023bc85513e32e3";
static NSString *ClientSecret = @"87fa1dde258a6bea536840d98b1c8934d26790cbb0124c3a136f1da2f2a8803b";
NSString *AccessToken;
NSString *RefreshToken;
dispatch_queue_t kBgQueue;

@implementation GeoChatAPIManager

+ (GeoChatAPIManager *)sharedManager
{
    static dispatch_once_t pred;
    static GeoChatAPIManager *manager = nil;
    
    dispatch_once(&pred, ^{
        NSLog(@"This is the only time you should be seeing this...");
        manager = [[GeoChatAPIManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSLog(@"The API manager is initialized...");
        kBgQueue = dispatch_queue_create("com.MosRedRocket.GeoChatManager.bgqueue", NULL);
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", kGeoChatEndpoint]]];
        _operationManager.completionQueue = kBgQueue;
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        _joinedRooms = [@[] mutableCopy];
    }
    
    return self;
}

- (NSMutableDictionary *)userInfo
{
    return _userInfo;
}

#pragma mark - Request methods

- (void)sendGETForBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters completion:(RequestCompletion)handler
{
    dispatch_async(kBgQueue, ^{
        self.operationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [self.operationManager GET:baseURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Did finish GET with object: %@", responseObject);
            handler(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Did finish GET with error: %@", error.description);
            handler(nil, error);
        }];
    });
    
}

- (void)sendPOSTForBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters completion:(RequestCompletion)handler
{
    dispatch_async(kBgQueue, ^{
        self.operationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        [self.operationManager POST:baseURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Did finish POST with object: %@", responseObject);
            handler(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Did finish POST with error: %@", error.description);
            handler(nil, error);
        }];
    });
}

- (void)sendPATCHRequestForBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters completion:(RequestCompletion)handler
{
    dispatch_async(kBgQueue, ^{
        [self.operationManager PATCH:baseURL parameters:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Did finish PATCH with object: %@", responseObject);
            handler(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Did finish PATCH with error: %@", error.description);
            handler(nil, error);
        }];
    });
}

- (void)sendDELETEForBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters completion:(RequestCompletion)handler
{
    dispatch_async(kBgQueue, ^{
        self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.operationManager DELETE:baseURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Did finish DELETE with object: %@", responseObject);
            handler(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Did finsih DELETE with error: %@", error.description);
            handler(nil, error);
        }];
    });
}

#pragma mark - authentication methods

- (void)loginWithAssertion:(NSString *)assertion
{
    NSURL *geoChatURL = [NSURL URLWithString:kGeoChatEndpoint];
    
    self.oAuthManager = [[AFOAuth2Manager alloc] initWithBaseURL:geoChatURL clientID:ClientID secret:ClientSecret];
    dispatch_async(kBgQueue, ^{
        [self.oAuthManager authenticateUsingOAuthWithURLString:@"oauth/token" parameters:@{@"grant_type":@"assertion", @"assertion":assertion} success:^(AFOAuthCredential *credential) {
            NSLog(@"Did finish successfully with oauth credentials: %@", credential);
            AccessToken = credential.accessToken;
            RefreshToken = credential.refreshToken;
            [AFOAuthCredential storeCredential:credential withIdentifier:kOAuthTokenIdentifier];
            
            [self fetchUserRoomList];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Posting notification...");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishLoggingIn" object:nil];
            });
            
        } failure:^(NSError *error) {
            NSLog(@"Did finish with error: %@", error.description);
        }];
    });
}

// i might not need this method... i think AFNetworking can deal with this
// but I would need real life testing to know for sure. i can't find anything
// in the documentation that says so but i would just assume it does
- (void)refreshAccessTokens
{
    dispatch_async(kBgQueue, ^{
        [self.oAuthManager authenticateUsingOAuthWithURLString:[NSString stringWithFormat:@"oauth/token"] refreshToken:RefreshToken success:^(AFOAuthCredential *credential) {
            NSLog(@"Finished refreshing access token with credential: %@", credential);
        } failure:^(NSError *error) {
            NSLog(@"Finished refreshing access token with error: %@", error);
        }];
    });
}

- (void)logout
{
    NSLog(@"Logging out and clearing token info...");
    [AFOAuthCredential deleteCredentialWithIdentifier:kOAuthTokenIdentifier];
}

#pragma mark - misc methods for rooms etc

- (void)fetchRoomsForLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSDictionary *parameters = @{@"access_token":AccessToken, @"latitude":latitude, @"longitude":longitude, @"offest": @"0", @"size": @"15", @"radius": @"1"};
    
    [self sendGETForBaseURL:@"api/v1/chat_rooms" parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"Did finish successfully...");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishFetchingRooms" object:responseItem];
            });
        } else {
            NSLog(@"Something went wrong fetching the rooms: %@", error);
        }
    }];
}

- (void)fetchRoomForID:(NSString *)roomID
{
    NSString *baseURL = [NSString stringWithFormat:@"api/v1/chat_room"];
    NSDictionary *parameters = @{@"access_token": AccessToken, @"id": roomID};
    
    if ([self checkID:roomID]) {
        NSLog(@"Use was in the room so now we fetch room info...");
        [self sendGETForBaseURL:baseURL parameters:parameters completion:^(id responeItem, NSError *error) {
            if (!error) {
                //NSLog(@"Finished fetching room with response item: %@", responeItem);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishRoomInfo" object:responeItem];
                });
            } else {
                NSLog(@"Finished fetching room with error: %@", error.description);
            }
        }];
    } else {
        NSLog(@"User was not in the room so now we have to add them...");
        [self addUserToRoom:roomID];
    }
}

- (void)createRoom:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSString *baseURL = [NSString stringWithFormat:@"/api/v1/chat_rooms/create"];
    NSDictionary *parameters = @{@"access_token": AccessToken, @"chat_room": @{@"name": name, @"latitude": latitude, @"longitude": longitude}};
    
    [self sendPOSTForBaseURL:baseURL parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"%s", __PRETTY_FUNCTION__);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishCreatingRoom" object:responseItem];
            });
        } else {
            NSLog(@"Failed to create room: %@", error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishRoomWithError" object:error];
            });
        }
    }];
}

- (void)deleteRoom:(NSString *)roomID
{
    NSString *baseURL = [NSString stringWithFormat:@"/api/v1/chat_room"];
    NSDictionary *parameters = @{@"access_token": AccessToken, @"id": roomID};
    
    NSLog(@"Attempting to delete room...");
    
    [self sendDELETEForBaseURL:baseURL parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteWasSuccessful" object:nil];
            });
        } else {
            NSLog(@"Something went wrong with deleting the room: %@", error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteWasUnsuccessful" object:nil];
            });
        }
    }];
}

- (void)addUserToRoom:(NSString *)roomID
{
    NSString *baseURL = [NSString stringWithFormat:@"/api/v1/chat_room/add_user"];
    NSDictionary *parameters = @{@"access_token": AccessToken, @"id": roomID};
    
    [self sendPOSTForBaseURL:baseURL parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"Did finish adding user to room: %@ now fetching details...", responseItem);
            [self.joinedRooms addObject:responseItem];
            [self fetchRoomForID:roomID];
        } else {
            NSLog(@"Could not add user at this time: %@", error.description);
        }
    }];
}

- (BOOL)checkID:(NSString *)roomID
{
    if (self.joinedRooms.count > 0) {
        for (NSDictionary *temp in self.joinedRooms) {
            NSString *tempID = [temp objectForKey:@"id"];
            if ([tempID isEqual:roomID]) {
                NSLog(@"This user is already in the room...");
                return YES;
            }
        }
    }
    NSLog(@"The user was not in the room...");
    return NO;
}

- (void)sendMessage:(NSString *)content room:(NSString *)roomID
{
    NSString *baseURL = [NSString stringWithFormat:@"/api/v1/chat_room/send_message"];
    NSDictionary *parameters = @{@"access_token": AccessToken, @"id": roomID, @"message": @{@"content": content}};
    
    [self sendPOSTForBaseURL:baseURL parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"%s : %@", __PRETTY_FUNCTION__, responseItem);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishSendingMessage" object:responseItem];
            });
        } else {
            NSLog(@"%s : %@", __PRETTY_FUNCTION__, error.description);
        }
    }];
    
}

- (void)fetchUserRoomList
{
    NSString *baseURL = [NSString stringWithFormat:@"/api/v1/user/chat_rooms"];
    NSDictionary *parameters = @{@"access_token" : AccessToken};
    
    [self sendGETForBaseURL:baseURL parameters:parameters completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"User list fetched...");
            self.joinedRooms = [responseItem mutableCopy];
        } else {
            NSLog(@"Error fetching user list: %@", error.description);
        }
    }];
}




@end
