//
//  KCLOpusDecoder.m
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLOpusDecoder.h"
#import <opus/opus.h>

@interface KCLOpusDecoder ()


@end

@implementation KCLOpusDecoder {
    OpusDecoder *decoder;

    opus_int16 *outputBuffer;

    NSUInteger decoderBufferLength;
}

- (id)initWithSampleRate:(KCLOpusSampleRate)sampleRate numberOfChannels:(KCLOpusChannels)channels frameSize:(int)frameSize {
    self = [super initWithSampleRate:sampleRate numberOfChannels:channels frameSize:frameSize];
    if (self) {
        decoderBufferLength = frameSize * self.numberOfChannels * sizeof(opus_int16);
        outputBuffer = malloc(decoderBufferLength);
    }
    return self;
}

- (BOOL)setupOpusDecoderWithError:(NSError *__autoreleasing *)error {
    if (decoder) {
        return YES;
    }
    int opusError = OPUS_OK;
    decoder = opus_decoder_create(self.sampleRate, self.numberOfChannels, &opusError);
    if (opusError != OPUS_OK) {
        *error = [self errorForOpusErrorCode:opusError details:nil];
        return NO;
    }
    return YES;
}

- (NSData *)decodeOpusData:(NSData *)data {
    int returnValue = opus_decode(decoder, [data bytes], data.length, outputBuffer, self.frameSize, 0);
    if (returnValue < 0) {
        return nil;
    }
    NSUInteger length = returnValue * sizeof(opus_int16) * self.numberOfChannels;
    NSData *pcmData = [NSData dataWithBytes:outputBuffer length:length];
    return pcmData;
}

- (void)dealloc {
    if (decoder) {
        opus_decoder_destroy(decoder);
    }
    if (outputBuffer) {
        free(outputBuffer);
    }
}

@end
