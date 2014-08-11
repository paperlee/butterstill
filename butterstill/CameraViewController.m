//
//  ViewController.m
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "CameraViewController.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface CameraViewController (){
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
}

@end

@implementation CameraViewController

@synthesize stillImageOutput, imagePreview, captureImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    FrontCamera = NO;
    [captureImage setHidden:YES];
    
    // Set up audio recorder path
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], kTempAudioFilePath, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Set up audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error){
        NSLog(@"Fail to create session: %@",error);
    }
    
    // Define the recorder settings
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    // Init and preapre the recorder
    NSError *initRecorderError = nil;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:&initRecorderError];
    if (!audioRecorder){
        // Error!
        NSLog(@"Fail to init recorder: %@",error);
    }
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
}

- (void)viewDidAppear:(BOOL)animated{
    [self initializeCamera];
}

// Init camera: assign live video feed in view
- (void) initializeCamera{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [captureVideoPreviewLayer setFrame:self.imagePreview.bounds];
    [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    // Duplicated setFrame?
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices){
        NSLog(@"Device name: %@", [device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]){
            if ([device position] == AVCaptureDevicePositionBack){
                NSLog(@"Device position: back");
                backCamera = device;
            } else {
                NSLog(@"Device position: front");
                frontCamera = device;
            }
        }
    }
    
    if (!FrontCamera){
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input){
            // Error!
            NSLog(@"Fail to open camera: %@",error);
        }
        [session addInput:input];
    }
    
    if (FrontCamera){
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input){
            NSLog(@"Fail to open front camera: %@",error);
        }
        [session addInput:input];
    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
}

- (void)capImage{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections){
        for (AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection){
            break;
        }
    }
    
    NSLog(@"about to request from: %@",stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        
        if (imageSampleBuffer != NULL){
            NSData *imageDate = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageDate]];
        }
    }];
}

- (void) processImage:(UIImage *)image{
    haveImage = YES;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        // iPad, resize image
        UIGraphicsBeginImageContext(CGSizeMake(768,1022));
        [image drawInRect:CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 130, 768, 768);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
    } else {
        // Device is iphone
        UIGraphicsBeginImageContext(CGSizeMake(320, 426));
        [image drawInRect:CGRectMake(0, 0, 320, 426)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 64, 320, 320);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
        
    }
    
    // adjust image orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        NSLog(@"landscape left image");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        NSLog(@"landscape right");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
        NSLog(@"upside down");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait){
        NSLog(@"upside upright");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)snapImage:(UIButton *)sender {
    captureImage.image = nil;
    [captureImage setHidden:NO];
    [imagePreview setHidden:YES];
    
    [self capImage];
    
    // Recording
    // Stop audio palyer pior to recording
    if (audioPlayer.playing){
        [audioPlayer stop];
    }
    
    if (!audioRecorder.recording){
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [session setActive:YES error:&error];
        if (error){
            NSLog(@"Fail to active session: %@",error);
        }
        
        //Start recording
        [audioRecorder record];
        
    }
}

- (IBAction)snapImageEnd:(UIButton *)sender {
    // End up recording
    [audioRecorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setActive:NO error:&error];
    if (error){
        NSLog(@"Fail to inactive session: %@",error);
    }
    
    // UI
    /*[self.buttonPlay setEnabled:YES];
    [self.buttonSave setEnabled:YES];
    [self.buttonTake setHidden:YES];
    [self.buttonRetake setHidden:NO];*/
    
}

- (IBAction)playAction:(UIButton *)sender {
    if (!audioRecorder.recording){
        if ([audioPlayer isPlaying]){
            [audioPlayer stop];
            
            [sender setSelected:NO];
        } else {
            NSError *error = nil;
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
            [audioPlayer setDelegate:self];
            [audioPlayer play];
            
            // Set up UI
            [sender setSelected:YES];
        }
        
    }
}

- (IBAction)saveAction:(UIButton *)sender {
}

- (IBAction)retakeAction:(UIButton *)sender {
    // Stop player if playing
    if (audioPlayer.playing){
        [audioPlayer stop];
    }
    
    // UI
    [self.buttonPlay setEnabled:NO];
    [self.buttonRetake setHidden:YES];
    [self.buttonSave setEnabled:NO];
    [self.buttonTake setHidden:NO];
    
    [imagePreview setHidden:NO];
    [captureImage setHidden:YES];
    
    
}

#pragma mark AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    // Prepare UI after finishing recording
    [self.buttonPlay setEnabled:YES];
    [self.buttonSave setEnabled:YES];
    [self.buttonTake setHidden:YES];
    [self.buttonRetake setHidden:NO];
}

#pragma mark AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"Finished playing...");
    [self.buttonPlay setSelected:NO];
}

@end
