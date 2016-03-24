//
//  YKVideoPlayerController.h
//  Video
//
//  Created by 闫康 on 16/3/24.
//  Copyright © 2016年 yankang. All rights reserved.
//

@import MediaPlayer;

@interface YKVideoPlayerController : MPMoviePlayerController

@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;


@end
