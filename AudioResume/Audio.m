//
//  Audio.m
//  AudioResume
//
//  Created by Justin Lee on 7/8/16.
//  Copyright © 2016 AppLovin. All rights reserved.
//

#import "Audio.h"

@interface Audio() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, getter=isAudioPlaying) BOOL audioPlaying;
@property (nonatomic, getter=isAudioInterrupted) BOOL audioInterrupted;

@end

@implementation Audio

- (AVAudioSession *)audioSession
{
    if (!_audioSession) {
        NSError *categoryError;
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
        if (categoryError) NSLog(@"CATEGORY ERROR : %@", categoryError);
    }
    return _audioSession;
}

- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSError *error;
        NSURL *mp3URL = [NSURL URLWithString:@"http://soundbible.com/mp3/Ferrari%20Racing%20Around-SoundBible.com-1150812389.mp3"];
        NSData *mp3Data = [[NSData alloc] initWithContentsOfURL:mp3URL];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:mp3Data error:&error];
        if (error) NSLog(@"ERROR : %@",error);
    }
    return _audioPlayer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioPlayer.delegate = self;
        [self setupAudioSession];
        [self setupAudioPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
    }
    return self;
}

- (void)playAudio
{
    
    if (self.audioSession.isOtherAudioPlaying && !self.isAudioPlaying) {
        NSLog(@"other audio ALREADY PLAYING!");
//        return;
    }
    
    
    if ([self.audioPlayer prepareToPlay]) {
        self.audioPlaying = [self.audioPlayer play];
    }
}

- (void)setupAudioSession
{
    if (self.audioSession.isOtherAudioPlaying) {
        self.audioPlaying = NO;
    }
    
}

- (void)setupAudioPlayer
{
    self.audioPlayer.numberOfLoops = 0;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSError *optionError;
    [self.audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&optionError];
    if (optionError) NSLog(@"OPTION ERROR : %@", optionError);
}

- (void)audioInterrupted:(NSNotification *)notification
{
    NSDictionary *interruptionUserInfo = notification.userInfo;
    NSInteger interruptionType = [[interruptionUserInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSInteger interruptionOption = [[interruptionUserInfo valueForKey:AVAudioSessionInterruptionOptionKey] integerValue];
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"interruption STARTED!");
            break;
        
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"interruption ENDED!");
            if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
                NSError *error;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
                     [self playAudio];
                     if (error) NSLog(@"ERROR? : %@", error);
                     NSLog(@"audio SHOULD RESUME!");
                 });
            }
            break;
        
        default:
            break;
    }
}

@end
