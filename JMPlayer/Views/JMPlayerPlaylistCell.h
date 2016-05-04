//
//  JMPlayerPlaylistCell.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/4.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMPlayerPlaylistCell : UITableViewCell

@property (nullable, nonatomic, copy) NSString *itemTitle;

+ (NSString *)cellId;

@end

NS_ASSUME_NONNULL_END
