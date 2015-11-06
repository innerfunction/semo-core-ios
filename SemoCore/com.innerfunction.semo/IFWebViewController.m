//
//  IFWebViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFWebViewController.h"
#import "IFFileResource.h"

@interface IFWebViewController ()

- (void)loadContent;
- (void)showLoadingIndicatorWithCompletion:(void(^)(void))completion;
- (void)hideLoadingImage;

@end

// TODO: Following are to force the webview and activity indicator to the full size of their subviews -
// Is there a better way to achieve this?

@interface UIWebView (FullScreen) @end

@implementation UIWebView (FullScreen)

- (void)didMoveToSuperview {
    self.frame = self.superview.frame;
}

@end

@interface UIActivityIndicatorView (FullScreen) @end

@implementation UIActivityIndicatorView (FullScreen)

- (void)didMoveToSuperview {
    self.frame = self.superview.frame;
}

@end
// -------------------------------------

@implementation IFWebViewController

- (id)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    webView = [[UIWebView alloc] init];
    webView.backgroundColor = _backgroundColor;
    webView.opaque = _opaque;
    webView.scrollView.bounces = _scrollViewBounces;
    webView.autoresizingMask = 1;
    webView.delegate = self;
    
    [self.view addSubview:webView];
    if (_loadingImage) {
        loadingImageView = [[UIImageView alloc] initWithImage:_loadingImage];
        loadingImageView.frame = webView.frame;
        [self.view addSubview:loadingImageView];
    }
    
    if (_showLoadingIndicator) {
        loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:webView.frame];
        loadingIndicatorView.hidden = YES;
        [self.view addSubview:loadingIndicatorView];
    }
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
    if (_allowedExternalURLs) {
        NSString *urlString = [url description];
        for (NSString *allowedURL in _allowedExternalURLs) {
            if ([urlString hasPrefix:allowedURL]) {
                return YES;
            }
        }
    }
    
    if ([@"file" isEqualToString:url.scheme]) {
        loadingExternalURL = NO;
        return YES;
    }
    if ([@"data" isEqualToString:url.scheme]) {
        loadingExternalURL = NO;
        return YES;
    }
    
    if (loadingExternalURL) {
        loadingExternalURL = NO;
        return YES;
    }
    else if (_loadExternalLinks && ([@"http" isEqualToString:url.scheme] || [@"https" isEqualToString:url.scheme])) {
        return YES;
    }
    else if (webViewLoaded && (navigationType != UIWebViewNavigationTypeOther)) {
        [self dispatchURI:[url description]];
        return NO;
    }
    return YES;
}

#pragma mark - private

- (void)loadContent {
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
            [webView loadHTMLString:html baseURL:_contentURL];
        }
        else {
            // Assume content's description will yield valid HTML.
            NSString *html = [_content description];
            [webView loadHTMLString:html baseURL:_contentURL];
        }
    }
    else if (_contentURL) {
        NSURLRequest* req = [NSURLRequest requestWithURL:_contentURL];
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
        [UIView animateWithDuration: 0.75
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^{ loadingImageView.alpha = 0.0; }
                         completion: ^(BOOL finished) { loadingImageView.hidden = YES; }];
    }
}

#pragma mark - IFTarget

- (void)doAction:(IFDoAction *)action {
    if ([@"load" isEqualToString:action.name]) {
        self.content = [action.parameters objectForKey:@"content"];
    }
    else {
        [super doAction:action];
    }
}

@end
