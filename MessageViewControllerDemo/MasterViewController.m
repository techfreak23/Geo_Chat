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
#import "LoginViewController.h"
#import "GeoChatAPIManager.h"
#import "MessagesViewController.h"
#import "RoomMapViewController.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MasterViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSMutableArray *roomItems;
@property (nonatomic, strong) NSArray *pickerItems;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIPickerView *pickerView;

@end

static NSString *reuseIdentifier = @"Cell";

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.title = @"GeoChat!";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
    
    self.navigationController.navigationBar.barTintColor  = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to load new rooms"];
    [refresh addTarget:self action:@selector(fetchRooms) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2 - 40.0f, frame.size.height/2 - 40.0f, 80.0f, 80.0f)];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFinishCreatingRoom" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRooms:) name:@"didFinishFetchingRooms" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRoomInfo:) name:@"didFinishRoomInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDeletingRoom) name:@"deleteWasSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cannotDeleteRoom) name:@"deleteWasUnsuccessful" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFinishFetchingRooms" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFinishRoomInfo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteWasSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteWasUnsuccessful" object:nil];
}

#pragma notification methods

- (void)didFinishWithRooms:(NSNotification *)notification
{
    NSLog(@"Did finish with rooms notif...");
    self.roomItems = [NSMutableArray arrayWithArray:(NSArray *)[notification object]];
    if (self.roomItems.count < 1) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:25];
        [messageLabel sizeToFit];
        messageLabel.text = @"Nothing to show here.";
        self.tableView.backgroundView = messageLabel;
        self.tableView.scrollEnabled = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.scrollEnabled = YES;
        [self.tableView reloadData];
    }
    
    [self.indicatorView stopAnimating];
    [self stopRefresh];
    
}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        MessagesViewController *controller = [[MessagesViewController alloc] init];
        controller.roomInfo = (NSMutableDictionary *)[notification object];
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)didFinishWithRoomInfo:(NSNotification *)notification
{
    MessagesViewController *controller = [[MessagesViewController alloc] init];
    controller.roomInfo = (NSMutableDictionary *)[notification object];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didFinishDeletingRoom
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.roomItems removeObjectAtIndex:indexPath.row];
    //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)didReceiveNewMessage:(NSNotification *)notification
{
    NSLog(@"New message from faye: %@", [notification object]);
}

- (void)cannotDeleteRoom
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showAlertViewWithTitle:@"Unauthorized" message:@"You must be the adminstrator of a room to delete it." cancelButton:@"Got it"];
}

#pragma mark - My methods

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles: nil];
    [alert show];
}

- (void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton otherButtonTitles:(NSArray*)otherButtons tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    if (otherButtons) {
        for (NSString *temp in otherButtons) {
            [alert addButtonWithTitle:temp];
        }
    }
    
    [alert addButtonWithTitle:cancelButton];
    alert.tag = tag;
    
    [alert show];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)fetchRooms
{
    [self.refreshControl beginRefreshing];
    CLLocation *location = self.locationManager.location;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    [[GeoChatAPIManager sharedManager] fetchRoomsForLatitude:latitude longitude:longitude];
}

- (void)addRoom
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreatingRoom:) name:@"didFinishCreatingRoom" object:nil];
    
    AddRoomViewController *controller = [[AddRoomViewController alloc] initWithNibName:@"AddRoomViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)viewSettings
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View profile", @"Change radius", @"Logout", nil];
    actionSheet.tintColor = [UIColor colorWithRed:20.0/255.0f green:204.0/255.0f blue:96.0/255.0f alpha:1.0f];
    [actionSheet showInView:self.view];
}

- (void)makeTableViewBlank
{
    self.roomItems = nil;
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
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
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [[[self.roomItems objectAtIndex:indexPath.row] objectForKey:@"distance"] floatValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

#pragma mark - table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *temp = (NSDictionary *)[self.roomItems objectAtIndex:indexPath.row];
    NSString *roomID = (NSString *)[temp objectForKey:@"id"];
    
    [[GeoChatAPIManager sharedManager] fetchRoomForID:roomID];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.layer.opacity = 0.5;
    
    [UIView animateWithDuration:0.25 animations:^ {
        cell.contentView.layer.opacity = 1.0;
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *temp = (NSDictionary *)[self.roomItems objectAtIndex:indexPath.row];
        NSString *roomID = (NSString *)[temp objectForKey:@"id"];
        [[GeoChatAPIManager sharedManager] deleteRoom:roomID];
    }
}

#pragma  mark - location manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed fetching location with error:%@", error.description);
    [self showAlertViewWithTitle:@"Location error" message:@"There was an error gathering your location :(" cancelButton:@"Okay"];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
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
                [self.locationManager requestWhenInUseAuthorization];
            } else {
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
            
            [self alertViewWithTitle:@"Sorry" message:@"In order to use GeoChat, we must be able to use your location to find chat rooms nearby. Please re-enable GeoChat for Location Services." cancelButton:@"Got it!" otherButtonTitles:@[@"Settings"] tag:202];
            
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
        [self alertViewWithTitle:@"Location Services disabled" message:@"In order to use GeoChat, we must be able to use your location to find and create rooms. Please re-enable Location Services if you wish to continue to use GeoChat." cancelButton:@"Got it!" otherButtonTitles:@[@"Settings"] tag:201];
        
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
    //CLLocation *location = [locations lastObject];
    [manager stopUpdatingLocation];
    [self fetchRooms];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            NSLog(@"Getting user info...");
            
        }
            break;
            
        case 1: {
            NSLog(@"Creating picker view and adding to view...");
            float height = 216.0f;
            float width = self.view.bounds.size.width;
            float startXCoord = self.view.bounds.size.height - height;
            
            self.pickerView = [[UIPickerView alloc] init];
            self.pickerView.frame = CGRectMake(startXCoord, 0, width, height);
            self.pickerView.delegate = self;
            self.pickerView.dataSource = self;
            self.pickerView.showsSelectionIndicator = YES;
            [self.view addSubview:self.pickerView];
        }
            break;
            
        case 2:{
            NSLog(@"User wants to logout");
            
            [self alertViewWithTitle:@"Logout" message:@"Are you sure?" cancelButton:@"Never mind" otherButtonTitles:@[@"Logout"] tag:203];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 201: {
            NSLog(@"Location settings alert view");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Button 0");
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                    break;
                
                case 1: {
                    NSLog(@"Button 1");
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 202: {
            NSLog(@"Access denied alert view");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Botton 0");
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                    break;
                    
                case 1: {
                    NSLog(@"Button 1");
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 203: {
            NSLog(@"Logging out alert view...");
            
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Logging out...");
                    [[FBSession activeSession] closeAndClearTokenInformation];
                    [[GeoChatAPIManager sharedManager] logout];
                    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    [self presentViewController:navController animated:NO completion:nil];
                }
                    break;
                    
                case 1: {
                    NSLog(@"Button 1...");
                }
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return (NSString *)[self.pickerItems objectAtIndex:row];
}


#pragma mark - picker delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //NSLog(@"Row: %ld\nComponent: %ld", (long)row, (long)component);
}

@end
