//
//  FLCTMessageHandler.m
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTMessageHandler.h"

@interface FLCTMessageHandler()

@property (nonatomic, strong, readwrite) NSString *eventName;
@property (nonatomic, strong, readwrite) FLCTJSHandler handler;
@property (nonatomic, assign, readwrite) GroupValueType permissionGroup;

@end

@implementation FLCTMessageHandler

- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler{
    return [self initWithEventName:name handler:handler permissionGroupValue:0];
}
- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler permissionGroupValue:(GroupValueType)groupValue{
    self = [super init];
    if (self) {
        _eventName = name;
        _handler = handler;
        _permissionGroup = groupValue;
    }
    return self;
}

@end
