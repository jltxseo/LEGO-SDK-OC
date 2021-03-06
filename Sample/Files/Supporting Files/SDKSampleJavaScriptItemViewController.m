//
//  SDKSampleJavaScriptItemViewController.m
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "LGOWKWebView+DataModel.h"
#import "LGOWKWebView.h"
#import "LGOWebView+DataModel.h"
#import "SDKSampleJavaScriptItemViewController.h"

@implementation SDKSampleJavaScriptItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    [self configureTests];
}

- (void)configureTests {
    if (self.zipURL != nil) {
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.zipURL]]];
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.zipURL]]];
        }
    } else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:self.file ofType:@"html"];
//        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
        }
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootViewController) {
            rootViewController.accessibilityLabel = @"AppFrame";
        }
        [self configureTestCases];
    }
}

- (void)configureTestCases {
    if ([self.file isEqualToString:@"Native.DataModel"]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(testDataModel)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)testDataModel {
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        [(UIWebView *)self.webView updateDataModel:@"date" dataValue:[[NSDate new] description]];
    } else if ([self.webView isKindOfClass:[WKWebView class]]) {
        [(WKWebView *)self.webView updateDataModel:@"date" dataValue:[[NSDate new] description]];
    }
}

@end
