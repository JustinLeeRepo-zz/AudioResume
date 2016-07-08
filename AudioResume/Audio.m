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
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, getter=isAudioPlaying) BOOL audioPlaying;
@property (nonatomic, getter=isAudioInterrupted) BOOL audioInterrupted;

@end

@implementation Audio

- (AVAudioSession *)audioSession
{
    if (!_audioSession) {
        _audioSession = [AVAudioSession sharedInstance];
    }
    return _audioSession;
}

- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSError *error;
        NSURL *mp3URL = [NSURL URLWithString:@"http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3"];
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
        return;
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
    self.audioPlayer.numberOfLoops = -1;
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
                [self playAudio];
                if (error) NSLog(@"ERROR? : %@", error);
                NSLog(@"audio SHOULD RESUME!");
            }
            break;
        
        default:
            break;
    }
}

@end
