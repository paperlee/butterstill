//
//  Venue.h
//  butterstill
//
//  Created by Paper on 8/19/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,assign) float lat;
@property (nonatomic,assign) float lng;
@property (nonatomic,assign) int distance;
@property (nonatomic,strong) NSString *categoryName;
@property (nonatomic,strong) NSString *categoryIconUrl;

@end
