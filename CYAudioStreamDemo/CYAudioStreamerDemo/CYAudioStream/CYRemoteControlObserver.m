//
//  CYRemoteControlOvserver.m
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/22.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import "CYRemoteControlObserver.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CYAudioStream.h"
#import "CYMusicPlayer.h"


@implementation CYRemoteControlObserver

static id _instance;

#pragma mark - single

+ (instancetype)sharedObverser {
    
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

#pragma mark - system

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self setupAudioSession];
    }
    return self;
}

#pragma mark - pravite


- (void)setupAudioSession {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //    [session setActive:YES error:nil];
    NSError *err;
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    
    NSLog(@"error is %@",err);
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    //加这个是为了第一次没更新playingInfo的问题
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:self action:@selector(a)];
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTarget:self action:@selector(a)];
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTarget:self action:@selector(a)];
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:self action:@selector(a)];
    [[MPRemoteCommandCenter sharedCommandCenter].stopCommand addTarget:self action:@selector(a)];
}

- (void)a {}

#pragma mark - public
 
- (BOOL)isHeadsetPluggedIn {
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                
                [[CYMusicPlayer sharedPlayer] pause];
                break;
            case UIEventSubtypeRemoteControlPlay:
                
                if ([CYMusicPlayer sharedPlayer].audioStream.isPaused) {
                    
                    [[CYMusicPlayer sharedPlayer] pause];
                } else {
                    
                    [[CYMusicPlayer sharedPlayer] play];
                }
                break;
            case UIEventSubtypeRemoteControlStop:
                
                [[CYMusicPlayer sharedPlayer] stop];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                
                [[CYMusicPlayer sharedPlayer] pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                
                [[CYMusicPlayer sharedPlayer] next];
                
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                [[CYMusicPlayer sharedPlayer] previous];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Notification event

/**
 *  耳机状态、设备音频会话类型变化的回调
 *  注意此方法并非在主线程回调
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            tipWithMessage(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            tipWithMessage(@"耳机拔出，停止播放操作");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([CYMusicPlayer sharedPlayer].audioStream.isPlaying) {
                    
                    [[CYMusicPlayer sharedPlayer] pause];
                }
            });
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            tipWithMessage(@"AVAudioSessionRouteChangeReasonCategoryChange");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[CYMusicPlayer sharedPlayer] pause];
            });
            
            break;
            
        default:
            break;
    }
}

/** 播放被打断 */
- (void)audioSessionInterrupted:(NSNotification *)notificaiton {
    
    AVAudioSessionInterruptionType type = [notificaiton.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
        if ([CYMusicPlayer sharedPlayer].audioStream.isPlaying) {
            
            [[CYMusicPlayer sharedPlayer] pause];
        }
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        
        if ([CYMusicPlayer sharedPlayer].audioStream.isPaused) {
            
            [[CYMusicPlayer sharedPlayer] pause];
        }
    }
}

//自定提醒窗口
NS_INLINE void tipWithMessage(NSString *message){
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"%@",message);
    });
    
    
}

@end
 
