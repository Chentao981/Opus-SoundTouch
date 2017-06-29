//
//  KCLOpusEncoder.h
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLOpusCodec.h"

@interface KCLOpusEncoder : KCLOpusCodec

- (BOOL)setupOpusEncoderWithError:(NSError *__autoreleasing *)error;

- (NSData *)encodePCMData:(NSData *)data;

@end
