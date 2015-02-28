//
//  WebViewController.m
//  LookingForInterest
//
//  Created by Wayne on 2/21/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

#define kSearchWeb @"https://www.google.com.tw/search?q=%@"
#define kSearchImage @"https://www.google.com.tw/search?site=imghp&tbm=isch&source=hp&ei=MKfpVKObL9Gm8AW12oGoAg&q=%@&oq=&gs_l=mobile-gws-hp.1.0.41.0.0.0.10252.1.0.0.1.1.0.0.0..0.0.msedr...0...1c..62.mobile-gws-hp..0.1.86.1.aIfV9iDtDOo"

@interface WebViewController () <WKNavigationDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) WKWebView *wkwebView;
- (IBAction)goBack:(UIButton *)sender;
- (IBAction)goForward:(UIButton *)sender;
- (IBAction)reload:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (nonatomic) BOOL isWebViewBeSetting;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.isWebViewBeSetting = NO;
    self.addressTextField.delegate = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidLayoutSubviews NS_AVAILABLE_IOS(5_0) {
    if (!self.isWebViewBeSetting) {
        [self initWebView];
        
        if (!self.keyword) {
            self.keyword = @"";
        }
        if (!self.keyword) {
            self.keyword = @"";
        }
        self.keyword = [self.keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self webViewLoadRequestByKeyword:self.keyword searchType:self.searchType];
        self.isWebViewBeSetting = YES;
    }
}

- (void)initWebView {
    self.wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.webViewContainer.frame),CGRectGetHeight(self.webViewContainer.frame))];
    self.wkwebView.navigationDelegate = self;
    [self.webViewContainer addSubview:self.wkwebView];
}

- (void)webViewLoadRequestByKeyword:(NSString *)keyword searchType:(SearchType)searchType {
    NSString *urlString = @"";
    
    if (searchType == SearchWeb) {
        urlString = [NSString stringWithFormat:kSearchWeb,keyword];
    } else {
        urlString = [NSString stringWithFormat:kSearchImage,keyword];
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.wkwebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.addressTextField.text = webView.URL.absoluteString;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"%@",webView.URL.absoluteString);
    self.navigationItem.title = webView.title;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (IBAction)goBack:(UIButton *)sender {
    [self.wkwebView goBack];
}

- (IBAction)goForward:(UIButton *)sender {
    [self.wkwebView goForward];
}

- (IBAction)reload:(UIButton *)sender {
    [self.wkwebView reload];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *https = @"https://";
    NSString *http = @"http://";
    if ([textField.text length] > [http length]) {
        if ([textField.text length] > [https length]) {
            if ([[textField.text substringToIndex:8] isEqualToString:https]) {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:textField.text]];
                [self.wkwebView loadRequest:request];
            } else if ([[textField.text substringToIndex:7] isEqualToString:http]) {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:textField.text]];
                [self.wkwebView loadRequest:request];
            } else {
                [self webViewLoadRequestByKeyword:textField.text searchType:SearchWeb];
            }
        } else if ([textField.text length] > [http length]) {
            if ([[textField.text substringToIndex:6] isEqualToString:http]) {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:textField.text]];
                [self.wkwebView loadRequest:request];
            } else {
               [self webViewLoadRequestByKeyword:textField.text searchType:SearchWeb];
            }
        } else {
           [self webViewLoadRequestByKeyword:textField.text searchType:SearchWeb];
        }
    } else {
        [self webViewLoadRequestByKeyword:textField.text searchType:SearchWeb];
    }
    return YES;
}
@end
