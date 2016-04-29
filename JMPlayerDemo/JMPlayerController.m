//
//  JMPlayerController.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerController.h"
#import "JMPlayer.h"

@interface JMPlayerController ()

@property (weak, nonatomic) IBOutlet UIView *playerWrapperView;
@property (nonatomic) JMPlayerView *playerView;

@end

@implementation JMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *URL1 = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14573563182394.mp4"];
    NSURL *URL2 = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1458389678814huanjieyaliBastaw_x264.mp4"];
    NSURL *URL3 = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1457716884751linghunbanlv_x264.mp4"];
    NSURL *URL4 = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14587093851044544c.mp4"];
    NSURL *URL5 = [NSURL URLWithString:@"https://movielalavideos.blob.core.windows.net/videos/563cb51788b8c6db4b000376.mp4"];
    _playerView = [[JMPlayerView alloc] initWithURLs:@[URL1, URL2, URL3, URL4, URL5]];
    [_playerWrapperView addSubview:_playerView];
}

@end
