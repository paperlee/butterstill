//
//  VenueBuilder.m
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "VenueBuilder.h"
#import "Venue.h"

@implementation VenueBuilder

+(NSArray *)venuesFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError){
        *error = localError;
        return nil;
    }
    //NSLog(@"%@",parsedObject);
    NSMutableArray *venues = [[NSMutableArray alloc] init];
    
    NSArray *results = [[parsedObject valueForKey:@"response"] valueForKey:@"groups"];
    NSArray *recommends = [[results objectAtIndex:0] valueForKey:@"items"];
    
    NSLog(@"returned items: %lu",(unsigned long)recommends.count);
    
    for (NSDictionary *venueDic in recommends){
        Venue *venue = [[Venue alloc] init];
        NSDictionary *venueDataDic = [venueDic valueForKey:@"venue"];
        
        [venue setValue:[venueDataDic valueForKey:@"name"] forKey:@"name"];
        [venue setValue:[[venueDataDic valueForKey:@"location"] valueForKey:@"address"] forKey:@"address"];
        [venue setValue:[[venueDataDic valueForKey:@"location"] valueForKey:@"lat"] forKey:@"lat"];
        [venue setValue:[[venueDataDic valueForKey:@"location"] valueForKey:@"lng"] forKey:@"lng"];
        [venue setValue:[[venueDataDic valueForKey:@"location"] valueForKey:@"distance"] forKey:@"distance"];
        // TODO: Assign categoryName and categoryIconUrl
         
        [venues addObject:venue];
        
    }
    
    return venues;
}

@end
