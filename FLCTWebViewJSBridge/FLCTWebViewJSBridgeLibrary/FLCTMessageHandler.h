//
//  FLCTMessageHandler.h
//  FLCTWebViewJSBridge
//
//  Created by Yin Heng on 15/12/31.
//  Copyright © 2015年 Yin Heng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLCTCommon.h"

typedef NSUInteger GroupValueType;

@interface FLCTMessageHandler : NSObject

@property (nonatomic, strong, readonly) NSString *eventName;
@property (nonatomic, strong, readonly) FLCTJSHandler handler;

- (instancetype)initWithEventName:(NSString *)name handler:(FLCTJSHandler)handler;

@end
