//
//  FLCTWebViewJSBridge.h
//  FLCTWebViewJSBridge
//
//  Created by Yin Heng on 15/12/18.
//  Copyright © 2015年 Yin Heng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "FLCTCommon.h"

#pragma mark - FLCTWebViewJSBridge
@interface FLCTWebViewJSBridge : NSObject<WKScriptMessageHandler,UIWebViewDelegate,WKNavigationDelegate>

@property (nonatomic, copy) FLCTEventCallHandler canRunEvent;

+ (instancetype)bridgeForWebView:(id)webView delegate:(id)delegate;
+ (instancetype)bridgeForWebView:(id)webView delegate:(id)delegate resourceBundle:(NSBundle*)bundle;
- (instancetype)initWithUIWebview:(UIWebView *)webview delegate:(NSObject<UIWebViewDelegate> *)delegate resourceBundle:(NSBundle*)bundle;
- (instancetype)initWithWKWebview:(WKWebView *)webview delegate:(NSObject<WKNavigationDelegate> *)delegate resourceBundle:(NSBundle*)bundle;

- (void)addEventListener:(NSString *)eventName handler:(FLCTJSHandler)handler;

- (void)removeEventListener:(NSString *)eventName;
- (void)removeEventListener:(NSString *)eventName handler:(FLCTJSHandler)handler;

- (void)invoke:(NSString *)eventName;
- (void)invoke:(NSString *)eventName data:(id)data;
- (void)invoke:(NSString *)eventName data:(id)data responseCallback:(FLCTJSResponseCallback)responseCallback;

@end
