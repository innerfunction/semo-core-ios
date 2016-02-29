//
//  UIViewController+ImageView.h
//  SemoCore
//
//  Created by Julian Goacher on 29/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ImageView)

- (void)showImageAtURL:(NSURL *)url referenceView:(UIView *)refView;
- (void)showImage:(UIImage *)image referenceView:(UIView *)refView;

@end
