//
//  PlayerViewController.h
//  udacity_dictionary
//
//  Created by Denis Fromfontan on 19.08.15.
//  Copyright (c) 2015 Denis Fromfontan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordedAudio.h"

@class RecordedAudio;

@interface PlayerViewController : UIViewController
@property (nonatomic,strong) RecordedAudio *recordedAudio;
@end
