//
//  LGOWebViewController.h
//  LEGO-SDK-OC
//
//  Created by 崔明辉 on 16/7/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGOWebViewController : UIViewController

@property (nonatomic, strong) UIView *webView;

@property (nonatomic, strong) NSURLRequest *initializeRequest;

@property (nonatomic, copy) NSDictionary *initializeContext;

- (void)callWithMethodName:(NSString *)methodName userInfo:(NSDictionary<NSString *, id> *)userInfo;


typedef void (^renderDidFinishedBlock)();
@property (nonatomic, copy) __nullable renderDidFinishedBlock renderDidFinished;
@property (nonatomic, assign) BOOL isPrerending;

- (void)configureWebView;
- (void)configureWebViewLayout;


@end
