//
//  UIColor+Crop.m
//  EventPacComponents
//
//  Created by Julian Goacher on 13/04/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "UIImage+CropScale.h"

@implementation UIImage (CropScale)

- (UIImage*)crop:(CGRect)rect {
    // Taken from http://stackoverflow.com/questions/158914/cropping-a-uiimage
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

// Crop the image to the specified height, but keep the width unchanged. Will center the crop box.
// If the current image size is less than the requested height then returns the image unchanged.
- (UIImage*)cropToHeight:(CGFloat)height {
    UIImage* result = self;
    height *= self.scale;
    CGSize currentSize = [self size];
    if (currentSize.height > height) {
        CGFloat y = (currentSize.height - height) / 2;
        result = [self crop:CGRectMake( 0, y, currentSize.width, height )];
    }
    return result;
}

- (UIImage*)scale:(CGSize)size {
    UIImage* result = self;
    CGSize currentSize = [self size];
    // Seems that width/height don't have to account for scale here.
    //CGFloat width = size.width * self.scale, height = size.height * self.scale;
    CGFloat width = size.width, height = size.height;
    if (currentSize.height != height || currentSize.width != width) {
        UIGraphicsBeginImageContext(size);
        [self drawInRect:CGRectMake(0, 0, width, height)];
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return result;
}

- (UIImage*)scaleToWidth:(CGFloat)width {
    UIImage* result = self;
    CGSize currentSize = [self size];
    if (width > -1 && currentSize.width != width) {
        result = [self scale:CGSizeMake(width, currentSize.height * (width / currentSize.width))];
    }
    return result;
}

- (UIImage*)scaleToWidth:(CGFloat)width height:(CGFloat)height {
    return [self scale:CGSizeMake(width, height)];
}

@end
