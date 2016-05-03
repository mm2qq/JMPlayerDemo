//
//  NSDictionary+JMAdd.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/3.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "NSDictionary+JMAdd.h"

@implementation NSDictionary (JMAdd)

+ (NSDictionary *)dictionaryWithJson:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

@end
