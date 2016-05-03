//
//  NSDictionary+JMAdd.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/3.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JMAdd)

/**
 *  Creates and returns a dictionary from a json.
 *
 *  @param json A json dictionary of `NSDictionary`, `NSString` or `NSData`.
 Example: {"user1":{"name","Mary"}, "user2": {name:"Joe"}}
 *
 *  @return A array, or nil if an error occurs.
 */
+ (nullable NSDictionary *)dictionaryWithJson:(id)json;

@end

NS_ASSUME_NONNULL_END
