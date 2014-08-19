//
//  VenueBuilder.h
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueBuilder : NSObject

+ (NSArray *)venuesFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
