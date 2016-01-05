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

typedef BOOL (^FLCTEventCallHandler)(NSString *eventName);
typedef void (^FLCTJSResponseCallback)(id responseData);
typedef void (^FLCTJSHandler)(id data, FLCTJSResponseCallback responseCallback);
typedef NSUInteger GroupValueType;
