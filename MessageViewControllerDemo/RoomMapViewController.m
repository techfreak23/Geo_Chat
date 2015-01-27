//
//  RoomMapViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/27/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "RoomMapViewController.h"
#import "AddRoomViewController.h"
#import "MessagesViewController.h"
#import "MasterViewController.h"
#import "LoginViewController.h"
#import "GeoChatAPIManager.h"

#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface RoomMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *roomMapView;
@property (nonatomic, strong) NSMutableArray *roomItems;

@end

@implementation RoomMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor  = [UIColor colorWithRed:40.0/255.0f green:215.0/255.0f blue:161.0/255.0f alpha:1.0f];;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"GeoChat!";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
    
    self.roomMapView.delegate = self;
    self.roomMapView.showsUserLocation = YES;
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

#pragma mark - notifications

- (void)didFinishWithRooms:(NSNotification *)notification
{
    
}

- (void)didFinishWithRoomInfo:(NSNotification *)notification
{
    
}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    
}

#pragma mark - my methods

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

- (void)updateLocation
{
    MKUserLocation *userLocation = self.roomMapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
    [self.roomMapView setRegion:region animated:YES];

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
    NSLog(@"User location: %@", userLocation);
    [self updateLocation];
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
                    NSLog(@"No...");
                }
                    break;
                    
                case 1: {
                    NSLog(@"But yes...");
                    [[FBSession activeSession] closeAndClearTokenInformation];
                    [[GeoChatAPIManager sharedManager] logout];
                    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    [self presentViewController:navController animated:NO completion:nil];
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
