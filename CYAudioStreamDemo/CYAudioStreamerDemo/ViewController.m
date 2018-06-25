//
//  ViewController.m
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/13.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import "ViewController.h"
#import "CYMusicPlayer.h"


static NSString * const _music0Url = @"http://v.cdn.bbwc.cn/audio/bloomberg/2014/0325/20140325033418591.mp3";


static NSString * const _videoUrl0 = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";


@interface ViewController ()<CYAudioStreamDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *bufferCompleteLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *bufferProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgress;
@property (weak, nonatomic) IBOutlet UILabel *restTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

- (IBAction)playBtnClicked:(UIButton *)sender;
- (IBAction)pauseBtnClicked:(UIButton *)sender;
- (IBAction)stopBtnClicked:(UIButton *)sender;
- (IBAction)clearCacheBtnClicked:(UIButton *)sender;
- (IBAction)nextBtnClicked:(UIButton *)sender;

@property (nonatomic, strong) CYMusicPlayer *player;

@end

@implementation ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
 
}



#pragma mark - btn clicked

- (IBAction)playBtnClicked:(UIButton *)sender {
    
 
    [self.player play];
   
}

- (IBAction)pauseBtnClicked:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    if (self.player.audioStream.isPlaying) {
        
        [self.player pause];
    } else {
        
        [self.player play];
    }
}

- (IBAction)stopBtnClicked:(UIButton *)sender {
    
    [self.player stop];
    
}

- (IBAction)clearCacheBtnClicked:(UIButton *)sender {
    
    [self.player.audioStream clearAllCachesWithCompletion:^(NSError *error) {
        
        if (error) {
            
            NSLog(@"error is %@",error.userInfo);
        } else {
            
            NSLog(@"cache cleared");
            self.bufferProgress.progress = 0;
        }
    }];
}

- (IBAction)nextBtnClicked:(UIButton *)sender {
    
    [self.player next];
}

#pragma mark - CYAudioStreamerDelegate

- (void)CYAudioStream:(CYAudioStream *)audioStream bufferProgressDidChange:(CGFloat)progress {
    
    self.bufferProgress.progress = progress;
}

- (void)CYAudioStream:(CYAudioStream *)audioStream playPositionDidChange:(CYAudioStreamPosition)position {
    
    self.playProgress.progress = position.progress;
    self.restTimeLabel.text = [NSString stringWithFormat:@"%02u:%02u",position.minute,position.second];
}

- (void)CYAudioStream:(CYAudioStream *)audioStream stateDidChange:(CYAudioStreamState)state {
    
    if (state == CYAudioStreamPlaying) {
        
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%02u:%02u",self.player.audioStream.duration.minute,self.player.audioStream.duration.second];
        self.pauseBtn.selected = NO;
    }
    
    if (state == CYAudioStreamStopped || state == CYAudioStreamFailed) {
        
        if (audioStream.position.progress != 1) {
            
            self.restTimeLabel.text = @"00:00";
            self.totalTimeLabel.text = @"00:00";
            self.playProgress.progress = 0;
            self.bufferProgress.progress = 0;
            self.pauseBtn.selected = NO;
        }
    }
    
    if (state == CYAudioStreamPaused) {
        
        self.pauseBtn.selected = YES;
    }
}

//- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//
//    [self.player.remoteControlObserver remoteControlReceivedWithEvent:event];
//
//}

@end
