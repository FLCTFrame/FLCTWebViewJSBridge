//
//  FLCTMessageHandler.m
//  FLCTWebViewJSBridge
//
//  Created by Yin Heng on 15/12/31.
//  Copyright © 2015年 Yin Heng. All rights reserved.
//

#import "FLCTMessageHandler.h"

@interface FLCTMessageHandler()

@property (nonatomic, strong, readwrite) NSString *eventName;
@property (nonatomic, strong, readwrite) FLCTJSHandler handler;

@end

@implementation FLCTMessageHandler

- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler{
    self = [super init];
    if (self) {
        _eventName = name;
        _handler = handler;
    }
    return self;
}

@end
