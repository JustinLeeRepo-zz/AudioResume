//
//  ViewController.m
//  AudioResume
//
//  Created by Justin Lee on 7/8/16.
//  Copyright © 2016 AppLovin. All rights reserved.
//

#import "ViewController.h"
#import "Audio.h"

@interface ViewController ()

@property (nonatomic, strong) Audio *audio;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audio = [[Audio alloc] init];
    [self.audio playAudio];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
