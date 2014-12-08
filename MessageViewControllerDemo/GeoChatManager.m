//
//  GeoChatManager.m
//  GeoChatManager
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#define kOAuthEndpoint @"https://geochat-v1.herokuapp.com/oauth/token"
#define kChatRoomsEndpoint @"https://geochat-v1.herokuapp.com/api/v1/chat_rooms"
#define kChatRoomEndpoint @"https://geochat-v1.herokuapp.com/api/v1/chat_room"
#define kUserEndpoint @"https://geochat-v1.herokuapp.com/api/v1/user"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "GeoChatManager.h"
#import "UYLPasswordManager.h"

@interface GeoChatManager() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSDictionary *authTokens;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableArray *roomList;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;

@end

static const NSString *ClientID = @"8c2ec2e8ab5a5a243a8446fac11a0fe744cc46019d6ac7122c72b27624dc6eaf";
static const NSString *ClientSecret = @"077bb6953ecc71a1ebe62701dbcde913ff0716fb20c81f5fdde7fb4c251efbbb";
NSString *AccessToken = @"5dd4b181793fbb65add3db6ac3fb74dc7abfaddd6aaefba080437b6a15f96097";
NSString *RefreshToken = @"e820bca534c3eaf88ed1078ba2959a306dbc6631ea51fbee708ed05078aa159e";

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
        [self fetchCurrentUser];
    }
    
    return self;
}

//sending the GET request
- (void)sendGetRequestForEndpoint:(NSString *)urlString completion:(RequestCompletion)handler
{
    NSURL *getURL = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [_urlSession dataTaskWithURL:getURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *newResponse = (NSHTTPURLResponse *)response;
            NSLog(@"Response code: %ld", (long)newResponse.statusCode);
            if (newResponse.statusCode == 200) {
                handler([self parseResponseData:data], nil);
            } else if (newResponse.statusCode == 401) {
                NSLog(@"Token expired...");
                //[self refreshAccessToken];
            }
            
        } else {
            NSLog(@"There was an error with the data task: %@", error.description);
            handler(nil, error);
        }
    }];
    [dataTask resume];
    
}

//sending the POST request
- (void)sendPostRequestForEndpoint:(NSString *)urlString withParameters:(NSDictionary *)params completion:(RequestCompletion)handler
{
    
    NSLog(@"Post params: %@", params);
    NSURL *postURL = [NSURL URLWithString:urlString];
    
    NSError *parseError;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&parseError];
    
    if (!parseError) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
        
        NSURLSessionDataTask *dataTask = [_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSLog(@"About to parse data...");
                NSLog(@"Response: %@", response);
                
                handler([self parseResponseData:data], nil);
                
            } else {
                NSLog(@"Something went wrong with the data task: %@", error.description);
                handler(nil, error);
            }
        }];
        [dataTask resume];
    } else {
        NSLog(@"There was an erroring converting the post params: %@", parseError.description);
        handler(nil, parseError);
    }
}

//parses JSON response data to id object type
- (id)parseResponseData:(NSData *)data
{
    NSLog(@"Parsing data...");
    
    NSError *error;
    
    id responseItem = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (!error) {
       //NSLog(@"Parsed response item: %@", responseItem);
        return responseItem;
    } else {
        NSLog(@"Something went wrong with parsing the data: %@", error.description);
        //return error;
    }
    return nil;
}

//login/signup after facebook auth using authToken
- (void)loginWithFacebookID:(NSString *)fbToken
{
    NSDictionary *paramDict = @{@"client_id": ClientID, @"client_secrect": ClientSecret, @"grant_type": @"assertion", @"assertion": fbToken};
    [self sendPostRequestForEndpoint:kOAuthEndpoint withParameters:paramDict completion:^(id responseItem, NSError *error) {
        if (!error) {
            _authTokens = (NSDictionary *)responseItem;
            NSLog(@"auth tokens: %@", _authTokens);
        }
    }];
}

//fetches user info. return dictionary and stores it as GeoChatUser object
- (void)fetchCurrentUser
{
    [self sendGetRequestForEndpoint:[self stringForCurrentUser] completion:^(id responseItem, NSError *error) {
        NSLog(@"User item: %@", responseItem);
        GeoChatUser *newUser = [[GeoChatUser alloc] init];
        [newUser configureUserForDictionary:(NSMutableDictionary *)responseItem];
        _currentUser = newUser;
        NSLog(@"Current user: %@", _currentUser);
    }];
}

//generates url string for current user
- (NSString *)stringForCurrentUser
{
    return [NSString stringWithFormat:@"%@?access_token=%@", kUserEndpoint, AccessToken];
}

//passes get room list url string to get request method
- (void)fetchRoomsWithLatitude:(NSString *)latitude longitude:(NSString *)longitude offset:(NSString *)offset size:(NSString *)size radius:(NSString *)radius
{
        [self sendGetRequestForEndpoint:[self fetchRoomStringWithLatitude:latitude longitude:longitude offset:offset size:size radius:radius] completion:^(id responseItem, NSError *error) {
            _roomList = [NSMutableArray arrayWithArray:(NSArray *)responseItem];
            
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithObject" object:responseItem];
            } else {
                NSLog(@"There was an error: %@", error.description);
            }
            
        }];
}

//creates url string to pass to get request
- (NSString *)fetchRoomStringWithLatitude:(NSString *)latitude longitude:(NSString *)longitude offset:(NSString *)offset size:(NSString *)size radius:(NSString *)radius
{
    return [NSString stringWithFormat:@"%@?access_token=%@&latitude=%@&longitude=%@&offset=%@&size=%@&radius=%@", kChatRoomsEndpoint, AccessToken, latitude, longitude, offset, size, radius];
}

//creates url string and param dict to create new chat room
- (void)createRoomWithName:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSString *urlString = [NSString stringWithFormat:@"%@/create", kChatRoomsEndpoint];
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"name": name, @"latitude": latitude, @"longitude": longitude};
    [self sendPostRequestForEndpoint:urlString withParameters:paramDict completion:^(id responseItem, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithObject" object:responseItem];
        }
    }];
}

- (void)fetchRoomForID:(NSString *)roomID
{
    [self sendGetRequestForEndpoint:[self stringForRoomID:roomID] completion:^(id responseItem, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishWithRoomObject" object:responseItem];
    }];
}

- (NSString *)stringForRoomID:(NSString *)roomID
{
    return [NSString stringWithFormat:@"%@?id=%@&access_token=%@", kChatRoomEndpoint, roomID, AccessToken];
}

//sends the message for a given room id
- (void)sendMessageWithText:(NSString *)message forChatRoomID:(NSString *)roomID
{
    NSString *urlString = [NSString stringWithFormat:@"%@/send_message", kChatRoomEndpoint];
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"id": roomID, @"content": message};
    [self sendPostRequestForEndpoint:urlString withParameters:paramDict completion:^(id responseItem, NSError *error) {
        
    }];
}

//gathers a list of all active chat rooms for the user
- (void)listChatroomsForUser
{
    [self sendGetRequestForEndpoint:[self fetchRoomListForUserString] completion:^(id responseItem, NSError *error) {
        
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
    NSDictionary *paramDict = @{@"access_token": AccessToken, @"grant_type": @"refresh_token", @"refresh_token": RefreshToken};
    [self sendPostRequestForEndpoint:kOAuthEndpoint withParameters:paramDict completion:^(id responseItem, NSError *error) {
        if (!error) {
            NSLog(@"Refresh and access tokens: %@", responseItem);
            AccessToken = [responseItem objectForKey:@"access_token"];
            RefreshToken = [responseItem objectForKey:@"refresh_token"];
        }
    }];
}

@end
