//
//  UIColor+Crop.h
//  EventPacComponents
//
//  Created by Julian Goacher on 13/04/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIImage (CropScale)

- (UIImage *)crop:(CGRect)rect;
- (UIImage *)cropToHeight:(CGFloat)height;
- (UIImage *)scale:(CGSize)size;
- (UIImage *)scaleToWidth:(CGFloat)width;
- (UIImage *)scaleToWidth:(CGFloat)width height:(CGFloat)height;

@end
