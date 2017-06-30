//
//  KCLSoundEffect.h
//  AudioQueueUsing
//
//  Created by Chentao on 2017/6/30.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCLSoundEffectOption : NSObject

/**
 * 速度 默认值是:1 次参数只会改变速度不会改变音调
 **/
@property (nonatomic, assign) float tempo;

/**
 * 音调 默认值是:0 (集音高变化semi-tones相比原来的音调) 男: -8 女:8
 **/
@property (nonatomic, assign) int pitch;

/**
 * 速率 默认值是:0.0 设置声音的速率
 **/
@property (nonatomic, assign) float rate;

/**
 * 采样率
 */
@property (nonatomic, assign) uint sampleRate;

/**
 * 声道
 */
@property (nonatomic, assign) uint channels;

@end


@interface KCLSoundEffect : NSObject

@property(nonatomic,strong)KCLSoundEffectOption *effectOption;

- (NSData *)addEffectToPCMData:(NSData *)pcmData;

@end
