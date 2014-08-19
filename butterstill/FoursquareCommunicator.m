//
//  FoursquareCommunicator.m
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "FoursquareCommunicator.h"
#import "FoursquareCommunicatorDelegate.h"

@implementation FoursquareCommunicator

-(void)searchVanuesAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/explore?ll=%.3f,%.3f&client_id=%@&client_secret=%@&v=20130815",coordinate.latitude,coordinate.longitude,FS_CLIENT_ID,FS_CLIENT_SECRET];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSLog(@"URL String: %@",urlString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError){
            [self.delegate fetchingVenuesFailedWithError:connectionError];
        } else {
            [self.delegate receivedVenuesJSON:data];
        }
    }];
}

@end
