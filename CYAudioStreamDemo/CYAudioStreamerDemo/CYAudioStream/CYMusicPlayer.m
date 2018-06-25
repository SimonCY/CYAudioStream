//
//  CYMusicPlayer.m
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/22.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import "CYMusicPlayer.h"

static id _instance;

@implementation CYMusicPlayer

@synthesize playList = _playList;

#pragma mark - single

+ (instancetype)sharedPlayer {
    
    if (_instance == nil) { // 防止频繁加锁
        
        @synchronized(self) {
            
            if (_instance == nil) { // 防止创建多次
                
                _instance = [[self alloc] init];
            }
        }
    }
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    if (_instance == nil) { // 防止频繁加锁
        
        @synchronized(self) {
            
            if (_instance == nil) { // 防止创建多次
                
                _instance = [super allocWithZone:zone];
            }
        }
    }
    return _instance;
}

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {

        _playList = [NSMutableArray array];
        
        self.remoteControlObserver = [CYRemoteControlObserver sharedObverser];
        
        self.audioStream = [CYAudioStream sharedStream];

    }
    return self;
}

#pragma mark - getter

- (CYAudioStreamModel *)currentModel {
    
    return self.audioStream.currentModel;
}

- (NSInteger)currentIndex {
    
    if ([self.playList containsObject:self.audioStream.currentModel]) {
        
        return [self.playList indexOfObject:self.audioStream.currentModel];
    }
    return 0;
}
 
#pragma mark - public

- (void)addModelToPlayList:(CYAudioStreamModel *)model {
    
    @synchronized(self) {
 
        [_playList addObject:model];
    }
}

- (void)insertModel:(CYAudioStreamModel *)model toPlayListAtIndex:(NSInteger)index{
    
    @synchronized(self) {
        
        if (index < 0 || index >= _playList.count) {
            
            return NSLog(@"CYMusicPlayer inset model to playlist at index %ld, bounds [0 - %ld]",(long)index,_playList.count);
        }
        
        [_playList insertObject:model atIndex:index];
    }
}

- (void)removeModelFromPlayList:(CYAudioStreamModel *)model {
    

    @synchronized(self) {
        
        if ([self.audioStream.currentModel isEqual:model]) {
            
            [self stop];
        }
        
        if ([_playList containsObject:model]) {
            
            [_playList removeObject:model];
        }
    }
}

- (void)removeModelFromPlayListAtIndex:(NSInteger)index {
    
    @synchronized(self) {
        
        CYAudioStreamModel *model = _playList[index];
        [self removeModelFromPlayList:model];
    }
}

- (void)removeAllModelsFromPlayList {
    
    [self stop];
    
    @synchronized(self) {
        
        [_playList removeAllObjects];
    }
}

- (void)playModelAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= _playList.count) {
        
        NSLog(@"CYMusicPlayer inset model to playlist at index %ld, bounds [0 - %ld]",index,_playList.count);
        return;
    }
    
    CYAudioStreamModel *model = _playList[index];
    self.audioStream.currentModel = model;
    [self play];
}


- (void)play {
    
    if (!self.playList.count) {
        
        NSLog(@"CYMusicPlayer play failed, playList is nil");
        return;
    }
    
    if (self.audioStream.isPaused) {
        
        [self.audioStream pause];
    } else {
        
        
        if (!self.audioStream.currentModel) {
            
            self.audioStream.currentModel = _playList.firstObject;
        }
        
        [self.audioStream play];
    }
}


- (void)pause {
    
    if (self.audioStream.isPlaying) {
        
        [self.audioStream pause];
    }
    
}

- (void)stop {
 
    [self.audioStream reset];
}

- (void)next {
    
    if (!self.currentModel) return;
    
    NSInteger currentIndex = [_playList indexOfObject:self.audioStream.currentModel];
    
    NSInteger totalCount = _playList.count;
    
    NSInteger nextIndex = 0;
 
    switch (self.loopMode) {
        case CYMusicPlayerLoopModeCycle:
        case CYMusicPlayerLoopModeSingle:
            
            nextIndex = currentIndex + 1;
            
            while (nextIndex > (totalCount - 1)) {
                
                nextIndex -= totalCount;
            }

            break;
        case CYMusicPlayerLoopModeRandom:
            
            while (currentIndex == nextIndex) {
                
                nextIndex = arc4random_uniform((int)totalCount);
            }
            
            break;
            
        default:
            break;
    }
    
    self.audioStream.currentModel = _playList[nextIndex];
    
    [self  play];
}

- (void)previous {
    
    if (!self.currentModel) return;
    
    NSInteger currentIndex = [_playList indexOfObject:self.audioStream.currentModel];
    
    NSInteger totalCount = _playList.count;
    
    NSInteger previousIndex = 0;
    
    
    switch (self.loopMode) {
        case CYMusicPlayerLoopModeCycle:
        case CYMusicPlayerLoopModeSingle:
            
            previousIndex = currentIndex - 1;
            
            while (previousIndex < 0) {
                
                previousIndex += totalCount;
            }
            
            break;
        case CYMusicPlayerLoopModeRandom:
            
            while (currentIndex == previousIndex) {
                
                previousIndex = arc4random_uniform((int)totalCount);
            }
            
            break;
            
        default:
            break;
    }
    
    self.audioStream.currentModel = _playList[previousIndex];
    
    [self  play];
}

@end
