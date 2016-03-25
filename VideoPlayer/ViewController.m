//
//  ViewController.m
//  VideoPlayer
//
//  Created by 闫康 on 16/3/24.
//  Copyright © 2016年 yankang. All rights reserved.
//

#import "ViewController.h"
#import "YKVideoPlayerController.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,strong)VideoModel *videoModel;//视频模型
@property (nonatomic, strong)  YKVideoPlayerController*videoController;


- (IBAction)playVideoButtonClick:(UIButton *)sender;
@end

@implementation ViewController

/*
 假数据 视频模型
 */
- (VideoModel *)videoModel {
    if (!_videoModel) {
        _videoModel = [[VideoModel alloc]init];
        
        _videoModel.name = @"妹妹，干啥又要分手啊？";
        _videoModel.middle_image = @"http://wimg.spriteapp.cn/picture/2016/0323/56f2039bbc2b6_wpd.jpg";
        _videoModel.videouri = @"http://wvideo.spriteapp.cn/video/2016/0323/56f2039bbc2b6_wpd.mp4";
        _videoModel.videotime = 54;
    }
    return _videoModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:self.videoModel.middle_image]];
    self.playTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.videoModel.videotime / 60, self.videoModel.videotime % 60];
    self.nameLabel.text = self.videoModel.name;
    
}

- (IBAction)playVideoButtonClick:(UIButton *)sender {
    
    [self playVideoWithURL:[NSURL URLWithString:self.videoModel.videouri]];
    [self.videoView addSubview:self.videoController.view];
    
}

- (void)playVideoWithURL:(NSURL *)url {
    if (!self.videoController) {
        self.videoController = [[YKVideoPlayerController alloc] initWithFrame:self.videoImageView.bounds];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
    }
    self.videoController.contentURL = url;
}

//停止视频的播放
- (void)reset {
    [self.videoController dismiss];
    self.videoController = nil;
}

@end
