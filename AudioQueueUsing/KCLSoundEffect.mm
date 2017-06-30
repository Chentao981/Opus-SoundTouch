//
//  KCLSoundEffect.m
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/30.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLSoundEffect.h"
#import <SoundTouch/SoundTouch.h>

using namespace soundtouch;

@implementation KCLSoundEffectOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sampleRate = 48000;
        self.channels = 1;
        self.tempo = 1;
        self.pitch = 0;
        self.rate = 1;
    }
    return self;
}

@end

@interface KCLSoundEffect ()
@end

@implementation KCLSoundEffect {
    soundtouch::SoundTouch mSoundTouch;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        KCLSoundEffectOption *defaultOption = [[KCLSoundEffectOption alloc] init];
        self.effectOption = defaultOption;

        mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
        mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
        mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);     //重叠帧长
    }
    return self;
}

-(void)setEffectOption:(KCLSoundEffectOption *)effectOption{
    _effectOption=effectOption;
    mSoundTouch.setSampleRate(_effectOption.sampleRate); // setSampleRate
    mSoundTouch.setChannels(_effectOption.channels);     //设置声音的声道
    mSoundTouch.setTempo(_effectOption.tempo);           //这个就是传说中的变速不变调
    mSoundTouch.setPitchSemiTones(_effectOption.pitch);  //设置声音的pitch (集音高变化semi-tones相比原来的音调) //男: -8 女:8
    mSoundTouch.setRate(_effectOption.rate);             //设置声音的速率
}


-(NSData *)addEffectToPCMData:(NSData *)audioData{
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
            numSamples = mSoundTouch.receiveSamples(samples, pcmSize);
            [soundTouchDatas appendBytes:samples length:numSamples * 2];
        } while (numSamples > 0);
        delete[] samples;
    }
    return soundTouchDatas;
}


@end
