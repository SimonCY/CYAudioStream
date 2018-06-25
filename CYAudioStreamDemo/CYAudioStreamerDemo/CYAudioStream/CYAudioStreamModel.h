//
//  CYAudioStreamModel.h
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/19.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYAudioStreamModel : NSObject

@property (nonatomic, copy) NSString *sourceUrl;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIImage *thumbImage;

NS_ASSUME_NONNULL_END

@end
