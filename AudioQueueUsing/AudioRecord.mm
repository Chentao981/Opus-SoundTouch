//
//  AudioRecord.m
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "AudioRecord.h"
#import "KCLDataWriter.h"
#import "KCLFileManager.h"
#import "KCLOpusEncoder.h"
#import "KCLOpusDecoder.h"
#import <SoundTouch/SoundTouch.h>

using namespace soundtouch;

@interface AudioRecord ()

@property (nonatomic, strong) NSFileHandle *pcmFileHandler;

@property (nonatomic, strong) KCLOpusEncoder *opusEncoder;
@property (nonatomic, strong) KCLOpusDecoder *opusDecoder;

@end

@implementation AudioRecord {

    soundtouch::SoundTouch mSoundTouch;
}

@synthesize aqc;

static void AQInputCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, unsigned long inNumPackets, const AudioStreamPacketDescription *inPacketDesc) {

    AudioRecord *engine = (__bridge AudioRecord *)inUserData;
    if (inNumPackets > 0) {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }

    if (engine.aqc.run) {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *filePath = [[[KCLFileManager documentsDir] stringByAppendingPathComponent:@"test"] stringByAppendingPathExtension:@"pcm"];
        [KCLFileManager createFileAtPath:filePath];
        self.pcmFileHandler = [NSFileHandle fileHandleForWritingAtPath:filePath];

        aqc.mDataFormat.mSampleRate = kSamplingRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;

        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;

        aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;

        aqc.frameSize = kFrameSize;

        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void *_Nullable)(self), NULL, kCFRunLoopCommonModes, 0, &aqc.queue);

        for (int i = 0; i < kNumberBuffers; i++) {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }

        aqc.recPtr = 0;
        aqc.run = 1;

        self.opusEncoder = [[KCLOpusEncoder alloc] initWithSampleRate:KCLOpusSampleRate_48000 numberOfChannels:KCLOpusChannelsMono frameSize:480];
        [self.opusEncoder setupOpusEncoderWithError:nil];

        self.opusDecoder = [[KCLOpusDecoder alloc] initWithSampleRate:KCLOpusSampleRate_48000 numberOfChannels:KCLOpusChannelsMono frameSize:480];
        [self.opusDecoder setupOpusDecoderWithError:nil];

        mSoundTouch.setSampleRate(kSamplingRate); // setSampleRate
        mSoundTouch.setChannels(1);               //设置声音的声道
        mSoundTouch.setTempoChange(100);          //这个就是传说中的变速不变调
        mSoundTouch.setPitchSemiTones(0);         //设置声音的pitch (集音高变化semi-tones相比原来的音调) //男: -8 女:8
        mSoundTouch.setRateChange(0);             //设置声音的速率
        mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
        mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
        mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);     //重叠帧长
    }
    return self;
}

- (void)dealloc {
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void)start {
    int status = AudioQueueStart(aqc.queue, NULL);
    NSLog(@"AudioQueueStart = %d", status);
}

- (void)stop {
    AudioQueueStop(aqc.queue, true);
}

- (void)pause {
    AudioQueuePause(aqc.queue);
}

- (void)processAudioBuffer:(AudioQueueBufferRef)buffer withQueue:(AudioQueueRef)queue {
    @autoreleasepool {
        long size = buffer->mAudioDataByteSize / aqc.mDataFormat.mBytesPerPacket;
        t_sample *data = (t_sample *)buffer->mAudioData;

        //////////////////////////
        KCLDataWriter *dataWriter = [[KCLDataWriter alloc] initWithData:[[NSMutableData alloc] init]];

        for (long i = 0; i < size; i++) {
            [dataWriter writeInt16:data[i]];
        }

        // PCM编码为Opus
        NSData *opusData = [self.opusEncoder encodePCMData:dataWriter.data];

        // Opus解码为PCM
        NSData *pcmData = [self.opusDecoder decodeOpusData:opusData];
        
        /////////////////////////
        NSData *audioData = pcmData;

        NSMutableData *soundTouchDatas = [[NSMutableData alloc] init];
        if (audioData != nil) {
            char *pcmData = (char *)audioData.bytes;
            int pcmSize = audioData.length;
            int nSamples = pcmSize / 2;
            mSoundTouch.putSamples((short *)pcmData, nSamples);
            short *samples = new short[pcmSize];
            int numSamples = 0;
            do {
                memset(samples, 0, pcmSize);
                // short samples[nSamples];
                numSamples = mSoundTouch.receiveSamples(samples, pcmSize);

                NSLog(@"numSamples:%d", numSamples);

                [soundTouchDatas appendBytes:samples length:numSamples * 2];

            } while (numSamples > 0);
            delete[] samples;
        }

        /////////////////////////
        [self.pcmFileHandler writeData:soundTouchDatas];
        
        
    }
}
@end
