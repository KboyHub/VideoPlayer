//
//  VideoModel.h
//  VideoPlayer
//
//  Created by 闫康 on 16/3/24.
//  Copyright © 2016年 yankang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TopicType) {
    TopicTypeAll = 1, // 全部
    TopicTypePicture = 10, // 图片
    TopicTypeTalk = 29, // 段子
    TopicTypeVoice = 31, // 声音
    TopicTypeVideo = 41 // 视频
};


@interface VideoModel : NSObject

@property (nonatomic, copy) NSString *name;
/** 中图片*/
@property (nonatomic, copy) NSString *middle_image;
/** 大图片 */
/** 视频的播放地址 */
@property (copy, nonatomic) NSString *videouri;
/** 视频的时长 */
@property (assign, nonatomic) NSInteger videotime;




@end
