//
//  FLCTWebViewJSBridge.m
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 15/12/18.
//  Copyright © 2015年 Mapleiny. All rights reserved.
//

#import "FLCTWebViewJSBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FLCTMessageHandler.h"
#import "FLCTClientMessage.h"
#import "FLCTWebViewMessage.h"

#define DEBUG 1

@interface FLCTWebViewJSBridge()

@property (nonatomic, weak) id<WKNavigationDelegate> webViewNavigationDelegate;
@property (nonatomic, weak) id<UIWebViewDelegate> webViewDelegate;
@property (nonatomic, weak) WKWebView *wkWebview;
@property (nonatomic, weak) UIWebView *uiWebview;
@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation FLCTWebViewJSBridge{
    NSMutableDictionary *_eventList;
    NSBundle *_resourceBundle;
    NSMutableDictionary* _responseCallbacks;
    long _responseCallBackUniqueId;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _eventList = [NSMutableDictionary dictionary];
        _responseCallbacks = [NSMutableDictionary dictionary];
        _responseCallBackUniqueId = 100;
    }
    return self;
}
+ (instancetype)bridgeForWebView:(id)webView delegate:(id)delegate{
    return [self bridgeForWebView:webView delegate:delegate resourceBundle:nil];
}
+ (instancetype)bridgeForWebView:(id)webView delegate:(id)delegate resourceBundle:(NSBundle*)bundle{
    if ([webView isKindOfClass:[UIWebView class]]) {
        return [[FLCTWebViewJSBridge alloc]initWithUIWebview:webView delegate:delegate resourceBundle:bundle];
    }else if([webView isKindOfClass:[WKWebView class]]){
        return [[FLCTWebViewJSBridge alloc]initWithWKWebview:webView delegate:delegate resourceBundle:bundle];
    }else{
        return [super init];
    }
}

#pragma init
- (instancetype)initWithUIWebview:(UIWebView *)webview delegate:(NSObject<UIWebViewDelegate> *)delegate resourceBundle:(NSBundle*)bundle{
    self = [super init];
    if (self) {
        _uiWebview = webview;
        webview.delegate = self;
        _webViewDelegate = delegate;
        _jsContext = [webview valueForKeyPath: @"documentView.webView.mainFrame.javaScriptContext"];
    }
    return self;
}
- (instancetype)initWithWKWebview:(WKWebView *)webview delegate:(NSObject<WKNavigationDelegate> *)delegate resourceBundle:(NSBundle*)bundle{
    self = [super init];
    if (self) {
        _wkWebview = webview;
        webview.navigationDelegate = self;
        _webViewNavigationDelegate = delegate;
        [_wkWebview.configuration.userContentController addScriptMessageHandler:self name:kScriptMessageHandlerName];
    }
    return self;
}
#pragma mark - Event Add
- (void)addEventListener:(NSString *)eventName handler:(FLCTJSHandler)handler{
    [self addEventListener:eventName handler:handler permissionGroupValue:0];
}
- (void)addEventListener:(NSString *)eventName handler:(FLCTJSHandler)handler permissionGroupValue:(GroupValueType)groupValue{
    NSAssert(eventName != nil, @"eventName should not be nil");
    NSMutableSet *events = [_eventList valueForKey:eventName];
    if (events == nil) {
        events = [NSMutableSet set];
        [_eventList setObject:events forKey:eventName];
    }
    [events addObject:[[FLCTMessageHandler alloc] initWithEventName:eventName handler:handler permissionGroupValue:groupValue]];
}

#pragma mark - Event Remove
- (void)removeEventListener:(NSString *)eventName{
    [_eventList removeObjectForKey:eventName];
}
- (void)removeEventListener:(NSString *)eventName handler:(FLCTJSHandler)handler{
    NSMutableSet *eventHandlers = [_eventList valueForKey:eventName];
    [eventHandlers removeObject:handler];
}

#pragma mark - Event info
- (NSSet *)listenedEventForGroup:(GroupValueType)groupValue{
    return [NSSet new];
}

#pragma mark - invoke webview event
- (void)invoke:(NSString *)eventName{
    [self invoke:eventName data:nil];
}
- (void)invoke:(NSString *)eventName data:(id)data{
    [self invoke:eventName data:data responseCallback:nil];
}
- (void)invoke:(NSString *)eventName data:(id)data responseCallback:(FLCTJSResponseCallback)responseCallback{
    
    long callBackId = 0;
    if (responseCallback) {
        callBackId = [self addCallBackQueue:responseCallback];
    }
    FLCTClientMessage *message = [FLCTClientMessage initWithEventName:eventName callBackId:callBackId data:data];
    [self dispatchMessage:message];
}

#pragma mark - proccessMessage

// get message from web
- (void)evalueMessageDictionary:(NSDictionary *)messageDictionary{
#ifdef DEBUG
    NSLog(@"evalueMessageDictionary:%@",messageDictionary);
#endif
    FLCTWebViewMessage *message = [FLCTWebViewMessage initWithDictionary:messageDictionary];
    if (![message.eventName isEqualToString:kJSCallBackEventName]) {
        // message from web orgin invoke
        NSSet *events = [_eventList valueForKey:message.eventName];
        if (events && [events isKindOfClass:[NSSet class]]) {
            [events enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                FLCTMessageHandler *jsHandler = obj;
                if ((jsHandler.permissionGroup&_currentPermissionGroup) != 0 && jsHandler.handler) {
                    FLCTJSResponseCallback callBack = ^(id data){
                        FLCTClientMessage *message = [FLCTClientMessage initWithEventName:kJSCallBackEventName callBackId:message.callBackId data:data];
                        [self dispatchMessage:message];
                    };
                    jsHandler.handler(message.data,callBack);
                }
            }];
        }
    }else{
        // message from clinet callback
        NSString *callBackIdString = [NSString stringWithFormat:@"%ld",message.callBackId];
        FLCTJSResponseCallback callBack = [_responseCallbacks valueForKey:callBackIdString];
        callBack(message.data);
        [_responseCallbacks removeObjectForKey:callBackIdString];
    }
    
}

// send message to web
- (void)dispatchMessage:(FLCTClientMessage *)clientMessage{
    NSString *jsString = [clientMessage convertingToJSONString];
#ifdef DEBUG
    NSLog(@"dispatchMessage:%@",jsString);
#endif
    if ([[NSThread currentThread] isMainThread]) {
        [self evaluateJavaScript:jsString];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self evaluateJavaScript:jsString];
        });
    }
}



#pragma mark - helper
- (long)addCallBackQueue:(FLCTJSResponseCallback)responseCallback{
    long callBackId = ++_responseCallBackUniqueId;
    NSString *callBackIdString = [NSString stringWithFormat:@"%ld",callBackId];
    _responseCallbacks[callBackIdString] = [responseCallback copy];
    return callBackId;
}

- (void)evaluateJavaScript:(NSString *)jsString{
    if (_uiWebview != nil) {
        [_jsContext evaluateScript:jsString];
    }else if (_wkWebview != nil){
        [_wkWebview evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];
    }
}
















#pragma mark -



#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:kScriptMessageHandlerName]) {
        [self evalueMessageDictionary:message.body];
    }
}


#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    __strong NSObject<UIWebViewDelegate>* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    __strong NSObject<UIWebViewDelegate>* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [strongDelegate webViewDidStartLoad:webView];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webView != _uiWebview) {
        return;
    }
    
    if (![[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"typeof %@ == 'object'",kJSBridgeName]] isEqualToString:@"true"]) {
        NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
        NSString *filePath = [bundle pathForResource:@"jsbridge" ofType:@"js"];
        NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString:js];
        _jsContext[[NSString stringWithFormat:@"__FLCTWebViewsendMessageToClient"]] = ^(id data){
        };
    }
    
    __strong NSObject<UIWebViewDelegate>* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    __strong NSObject<UIWebViewDelegate>* strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
}


#pragma mark - navigationDelegate
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        [strongDelegate webView:webView didCommitNavigation:navigation];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [strongDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [strongDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (webView != _wkWebview) {
        return;
    }
    [webView evaluateJavaScript:[NSString stringWithFormat:@"typeof %@ == 'object'",kJSBridgeName] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error == nil) {
            if ([result isEqual: @0]) {
                NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
                NSString *filePath = [bundle pathForResource:@"jsbridge" ofType:@"js"];
                NSString *js = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                [webView evaluateJavaScript:js completionHandler:nil];
            }
        }
    }];
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [strongDelegate webView:webView didFinishNavigation:navigation];
    }
}

-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [strongDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }
}

-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [strongDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [strongDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    __strong NSObject<WKNavigationDelegate>* strongDelegate = _webViewNavigationDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [strongDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
}

@end