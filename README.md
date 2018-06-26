# CYAudioStream
&emsp;&emsp;CYAudioStream是基于开源框架FreeStreamer封装的流媒体播放器，简单易用。

## Features
 
 * 支持在线音频边存边播
 * 支持后台播放
 * 支持耳机、锁屏远程事件响应
 * 支持播放列表管理

## Installation

将CYAudioStream文件夹拖拽至工程目录下，在build phases中导入依赖库：

 * UIKit.framework
 * libxml2.tbd
 * AVFoundation.framework
 * AudioToolBox.framework
 * CFNetworking.framework
 *  MediaPlayer.framework
 * FreeStreamer.framework
 
为了防止编译通过后运行时报“image not found”找不到镜像的错误，需要在build phases中新建一个copy file phase

![这里写图片描述](https://github.com/SimonCY/CYAudioStream/raw/master/ScreenShots/guide_framework.jpeg)

## Usage

使用时，导入CYMusicPlayer,

```
#import "CYMusicPlayer.h"
```

然后通过CYMusicPlayer单例方法创建音乐播放器，并设置播放列表使用即可，

```
    self.player = [CYMusicPlayer sharedPlayer];
    self.player.audioStream.delegate = self;
    
    CYAudioStreamModel *model0 = [[CYAudioStreamModel alloc] init];
    model0.sourceUrl = _music0Url;
    model0.title = @"music0";
    [self.player.playList addObject:model0];
    
    CYAudioStreamModel *model1 = [[CYAudioStreamModel alloc] init];
    model1.sourceUrl = _videoUrl0;
    model1.title = @"music1";
    [self.player.playList addObject:model1];
    
    [self.player play];
```

播放进度等回调播放相关回调由CYAudioStreamDelegate提供，

```
@protocol CYAudioStreamDelegate <NSObject>

@optional

- (void)CYAudioStreamPlayingDidCompleted:(CYAudioStream *)audioStream;

- (void)CYAudioStreamPlayingDidFailed:(CYAudioStream *)audioStream;
 
- (void)CYAudioStream:(CYAudioStream *)audioStream playPositionDidChange:(CYAudioStreamPosition)position;

- (void)CYAudioStream:(CYAudioStream *)audioStream bufferProgressDidChange:(CGFloat)progress;

- (void)CYAudioStream:(CYAudioStream *)audioStream stateDidChange:(CYAudioStreamState)state;

@end
```
CYRemoteControlObserver会自动监听和处理远程控制事件，如需后台播放，须在capabilities中对Background Modes进行设置。

![这里写图片描述](https://github.com/SimonCY/CYAudioStream/raw/master/ScreenShots/guide_backmode.jpeg)
