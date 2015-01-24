//
//  AddRoomViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/1/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AddRoomViewController.h"
#import "GeoChatAPIManager.h"

@interface AddRoomViewController () <UIAlertViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) UITextField *roomNameField;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIButton *updateButton;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *menuItems;


@end

@implementation AddRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = @[@"Text field view", @"Location view", @"Map view"];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreatingRoom:) name:@"didFinishCreatingRoom" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishRoomWithError:) name:@"didFinishRoomWithError" object:nil];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:58.0/255.0f green:90.0/255.0f blue:64.0/255.0f alpha:1.0f];
    
    self.title = @"Add room";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelAdd)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createNewRoom)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancelAdd
{
    [self.roomNameField resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewRoom
{
    NSLog(@"Create room...");
    [self.roomNameField resignFirstResponder];
    MKUserLocation *location = self.mapView.userLocation;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    [[GeoChatAPIManager sharedManager] createRoom:self.roomNameField.text latitude:latitude longitude:longitude];
}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    NSLog(@"Did finish creating room: %@", [notification object]);
    [self.roomNameField resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion: ^{
        NSLog(@"Dismissed add room view with completion...");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishAddingRoom" object:[notification object]];
    }];
}

- (void)didFinishRoomWithError:(NSNotification *)notification
{
    NSLog(@"There was an error...");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong with creating the room :(" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)updateLocation
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            NSString *cityName = [placemark locality];
            NSLog(@"City: %@", cityName);
            self.locationLabel.text = cityName;
        }
    }];
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
    [self.mapView setRegion:region animated:YES];
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
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView sizeToFit];
    frame.size.height = cell.frame.size.height;
    frame.origin = cell.frame.origin;
    cell.frame = frame;
    cell.contentView.frame = frame;
    
    CGRect cellFrame = cell.frame;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    
    switch (indexPath.row) {
        case 0: {
            NSLog(@"Setting name text field...");
            self.roomNameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, cellFrame.size.width - 10, cellFrame.size.height - 5)];
            self.roomNameField.translatesAutoresizingMaskIntoConstraints = NO;
            self.roomNameField.placeholder = @"Room name";
            self.roomNameField.delegate = self;
            [cell.contentView addSubview:self.roomNameField];
        }
            break;
            
        case 1: {
            NSLog(@"Setting location label...");
            self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width/2, cellFrame.size.height)];
            self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
            self.locationLabel.text = @"Getting location...";
            self.locationLabel.textAlignment = NSTextAlignmentCenter;
            self.locationLabel.backgroundColor = [UIColor lightGrayColor];
            
            self.updateButton = [[UIButton alloc] initWithFrame:CGRectMake(self.locationLabel.frame.size.width, self.locationLabel.frame.origin.y, self.locationLabel.frame.size.width, self.locationLabel.frame.size.height)];
            self.updateButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self.updateButton addTarget:self action:@selector(updateLocation) forControlEvents:UIControlEventTouchUpInside];
            self.updateButton.titleLabel.textColor = [UIColor blackColor];
            [self.updateButton setTitle:@"Update location" forState:UIControlStateNormal];
            self.updateButton.backgroundColor = [UIColor purpleColor];
            
            [cell.contentView addSubview:self.updateButton];
            [cell.contentView addSubview:self.locationLabel];
        }
            break;
            
        case 2: {
            NSLog(@"Setting map view...");
            self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width, self.view.frame.size.height - statusHeight - navHeight - (cellFrame.size.height * 2))];
            self.mapView.delegate = self;
            [cell.contentView addSubview:self.mapView];
            self.mapView.showsUserLocation = YES;
        }
            
        default:
            break;
    }
    
    NSLog(@"Table cell loading: %@", [self.menuItems objectAtIndex:indexPath.row]);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        NSLog(@"Map view cell...");
        
        CGFloat mapHeight = self.view.frame.size.height - 155;
        
        return mapHeight;
    } else {
        return 44.0;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 2) {
        NSLog(@"Map view cell...");
        CGFloat mapHeight = self.view.frame.size.height - 155;
        
        return mapHeight;
    } else {
        return 44.0;
    }
    
    return 0.0;
}

#pragma mark - table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selecting row at index path row: %ld", (long)indexPath.row);
}

#pragma mark - map view delegate methods

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Could not gather your location at this time." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"The map view cannot load at this time." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, userLocation);
    CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
    if (accuracy) {
        NSLog(@"We have our accuracy...");
        [self updateLocation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    NSLog(@"No longer locating the user...");
}

#pragma mark - text field delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length < 2) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"The text field is editing...");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
