//
//  CYAudioStreamer.h
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/13.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYAudioStream,CYAudioStreamModel;

typedef void(^CYAudioStreamerCompletionBlock)(NSError *error);

typedef struct {
    unsigned minute;
    unsigned second;
    
    /** Playback time in seconds. */
    float playbackTimeInSeconds;
    
    /**
     * Position within the stream, where 0 is the beginning
     * and 1.0 is the end.
     */
    float progress;
} CYAudioStreamPosition;



typedef NS_ENUM(NSInteger, CYAudioStreamState) {
 
    CYAudioStreamRetrievingURL,
    CYAudioStreamStopped,
    CYAudioStreamBuffering,
    CYAudioStreamPlaying,
    CYAudioStreamPaused,
    CYAudioStreamSeeking,
    CYAudioStreamEndOfFile,
    CYAudioStreamFailed,
    CYAudioStreamRetryingStarted,
    CYAudioStreamRetryingSucceeded,
    CYAudioStreamRetryingFailed,
    CYAudioStreamPlaybackCompleted,
    CYAudioStreamUnknownState
};


@protocol CYAudioStreamDelegate <NSObject>

@optional

- (void)CYAudioStreamPlayingDidCompleted:(CYAudioStream *)audioStream;

- (void)CYAudioStreamPlayingDidFailed:(CYAudioStream *)audioStream;
 
- (void)CYAudioStream:(CYAudioStream *)audioStream playPositionDidChange:(CYAudioStreamPosition)position;

- (void)CYAudioStream:(CYAudioStream *)audioStream bufferProgressDidChange:(CGFloat)progress;

- (void)CYAudioStream:(CYAudioStream *)audioStream stateDidChange:(CYAudioStreamState)state;

@end


/** CYAudioStream提供播放器的基本功能 */
@interface CYAudioStream : NSObject

@property (nonatomic, weak) id<CYAudioStreamDelegate> delegate;

@property (nonatomic, strong) CYAudioStreamModel *currentModel;

@property (nonatomic, assign, getter=isPlaying, readonly) BOOL playing;

@property (nonatomic, assign, getter=isPaused, readonly) BOOL paused;

@property (nonatomic, assign, getter=isBuffering, readonly) BOOL buffering;

@property (nonatomic, assign) CYAudioStreamPosition position;

@property (nonatomic, assign) CYAudioStreamPosition duration;

/** default is 1.0 */
@property (nonatomic, assign) CGFloat volume;

/**
 * Sets the audio stream playback rate from 0.5 to 2.0.
 * Value 1.0 means the normal playback rate. Values below
 * 1.0 means a slower playback rate than usual and above
 * 1.0 a faster playback rate.
 *
 * default is 1.0.
 * The play rate has only effect if the stream is playing.
 */
@property (nonatomic, assign) CGFloat playRate;

#pragma mark - init

+ (instancetype)sharedStream;

#pragma mark - media

- (void)playWithModel:(CYAudioStreamModel *)model;

/** CYAudioStreamer默认单曲循环播放 */
- (void)play;

/** pause状态下，调用 pause 方法以继续播放 ，此处为freeSteamer的风格，调用play方法并不会使streamer继续播放*/
- (void)pause;

- (void)stop;

/** stop playing if audioStreamer is playing , and clear playInfo for the playmodel */
- (void)reset;

- (CGFloat)getMusicTimeWithSourceUrl:(NSURL *)sourceUrl;

#pragma mark - caches
 
/** must be called in main thread, this method will not work if audioStreamer is playing  */
- (void)clearAllCachesWithCompletion:(CYAudioStreamerCompletionBlock)completion;

@end
