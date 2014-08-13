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

@end

@implementation StillsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stillsData = [[DBManager getSharedInstance] getDatas];
    self.isInit = YES;
    
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
    
}

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
    
    // Add action to play button
    UIButton *playButton = (UIButton *)[cell viewWithTag:101];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    self.currentPlayIndexPath = (NSIndexPath *) indexPath;
    
    //NSLog(@"index path is %@",indexPath);
    if (indexPath != nil){
       // NSLog(@"YES I AM IN");
        // Play sound
        if ([audioPlayer isPlaying]){
            [audioPlayer stop];
            
            [sender setSelected:NO];
        } else {
            
            NSError *error = nil;
            NSString *audioFileName = [[self.stillsData objectAtIndex:[indexPath row]] valueForKey:@"audio"];
            //NSLog(@"GOGOGO: %@",audioFileName);
            NSURL *audioFilePathURL = [self documentsPathURLForFileName:audioFileName];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFilePathURL error:&error];
            [audioPlayer setDelegate:self];
            [audioPlayer play];
            
            // Set up UI
            [sender setSelected:YES];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"Finished playing...");
    
    
    NSLog(@"current play index path: %@",self.currentPlayIndexPath);
    if (self.currentPlayIndexPath){
        NSLog(@"current play index path: %@",self.currentPlayIndexPath);
        UITableViewCell *currentPlayingCell = [self.tableView cellForRowAtIndexPath:self.currentPlayIndexPath];
        UIButton *buttonPlay = (UIButton *)[currentPlayingCell viewWithTag:101];
        [buttonPlay setSelected:NO];
    }
    
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
