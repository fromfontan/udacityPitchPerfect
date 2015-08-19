//
//  ViewController.m
//  udacity_dictionary
//
//  Created by Denis Fromfontan on 17.08.15.
//  Copyright (c) 2015 Denis Fromfontan. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "RecordedAudio.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController () <AVAudioRecorderDelegate> {
    AVAudioRecorder *recorder;
}
@property (readonly) NSString *documentsDir;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recordingLabel.hidden=YES;
    self.stopButton.hidden=YES;
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.recButton.enabled=YES;
    self.stopButton.hidden=YES;
    self.recordingLabel.hidden=YES;

}
- (IBAction)recPressed:(id)sender {
    
    
    self.recButton.enabled=NO;
    self.stopButton.hidden=NO;
    self.recordingLabel.hidden=NO;
    
    SEL requestRecordPermissionSelector = NSSelectorFromString(@"requestRecordPermission:");
    if([[AVAudioSession sharedInstance] respondsToSelector:requestRecordPermissionSelector]) {
        [[AVAudioSession sharedInstance] performSelector:requestRecordPermissionSelector withObject:^(BOOL granted) {
            if(granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startAudioRecording];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Доступ к микрофону запрещен" message:@"для записи приложению нужен доступ к микрофону, включите в настройках епта" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
                    
                });
                
                
            }
            
        }];
        
    } else {
        [self startAudioRecording];
    }

    
}


-(void) startAudioRecording {
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
//    [df setLocale:locale];
//    [df setDateFormat:@"YYYY.MM.dd HH:mm:SS"];
    NSString *filename = [NSString stringWithFormat:@"Documents/audio.aif"];
    
    
    
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:filename]];
    
    
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16400.0f] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    NSError *error = nil;
    recorder  = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if(recorder==nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ошибка инициализации аудиорекордера" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
        [alert show];
        return;
    }
    recorder.delegate = self;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ret1 = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    BOOL ret2 = [audioSession setActive:YES error:&error];
    if(!ret1 || !ret2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ошибка инициализации аудиорекордера" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
        [alert show];
        return;
    }
    
    [recorder record];
}


- (IBAction)stopPressed:(id)sender {
    [recorder stop];
    
    self.recButton.enabled=YES;
    self.stopButton.hidden=YES;
    self.recordingLabel.hidden=YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showPlayer"]) {
        PlayerViewController *pvc = (PlayerViewController*)segue.destinationViewController;
        RecordedAudio *recordedAudio = [[RecordedAudio alloc] init];
        recordedAudio.fileURL = recorder.url;
        recordedAudio.title = recorder.url.lastPathComponent;
        pvc.recordedAudio = recordedAudio;
    }
    
}

//Ждем пока допишется файл
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if(flag) {
        [self performSegueWithIdentifier:@"showPlayer" sender:self.stopButton];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"writing audio file" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
        [alert show];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
