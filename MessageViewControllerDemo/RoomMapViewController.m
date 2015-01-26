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

#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface RoomMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) IBOutlet MKMapView *roomMapView;

@end

@implementation RoomMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor  = [UIColor colorWithRed:9.0/255.0f green:161.0/255.0f blue:41.0/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"GeoChat!";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoom)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"System-settings-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
    
    self.roomMapView.delegate = self;
}

- (void)addRoom
{
    NSLog(@"Adding room...");
}

- (void)viewSettings
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View profile", @"Logout", nil];
    //actionSheet.tintColor = [UIColor colorWithRed:20.0/255.0f green:204.0/255.0f blue:96.0/255.0f alpha:1.0f];
    [actionSheet showInView:self.view];
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
        if (IS_IOS_8_OR_LATER) {
            [manager requestWhenInUseAuthorization];
        }
    } else {
        //Location services are not enabled...
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services disabled" message:@"In order to use GeoChat, we must be able to use your location to find and create rooms around you. Please re-enable Location Services if you wish to continue to use GeoChat." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Settings", nil];
        alert.tag = 200;
        [alert show];
    }
}

#pragma mark - Map view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 200: {
            NSLog(@"Location services alert...");
            switch (buttonIndex) {
                case 0: {
                    NSLog(@"Button 0...");
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

@end
