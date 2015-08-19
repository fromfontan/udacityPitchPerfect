//
//  PlayerViewController.m
//  udacity_dictionary
//
//  Created by Denis Fromfontan on 19.08.15.
//  Copyright (c) 2015 Denis Fromfontan. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController () <AVAudioPlayerDelegate> {
    AVAudioPlayer *player;
}
@property (weak, nonatomic) IBOutlet UIButton *vaderButton;
@property (weak, nonatomic) IBOutlet UIButton *chipmunkButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (nonatomic,readonly) AVAudioPlayer *player;
@property (nonatomic,readonly) AVAudioFile *audioFile;
@property (nonatomic,strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic,readonly) AVAudioEngine *audioEngine;

@end

@implementation PlayerViewController
@synthesize player,audioFile,audioEngine;

-(AVAudioPlayer*)player {
    if(!player) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudio.fileURL error:nil];
    }
    return player;
}

-(AVAudioFile*)audioFile {
    if(!audioFile) {
        audioFile = [[AVAudioFile alloc] initForReading:self.recordedAudio.fileURL error:nil];
    }
    return audioFile;
}

-(AVAudioEngine*)audioEngine {
    if(!audioEngine) {
        audioEngine = [[AVAudioEngine alloc] init];
    }
    return audioEngine;
}



-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(!NSClassFromString(@"AVAudioEngine")) {
        self.chipmunkButton.enabled = NO;
        self.vaderButton.enabled=NO;
    }
    
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

- (IBAction)playFast:(id)sender {
    [self stopPlayer];
    [self playWithRate:2.0];
}

- (IBAction)playSlow:(id)sender {
    [self stopPlayer];
    [self playWithRate:0.5];
}

- (IBAction)chipmunkAction:(id)sender {
    [self stopPlayer];
    [self playAudioWithPitch:1000.0];
}

- (IBAction)vaderAction:(id)sender {
    [self stopPlayer];
    [self playAudioWithPitch:-1000.0];
}


-(void)stopPlayer {
    [self.player stop];
    [self.audioEngine stop];
    [self.audioEngine reset];
}

-(void)playWithRate:(float)rate {
    self.player.enableRate = YES;
    self.player.rate=rate;
    self.player.currentTime = 0;
    self.player.delegate=self;
    [self.player play];
    self.stopButton.enabled = YES;
}

-(void)playAudioWithPitch:(float)pitch {
    
    [self.player stop];
    self.stopButton.enabled = YES;
    [self.audioEngine stop];
    [self.audioEngine reset];
    
    self.audioPlayerNode = [[AVAudioPlayerNode alloc] init];
    [audioEngine attachNode:self.audioPlayerNode];
    AVAudioUnitTimePitch *changePitchEffect = [[AVAudioUnitTimePitch alloc] init];
    changePitchEffect.pitch = pitch;
    [self.audioEngine attachNode:changePitchEffect];
    [self.audioEngine connect:self.audioPlayerNode to:changePitchEffect format:nil];
    [self.audioEngine connect:changePitchEffect to:self.audioEngine.outputNode format:nil];
    
    [self.audioPlayerNode scheduleFile:self.audioFile atTime:nil completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stopButton.enabled = NO;
        });
    }];
    [self.audioEngine startAndReturnError:nil];
    [self.audioPlayerNode play];
    
}

- (IBAction)stopButtonPressed:(id)sender {
    [self.player stop];
    [self.audioPlayerNode stop];
    self.stopButton.enabled = NO;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.stopButton.enabled = NO;
}


@end
