//
//  FLCTWebViewMessage.m
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTWebViewMessage.h"

@implementation FLCTWebViewMessage

+ (instancetype)initWithDictionary:(NSDictionary *)message{
    NSString *name = [message valueForKey:kJSMessageName];
    id data = [message valueForKey:kJSMessageData];
    long callBackId = [[message valueForKey:kJSMessageCallBackId]longValue];
    
    return [FLCTWebViewMessage initWithEventName:name data:data callBackId:callBackId];
}
+ (instancetype)initWithEventName:(NSString *)eventName data:(id)data callBackId:(long)callBackId{
    FLCTWebViewMessage *message = [[FLCTWebViewMessage alloc] init];
    message.eventName = eventName;
    message.data = data;
    message.callBackId = callBackId;
    return message;
}

@end
