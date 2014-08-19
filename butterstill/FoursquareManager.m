//
//  FoursquareManager.m
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "FoursquareManager.h"
#import "VenueBuilder.h"
#import "FoursquareCommunicator.h"

@implementation FoursquareManager

-(void)fetechingVenuesAtCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.communicator searchVanuesAtCoordinate:coordinate];
}

#pragma mark - FoursquareCommunicatorDelegate
-(void)receivedVenuesJSON:(NSData *)objectNotation{
    NSError *error = nil;
    NSArray *venues = [VenueBuilder venuesFromJSON:objectNotation error:&error];
    
    if (error){
        [self.delegate fetchingVenuesFailedWithError:error];
    } else {
        [self.delegate didReceiveVenues:venues];
    }
}

-(void)fetchingVenuesFailedWithError:(NSError *)error{
    [self.delegate fetchingVenuesFailedWithError:error];
}

@end
