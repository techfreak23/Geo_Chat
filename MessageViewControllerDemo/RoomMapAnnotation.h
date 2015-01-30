//
//  RoomMapAnnotation.h
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 1/28/15.
//  Copyright (c) 2015 Art Sevilla. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RoomMapAnnotation : MKPointAnnotation

@property (nonatomic, assign) NSString *roomID;

@end
