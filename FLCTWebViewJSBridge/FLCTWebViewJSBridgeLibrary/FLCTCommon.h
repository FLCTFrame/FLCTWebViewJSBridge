//
//  FLCTCommon.h
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#define kScriptMessageHandlerName @"FLCTWebViewMessager"
#define kJSBridgeName @"FLCTWebViewJSBridge"

#define kJSMessageName @"eventName"
#define kJSMessageData @"eventData"
#define kJSMessageCallBackId @"eventCallBackId"

#define kJSCallBackEventName @"eventCallBack"

typedef void (^FLCTJSResponseCallback)(id responseData);
typedef void (^FLCTJSHandler)(id data, FLCTJSResponseCallback responseCallback);
typedef NSUInteger GroupValueType;

static inline id deserializeMessageJSON(NSString *messageJSON) {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}
static inline NSString* serializeMessageObject(NSObject *object) {
    return [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] encoding:NSUTF8StringEncoding];
}
