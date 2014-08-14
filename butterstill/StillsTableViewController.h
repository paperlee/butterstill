//
//  StillsTableViewController.h
//  butterstill
//
//  Created by Paper on 8/12/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"

@interface StillsTableViewController : UITableViewController<AVAudioPlayerDelegate, EZAudioFileDelegate>

@property (nonatomic,strong) NSArray *stillsData;
//@property (nonatomic,weak) NSIndexPath *currentPlayIndexPath;
@property (nonatomic,assign) BOOL isAutoPlaying;

@end
