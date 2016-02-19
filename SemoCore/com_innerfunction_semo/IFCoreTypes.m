//
//  IFCoreTypes.m
//  SemoCore
//
//  Created by Julian Goacher on 28/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFCoreTypes.h"

@implementation IFCoreTypes

+ (NSDictionary *)types {
    return @{
        @"EmptyView":      @"IFTargetContainerViewController",
        @"NavigationView": @"IFNavigationViewController",
        @"SlideView":      @"IFSlideViewController",
        @"WebView":        @"IFWebViewController",
        @"ListView":       @"IFListViewController"
    };
}

@end
