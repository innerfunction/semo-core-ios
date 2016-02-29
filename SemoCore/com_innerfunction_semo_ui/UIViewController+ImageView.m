//
//  UIViewController+ImageView.m
//  SemoCore
//
//  Created by Julian Goacher on 29/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "UIViewController+ImageView.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

@implementation UIViewController (ImageView)

- (void)showImageAtURL:(NSURL *)url referenceView:(UIView *)refView {
    // Create image info
    JTSImageInfo *imageInfo = [JTSImageInfo new];
    imageInfo.imageURL = url;
    imageInfo.referenceRect = refView.frame;
    imageInfo.referenceView = refView.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)showImage:(UIImage *)image referenceView:(UIView *)refView {
    // Create image info
    JTSImageInfo *imageInfo = [JTSImageInfo new];
    imageInfo.image = image;
    imageInfo.referenceRect = refView.frame;
    imageInfo.referenceView = refView.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

@end
