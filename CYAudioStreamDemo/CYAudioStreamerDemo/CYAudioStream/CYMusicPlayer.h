//
//  CYMusicPlayer.h
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/22.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYAudioStream.h"
#import "CYRemoteControlObserver.h"
#import "CYAudioStreamModel.h"

typedef NS_ENUM(NSUInteger, CYMusicPlayerLoopMode) {
    CYMusicPlayerLoopModeCycle,
    CYMusicPlayerLoopModeSingle,
    CYMusicPlayerLoopModeRandom,
};

@class CYMusicPlayer;

@protocol CYMusicPlayerDelegate <NSObject>

@optional

- (void)CYMusicPlayer:(CYMusicPlayer *)player didSwitchToModel:(CYAudioStreamModel *)model;
 
@end


/** 基于CYAudioStreamer，在CYAudioStreamer的基础上做一些 列表播放 业务的管理 */
@interface CYMusicPlayer : NSObject

@property (nonatomic, weak) id<CYMusicPlayerDelegate> delegate;

@property (nonatomic, strong) CYAudioStream *audioStream;

@property (nonatomic, strong) CYRemoteControlObserver *remoteControlObserver;

@property (nonatomic, strong, readonly) CYAudioStreamModel *currentModel;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

/** default is cycle */
@property (nonatomic, assign) CYMusicPlayerLoopMode loopMode;

@property (nonatomic, strong, readonly) NSMutableArray <CYAudioStreamModel *>*playList;

- (void)addModelToPlayList:(CYAudioStreamModel *)model;
- (void)insertModel:(CYAudioStreamModel *)model toPlayListAtIndex:(NSInteger)index;
- (void)removeModelFromPlayList:(CYAudioStreamModel *)model;
- (void)removeModelFromPlayListAtIndex:(NSInteger)index;
- (void)removeAllModelsFromPlayList;


+ (instancetype)sharedPlayer;

/** if there is not a current model, default play music at index 0 in playlist */
- (void)play;

- (void)playModelAtIndex:(NSInteger)index;

/** pause状态下，调用 play 方法以继续播放 */
- (void)pause;

/** stop playing and set the currentModel to nil */
- (void)stop;

- (void)next;

- (void)previous;


@end
