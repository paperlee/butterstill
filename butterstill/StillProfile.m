//
//  StillProfile.m
//  butterstill
//
//  Created by Paper on 8/12/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "StillProfile.h"

@implementation StillProfile

@synthesize row_id = _row_id;
@synthesize uid = _uid;
@synthesize author = _author;
@synthesize description = _description;
@synthesize image = _image;
@synthesize audio = _audio;
@synthesize create_date = _create_date;
@synthesize update_date = _update_date;
@synthesize sync_date = _sync_date;
@synthesize liked = _liked;
@synthesize disliked = _disliked;
@synthesize remote = _remote;
@synthesize enable = _enable;

- (id)initWithStillProfile:(NSMutableDictionary *)stillProfileData{
    if ((self = [super init])){
        self.row_id = [[stillProfileData objectForKey:@"id"] intValue];
        self.uid = [[stillProfileData objectForKey:@"uid"] intValue];
        self.author = [stillProfileData objectForKey:@"author"];
        self.description = [stillProfileData objectForKey:@"description"];
        self.image = [stillProfileData objectForKey:@"image"];
        self.audio = [stillProfileData objectForKey:@"audio"];
        self.create_date = [[stillProfileData objectForKey:@"create_date"] intValue];
        self.update_date = [[stillProfileData objectForKey:@"update_date"] intValue];
        self.sync_date = [[stillProfileData objectForKey:@"sync_date"] intValue];
        self.liked = [[stillProfileData objectForKey:@"liked"] intValue];
        self.disliked = [[stillProfileData objectForKey:@"disliked"] intValue];
        self.remote = [stillProfileData objectForKey:@"remote"];
        self.enable = [[stillProfileData objectForKey:@"enable"] intValue];
        
    }
    return self;
}

@end
