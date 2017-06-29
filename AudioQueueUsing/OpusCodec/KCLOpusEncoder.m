//
//  KCLOpusEncoder.m
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLOpusEncoder.h"
#import <opus/opus.h>
#import "KCLDataWriter.h"

@interface KCLOpusEncoder ()

@end

@implementation KCLOpusEncoder {
    OpusEncoder *encoder;

    unsigned char encode_out_buffer[1024 * 1024 * 2];

    opus_int32 max_data_bytes;
}

- (id)initWithSampleRate:(KCLOpusSampleRate)sampleRate numberOfChannels:(KCLOpusChannels)channels frameSize:(int)frameSize {
    self = [super initWithSampleRate:sampleRate numberOfChannels:channels frameSize:frameSize];
    if (self) {
        max_data_bytes = (frameSize << 1);
    }
    return self;
}

- (BOOL)setupOpusEncoderWithError:(NSError *__autoreleasing *)setupError {
    if (encoder) {
        return YES;
    }

    int opusError = OPUS_OK;
    int Fs = self.sampleRate; //采样率
    int channels = self.numberOfChannels;

    opus_int32 bitrate_bps = 64000;

    int complexity = 1; //录制质量 1-10

    encoder = opus_encoder_create(Fs, channels, OPUS_APPLICATION_VOIP, &opusError);
    if (opusError != OPUS_OK) {
        *setupError = [self errorForOpusErrorCode:opusError details:nil];
        return NO;
    }

    opus_encoder_ctl(encoder, OPUS_SET_BANDWIDTH(OPUS_BANDWIDTH_WIDEBAND));

    opus_encoder_ctl(encoder, OPUS_SET_BITRATE(bitrate_bps));

    opus_encoder_ctl(encoder, OPUS_SET_VBR(1));

    opus_encoder_ctl(encoder, OPUS_SET_COMPLEXITY(complexity));

    opus_encoder_ctl(encoder, OPUS_SET_INBAND_FEC(0));

    opus_encoder_ctl(encoder, OPUS_SET_FORCE_CHANNELS(OPUS_AUTO));

    opus_encoder_ctl(encoder, OPUS_SET_DTX(0));

    opus_encoder_ctl(encoder, OPUS_SET_LSB_DEPTH(16));

    return YES;
}

- (NSData *)encodePCMData:(NSData *)pcmData {
    //    opus frame datas
    //    unsigned char *output = encode_out_buffer;
    //    int returnValue = opus_encode(encoder, [pcmData bytes], self.frameSize, output+1, max_data_bytes);
    //    if (returnValue < 0) {
    //        return nil;
    //    }
    //    output[0] = returnValue;
    //    int outputlen = returnValue + 1;
    //    NSData *opusFrameData = [[NSData alloc] initWithBytes:output length:outputlen];
    //    return opusFrameData;

    // 纯opus datas
    unsigned char *output = encode_out_buffer;
    int returnValue = opus_encode(encoder, [pcmData bytes], self.frameSize, output, max_data_bytes);
    if (returnValue < 0) {
        return nil;
    }
    NSData *opusFrameData = [[NSData alloc] initWithBytes:output length:returnValue];
    return opusFrameData;
}

- (void)dealloc {
    if (encoder) {
        opus_encoder_destroy(encoder);
    }
}

@end
