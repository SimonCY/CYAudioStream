//
//  CYAudioStreamer.m
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/13.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import "CYAudioStream.h"
#import <FreeStreamer/FreeStreamer.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CYAudioStreamModel.h"
#import "CYRemoteControlObserver.h"
#import "CYMusicPlayer.h"

#define cy_WEAKSELF __weak __typeof(&*self)weakSelf = self;
#define cy_STRONGSELF __strong __typeof(&*self) strongSelf = strongSelf;



@interface CYAudioStream ()
 
@property (nonatomic, strong) FSAudioStream *audioStream;
 
@property (nonatomic, strong) CADisplayLink *timer;

@end


static id _instance;


@implementation CYAudioStream

@synthesize position = _position;

#pragma mark - single

+ (instancetype)sharedStream {
 
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

- (void)dealloc {
 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    
    if (self = [super init]) {
 
        cy_WEAKSELF
        [CYRemoteControlObserver sharedObverser];
        
        self.audioStream = [[FSAudioStream alloc] init];
        self.audioStream.onStateChange = ^(FSAudioStreamState state) {
          
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CYAudioStream:stateDidChange:)]) {
                
                [weakSelf.delegate CYAudioStream:weakSelf stateDidChange:(CYAudioStreamState)state];
            }
            NSLog(@"CYAudioStream 状态改变%d",(int)state);
            
            switch (state) {
                case kFsAudioStreamRetrievingURL:
                    
                    _paused = NO;
                    [weakSelf startTimer];
                    break;
                case kFsAudioStreamStopped:
                    
                    _paused = NO;
                    [weakSelf stopTimer];
                    break;
                case kFsAudioStreamBuffering:
                    
                    _buffering = YES;
                    [weakSelf startTimer];
                    break;
                case kFsAudioStreamPlaying:
                    
                    _paused = NO;
                    [weakSelf startTimer];
                    break;
                case kFsAudioStreamPaused:
                    
                    _paused = YES;
                    break;
                case kFsAudioStreamSeeking:
                    
                    _paused = NO;
                    
                    break;
                case kFSAudioStreamEndOfFile:
                    
                    _buffering = NO;
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CYAudioStream:bufferProgressDidChange:)]) {
     
                            [weakSelf.delegate CYAudioStream:weakSelf bufferProgressDidChange:1];//缓存进度
                    }
                    
                    break;
                case kFsAudioStreamFailed:
                    
                    [weakSelf stopTimer];
                    break;
                case kFsAudioStreamRetryingStarted:
                    
                    [weakSelf startTimer];
                    break;
                case kFsAudioStreamRetryingSucceeded:
                    
                    [weakSelf startTimer];
                    break;
                case kFsAudioStreamRetryingFailed:
                    
                    [weakSelf stopTimer];
                    break;
                case kFsAudioStreamPlaybackCompleted:
                    
                    [weakSelf stopTimer];
                    break;
                case kFsAudioStreamUnknownState:
                    
                    [weakSelf stopTimer];
                    break;
                    
                default:
                    break;
            }

        };
        self.audioStream.onMetaDataAvailable = ^(NSDictionary *metaData) {
//            NSMutableString *streamInfo = [[NSMutableString alloc] init];
//            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            
//            if (metaData[@"MPMediaItemPropertyTitle"]) {
//                songInfo[MPMediaItemPropertyTitle] = metaData[@"MPMediaItemPropertyTitle"];
//            } else if (metaData[@"StreamTitle"]) {
//                songInfo[MPMediaItemPropertyTitle] = metaData[@"StreamTitle"];
//            }
//
//            if (metaData[@"MPMediaItemPropertyArtist"]) {
//                songInfo[MPMediaItemPropertyArtist] = metaData[@"MPMediaItemPropertyArtist"];
//            }
//
//            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
//
//            if (metaData[@"MPMediaItemPropertyArtist"] &&
//                metaData[@"MPMediaItemPropertyTitle"]) {
//                [streamInfo appendString:metaData[@"MPMediaItemPropertyArtist"]];
//                [streamInfo appendString:@" - "];
//                [streamInfo appendString:metaData[@"MPMediaItemPropertyTitle"]];
//            } else if (metaData[@"StreamTitle"]) {
//                [streamInfo appendString:metaData[@"StreamTitle"]];
//            }
//
//
//            if (metaData[@"CoverArt"]) {
//                NSData *data = [[NSData alloc] initWithBase64EncodedString:metaData[@"CoverArt"] options:0];
//            }
            
            NSLog(@"CYAudioStreamer meta:%@",metaData);
        };
        self.audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CYAudioStreamPlayingDidFailed:)]) {
                
                [weakSelf.delegate CYAudioStreamPlayingDidFailed:weakSelf];
            }
            NSLog(@"CYAudioStream 播放出现问题%@",description);
        };
        self.audioStream.onCompletion=^(){
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CYAudioStreamPlayingDidCompleted:)]) {
                [weakSelf.delegate CYAudioStreamPlayingDidCompleted:weakSelf];
            }
            
            //在这偷了点懒，没有用代理做事件的传递，而是直接在这里处理的player中的业务
            if ([CYMusicPlayer sharedPlayer].loopMode != CYMusicPlayerLoopModeSingle) {
                
                [[CYMusicPlayer sharedPlayer] next];
            } else {
                
                [weakSelf play];
            }
            NSLog(@"CYAudioStream 播放完成");
        };
 
        //default data
        self.playRate = 1.f;
        self.volume = 1.f;
    }
    return self;
}

#pragma mark - setter

- (void)setPosition:(CYAudioStreamPosition)position {
    
    if (!self.currentModel) {
        
        return;
    }
    _position = position;
    
    NSInteger seconds = position.playbackTimeInSeconds;
    if (seconds <= 0) {
        
        seconds = 0;
    }
    FSStreamPosition fs_position = {};
    fs_position.playbackTimeInSeconds = seconds;
    [_audioStream seekToPosition:fs_position];
}

- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    
    _audioStream.volume = volume;
}

- (void)setPlayRate:(CGFloat)playRate {
    _playRate = playRate;

    [_audioStream setPlayRate:playRate];
}

- (void)setCurrentModel:(CYAudioStreamModel *)currentModel {
    
    if ([_currentModel isEqual:currentModel]) {
        
        return;
    }
    [self reset];
 
    _currentModel = currentModel;
    
    _audioStream.url = [NSURL URLWithString:currentModel.sourceUrl];
 
//    if (_currentModel) {
    //在这偷了点懒，没有用代理做事件的传递，而是直接在这里处理的player中的业务
    if ([CYMusicPlayer sharedPlayer].delegate && [[CYMusicPlayer sharedPlayer].delegate respondsToSelector:@selector(CYMusicPlayer:didSwitchToModel:)]) {
        
        [[CYMusicPlayer sharedPlayer].delegate CYMusicPlayer:[CYMusicPlayer sharedPlayer] didSwitchToModel:[CYMusicPlayer sharedPlayer].audioStream.currentModel];
    }
//    }
}


#pragma mark - getter

- (BOOL)isPlaying {
 
    return self.audioStream.isPlaying;
}

- (CYAudioStreamPosition)duration {

    CYAudioStreamPosition duration = {};
    FSStreamPosition fs_duration= self.audioStream.duration;
    duration.minute = fs_duration.minute;
    duration.second = fs_duration.second;
    duration.playbackTimeInSeconds = fs_duration.playbackTimeInSeconds;
    duration.progress = fs_duration.position;
    return duration;
}

- (CYAudioStreamPosition)position {
    
    CYAudioStreamPosition position = {};
    FSStreamPosition fs_position= self.audioStream.currentTimePlayed;
    position.minute = fs_position.minute;
    position.second = fs_position.second;
    position.playbackTimeInSeconds = fs_position.playbackTimeInSeconds;
    position.progress = fs_position.position;
    return position;
}
#pragma mark - timer

- (void)startTimer {
    
    if (self.timer) return;

    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerEvent)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    
    if (self.timer) {
        
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerEvent {
    
    //播放进度
    if (self.isPlaying) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(CYAudioStream:playPositionDidChange:)]) {
            
            [self.delegate CYAudioStream:self playPositionDidChange:self.position];
        }
    }
    
 
    //缓冲进度
    if (self.isBuffering) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(CYAudioStream:bufferProgressDidChange:)]) {
            
            float  prebuffer = (float)self.audioStream.prebufferedByteCount;
            float contentlength = (float)self.audioStream.contentLength;
            if (contentlength>0) {
                
                [self.delegate CYAudioStream:self bufferProgressDidChange:prebuffer /contentlength];//缓存进度
            }
        }
    }
    
    [self updatePlayingInfoWithStoped:NO];
}

#pragma mark - public

- (void)playWithModel:(CYAudioStreamModel *)model {
    
    self.currentModel = model;
    
    [self play];
}

- (void)play {
 
    [self clearAllCachesWithCompletion:^(NSError *error) {
        
        if (error) {
            
            NSLog(@"error is %@",error.userInfo);
        } else {
            
            NSLog(@"cache cleared");
        }
    }];
    
    if (!self.currentModel.sourceUrl.length) {
        
        NSLog(@"CYAudioStream haven`t a correct source url");
        return;
    }
    
    if (self.isPlaying) {
        
        return;
    }
    
    [_audioStream play];
}

- (void)pause {
    
    if (self.audioStream.isPlaying) {
        
        [self.audioStream pause];
    } else if (self.isPaused) {
        
        [self.audioStream pause];
    }
}

- (void)stop {
    
    [self stopTimer];
    [self updatePlayingInfoWithStoped:YES];
    [self.audioStream stop];
}

- (void)reset {
    
    [self stop];
 
    _paused = NO;
    _buffering = NO;
    _audioStream.url = nil;
    _currentModel = nil;
}
 
- (void)clearAllCachesWithCompletion:(CYAudioStreamerCompletionBlock)completion {
 
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.audioStream.configuration.cacheDirectory error:nil];
        NSError *error = nil;
        for (NSString *file in arr) {
            
            if ([file hasPrefix:@"FSCache-"]) {
                
                NSString *path = [NSString stringWithFormat:@"%@/%@",self.audioStream.configuration.cacheDirectory, file];
                BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                if (result == NO) {
                    
                    error = [NSError errorWithDomain:NSPOSIXErrorDomain code:901 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"CYAudioStreamer remove file error, filePath:%@",path] forKey:NSLocalizedDescriptionKey]];
                    
                }
            }
        }
        if (completion) completion(error);
    });
}

// 系统自带API解析MP3时长
- (CGFloat)getMusicTimeWithSourceUrl:(NSURL *)sourceUrl {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:sourceUrl options:nil];
    // 获取音频总时长
    CGFloat time = asset.duration.value / asset.duration.timescale;
    return time;
}

- (void)updatePlayingInfoWithStoped:(BOOL)isStoped {
 
    if (!isStoped && self.currentModel) {
        
        NSMutableDictionary *musicInfoDict = [[NSMutableDictionary alloc] init];
        //设置歌曲题目
        [musicInfoDict setObject:self.currentModel.title forKey:MPMediaItemPropertyTitle];
        //设置歌手名
        [musicInfoDict setObject:@"" forKey:MPMediaItemPropertyArtist];
        //设置专辑名
        [musicInfoDict setObject:@"" forKey:MPMediaItemPropertyAlbumTitle];
        //设置艺术照
        if (self.currentModel.thumbImage) {
            
            MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage:self.currentModel.thumbImage];
            [musicInfoDict setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        } else {
            
            MPMediaItemArtwork *albumArt = [ [MPMediaItemArtwork alloc] initWithImage:[UIImage new]];
            [musicInfoDict setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        }
        //设置歌曲时长
        [musicInfoDict setObject:[NSNumber numberWithFloat:self.duration.playbackTimeInSeconds] forKey:MPMediaItemPropertyPlaybackDuration];
        
        //设置已经播放时长
        [musicInfoDict setObject:[NSNumber numberWithFloat:self.position.playbackTimeInSeconds]
                          forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:musicInfoDict];
    } else {
     
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    }
}


@end
