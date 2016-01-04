//
//  FLCTCommonMessage.h
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTCommonMessage.h"
#import <objc/runtime.h>

@implementation FLCTCommonMessage

// 子类的属性获取问题
- (NSMutableDictionary *)convertingToDictionary{
    unsigned int count = 0;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    objc_property_t *properties = class_copyPropertyList(FLCTCommonMessage.class, &count);
    
    for (int i = 0; i < count; i++) {
        
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        
        if (value == nil) {
            // nothing todo
        }else if ([value isKindOfClass:[NSNumber class]]
                 || [value isKindOfClass:[NSString class]]
                 || [value isKindOfClass:[NSDictionary class]]) {
            // TODO: extend to other types
            [dictionary setObject:value forKey:key];
        }else if ([value isKindOfClass:[NSObject class]]) {
            [dictionary setObject:[value convertingToDictionary] forKey:key];
        }
    }
    
    free(properties);
    
    return dictionary;
}
- (NSString *)convertingToJSONStringWithDictionary:(NSDictionary *)dictionary{
    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil] encoding:NSUTF8StringEncoding];
}
- (NSString *)convertingToJSONString{
    return [self convertingToJSONStringWithDictionary:[self convertingToDictionary]];
}
- (NSString *)convertingToJSONStringWithExtend:(NSDictionary *)extendDictionary{
    NSMutableDictionary *dictionary = [self convertingToDictionary];
    [dictionary addEntriesFromDictionary:extendDictionary];
    return [self convertingToJSONStringWithDictionary:dictionary];
}

@end
