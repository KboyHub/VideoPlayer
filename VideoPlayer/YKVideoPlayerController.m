//
//  YKVideoPlayerController.m
//  Video
//
//  Created by 闫康 on 16/3/24.
//  Copyright © 2016年 yankang. All rights reserved.
//

#import "YKVideoPlayerController.h"
#import "YKVideoControlView.h"

static const CGFloat videoPlayerControllerAnimationTimeinterval = 0.3f;

@interface YKVideoPlayerController ()

@property (nonatomic, strong) YKVideoControlView *videoControlView;//播放器控制视图
@property (nonatomic, strong) UIView *movieBackgroundView;//背景
@property (nonatomic, assign) BOOL isFullscreenMode;//是否全屏
@property (nonatomic, assign) CGRect originFrame;//原始大小
@property (nonatomic, strong) NSTimer *durationTimer;//时间定时器
@property (nonatomic, strong) UIView *originView;//原始视图

@end

@implementation YKVideoPlayerController


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControlView];
        self.videoControlView.frame = self.view.bounds;
        [self configureObserver];//配置观察者
        [self configureControlAction];//配置视频控制
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
}

#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:videoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stop];
    [self stopDurationTimer];
    [UIView animateWithDuration:videoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
#pragma mark - 定时器相关
//启动定时器
- (void)startDurationTimer
{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}


//销毁定时器
- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}


#pragma mark - 配置观察者
- (void)configureObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
}

#pragma mark - 播放状态改变
- (void)onMPMoviePlayerPlaybackStateDidChangeNotification{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControlView.playState = 1;
        [self startDurationTimer];
        [self.videoControlView.indicatorView stopAnimating];
        [self.videoControlView autoFadeOutControlBar];
         self.videoControlView.pauseButton.hidden = NO;
    } else {
         self.videoControlView.playState = 0;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControlView animateShow];
            self.videoControlView.playButton.hidden = NO;
        }
    }

}

#pragma mark - 缓冲加载
- (void)onMPMoviePlayerLoadStateDidChangeNotification{
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControlView.indicatorView startAnimating];
    }
}

#pragma mark - 准备显示状态改变
- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification{
    
}

#pragma mark - 设置时长
- (void)onMPMovieDurationAvailableNotification{
    [self setProgressSliderMaxMinValues];
}

#pragma mark - 配置视频控制
- (void)configureControlAction{
    [self.videoControlView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];//播放
    [self.videoControlView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];//暂停
    [self.videoControlView.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];//关闭
    [self.videoControlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];//全屏
    [self.videoControlView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];//取消全屏
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];//进度条值改变
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];//开始触摸
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];//结束触摸
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];//释放触摸操作
    [self setProgressSliderMaxMinValues];//设置进度条最值
    [self monitorVideoPlayback];//

}

- (void)playButtonClick
{
    [self play];
    self.videoControlView.playButton.hidden = YES;
    self.videoControlView.pauseButton.hidden = NO;
}

- (void)pauseButtonClick
{
    [self pause];
    self.videoControlView.playButton.hidden = NO;
    self.videoControlView.pauseButton.hidden = YES;
}

- (void)closeButtonClick
{
    [self dismiss];
}

- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    
    self.originView = self.view.superview;
    [keyWindow addSubview:self.view];
    [UIView animateWithDuration:0.3f animations:^{
        
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControlView.fullScreenButton.hidden = YES;
        self.videoControlView.shrinkScreenButton.hidden = NO;
    }];
}

- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    [self.originView addSubview:self.view];
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControlView.fullScreenButton.hidden = NO;
        self.videoControlView.shrinkScreenButton.hidden = YES;
    }];
}

- (void)progressSliderTouchBegan:(UISlider *)slider
{
    [self pause];
    [self.videoControlView cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider
{
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControlView autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider
{
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}


- (void)setProgressSliderMaxMinValues
{
    CGFloat duration = self.duration;
    self.videoControlView.progressSlider.minimumValue = 0.f;
    self.videoControlView.progressSlider.maximumValue = duration;
}

- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];//配置视频播放时间
    self.videoControlView.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControlView.currentTimeLabel.text = [NSString stringWithFormat:@"%@",timeElapsedString];
    self.videoControlView.leftTimeLabel.text = [NSString stringWithFormat:@"%@",timeRmainingString];
}

#pragma mark - Property
- (YKVideoControlView *)videoControlView
{
    if (!_videoControlView) {
        _videoControlView = [[YKVideoControlView alloc] init];
    }
    return _videoControlView;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControlView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControlView setNeedsLayout];
    [self.videoControlView layoutIfNeeded];
}
//销毁观察者
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
