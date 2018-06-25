//
//  CYAudioStreamModel.m
//  CYAudioStreamerDemo
//
//  Created by chenyan on 2018/6/19.
//  Copyright © 2018年 modernmedia. All rights reserved.
//

#import "CYAudioStreamModel.h"

@implementation CYAudioStreamModel

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[self class]]) {
        
        return NO;
    }
    
    if (![self.sourceUrl isEqualToString:((CYAudioStreamModel *)object).sourceUrl]) {
        
        return NO;
    }
    
    if (![self.title isEqualToString:((CYAudioStreamModel *)object).title]) {
        
        return NO;
    }
    
    if (![self.thumbImage isEqual:((CYAudioStreamModel *)object).thumbImage]) {
        
        return NO;
    }
    return YES;
}

#pragma mark - getter

- (NSString *)title {
    
    return _title.length? _title:@"未知音乐";
}

- (UIImage *)thumbImage {
    
    if (!_thumbImage) {
        
        NSString *defaultImagePath = [[NSBundle mainBundle] pathForResource:@"cy_artwork_unknown" ofType:@"png"];
        _thumbImage = [UIImage imageWithContentsOfFile:defaultImagePath];
    }
    return _thumbImage;
}
@end
