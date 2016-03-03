//
//  IFWebViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFWebViewController.h"
#import "IFFileResource.h"
#import "UIViewController+ImageView.h"

@interface IFWebViewController ()

- (void)loadContent;
- (void)showLoadingIndicatorWithCompletion:(void(^)(void))completion;
- (void)hideLoadingImage;

@end

@interface UIActivityIndicatorView (FullScreen) @end

@implementation UIActivityIndicatorView (FullScreen)

- (void)didMoveToSuperview {
    self.frame = self.superview.frame;
}

@end

@implementation IFWebViewController

- (id)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor whiteColor];
        _useHTMLTitle = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        
        self.view = webView;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    webView.frame = self.view.bounds;
    loadingImageView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadContent];
}

#pragma mark - IFIOCConfigurable

- (void)beforeConfiguration:(id)configuration inContainer:(IFContainer *)container {}

- (void)afterConfiguration:(id)configuration inContainer:(IFContainer *)container {
    webView.backgroundColor = _backgroundColor;
    webView.opaque = _opaque;
    webView.scrollView.bounces = _scrollViewBounces;
    if (_loadingImage) {
        loadingImageView = [[UIImageView alloc] initWithImage:_loadingImage];
        loadingImageView.frame = webView.frame;
        loadingImageView.contentMode = UIViewContentModeCenter;
        loadingImageView.backgroundColor = _backgroundColor;
        [self.view addSubview:loadingImageView];
    }
    if (_showLoadingIndicator) {
        loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:webView.frame];
        loadingIndicatorView.hidden = YES;
        [self.view addSubview:loadingIndicatorView];
    }
}

#pragma mark - web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)view {
    [self hideLoadingImage];
    if (loadingIndicatorView) {
        loadingIndicatorView.hidden = YES;
    }
    if (_useHTMLTitle) {
        NSString *title = [view stringByEvaluatingJavaScriptFromString:@"document.title"];
        if ([title length]) {
            self.title = title;
        }
    }
    // Disable long touch events. See http://stackoverflow.com/questions/4314193/how-to-disable-long-touch-in-uiwebview
    [view stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
    // Change console.log to use the epConsoleLog function.
    //[view stringByEvaluatingJavaScriptFromString:@"console.log = epConsoleLog"];
    webViewLoaded = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    // Allow pre-configured URLs to load.
    if (_allowedExternalURLs) {
        NSString *urlString = [url description];
        for (NSString *allowedURL in _allowedExternalURLs) {
            if ([urlString hasPrefix:allowedURL]) {
                return YES;
            }
        }
    }
    // Load images (identified by file extension) when requested by a user action.
    NSString *ext = url.pathExtension;
    if ( navigationType == UIWebViewNavigationTypeLinkClicked && (
            [@"jpeg" isEqualToString:ext] ||
            [@"jpg" isEqualToString:ext] ||
            [@"png" isEqualToString:ext] ||
            [@"gif" isEqualToString:ext]) ) {
        [self showImageAtURL:url referenceView:self.view];
        return NO;
    }
    // Always load file: URLs.
    if ([@"file" isEqualToString:url.scheme]) {
        loadingExternalURL = NO;
        return YES;
    }
    // Always load data: URLs.
    if ([@"data" isEqualToString:url.scheme]) {
        loadingExternalURL = NO;
        return YES;
    }
    // If loading a pre-configured exernal URL...
    if (loadingExternalURL) {
        loadingExternalURL = NO;
        return YES;
    }
    else if (_loadExternalLinks && ([@"http" isEqualToString:url.scheme] || [@"https" isEqualToString:url.scheme])) {
        return YES;
    }
    else if (webViewLoaded && (navigationType != UIWebViewNavigationTypeOther)) {
        [self postMessage:[url description]];
        return NO;
    }
    return YES;
}

#pragma mark - private

- (void)loadContent {
    NSURL *contentURL = [NSURL URLWithString:_contentURL];
    // Specified content takes precedence over a contentURL property. Note that contentURL
    // can still be used to specify the content base URL in those cases where it can't
    // otherwise be determined.
    if (_content) {
        if ([_content isKindOfClass:[IFFileResource class]]) {
            IFFileResource *fileResource = (IFFileResource *)_content;
            NSString *html = [fileResource asString];
            // Note that a file resource can specify the base URL.
            [webView loadHTMLString:html baseURL:fileResource.externalURL];
        }
        else if ([_content isKindOfClass:[IFResource class]]) {
            IFResource *resource = (IFResource *)_content;
            NSString *html = [resource asString];
            [webView loadHTMLString:html baseURL:contentURL];
        }
        else {
            // Assume content's description will yield valid HTML.
            NSString *html = [_content description];
            [webView loadHTMLString:html baseURL:contentURL];
        }
    }
    else if (_contentURL) {
        NSURLRequest* req = [NSURLRequest requestWithURL:contentURL];
        loadingExternalURL = YES;
        [webView loadRequest:req];
    }
}

- (void)showLoadingIndicatorWithCompletion:(void(^)(void))completion {
    if (loadingIndicatorView) {
        loadingIndicatorView.hidden = NO;
        // Execute the completion on the main ui thread, after the spinner has had a chance to display.
        dispatch_async(dispatch_get_main_queue(), completion );
    }
    else completion();
}

- (void)hideLoadingImage {
    if (loadingImageView && !loadingImageView.hidden) {
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^{ loadingImageView.alpha = 0.0; }
                         completion: ^(BOOL finished) { loadingImageView.hidden = YES; }];
    }
}

#pragma mark - IFMessageHandler

- (BOOL)handleMessage:(IFMessage *)message sender:(id)sender {
    if ([message hasName:@"load"]) {
        self.content = [message.parameters objectForKey:@"content"];
        return YES;
    }
    return NO;
}

@end
