//
//  ViewController.m
//  FLCTWebViewJSBridge
//
//  Created by Mapleiny on 16/1/4.
//  Copyright © 2016年 Mapleiny. All rights reserved.
//

#import "ViewController.h"
#import "FLCTWebViewJSBridge.h"

@interface ViewController ()

@property (nonatomic,strong) UIWebView *webview;
@property (nonatomic,strong) FLCTWebViewJSBridge *JSBridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}
- (void)buildUI{
    self.view.backgroundColor = [UIColor whiteColor];
    _webview = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webview.backgroundColor = [UIColor whiteColor];
    
    _JSBridge = [FLCTWebViewJSBridge bridgeForWebView:_webview delegate:self];
    _JSBridge.canRunEvent = ^BOOL(NSString *eventName) {
        return YES;
    };
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendMessage)];
    
    [self.view addSubview:_webview];
    
    [self setJSBridgeEvent];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"demo" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webview loadHTMLString:html baseURL:nil];
    
    
}

- (void)sendMessage{
    [_JSBridge invoke:@"message" data:@"hello" responseCallback:^(id responseData) {
        NSLog(@"invoke:@\"post\" callback:%@",responseData);
    }];
}

- (void)setJSBridgeEvent{
    [_JSBridge addEventListener:@"log" handler:^(id data, FLCTJSResponseCallback responseCallback) {
        NSLog(@"message from webview log:%@",data);
        if (responseCallback) {
            responseCallback(@"I just log a message in client console.");
        }
    }];
}

@end
