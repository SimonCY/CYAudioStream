//
//  CYRemoteControlOvserver.h
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/22.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CYRemoteControlObserver : NSObject

+ (instancetype)sharedObverser;

/** 耳机是否插入 */
- (BOOL)isHeadsetPluggedIn;


/** 处理远程控制事件 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;


@end


 
