//
//  StillsTableViewController.h
//  butterstill
//
//  Created by Paper on 8/12/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface StillsTableViewController : UITableViewController<AVAudioPlayerDelegate>

@property (nonatomic,strong) NSArray *stillsData;

@end
