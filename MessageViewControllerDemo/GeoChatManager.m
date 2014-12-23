//
//  GeoChatManager.m
//  GeoChatManager
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

//#define kOAuthEndpoint @"http://10.0.0.31:3000/oauth/token"
//#define kChatRoomsEndpoint @"http://10.0.0.31:3000/api/v1/chat_rooms"
//#define kChatRoomEndpoint @"http://10.0.0.31:3000/api/v1/chat_room"
//#define kUserEndpoint @"http://10.0.0.31:3000/api/v1/user"

#define kOAuthEndpoint @"https://geochat-v1.herokuapp.com/oauth/token"
#define kChatRoomsEndpoint @"https://geochat-v1.herokuapp.com/api/v1/chat_rooms"
#define kChatRoomEndpoint @"https://geochat-v1.herokuapp.com/api/v1/chat_room"
#define kUserEndpoint @"https://geochat-v1.herokuapp.com/api/v1/user"
#define kFacebookTokenIdentifier @"facebookToken"
#define kAccessTokenIdentifier @"accessToken"
#define kRefreshTokenIdentifier @"refreshToken"
#define kExpirationTokenIdentifier @"expireToken"

//#define kBgQueue dispatch_queue_create("com.MosRedRocket.geochatmanager.bgqueue", NULL)



#import "GeoChatManager.h"
#import "UYLPasswordManager.h"
#import "dispatch/dispatch.h"

@interface GeoChatManager() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSDictionary *authTokens;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableArray *roomList;
@property (nonatomic, strong) NSMutableArray *joinedRooms;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) UYLPasswordManager *manager;

@end

static const NSString *ClientID = @"107d5e7228ae2c1c911a4ff910ceda2a05fca50ff951c271f6d3a7851f9bbdf5";
static const NSString *ClientSecret = @"06dcef77d5ff607b7efae20f406b2667f8341e375819182870192a43c6461d16";
NSString *AccessToken;
NSString *RefreshToken;
dispatch_queue_t kBgQueue;

@implementation GeoChatManager

//creating a singleton. will only be intiliazed once and then persisted. to better keep track of timers, tokens, and user information
+ (GeoChatManager *)sharedManager
{
    static dispatch_once_t pred;
    static GeoChatManager *manager = nil;
    
    dispatch_once(&pred, ^{
        manager = [[GeoChatManager alloc] init];
        NSLog(@"Starting up the manager...");
    });
    
    return manager;
}

//custom initialization
- (id)init
{
    self = [super init];
    
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        _manager = [UYLPasswordManager sharedInstance];
        kBgQueue = dispatch_queue_create("com.MosRedRocket.GeoChatManager.bgqueue", NULL);
    }
    
    return self;
}

//sending the GET request
- (void)sendGetRequestForEndpoint:(NSString *)urlString completion:(RequestCompletion)handler
{
    [self.delegate didBeginLoading];
    NSURL *getURL = [NSURL URLWithString:urlString];
    
    dispatch_async(kBgQueue, ^ {
        NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:getURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSHTTPURLResponse *newResponse = (NSHTTPURLResponse *)response;
                NSLog(@"Response code: %ld", (long)newResponse.statusCode);
                handler([self parseResponseData:data], response, nil);
                
            } else {
                NSLog(@"There was an error with the data task: %@", error.description);
                handler(nil, response, error);
            }
        }];
        [dataTask resume];
    });
}

//sending the POST request
- (void)sendPostRequestForEndpoint:(NSString *)urlString withParameters:(NSDictionary *)params completion:(RequestCompletion)handler
{
    [self.delegate didBeginLoading];
    NSLog(@"Post params: %@", params);
    NSURL *postURL = [NSURL URLWithString:urlString];
    
    NSError *parseError;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&parseError];
    
    if (!parseError) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
        [request setTimeoutInterval:30.0];
        request.cachePolicy = NSURLCacheStorageAllowedInMemoryOnly;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
        
        dispatch_async(kBgQueue, ^ {
            NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSLog(@"About to parse data...");
                    handler([self parseResponseData:data], response, nil);
                    
                } else {
                    NSLog(@"Something went wrong with the data task: %@", error.description);
                    handler(nil, response, error);
                }
            }];
            [dataTask resume];
        });
    } else {
        NSLog(@"There was an erroring converting the post params: %@", parseError.description);
        handler(nil, nil, parseError);
    }
}

//parses JSON response data to id object type
- (id)parseResponseData:(NSData *)data
{
    NSLog(@"Parsing data...");
    NSError *error;
    
    id responseItem = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (!error) {
        return responseItem;
    } else {
        NSLog(@"Something went wrong with parsing the data: %@", error.description);
    }
    return nil;
}

//login/signup after facebook auth using authToken
- (void)loginWithFacebookID:(NSString *)fbToken
{
    NSDictionary *paramDict = @{@"client_id": ClientID, @"client_secrect": ClientSecret, @"grant_type": @"assertion", @"assertion": fbToken};
    
    [self sendPostRequestForEndpoint:kOAuthEndpoint withParameters:paramDict completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *responseH = (NSHTTPURLResponse *)response;
            
            if (responseH.statusCode == 200) {
                self.isLoggedIn = YES;
                self.authTokens = (NSDictionary *)responseItem;
                NSLog(@"auth tokens: %@", self.authTokens);
                NSLog(@"fb token: %@", fbToken);
                
                NSString *expIn = [self.authTokens objectForKey:@"expires_in"];
                int expiresIn = [expIn intValue];
                
                if (expiresIn < 1200) {
                    AccessToken = [self.authTokens objectForKey:@"access_token"];
                    RefreshToken = [self.authTokens objectForKey:@"refresh_token"];
                    [self refreshAccessToken];
                    //[self performSelectorOnMainThread:@selector(refreshAccessToken) withObject:nil waitUntilDone:YES];
                } else {
                    AccessToken = [self.authTokens objectForKey:@"access_token"];
                    RefreshToken = [self.authTokens objectForKey:@"refresh_token"];
                }
                
                [self fetchCurrentUser];
                [self fetchRoomsForUser];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Should be sending notification...");
                    [self.delegate didFinishLoading];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishLoggingIn" object:nil];
                });
                
            } else if (responseH.statusCode == 401) {
                NSLog(@"Not authorized...");
                [self refreshAccessToken];
            }
        }
    }];
}

//fetches user info. return dictionary and stores it as GeoChatUser object
- (void)fetchCurrentUser
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self sendGetRequestForEndpoint:[self stringForCurrentUser] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        //NSLog(@"User item: %@", responseItem);
        GeoChatUser *newUser = [[GeoChatUser alloc] init];
        [newUser configureUserForDictionary:(NSMutableDictionary *)responseItem];
        self.currentUser = newUser;
        NSLog(@"Current user: %@", self.
              currentUser);
    }];
}

- (void)fetchRoomsForUser
{
    [self sendGetRequestForEndpoint:[self stringForUserRooms] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.joinedRooms = [NSMutableArray arrayWithArray:responseItem];
            });
        }
    }];
}

- (NSMutableArray *)joinedRooms
{
    return _joinedRooms;
}

- (NSString *)stringForUserRooms
{
    return [NSString stringWithFormat:@"%@/chat_rooms?access_token=%@", kUserEndpoint, AccessToken];
}

//generates url string for current user
- (NSString *)stringForCurrentUser
{
    return [NSString stringWithFormat:@"%@?access_token=%@", kUserEndpoint, AccessToken];
}

//passes get room list url string to get request method
- (void)fetchRoomsWithLatitude:(NSString *)latitude longitude:(NSString *)longitude offset:(NSString *)offset size:(NSString *)size radius:(NSString *)radius
{
        [self sendGetRequestForEndpoint:[self fetchRoomStringWithLatitude:latitude longitude:longitude offset:offset size:size radius:radius] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
            self.roomList = [NSMutableArray arrayWithArray:(NSArray *)responseItem];
            
            if (!error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                
                if (httpResponse.statusCode == 200) {
                    NSLog(@"Good response");
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.delegate didFinishLoading];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithObject" object:responseItem];
                    });
                } else if (httpResponse.statusCode == 401) {
                    NSLog(@"Auth token is expired...");
                }
            } else {
                NSLog(@"There was an error: %@", error.description);
            }
            
        }];
}

//creates url string to pass to get request
- (NSString *)fetchRoomStringWithLatitude:(NSString *)latitude longitude:(NSString *)longitude offset:(NSString *)offset size:(NSString *)size radius:(NSString *)radius
{
    NSLog(@"Room url: %@", [NSString stringWithFormat:@"%@?access_token=%@&latitude=%@&longitude=%@&offset=%@&size=%@&radius=%@", kChatRoomsEndpoint, AccessToken, latitude, longitude, offset, size, radius]);
    return [NSString stringWithFormat:@"%@?access_token=%@&latitude=%@&longitude=%@&offset=%@&size=%@&radius=%@", kChatRoomsEndpoint, AccessToken, latitude, longitude, offset, size, radius];
}

//creates url string and param dict to create new chat room
- (void)createRoomWithName:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSString *urlString = [NSString stringWithFormat:@"%@/create", kChatRoomsEndpoint];
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"name": name, @"latitude": latitude, @"longitude": longitude};
    [self sendPostRequestForEndpoint:urlString withParameters:paramDict completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Should be posting notification...");
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.delegate didFinishLoading];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishCreatingRoom" object:responseItem];
            });
        }
    }];
}

//fetches room info for id
- (void)fetchRoomForID:(NSString *)roomID
{
    [self sendGetRequestForEndpoint:[self stringForRoomID:roomID] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.delegate didFinishLoading];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithRoomInfo" object:responseItem];
        });
    }];
}

//creates string for room request
- (NSString *)stringForRoomID:(NSString *)roomID
{
    return [NSString stringWithFormat:@"%@?id=%@&access_token=%@", kChatRoomEndpoint, roomID, AccessToken];
}

//sends the message for a given room id
- (void)sendMessageWithText:(NSString *)message forChatRoomID:(NSString *)roomID
{
    NSString *urlString = [NSString stringWithFormat:@"%@/send_message", kChatRoomEndpoint];
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"id": roomID, @"message": @{@"content": message}};
    [self sendPostRequestForEndpoint:urlString withParameters:paramDict completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode == 201) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    NSLog(@"should be sending message here...");
                    [self.delegate didFinishLoading];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishSendingWithSuccess" object:responseItem];
                });
            } else if (httpResponse.statusCode == 500) {
                NSLog(@"Internal server error...");
            } else if (httpResponse.statusCode == 401) {
                NSLog(@"Auth token has expired...");
            }
        }
    }];
}

- (void)fetchNewMessagesForRoom:(NSString *)roomID index:(NSString *)index
{
    NSLog(@"Fetching new messages...");
    [self sendGetRequestForEndpoint:[self stringForNewMessages:roomID index:index] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSMutableArray *temp = (NSMutableArray *)responseItem;
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.delegate didFinishLoading];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithNewMessages" object:temp];
            });
        } else {
            NSLog(@"Something went wrong with retrieving the new messages: %@", error.description);
        }
    }];
    
}

- (NSString *)stringForNewMessages:(NSString *)roomID index:(NSString *)index
{
    return [NSString stringWithFormat:@"%@/retrieve_messages?access_token=%@&id=%@&index=%@", kChatRoomEndpoint, AccessToken, roomID, index];
}

- (void)addUserToRoom:(NSString *)roomID
{
    NSString *urlString = [NSString stringWithFormat:@"%@/add_user", kChatRoomEndpoint];
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"id": roomID};
    [self sendPostRequestForEndpoint:urlString withParameters:paramDict completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishAddingToRoom" object:nil];
            });
        } else {
            NSLog(@"Something went wrong with adding the user...");
        }
    }];
}

//gathers a list of all active chat rooms for the user
- (void)listChatroomsForUser
{
    [self sendGetRequestForEndpoint:[self fetchRoomListForUserString] completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Those rooms though...");
        }
    }];
}

//creates string for user room list request
- (NSString *)fetchRoomListForUserString
{
    return [NSString stringWithFormat:@"%@/chat_rooms?access_token=%@", kUserEndpoint, AccessToken];
}

//refreshes the access token (access token expires 2 hours after being issued)
- (void)refreshAccessToken
{
    NSLog(@"Refreshing tokens...");
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"grant_type": @"refresh_token", @"refresh_token": RefreshToken};
    [self sendPostRequestForEndpoint:kOAuthEndpoint withParameters:paramDict completion:^(id responseItem, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *temp = (NSDictionary *)responseItem;
            
            if (httpResponse.statusCode == 200) {
                NSLog(@"Resetting the tokens");
                AccessToken = [temp objectForKey:@"access_token"];
                RefreshToken = [temp objectForKey:@"refresh_token"];
            }
        }
    }];
}

@end
