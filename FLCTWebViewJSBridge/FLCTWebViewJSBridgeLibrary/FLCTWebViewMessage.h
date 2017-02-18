//
//  FLCTWebViewMessage.h
//  FLCTWebViewJSBridge
//
//  Created by Yin Heng on 15/12/31.
//  Copyright © 2015年 Yin Heng. All rights reserved.
//

#import "FLCTCommonMessage.h"

@interface FLCTWebViewMessage : FLCTCommonMessage

+ (instancetype)initWithDictionary:(NSDictionary *)message;

@end
