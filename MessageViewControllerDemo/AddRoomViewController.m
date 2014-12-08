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
#import "GeoChatManager.h"

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
    
    _menuItems = @[@"Text field view", @"Location view", @"Map view"];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishCreatingRoom:) name:@"didFinishCreatingRoom" object:nil];
    
    self.title = @"Add room";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelAdd)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createNewRoom)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView.scrollEnabled = NO;
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewRoom
{
    NSLog(@"Create room...");
    MKUserLocation *location = _mapView.userLocation;
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    [[GeoChatManager sharedManager] createRoomWithName:_roomNameField.text latitude:latitude longitude:longitude];
}

- (void)didFinishCreatingRoom:(NSNotification *)notification
{
    NSLog(@"Did finish creating room: %@", [notification object]);
    [self.presentingViewController dismissViewControllerAnimated:YES completion: ^{
        NSLog(@"Dismissed add room view with completion...");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishAddingRoom" object:[notification object]];
    }];
}

- (void)updateLocation
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:_mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            NSString *cityName = [placemark locality];
            NSLog(@"City: %@", cityName);
            _locationLabel.text = cityName;
        }
    }];
    MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 5000, 5000);
    [_mapView setRegion:region animated:YES];
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
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    CGRect cellFrame = cell.frame;
    
    
    switch (indexPath.row) {
        case 0: {
            NSLog(@"Setting name text field...");
            _roomNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width/2, cellFrame.size.height)];
            _roomNameField.translatesAutoresizingMaskIntoConstraints = NO;
            _roomNameField.placeholder = @"Room name";
            _roomNameField.delegate = self;
            [cell.contentView addSubview:_roomNameField];
        }
            break;
            
        case 1: {
            NSLog(@"Setting location label...");
            _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellFrame.size.width/2, cellFrame.size.height)];
            _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _locationLabel.text = @"Getting location...";
            _locationLabel.textAlignment = NSTextAlignmentCenter;
            
            _updateButton = [[UIButton alloc] initWithFrame:CGRectMake(_locationLabel.frame.size.width, _locationLabel.frame.origin.y, cellFrame.size.width/2, cellFrame.size.height)];
            _updateButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_updateButton addTarget:self action:@selector(updateLocation) forControlEvents:UIControlEventTouchUpInside];
            _updateButton.titleLabel.textColor = [UIColor blackColor];
            [_updateButton setTitle:@"Update location" forState:UIControlStateNormal];
            _updateButton.backgroundColor = [UIColor purpleColor];
            
            [cell.contentView addSubview:_updateButton];
            [cell.contentView addSubview:_locationLabel];
        }
            break;
            
        case 2: {
            NSLog(@"Setting map view...");
            _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            _mapView.delegate = self;
            [cell.contentView addSubview:_mapView];
            _mapView.showsUserLocation = YES;
        }
            
        default:
            break;
    }
    
    NSLog(@"Table cell loading: %@", [_menuItems objectAtIndex:indexPath.row]);
    
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
        [self updateLocation];
    }
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
