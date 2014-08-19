//
//  ViewController.m
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "CameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface CameraViewController (){
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
}

@end

@implementation CameraViewController

@synthesize stillImageOutput, imagePreview, captureImage;

#pragma mark - Initialization
-(id)init {
    self = [super init];
    
    if(self){
        [self initializeViewController];
    }
    
    //pthread_mutex_init(&outputAudioFileLock, NULL);
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    NSLog(@"init microphone");
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get current location
    [self currentLocationIdentifer];
    
    self.isRecording = NO;
    
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
    
    // To fix volume too small problem in iPhone
    NSError *setOverrideError = nil;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
    if (setOverrideError){
        NSLog(@"Set Override Speaker error: %@",setOverrideError);
    }
    
    // Define the recorder settings
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    
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
    
    // Set up audioPlot
    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:self.soundWaveView.frame];
    [self.soundWaveView addSubview:self.audioPlot];
    self.audioPlot.clipsToBounds = NO;
    self.audioPlot.opaque = NO;
    self.audioPlot.backgroundColor = [UIColor clearColor];
    self.audioPlot.color = [UIColor colorWithRed:0.9 green:0.12 blue:0.13 alpha:0.4];
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.hidden = YES;
    self.audioPlot.gain = 3;
    self.audioPlot.userInteractionEnabled = NO;
    
    // Assign button images animation
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:15];
    UIImage *tempImage = nil;
    for (int i = 1;i<16;i++){
        tempImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_butterfly%04d",i]];
        [images addObject:tempImage];
    }
    
    self.buttonTake.imageView.animationImages = images;
    [self.buttonTake.imageView startAnimating];
    
    
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

-(void)currentLocationIdentifer{
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
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
    self.isRecording = YES;
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        
        if (imageSampleBuffer != NULL){
            NSData *imageDate = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageDate]];
            
            // Start recording
            //[self performSelector:@selector(startRecording) withObject:nil afterDelay:0.5];
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            //self.isRecording = YES;
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (!audioRecorder.isRecording && self.isRecording){
                    //NSLog(@"Init recorder: %hhd :: %hhd",audioRecorder.isRecording,self.isRecording);
                    AVAudioSession *session = [AVAudioSession sharedInstance];
                    NSError *error = nil;
                    [session setActive:YES error:&error];
                    if (error){
                        NSLog(@"Fail to active session: %@",error);
                    }
                    
                    //Start recording
                    [audioRecorder record];
                    
                    
                    //[self.audioPlot clear];
                    
                    [self.audioPlot setHidden:NO];
                    
                    [self.microphone startFetchingAudio];
                }
            });
            
        }
    }];
    
    
}

- (void) processImage:(UIImage *)image{
    haveImage = YES;
    
    [captureImage setImage:image];
    
    /*if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
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
        
    }*/
    
    self.takenImageOrientation = [[UIDevice currentDevice] orientation];
    NSLog(@"Now the orientation is %ld",(long)self.takenImageOrientation);
    
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

- (void)startRecording{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setActive:YES error:&error];
    if (error){
        NSLog(@"Fail to active session: %@",error);
    }
    
    //Start recording
    [audioRecorder record];
    
    
    //[self.audioPlot clear];
    
    [self.audioPlot setHidden:NO];
    
    [self.microphone startFetchingAudio];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)snapImage:(UIButton *)sender {
    // Prepare UI
    captureImage.image = nil;
    [captureImage setHidden:NO];
    [imagePreview setHidden:YES];
    
    // Hold butterfly
    [sender.imageView stopAnimating];
    [sender setImageEdgeInsets:UIEdgeInsetsMake(-8, 0, 0, 8)];
    [self.hintText setText:@"Hold on..."];
    
    // Recording
    // Stop audio palyer pior to recording
    if (audioPlayer.playing){
        [audioPlayer stop];
    }
    
    [self capImage];
    
}

// TOFIX: Use gesture recognizer instead of touch up/down

- (IBAction)snapImageEnd:(UIButton *)sender {
    NSLog(@"Snap image end");
    // End up recording
    if (audioRecorder.recording){
        [audioRecorder stop];
        [self.microphone stopFetchingAudio];
        self.isRecording = NO;
    } else{
        NSLog(@"Still in queue. Cancel the pending request.");
        //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRecording) object:nil];
        if (self.isRecording){
            NSLog(@"Still in queue. Cancel the pending request. 2");
            // still in delay recording process...
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                NSLog(@"Pending to stop the recorder");
                [audioRecorder stop];
                [self.microphone stopFetchingAudio];
                self.isRecording = NO;
            });
        }
    }
    
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setActive:NO error:&error];
    if (error){
        NSLog(@"Fail to inactive session: %@",error);
    }
    
    // Butterfly fly again
    //[sender.imageView startAnimating];
    [sender setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.hintText setText:@"Retake"];
    
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
    NSLog(@"Saving...");
    NSString *unique_name = [NSString stringWithFormat:@"%.0f",[NSDate timeIntervalSinceReferenceDate]*1000];
    
    // Save image to app document
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"%@.jpg",unique_name]];
    
    NSInteger shallImageOrientation;
    switch (self.takenImageOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            shallImageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            shallImageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            shallImageOrientation = UIImageOrientationUp;
            break;
        default:
            shallImageOrientation = UIImageOrientationRight;
            break;
    }
    
    UIImage *saveImage = [[UIImage alloc] initWithCGImage:self.captureImage.image.CGImage scale:1.0 orientation:shallImageOrientation];
    //NSLog(@"Taken image orientation: %d",self.takenImageOrientation);
    //UIImage *saveImage = [self fixRotationWithImage:self.captureImage.image];
    NSData *jpgData = UIImageJPEGRepresentation(saveImage, 0.0);
    [jpgData writeToFile:imagePath atomically:YES];
    NSLog(@"Saved image file");
    
    // Save audio to app document
    NSURL *audioPathURL = [self audioFilePathURL];
    NSString *storedAudioPath = [self documentsPathForFileName:[NSString stringWithFormat:@"%@.m4a",unique_name]];
    NSError *error = nil;
    BOOL storeAudioSuccess = [[NSFileManager defaultManager] copyItemAtPath:audioPathURL.path toPath:storedAudioPath error:&error];
    if (!storeAudioSuccess) {
        NSLog(@"Failed to save audio file: %@",error);
    } else {
        NSLog(@"Saved audio file.");
    }
    
    //TODO: smarter cal. row height
    float row_height = floorf(320*saveImage.size.height/saveImage.size.width);
    NSLog(@"Saved image row height is %f",row_height);
    /*if (self.takenImageOrientation == UIImageOrientationLeft || self.takenImageOrientation == UIImageOrientationRight){
        row_height = 320*captureImage.image.size.width/captureImage.image.size.height;
    }*/
    
    //TOFIX: Wrong name between uid and image/audio file name
    NSMutableDictionary *stillProfile = [[NSMutableDictionary alloc] init];
    [stillProfile setObject:[NSNumber numberWithInt:[unique_name intValue]] forKey:@"uid"];
    [stillProfile setObject:@"paper" forKey:@"author"];
    [stillProfile setObject:@"nothing..." forKey:@"description"];
    [stillProfile setObject:[NSString stringWithFormat:@"%@.jpg",unique_name] forKey:@"image"];
    [stillProfile setObject:[NSString stringWithFormat:@"%@.m4a",unique_name] forKey:@"audio"];
    [stillProfile setObject:[NSNumber numberWithInt:[unique_name intValue]] forKey:@"create_date"];
    [stillProfile setObject:[NSNumber numberWithInt:[unique_name intValue]] forKey:@"update_date"];
    [stillProfile setObject:[NSNumber numberWithInt:[unique_name intValue]] forKey:@"sync_date"];
    [stillProfile setObject:[NSNumber numberWithInt:0] forKey:@"liked"];
    [stillProfile setObject:[NSNumber numberWithInt:0] forKey:@"disliked"];
    [stillProfile setObject:@"no" forKey:@"remote"];
    [stillProfile setObject:[NSNumber numberWithInt:1] forKey:@"enable"];
    [stillProfile setObject:[NSNumber numberWithFloat:row_height] forKey:@"row_height"];
    
    NSLog(@"Will save %@",stillProfile);
    
    BOOL saveDBSuccess = [[DBManager getSharedInstance] saveData:stillProfile];
    if (!saveDBSuccess){
        NSLog(@"Failed to save in db");
    } else {
        NSLog(@"Success to go db");
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakeAction:(UIButton *)sender {
    // Stop player if playing
    if (audioPlayer.playing){
        [audioPlayer stop];
    }
    
    // UI
    [self.buttonPlay setEnabled:NO];
    [self.buttonPlay setSelected:NO];
    [self.buttonRetake setHidden:YES];
    [self.buttonSave setEnabled:NO];
    [self.buttonTake setHidden:NO];
    [self.buttonTake setEnabled:YES];
    [self.buttonTake.imageView startAnimating];
    [self.hintText setText:@"Tap and Hold"];
    
    [imagePreview setHidden:NO];
    [captureImage setHidden:YES];
    [self.audioPlot setHidden:YES];
    
    if (self.audioPlot){
        self.audioPlot = nil;
    }
    
    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:self.soundWaveView.frame];
    [self.soundWaveView addSubview:self.audioPlot];
    self.audioPlot.clipsToBounds = NO;
    self.audioPlot.opaque = NO;
    self.audioPlot.backgroundColor = [UIColor clearColor];
    self.audioPlot.color = [UIColor colorWithRed:0.9 green:0.12 blue:0.13 alpha:0.4];
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.hidden = YES;
    self.audioPlot.gain = 3;
    self.audioPlot.userInteractionEnabled = NO;
    
}

#pragma mark AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    NSLog(@"Recording end");
    
    // Prepare UI after finishing recording
    [self.buttonPlay setEnabled:YES];
    [self.buttonSave setEnabled:YES];
    //[self.buttonTake setHidden:YES];
    [self.buttonTake setEnabled:NO];
    [self.buttonRetake setHidden:NO];
}

#pragma mark AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"Finished playing...");
    [self.buttonPlay setSelected:NO];
}

#pragma mark EZMicrophoneDelegate
- (void) microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (audioRecorder.isRecording){
            [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        }
        
    });
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations objectAtIndex:0];
    // TODO: What if get wrong location? UI flow fix?
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Got location");
    
    self.locationLabel.text = [NSString stringWithFormat:@"Lng:%.2f Lat:%.2f",currentLocation.coordinate.latitude,currentLocation.coordinate.latitude];
    
    /*CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error){
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
        } else {
            // Error!
            NSLog(@"Geocode failed with error: %@",error);
            NSLog(@"Current location fetch error");
        }
    }];*/
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Fail to get location: %@",error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Failed to Get Location" message:@"Try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)buttonClose:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Utility
- (NSString *)documentsPathForFileName:(NSString *)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (NSURL *)audioFilePathURL{
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], kTempAudioFilePath, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL;
}

/*- (UIImage *)fixRotationWithImage:(UIImage *)image{
    
    NSInteger orientation = self.takenImageOrientation;
    
    if (orientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}*/

@end
