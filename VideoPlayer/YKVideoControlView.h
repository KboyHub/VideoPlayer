//
//  YKVideoControlView.h
//  Video
//
//  Created by 闫康 on 16/3/24.
//  Copyright © 2016年 yankang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKVideoControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;//顶部
@property (nonatomic, strong, readonly) UIView *bottomBar;//底部
@property (nonatomic, strong, readonly) UIButton *playButton;//播放
@property (nonatomic, strong, readonly) UIButton *pauseButton;//暂停
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;//全屏
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;//原始
@property (nonatomic, strong, readonly) UISlider *progressSlider;//进度条
@property (nonatomic, strong, readonly) UIButton *closeButton;//关闭
@property (nonatomic, strong, readonly) UILabel *leftTimeLabel;//剩余时间
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;//当前时间
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;//缓冲指示器
@property (nonatomic,assign)NSInteger playState;
- (void)animateHide;//隐藏控制视图
- (void)animateShow;//显示控制视图
- (void)autoFadeOutControlBar;//
- (void)cancelAutoFadeOutControlBar;//


@end
