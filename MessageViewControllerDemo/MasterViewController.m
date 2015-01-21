//
//  MasterViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 11/30/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JSQMessagesViewController.h"
#import "JSQMessages.h"
#import "MasterViewController.h"
#import "AddRoomViewController.h"
#import "UserViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "GeoChatAPIManager.h"
#import "GeoChatManager.h"
#import "MessagesViewController.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MasterViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *roomItems;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

static NSString *reuseIdentifier = @"Cell";

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Master view loading...");
    
    self.title = @"GeoChat!";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to load new rooms"];
    [refresh addTarget:self action:@selector(fetchRooms) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2 - 50, frame.size.height/2 - 50, 200.0, 200.0)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRooms:) name:@"didFinishFetchingRooms" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRoomInfo:) name:@"didFinishRoomInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreatingRoom:) name:@"didFinishCreatingRoom" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My methods

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles: nil];
    [alert show];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)fetchRooms
{
    NSLog(@"Fetching rooms...");
    
    CLLocation *location = self.locationManager.location;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    //[[GeoChatManager sharedManager] fetchRoomsWithLatitude:latitude longitude:longitude offset:@"0" size:@"50" radius:@"100"];
    [[GeoChatAPIManager sharedManager] fetchRoomsForLatitude:latitude longitude:longitude];
}

- (void)addRoom
{
    NSLog(@"Adding room...");
    AddRoomViewController *controller = [[AddRoomViewController alloc] initWithNibName:@"AddRoomViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)viewSettings
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View profile", @"Logout", nil];
    [actionSheet showInView:self.view];
}

- (void)makeTableViewBlank
{
    self.roomItems = nil;
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
}

#pragma notification methods

- (void)didFinishWithRooms:(NSNotification *)notification
{
    NSLog(@"Did finish with rooms notif...");
    self.roomItems = [NSMutableArray arrayWithArray:(NSArray *)[notification object]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.indicatorView stopAnimating];
    self.tableView.scrollEnabled = YES;
    [self stopRefresh];
    [self.tableView reloadData];

}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    NSLog(@"Did finish creating room notif...");
}

- (void)didFinishWithRoomInfo:(NSNotification *)notification
{
    NSLog(@"Did finish room info notif...");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.roomItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    [cell.contentView sizeToFit];
    cell.textLabel.text = [[self.roomItems objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [[[self.roomItems objectAtIndex:indexPath.row] objectForKey:@"distance"] floatValue]];
    //cell.
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

#pragma mark - table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did select row: %@", [self.roomItems objectAtIndex:indexPath.row]);
    
    NSDictionary *temp = (NSDictionary *)[self.roomItems objectAtIndex:indexPath.row];
    NSString *roomID = (NSString *)[temp objectForKey:@"id"];
    NSLog(@"Room id: %@", roomID);
    
    [[GeoChatAPIManager sharedManager] fetchRoomForID:roomID];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.layer.opacity = 0.5;
    
    [UIView animateWithDuration:0.25 animations:^ {
        cell.contentView.layer.opacity = 1.0;
    }];
}

#pragma  mark - location manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed fetching location with error:%@", error.description);
    [self showAlertViewWithTitle:@"Location error" message:@"There was an error gathering your location :(" cancelButton:@"Okay"];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Auth status did change: %d", status);
    
    CLAuthorizationStatus locationServices = [CLLocationManager locationServicesEnabled];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:25];
    [messageLabel sizeToFit];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (locationServices) {
        if (status == kCLAuthorizationStatusNotDetermined) {
            if (IS_IOS_8_OR_LATER) {
                NSLog(@"Starting location services on iOS 8...");
                [self.locationManager requestAlwaysAuthorization];
            } else {
                NSLog(@"Starting location services...");
                [self.locationManager startUpdatingLocation];
                self.navigationItem.leftBarButtonItem.enabled = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                [self.view addSubview:self.indicatorView];
                [self.indicatorView startAnimating];
            }
        } else if (status == kCLAuthorizationStatusRestricted) {
            NSLog(@"Status restricted...");
            [self showAlertViewWithTitle:@"Whoa there" message:@"It looks like Location Services are currently restricted on your device. Come back later when they are unrestricted." cancelButton:@"Okay..."];
            
            messageLabel.text = @"Location Services are currently restricted. Cannot update chat rooms.";
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self makeTableViewBlank];
            
        } else if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"Status denied...");
            [self showAlertViewWithTitle:@"Sorry" message:@"In order to use GeoChat, we must be able to use your location to find chat rooms nearby. Please re-enable GeoChat for Location Services." cancelButton:@"Got it!"];
            
            messageLabel.text = @"Location services are 'off' for GeoChat";
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self makeTableViewBlank];
        } else {
            NSLog(@"Already authorized...");
            
            [self.locationManager startUpdatingLocation];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSLog(@"Most recent location: %@", [self.locationManager location]);
            
            [self.view addSubview:self.indicatorView];
            [self.indicatorView startAnimating];
        }
    } else {
        NSLog(@"Status location services off");
        [self showAlertViewWithTitle:@"Sorry about this!" message:@"It looks like you have Location Services disabled. GeoChat requires the use of your location to find the nearest chat rooms. Please enable your Location Services if you wish to use our service." cancelButton:@"Got it!"];
        
        messageLabel.text = @"Please re-enable Location Services in order to use GeoChat.";
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self makeTableViewBlank];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"Gathering location: %@", location);
    [manager stopUpdatingLocation];
    [self fetchRooms];
    
    /*
    CLLocationAccuracy accuracy = location.horizontalAccuracy;
    
    if (accuracy) {
        NSLog(@"The location manager has the needed accuracy...");
        [manager stopUpdatingLocation];
        [self fetchRooms];
    }
     */
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            NSLog(@"Getting user info...");
            
        }
            break;
            
        case 1:{
            NSLog(@"User wants to logout");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Never mind" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancelling...?");
            break;
            
        case 1:
            NSLog(@"Logging out...");
            break;
            
        default:
            break;
    }
}

@end
