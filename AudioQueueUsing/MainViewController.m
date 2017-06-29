//
//  MainViewController.m
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "MainViewController.h"
#import "AudioRecord.h"

@interface MainViewController ()

@property (nonatomic, strong) AudioRecord *audioRecord;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    startButton.backgroundColor=[UIColor grayColor];
    [startButton addTarget:self action:@selector(startButtonTouchHandler) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.view addSubview:startButton];

    UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 30)];
    stopButton.backgroundColor = [UIColor grayColor];
    [stopButton addTarget:self action:@selector(stopButtonTouchHandler) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    
    
    
}

- (void)startButtonTouchHandler {

    self.audioRecord = [[AudioRecord alloc] init];

    [self.audioRecord start];
}

- (void)stopButtonTouchHandler {
}

@end
