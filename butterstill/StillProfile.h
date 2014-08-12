//
//  StillProfile.h
//  butterstill
//
//  Created by Paper on 8/12/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StillProfile : NSObject{
    int _row_id;
    int _uid;
    NSString *_author;
    NSString *_description;
    NSString *_image;
    NSString *_audio;
    int _create_date;
    int _update_date;
    int _sync_date;
    int _liked;
    int _disliked;
    NSString *_remote;
    int _enable;
    
}

@property (nonatomic,assign) int row_id;
@property (nonatomic,assign) int uid;
@property (nonatomic,copy) NSString *author;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,copy) NSString *image;
@property (nonatomic,copy) NSString *audio;
@property (nonatomic,assign) int create_date;
@property (nonatomic,assign) int update_date;
@property (nonatomic,assign) int sync_date;
@property (nonatomic,assign) int liked;
@property (nonatomic,assign) int disliked;
@property (nonatomic,copy) NSString *remote;
@property (nonatomic,assign) int enable;

- (id)initWithStillProfile:(NSMutableDictionary *)stillProfile;

@end
