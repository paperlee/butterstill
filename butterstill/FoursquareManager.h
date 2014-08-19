//
//  FoursquareManager.h
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "FoursquareCommunicatorDelegate.h"
#import "FoursquareManagerDelegate.h"

@class FoursquareCommunicator;

@interface FoursquareManager : NSObject<FoursquareCommunicatorDelegate>

@property (nonatomic,strong) FoursquareCommunicator *communicator;
@property (nonatomic,weak) id<FoursquareManagerDelegate> delegate;

-(void)fetechingVenuesAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end
