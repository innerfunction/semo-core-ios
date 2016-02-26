//
//  IFWebViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 23/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFViewController.h"
#import "IFIOCConfigurable.h"
#import "IFPostActionHandler.h"

@interface IFWebViewController : IFViewController <UIWebViewDelegate, IFIOCConfigurable, IFPostActionHandler> {
    UIWebView *webView;
    UIImageView *loadingImageView;
    UIActivityIndicatorView *loadingIndicatorView;
    BOOL loadingExternalURL;
    BOOL webViewLoaded;
}

/** An image to be displayed whilst the initial page loads. */
@property (nonatomic, strong) UIImage *loadingImage;
/** Whether to display a loading indicator. */
@property (nonatomic, assign) BOOL showLoadingIndicator;
/** A flag indicating whether to load external links within the web view. */
@property (nonatomic, assign) BOOL loadExternalLinks;
/** A flag indicating whether the view controller should use the title of the loaded HTML page as its title. */
@property (nonatomic, assign) BOOL useHTMLTitle;
/** The view background colour. */
@property (nonatomic, strong) UIColor *backgroundColor;
/** Whether the webview is opaque. iOS only property. */
@property (nonatomic, assign) BOOL opaque;
/** Whether the webview bounces during scroll. iOS only property. */
@property (nonatomic, assign) BOOL scrollViewBounces;
/** A list of allowed external URLs. */
@property (nonatomic, strong) NSArray *allowedExternalURLs;
/** A URL to load content from. Only called if no content is directly specified. */
@property (nonatomic, strong) NSString *contentURL;
/** The web view content. May be specified using a string or a URI resource. */
@property (nonatomic, strong) id content;

@end
