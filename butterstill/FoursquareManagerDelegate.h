//
//  FoursquareManagerDelegate.h
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FoursquareManagerDelegate
-(void)didReceiveVenues:(NSArray *)venues;
-(void)fetchingVenuesFailedWithError:(NSError *)error;

@end
