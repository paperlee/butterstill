//
//  StillsTableViewController.m
//  butterstill
//
//  Created by Paper on 8/12/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "StillsTableViewController.h"
#import "DBManager.h"
#import "StillProfile.h"

@interface StillsTableViewController (){
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic,assign) BOOL isInit;
//@property (nonatomic,strong) EZAudioPlot *audioPlot;
//@property (nonatomic,strong) EZAudioFile *audioFile;
@property (nonatomic,assign) NSInteger currentCenterIndexPathRow;
@property (nonatomic,assign) NSInteger playingIndexPathRow;

@end

@implementation StillsTableViewController
{
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        hidden = NO;
        self.isAutoPlaying = NO;
        self.playingIndexPathRow = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stillsData = [[DBManager getSharedInstance] getDatas];
    self.isInit = YES;
    
    self.currentCenterIndexPathRow = -1;
    //[self.tableView setEditing:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isInit){
        //NSLog(@"Cool! I am first time here");
        self.isInit = NO;
    } else {
        //NSLog(@"View Will Appear!");
        // Refresh the table
        [self refreshTable];
    }
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    [self.navigationController setToolbarHidden:hidden animated:YES];
    
}

/*-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    //NSLog(@"There are %d rows.",[self.stillsData count]);
    return [self.stillsData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StillTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StillTableViewCell"];
    }
    
    StillProfile *stillProfile = [self.stillsData objectAtIndex:indexPath.row];
    UIImageView *stillImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *imagePath = [self documentsPathForFileName:stillProfile.image];
    stillImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    float shall_height = floorf(stillImageView.frame.size.width*(stillImageView.image.size.height/stillImageView.image.size.width));
    stillImageView.frame = CGRectMake(stillImageView.frame.origin.x, stillImageView.frame.origin.y, stillImageView.frame.size.width, shall_height);
    
    //[[self.stillsData objectAtIndex:[indexPath row]] setObject:[NSNumber numberWithFloat:shall_height] forKey:@"row_height"];
    
    // Add action to play button
    UIButton *playButton = (UIButton *)[cell viewWithTag:101];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"Done assign cell");
    
    //[stillProfile setValue:[NSNumber numberWithFloat:shall_height] forKey:@"rowHeight"];
    
    //NSLog(@"image height is %f",stillImageView.image.size.height);
    //NSLog(@"image in device height is %f",stillImageView.frame.size.height);
    //NSLog(@"row height is %f",cell.frame.size.height);
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // TODO: use ios7+ esstimated row height method
    float rowHeight = [[[self.stillsData objectAtIndex:indexPath.row] valueForKey:@"row_height"] floatValue];
    NSLog(@"row height: %f",rowHeight);
    return rowHeight;
}

- (void)refreshTable{
    self.stillsData = [[DBManager getSharedInstance] getDatas];
    [self.tableView reloadData];
}

- (void)playButtonAction:(UIButton *)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    //NSLog(@"begin assign: %@",self.currentPlayIndexPath);
    //self.currentPlayIndexPath = (NSIndexPath *) indexPath;
    //NSLog(@"end assign: %@",self.currentPlayIndexPath);
    
    //NSLog(@"index path is %@",indexPath);
    if (indexPath != nil){
       // NSLog(@"YES I AM IN");
        // Play sound
        
        if ([sender isSelected]){
            [audioPlayer stop];
            
            [sender setSelected:NO];
            
            if (self.playingIndexPathRow != -1){
                NSLog(@"Actively stop audio at %ld",(long)self.playingIndexPathRow);
                NSIndexPath *ip = [NSIndexPath indexPathForRow:self.playingIndexPathRow inSection:0];
                UITableViewCell *playingCell = [self.tableView cellForRowAtIndexPath:ip];
                UIButton *buttonPlay = (UIButton *)[playingCell viewWithTag:101];
                [buttonPlay setSelected:NO];
            }
            
            self.playingIndexPathRow = -1;
            
            
            
        } else {
            
            if (audioPlayer.isPlaying){
                [audioPlayer stop];
            }
            
            NSError *error = nil;
            NSString *audioFileName = [[self.stillsData objectAtIndex:[indexPath row]] valueForKey:@"audio"];
            //NSLog(@"GOGOGO: %@",audioFileName);
            NSURL *audioFilePathURL = [self documentsPathURLForFileName:audioFileName];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFilePathURL error:&error];
            [audioPlayer setDelegate:self];
            [audioPlayer play];
            
            // Set up UI
            [sender setSelected:YES];
            
            // TODO: Smarter way to change button status?
            /*double audioDuration = audioPlayer.duration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, audioDuration * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [sender setSelected:NO];
            });*/
            
            self.isAutoPlaying = NO;
            
            self.playingIndexPathRow = [indexPath row];
            
        }
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (audioPlayer.isPlaying){
            [audioPlayer stop];
        }
        
        // Delete db and local data first
        
        NSMutableDictionary *deletingData = [self.stillsData objectAtIndex:[indexPath row]];
        NSInteger row_id = [[deletingData valueForKey:@"row_id"] intValue];
        
        NSLog(@"Prepare to delete %ld and db id is %ld",(long)[indexPath row],(long)row_id);
        BOOL deleteSuccess = [[DBManager getSharedInstance] deleteData:row_id];
        if (deleteSuccess){
            // Delete audio and image file
            
            NSString *audioFilePath = [self documentsPathForFileName:[deletingData valueForKey:@"audio"]];
            NSString *imageFilePath = [self documentsPathForFileName:[deletingData valueForKey:@"image"]];
            NSError *audioError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:&audioError];
            if (audioError){
                NSLog(@"Error to delete audio file: %@",audioError);
            }
            
            NSError *imageError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:imageFilePath error:&imageError];
            if (imageError){
                NSLog(@"Error to delete image file: %@",imageError);
            }
            
            //self.stillsData = [[DBManager getSharedInstance] getDatas];
            
            [self.stillsData removeObjectAtIndex:[indexPath row]];
            
            NSLog(@"Deleted from file and db");
            
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"goStillSegue"]){
        NSLog(@"goStillSegue");
        if (audioPlayer.isPlaying){
            [audioPlayer stop];
            
            if (self.playingIndexPathRow != -1){
                NSLog(@"Passively stop audio at %ld",(long)self.playingIndexPathRow);
                NSIndexPath *ip = [NSIndexPath indexPathForRow:self.playingIndexPathRow inSection:0];
                UITableViewCell *playingCell = [self.tableView cellForRowAtIndexPath:ip];
                UIButton *buttonPlay = (UIButton *)[playingCell viewWithTag:101];
                [buttonPlay setSelected:NO];
            }
            
            self.playingIndexPathRow = -1;
            self.isAutoPlaying = NO;
        }
        
    }
}


#pragma mark AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"Finished playing...");
    
    // Anway isAutoPlaying is NO
    self.isAutoPlaying = NO;
    
    //NSLog(@"Shall stop at %d",self.currentCenterIndexPathRow);
    if (self.playingIndexPathRow != -1){
        
        //NSUInteger unsignedIndex = (NSUInteger)self.playingIndexPathRow;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:self.playingIndexPathRow inSection:0];
        
        NSLog(@"Closing %@",ip);
        
        UITableViewCell *playingCell = [self.tableView cellForRowAtIndexPath:ip];
        UIButton *buttonPlay = (UIButton *)[playingCell viewWithTag:101];
        [buttonPlay setSelected:NO];
    }
    
    
}

/*
#pragma mark - EZAudioPlot
-(void)initAudioPlotForView:(UIView *)view{
    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:view.frame];
    [view addSubview:self.audioPlot];
    self.audioPlot.clipsToBounds = NO;
    self.audioPlot.opaque = NO;
    self.audioPlot.backgroundColor = [UIColor colorWithRed:0.816 green:0.249 blue:0.255 alpha:0];
    self.audioPlot.color = [UIColor colorWithRed:0.9 green:0.12 blue:0.13 alpha:0.4];
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.hidden = YES;
    self.audioPlot.gain = 10;
    self.audioPlot.userInteractionEnabled = NO;
}*/

#pragma mark - expand and schrink
-(void)expand{
    if (hidden){
        return;
    }
    hidden = YES;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)contract{
    if (!hidden){
        return;
    }
    hidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // Cancel all queue
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlayCenterPost) object:nil];
    
    /*if (self.isAutoPlaying && audioPlayer.isPlaying){
        [audioPlayer stop];
        self.isAutoPlaying = NO;
    }*/
    
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;
    
    if (differenceFromStart < 0){
        //scroll up
        if (scrollView.isTracking && (abs(differenceFromLast)>1)){
            [self expand];
        }
    } else {
        if (scrollView.isTracking && (abs(differenceFromLast)>1)){
            [self contract];
        }
    }
    
    
    // Determine shall stop audio or not
    CGPoint center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    CGPoint centerInTable = [self.view convertPoint:center fromView:self.tableView.superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:centerInTable];
    if ([indexPath row] != self.currentCenterIndexPathRow){
        // Scroll to another post
        if (self.isAutoPlaying && audioPlayer.isPlaying){
            [audioPlayer stop];
            self.isAutoPlaying = NO;
            
            if (self.playingIndexPathRow != -1){
                NSLog(@"Passively stop audio at %ld",(long)self.playingIndexPathRow);
                NSIndexPath *ip = [NSIndexPath indexPathForRow:self.playingIndexPathRow inSection:0];
                UITableViewCell *playingCell = [self.tableView cellForRowAtIndexPath:ip];
                UIButton *buttonPlay = (UIButton *)[playingCell viewWithTag:101];
                [buttonPlay setSelected:NO];
            }
            
            self.playingIndexPathRow = -1;
        }
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    /*CGPoint center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];*/
    //NSLog(@"Did end dragging: %d",self.currentCenterIndexPathRow);
    
    CGPoint center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    CGPoint centerInTable = [self.view convertPoint:center fromView:self.tableView.superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:centerInTable];
    if (self.currentCenterIndexPathRow == [indexPath row] && audioPlayer.isPlaying){
        return;
    }
    [self performSelector:@selector(autoPlayCenterPost) withObject:nil afterDelay:1];
    
}

-(void)scrollViewDidEndDecfelerating:(UIScrollView *)scrollView{
    
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    [self contract];
    return YES;
}

-(void)autoPlayCenterPost{
    CGPoint center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    CGPoint centerInTable = [self.view convertPoint:center fromView:self.tableView.superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:centerInTable];
    NSLog(@"Center index path is %@",indexPath);
    
    if (indexPath == nil){
        return;
    }
    
    //NSLog(@"Old center is %d",self.currentCenterIndexPathRow);
    //NSLog(@"Current center is %d",[indexPath row]);
    
    /*if (self.currentCenterIndexPathRow == [indexPath row]){
        return;
    }*/
    
    self.currentCenterIndexPathRow = [indexPath row];
    
    // Play audio
    if (audioPlayer.isPlaying){
        [audioPlayer stop];
    }
    NSError *error = nil;
    NSString *audioFileName = [[self.stillsData objectAtIndex:[indexPath row]] valueForKey:@"audio"];
    //NSLog(@"GOGOGO: %@",audioFileName);
    NSURL *audioFilePathURL = [self documentsPathURLForFileName:audioFileName];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFilePathURL error:&error];
    if (error){
        NSLog(@"Error play audio: %@",error);
    }
    self.isAutoPlaying = YES;
    [audioPlayer setDelegate:self];
    [audioPlayer play];
    self.playingIndexPathRow = [indexPath row];
    
    // UI
    UITableViewCell *centerCell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *buttonPlay = (UIButton *)[centerCell viewWithTag:101];
    [buttonPlay setSelected:YES];
    /*double audioDuration = audioPlayer.duration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, audioDuration * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [buttonPlay setSelected:NO];
    });*/
    
}

#pragma mark - Utility
- (NSString *)documentsPathForFileName:(NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (NSURL *)documentsPathURLForFileName:(NSString *)name{
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], name, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}

@end
