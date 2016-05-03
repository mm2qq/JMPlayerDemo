//
//  JMPlayerController.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerController.h"
#import "JMPlayer.h"
#import "NSDictionary+JMAdd.h"

@interface TestItem : NSObject <JMPlayerItemInfoDelegate>

@property (nonatomic, copy) NSString *itemTitle;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *playUrl;

@end

@implementation TestItem

@end

@interface JMPlayerController ()

@property (weak, nonatomic) IBOutlet UIView *playerWrapperView;
@property (nonatomic) JMPlayer *player;

@end

@implementation JMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"]];
    NSDictionary *dic = [NSDictionary dictionaryWithJson:data];
    NSArray *videoList = dic[@"videoList"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:videoList.count];

    for (NSDictionary *video in videoList) {
        TestItem *item = [TestItem new];
        [item setItemTitle:video[@"title"]];
        [item setItemDescription:video[@"description"]];
        [item setPlayUrl:video[@"playUrl"]];
        [items addObject:item];
    }

    _player = [[JMPlayer alloc] initWithItems:items];
    [_playerWrapperView addSubview:_player];
}

@end
