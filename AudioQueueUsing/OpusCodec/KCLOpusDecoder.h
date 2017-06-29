//
//  KCLOpusDecoder.h
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLOpusCodec.h"

@interface KCLOpusDecoder : KCLOpusCodec

- (BOOL)setupOpusDecoderWithError:(NSError *__autoreleasing *)error;

- (NSData *)decodeOpusData:(NSData *)data;

@end
