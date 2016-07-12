//
//  Audio.m
//  AudioResume
//
//  Created by Justin Lee on 7/8/16.
//  Copyright © 2016 AppLovin. All rights reserved.
//

#import "Audio.h"

@interface Audio()

@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) AVPlayer *audioPlayer;
//@property (nonatomic, strong) AVPlayerItem *audioPlayerItem;
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

- (AVPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSURL *mp3URL = [NSURL URLWithString:@"http://soundbible.com/mp3/Ferrari%20Racing%20Around-SoundBible.com-1150812389.mp3"];
        _audioPlayer = [[AVPlayer alloc] initWithURL:mp3URL];
    }
    return _audioPlayer;
}


//- (AVPlayerItem *)audioPlayerItem
//{
//    if (!_audioPlayerItem) {
//        NSURL *mp3URL = [NSURL URLWithString:@"http://soundbible.com/mp3/Ferrari%20Racing%20Around-SoundBible.com-1150812389.mp3"];
//        _audioPlayerItem = [[AVPlayerItem alloc] initWithURL:mp3URL];
//    }
//    return _audioPlayerItem;
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupAudioSession];
        [self setupAudioPlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(interruptPlayingAudio:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
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
    
    
//    if ([self. prepareToPlay]) {
    [self.audioPlayer play];
    self.audioPlaying = YES;
//    }
}

- (void)setupAudioSession
{
    if (self.audioSession.isOtherAudioPlaying) {
        self.audioPlaying = NO;
    }
    
}

- (void)setupAudioPlayer
{
//    self.audioPlayer.numberOfLoops = 0;
}

- (void)interruptPlayingAudio:(NSNotification *)notification
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
