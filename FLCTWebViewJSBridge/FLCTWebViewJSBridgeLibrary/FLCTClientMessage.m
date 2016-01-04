//
//  FLCTClientMessage.m
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTClientMessage.h"

@implementation FLCTClientMessage

+ (instancetype)initWithEventName:(NSString *)eventName callBackId:(long)callBackId data:(id)data{
    FLCTClientMessage *message = [[FLCTClientMessage alloc]init];
    message.eventName = eventName;
    message.callBackId = callBackId;
    message.data = data;
    return message;
}

@end
