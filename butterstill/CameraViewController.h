//
//  ViewController.h
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"
#import "DBManager.h"

#define kTempAudioFilePath @"TempAudio.m4a"

@interface CameraViewController : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate,EZMicrophoneDelegate>{
    BOOL FrontCamera;
    BOOL haveImage;
}

@property (nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIImageView *captureImage;
@property (weak, nonatomic) IBOutlet UIView *soundWaveView;

@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonTake;
@property (weak, nonatomic) IBOutlet UIButton *buttonRetake;

@property (nonatomic,strong) EZAudioPlot *audioPlot;
@property (nonatomic,strong) EZMicrophone *microphone;

- (IBAction)snapImage:(UIButton *)sender;
- (IBAction)snapImageEnd:(UIButton *)sender;

- (IBAction)playAction:(UIButton *)sender;
- (IBAction)saveAction:(UIButton *)sender;
- (IBAction)retakeAction:(UIButton *)sender;
- (IBAction)buttonClose:(UIButton *)sender;


@end
