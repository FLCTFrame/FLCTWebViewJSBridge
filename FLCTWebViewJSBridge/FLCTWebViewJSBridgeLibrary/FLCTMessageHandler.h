//
//  FLCTMessageHandler.h
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLCTCommon.h"

typedef NSUInteger GroupValueType;

@interface FLCTMessageHandler : NSObject

@property (nonatomic, strong, readonly) NSString *eventName;
@property (nonatomic, strong, readonly) FLCTJSHandler handler;
@property (nonatomic, assign, readonly) GroupValueType permissionGroup;

- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler;
- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler permissionGroupValue:(GroupValueType)groupValue;

@end
