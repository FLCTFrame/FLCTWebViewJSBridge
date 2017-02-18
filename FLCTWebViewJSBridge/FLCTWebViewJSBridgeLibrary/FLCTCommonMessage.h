//
//  FLCTCommonMessage.h
//  FLCTWebViewJSBridge
//
//  Created by Yin Heng on 15/12/31.
//  Copyright © 2015年 Yin Heng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLCTCommon.h"

@interface FLCTCommonMessage : NSObject

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) id data;
@property (nonatomic, assign) long callBackId;

- (NSMutableDictionary *)convertingToDictionary;
- (NSString *)convertingToJSONString;
- (NSString *)convertingToJSONStringWithExtend:(NSDictionary *)extendDictionary;

@end
