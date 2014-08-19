//
//  FoursquareCommunicator.h
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol FoursquareCommunicatorDelegate;

@interface FoursquareCommunicator : NSObject
@property (weak,nonatomic) id<FoursquareCommunicatorDelegate> delegate;

-(void)searchVanuesAtCoordinate:(CLLocationCoordinate2D)coordinate;
@end
