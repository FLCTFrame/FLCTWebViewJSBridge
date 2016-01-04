//
//  FLCTClientMessage.h
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTCommonMessage.h"

@interface FLCTClientMessage : FLCTCommonMessage

+ (instancetype)initWithEventName:(NSString *)callName callBackId:(long)callBackId data:(id)data;

@end
