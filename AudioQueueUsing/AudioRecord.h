//
//  AudioRecord.h
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// use Audio Queue

// Audio Settings
#define kNumberBuffers      3

#define t_sample             SInt16

#define kSamplingRate 48000
#define kNumberChannels     1
#define kBitsPerChannels    (sizeof(t_sample) * 8)
#define kBytesPerFrame (kNumberChannels * sizeof(t_sample))
#define kFrameSize 960

typedef struct AQCallbackStruct {
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
} AQCallbackStruct;

@interface AudioRecord : NSObject

@property (nonatomic, assign) AQCallbackStruct aqc;

-(void)start;

-(void)stop;

- (void)pause;

- (void)processAudioBuffer:(AudioQueueBufferRef)buffer withQueue:(AudioQueueRef)queue;

@end
