# CYAudioStream
&emsp;&emsp;CYAudioStream是基于开源框架**FreeStreamer**封装的流媒体播放器。在FreeStreamer的基础上优化了播放、缓冲进度等事件的回调方式，CYMusicPlayer封装了基本的列表播放业务，简单易用。

## Features
 
- **支持音频格式等基本特性请查看[FreeStreamer](https://github.com/muhku/FreeStreamer)**
- **支持在线音频边存边播**
- **支持后台播放**
- **支持耳机、锁屏远程事件响应**
- **支持播放列表管理**

## Installation

将CYAudioStream文件夹拖拽至工程目录下，在build phases中导入依赖库：

-  **UIKit.framework**
-  **libxml2.tbd**
-  **AVFoundation.framework**
-  **AudioToolBox.framework**
-  **CFNetworking.framework**
-  **MediaPlayer.framework**
-  **FreeStreamer.framework**
 
为了防止编译通过后运行时报“image not found”找不到镜像的错误，需要在build phases中新建一个**copy file** phase

![这里写图片描述](https://github.com/SimonCY/CYAudioStream/raw/master/ScreenShots/guide_framework.jpeg)

 **注意：** demo中默认的FreeStreamer.Framework是由lipo命令合成的**真机+模拟器**动态库，方便开发阶段使用模拟器调试，打包时请手动将其替换为iphones_freestream目录下的**真机动态库**。

## Usage

使用时，导入CYMusicPlayer,

```Objc
#import "CYMusicPlayer.h"
```

然后通过**CYMusicPlayer**单例方法创建音乐播放器，并设置播放列表使用即可，

```Objc
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

播放进度等回调播放相关回调由**CYAudioStreamDelegate**提供，

```Objc
@protocol CYAudioStreamDelegate <NSObject>

@optional

- (void)CYAudioStreamPlayingDidCompleted:(CYAudioStream *)audioStream;

- (void)CYAudioStreamPlayingDidFailed:(CYAudioStream *)audioStream;
 
- (void)CYAudioStream:(CYAudioStream *)audioStream playPositionDidChange:(CYAudioStreamPosition)position;

- (void)CYAudioStream:(CYAudioStream *)audioStream bufferProgressDidChange:(CGFloat)progress;

- (void)CYAudioStream:(CYAudioStream *)audioStream stateDidChange:(CYAudioStreamState)state;

@end
```
CYRemoteControlObserver会自动监听和处理远程控制事件，如需后台播放，须在**capabilities中对Background Modes**进行设置。

![这里写图片描述](https://github.com/SimonCY/CYAudioStream/raw/master/ScreenShots/guide_backmode.jpeg)
