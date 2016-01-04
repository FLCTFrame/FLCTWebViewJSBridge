//
//  FLCTWebViewMessage.h
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/31.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTCommonMessage.h"

@interface FLCTWebViewMessage : FLCTCommonMessage

+ (instancetype)initWithDictionary:(NSDictionary *)message;

@end
