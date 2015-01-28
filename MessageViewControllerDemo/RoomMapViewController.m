//
//  RoomMapViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/27/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RoomMapViewController.h"
#import "AddRoomViewController.h"
#import "MessagesViewController.h"
#import "MasterViewController.h"
#import "LoginViewController.h"
#import "GeoChatAPIManager.h"

#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface RoomMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *roomMapView;
@property (nonatomic, strong) NSMutableArray *roomItems;
@property (nonatomic, strong) UITextField *roomNameField;

@end

BOOL locationFetched;

@implementation RoomMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    locationFetched = NO;
    
    self.roomNameField = [[UITextField alloc] init];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor  = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshRooms)];
    UIBarButtonItem *addRoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    
    self.navigationItem.title = @"GeoChat!";
    [self.navigationItem setRightBarButtonItems:@[addRoomButton, refreshButton]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
    
    self.roomMapView.delegate = self;
    self.roomMapView.showsUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"Map view appearing...");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRooms:) name:@"didFinishFetchingRooms" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRoomInfo:) name:@"didFinishRoomInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreatingRoom:) name:@"didFinishCreatingRoom" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"Map view disappearing...");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notifications

- (void)didFinishWithRooms:(NSNotification *)notification
{
    NSLog(@"We've got the rooms...");
}

- (void)didFinishWithRoomInfo:(NSNotification *)notification
{
    
}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    NSLog(@"We finished creating the room...");
}

#pragma mark - my methods

- (void)fetchRooms
{
    NSLog(@"Fetching rooms...");
    
    CLLocation *location = self.locationManager.location;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    [[GeoChatAPIManager sharedManager] fetchRoomsForLatitude:latitude longitude:longitude];
}

- (void)addRoom
{
    self.roomNameField.delegate = self;
    self.roomNameField.borderStyle = UITextBorderStyleNone;
    self.roomNameField.tintColor = [UIColor blackColor];
    self.roomNameField.backgroundColor = [UIColor whiteColor];
    self.roomNameField.placeholder = @"Room name";
    self.roomNameField.returnKeyType = UIReturnKeyDone;
    self.roomNameField.textAlignment = NSTextAlignmentCenter;
    self.roomNameField.layer.cornerRadius = 10.0f;
    self.roomNameField.layer.masksToBounds = YES;
    self.navigationItem.titleView = self.roomNameField;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddRoom)];
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createRoom)];
    [self.navigationItem setRightBarButtonItems:@[createButton]];
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGSize navSize = frame.size;
    
    self.roomNameField.frame = CGRectMake(frame.origin.x - createButton.width, frame.origin.y - 5, navSize.width, navSize.height - 10);
    
    self.navigationItem.titleView = self.roomNameField;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    [self.roomNameField becomeFirstResponder];
}

- (void)viewSettings
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View profile", @"Logout", nil];
    [actionSheet showInView:self.view];
}

- (void)refreshRooms
{
    [self updateLocation];
}

- (void)createRoom
{
    NSLog(@"Creating room...");
    [self.roomNameField resignFirstResponder];
    MKUserLocation *location = self.roomMapView.userLocation;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    [[GeoChatAPIManager sharedManager] createRoom:self.roomNameField.text latitude:latitude longitude:longitude];
    
    [self cancelAddRoom];
}

- (void)cancelAddRoom
{
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"GeoChat!";
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshRooms)];
    UIBarButtonItem *addRoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    
    [self.roomNameField resignFirstResponder];
    [self.navigationItem setRightBarButtonItems:@[addRoomButton, refreshButton]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
}


- (void)updateLocation
{
    MKUserLocation *userLocation = self.roomMapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
    [self.roomMapView setRegion:region animated:YES];
    [self fetchRooms];
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

#pragma mark - location manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    CLAuthorizationStatus locationServices = [CLLocationManager locationServicesEnabled];
    
    if (locationServices) {
        if (status == kCLAuthorizationStatusNotDetermined) {
            if (IS_IOS_8_OR_LATER) {
                [manager requestWhenInUseAuthorization];
            } else {
                
            }
        } else if (status == kCLAuthorizationStatusDenied) {
            [self alertViewWithTitle:@"Location Services denied" message:@"GeoChat needs to be able to use your location in order to find and create rooms." cancelButton:@"Got it" otherButtonTitles:@[@"Settings"] tag:201];
        } else if (status == kCLAuthorizationStatusRestricted) {
            [self alertViewWithTitle:@"Location Services restricted" message:@"Sorry, but your Location Services have been restricted! Please come back when Location Services are unrestricted." cancelButton:@"Okay :(" otherButtonTitles:nil tag:202];
        } else {
            NSLog(@"Already authorized...");
            
        }
    } else {
        //Location services are not enabled...
        [self alertViewWithTitle:@"Location Services disabled" message:@"In order to use GeoChat, we must be able to use your location to find and create rooms around you. Please re-enable Location Services if you wish to contiue to use GeoChat." cancelButton:@"Okay" otherButtonTitles:@[@"Settings"] tag:200];
    }
}

#pragma mark - Map view delegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!locationFetched) {
        NSLog(@"User location: %@", userLocation);
        [self updateLocation];
        locationFetched = YES;
    }
}

#pragma mark - text field delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"The delegate is working...");
    if (textField.text.length > 3) {
        NSLog(@"The done button should be enabling...");
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 3) {
        NSLog(@"The done button should be enabling...");
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 3) {
        NSLog(@"The done button should be enabling...");
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            NSLog(@"Button 0...");
        }
            break;
            
        case 1: {
            NSLog(@"Button 1...");
            [self alertViewWithTitle:@"Logout" message:@"Are you sure?" cancelButton:@"Never mind" otherButtonTitles:@[@"Logout"] tag:203];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 200: {
            NSLog(@"Location services alert...");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Opening settings...");
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                    break;
                    
                case 1: {
                    NSLog(@"Got it...");
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        case 201: {
            NSLog(@"Location Services denied....");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Opening settings...");
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                    break;
                    
                case 1: {
                    NSLog(@"Got it...");
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 202: {
            NSLog(@"Location services disabled...");
        }
            break;
            
        case 203: {
            NSLog(@"Logging out...");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"But yes...");
                    [[FBSession activeSession] closeAndClearTokenInformation];
                    [[GeoChatAPIManager sharedManager] logout];
                    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    [self presentViewController:navController animated:NO completion:nil];
                }
                    break;
                    
                case 1: {
                    NSLog(@"No...");
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

@end
