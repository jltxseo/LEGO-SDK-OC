//
//  LGOModalController.m
//  LEGO-SDK-OC
//
//  Created by adi on 16/8/4.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGOModalController.h"
#import "LGOCore.h"
#import "LGOBuildFailed.h"
#import "LGOModalPresentationTransition.h"
#import "LGOModalDismissTransition.h"
#import "LGOWebViewController.h"
#import "LGOWKWebView.h"
#import "LGOViewControllerGlobalValues.h"

// Request
@interface LGOModalRequest : LGORequest

@property (nonatomic, strong) NSString* opt; // present/dismiss
@property (nonatomic, strong) NSString* path; // an URLString or LGOViewControllerMapping[path]
@property (nonatomic, assign) BOOL animated; // push or pop need animation. Defaults to true.
@property (nonatomic, assign) BOOL withNavigationController; // ViewController will wrap by navigationController, defaults to YES.
@property (nonatomic, assign) UIEdgeInsets edgeInsets; // ViewController will wrap by UIWindow with EdgeInsets.
@property (nonatomic, strong) NSDictionary<NSString *, id>* args; // deliver args to next ViewController

@end

@implementation LGOModalRequest


@end


// Operation
@class LGOModalOperation;
LGOModalOperation* lastOperation;
NSDate* lastPresent;

@interface LGOModalOperation : LGORequestable<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) LGOModalRequest *request;

@end

@implementation LGOModalOperation

- (LGOResponse *)requestSynchronize{
    if ([self.request.opt isEqualToString:@"present"]){
        [self present];
    }
    else if ([self.request.opt isEqualToString:@"dismiss"]){
        [self dismiss];
    }
    return [LGOResponse new];
}

- (void) dismiss{
    UIViewController* viewController = [self requestViewController];
    if(!viewController){ return; }
    
    UIViewController* presentedViewController = viewController.presentedViewController;
    if (presentedViewController) {
        [presentedViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return;
    }
    
    UINavigationController* naviViewController = viewController.navigationController;
    if (naviViewController){
        [naviViewController dismissViewControllerAnimated:self.request.animated completion:nil];
        return;
    }
    
    if (viewController.presentingViewController){
        [viewController dismissViewControllerAnimated:self.request.animated completion:nil];
    }
    
}

- (void) present{
    if (lastPresent && [lastPresent timeIntervalSinceNow] > -1.0 ){
        NSLog(@"两次 Present 的操作不能少于 1 秒");
        return;
    }
    else {
        lastPresent = [NSDate new];
    }
    
    NSURL* relativeURL = nil;
    UIViewController* webViewController = self.request.context.requestViewController;
    if (webViewController && [webViewController isKindOfClass:[LGOWebViewController class]]){
        UIView* webView = ((LGOWebViewController *)webViewController).webView;
        if (webView && [webView isKindOfClass:[LGOWKWebView class]]){
            relativeURL = ((LGOWKWebView*)webView).URL;
        }
    }
    
    NSURL* URL = [NSURL URLWithString:self.request.path relativeToURL:relativeURL];
    if (URL){
        [self presentWebView:URL];
    }
    else {
        LGOViewControllerInitializeBlock initBlock = [LGOViewControllerGlobalValues LGOViewControllerMapping][self.request.path];
        if (initBlock){
            [self presentViewController:initBlock];
        }
    }
}

// ... supp

- (void) presentWebView:(NSURL *)URL{
    UIViewController* viewController = [self requestViewController];
    if (!viewController) {return;}
    LGOWebViewController* aWebViewController = [LGOWebViewController new];
    aWebViewController.initializeContext = self.request.args;
    aWebViewController.initializeRequest = [[NSURLRequest alloc] initWithURL:URL];
    aWebViewController.title = [self.request.args[@"title"] isKindOfClass:[NSString class]]? self.request.args[@"title"] : @"";
    
    static BOOL presented = NO;
    UIViewController* presentingViewController = aWebViewController;
    if (self.request.withNavigationController){
        UINavigationController* naviController = [self requestNavigationController:aWebViewController];
        if (naviController){
            
            // if self.request.edgeInsets
            naviController.modalPresentationStyle = UIModalPresentationCustom;
            naviController.transitioningDelegate = self;
            lastOperation = self;
            
            presentingViewController = naviController;
        }
        else {
            // if self.request.edgeInsets
            aWebViewController.modalPresentationStyle = UIModalPresentationCustom;
            aWebViewController.transitioningDelegate = self;
            lastOperation = self;
            
            presentingViewController = aWebViewController;
        }
    }
    else{
        // if self.request.edgeInsets
        aWebViewController.modalPresentationStyle = UIModalPresentationCustom;
        aWebViewController.transitioningDelegate = self;
        lastOperation = self;
        
        presentingViewController = aWebViewController;
    }
    
    if (aWebViewController.isPrerending){
        aWebViewController.renderDidFinished = ^{
            if (presented){ return ; }
            presented = YES;
            [viewController presentViewController:presentingViewController animated:YES completion:nil];
        };
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (presented){ return ; }
            presented = YES;
            [viewController presentViewController:presentingViewController animated:YES completion:nil];
        });
    }
    else{
        [viewController presentViewController:presentingViewController animated:YES completion:nil];
    }
}

- (void) presentViewController:(LGOViewControllerInitializeBlock)initBlock{
    UIViewController* viewController = [self requestViewController];
    if (!viewController){return;}
    UIViewController* instance = initBlock(self.request.args);
    if (instance){
        instance.title = [self.request.args[@"title"] isKindOfClass:[NSString class]]? self.request.args[@"title"]: @"";
        if (self.request.withNavigationController){
            UIViewController* aViewController = [self requestNavigationController:instance];
            if (aViewController){
                [viewController presentViewController:aViewController animated:YES completion:nil];
            }
            else {
                [viewController presentViewController:instance animated:YES completion:nil];
            }
        }
        else {
            [viewController presentViewController:instance animated:YES completion:nil];
        }
    }
}

- (UINavigationController*) requestNavigationController:(UIViewController*)rootViewController{
    id naviClz = [self requestViewController].navigationController.self;
    if(!naviClz) { return nil; }
    // @Td dynamic init naviController
    return nil;
}

- (UIViewController*) requestViewController{
    UIView* view = [self.request.context.sender isKindOfClass:[UIView class]] ? (UIView *)self.request.context.sender:nil;
    if(view){
        UIResponder* next = [view nextResponder];
        for (int count = 0; count<100; count++) {
            if([next isKindOfClass:[UIViewController class]]){
                return (UIViewController *)next;
            }
            else{
                if (next){
                    next = [next nextResponder];
                }
            }
        }
    }
    return nil;
}

// ... delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[LGOModalPresentationTransition alloc] initWithTargetEdgeInsets:self.request.edgeInsets];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[LGOModalDismissTransition alloc] initWithTargetEdgeInsets:self.request.edgeInsets];
}

@end


// Module
@implementation LGOModalController

- (LGORequestable *)buildWithRequest:(LGORequest *)request{
    if ([request isKindOfClass:[LGOModalRequest class]]){
        LGOModalOperation *operation = [LGOModalOperation new];
        operation.request = (LGOModalRequest *)request;
        return operation;
    }
    return [[LGOBuildFailed alloc] initWithErrorString:@"RequestObject Downcast Failed"];
}

- (LGORequestable *)buildWithDictionary:(NSDictionary *)dictionary context:(LGORequestContext *)context{
    LGOModalRequest *request = [LGOModalRequest new];
    request.context = context;
    request.opt = [dictionary[@"opt"] isKindOfClass:[NSString class]] ? dictionary[@"opt"] : @"";
    request.path = [dictionary[@"path"] isKindOfClass:[NSString class]] ? dictionary[@"path"] : @"";
    request.animated = [dictionary[@"animated"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"animated"]).boolValue : YES;
    request.withNavigationController = [dictionary[@"withNavigationController"] isKindOfClass:[NSNumber class]] ? ((NSNumber *)dictionary[@"withNavigationController"]).boolValue : YES;
    request.edgeInsets = [dictionary[@"edgeInsets"] isKindOfClass:[NSString class]] ? [self edgeInsetsFromString:(NSString *)dictionary[@"edgeInsets"]] : UIEdgeInsetsZero ;
    request.args = [dictionary[@"args"] isKindOfClass:[NSDictionary class]] ? dictionary[@"args"] : @{};
    return [self buildWithRequest:request];
}

- (UIEdgeInsets) edgeInsetsFromString:(NSString *)str{
    NSArray<NSString *>* arr = [str componentsSeparatedByString:@","];
    if (arr.count == 4){
        return UIEdgeInsetsMake([arr[0] floatValue], [arr[1] floatValue], [arr[2] floatValue], [arr[3] floatValue]);
    }
    return UIEdgeInsetsZero;
}

@end
