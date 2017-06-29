//
//  KCLOpusCodec.h
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int32_t, KCLOpusSampleRate) {
    KCLOpusSampleRate_8000 = 8000,
    KCLOpusSampleRate_12000 = 12000,
    KCLOpusSampleRate_16000 = 16000,
    KCLOpusSampleRate_24000 = 24000,
    KCLOpusSampleRate_48000 = 48000,
};

typedef NS_ENUM(int, KCLOpusChannels) {
    KCLOpusChannelsMono = 1,
    KCLOpusChannelsStereo = 2,
};

@interface KCLOpusCodec : NSObject

@property (nonatomic, readonly) KCLOpusSampleRate sampleRate;
@property (nonatomic, readonly) KCLOpusChannels numberOfChannels;
@property (nonatomic, readonly) int frameSize;

- (id)initWithSampleRate:(KCLOpusSampleRate)sampleRate numberOfChannels:(KCLOpusChannels)channels frameSize:(int)frameSize;

- (NSError *)errorForOpusErrorCode:(int)errorCode details:(NSString *)details;

@end
