//
//  IFTableViewCellFactory.m
//  SemoCore
//
//  Created by Julian Goacher on 24/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFTableViewCellFactory.h"
#import "IFTableViewController.h"
#import "UIColor+IF.h"
#import "UIImage+CropScale.h"
#import "NSDictionary+IFValues.h"
#import "IFTypeConversions.h"

#define DefaultRowHeight        [NSNumber numberWithFloat:44.0]
#define DefaultRowImageWidth    [NSNumber numberWithFloat:40.0]

@interface IFTableViewCellFactory()

- (UIImage *)loadImageWithRowData:(NSDictionary *)rowData dataName:(NSString *)dataName;
- (UIImage *)loadImageWithRowData:(NSDictionary *)rowData dataName:(NSString *)dataName width:(CGFloat)width height:(CGFloat)height;
- (UIImage *)dereferenceImage:(NSString *)imageRef;

@end

@implementation IFTableViewCellFactory

- (id)init {
    self = [super init];
    if (self) {
        imageCache = [[NSCache alloc] init];
    }
    return self;
}

#define RowDataStringValue(name)    ([rowData getValueAsString:name defaultValue:[_rowConfiguration getValueAsString:name]])
#define RowDataCGFloatValue(name)   ((CGFloat)[[rowData getValueAsNumber:name defaultValue:[_rowConfiguration getValueAsNumber:name]] floatValue])

- (UITableViewCell *)resolveCellForTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [_tableData rowDataForIndexPath:indexPath];
    
    NSString *style = RowDataStringValue(@"style");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:style];
    
    if (!cell) {
        UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
        if ([style isEqualToString:@"Style1"]) {
            cellStyle = UITableViewCellStyleValue1;
        }
        else if ([style isEqualToString:@"Style2"]) {
            cellStyle = UITableViewCellStyleValue2;
        }
        else if ([style isEqualToString:@"Subtitle"]) {
            cellStyle = UITableViewCellStyleSubtitle;
        }
        cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:style];
    }
    
    NSString *title       = RowDataStringValue(@"title");
    NSString *description = RowDataStringValue(@"description");
    
    cell.textLabel.text = title;
    if (description) {
        cell.detailTextLabel.text = description;
    }
    
    NSString *textColor = RowDataStringValue(@"textColor");
    NSString *selectedTextColor = RowDataStringValue(@"selectedTextColor");
    cell.textLabel.textColor = [UIColor colorForHex:textColor];
    cell.textLabel.highlightedTextColor = [UIColor colorForHex:selectedTextColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor colorForHex:RowDataStringValue(@"detailTextColor")];
    cell.detailTextLabel.highlightedTextColor = [UIColor colorForHex:RowDataStringValue(@"detailSelectedTextColor")];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor colorForHex:RowDataStringValue(@"backgroundColor")];
    
    NSString *selectedBackgroundColor = RowDataStringValue(@"selectedBackgroundColor");
    // NOTE: This won't work correctly on grouped lists with rounded corners:
    if (selectedBackgroundColor) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorForHex:selectedBackgroundColor];
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    CGFloat imageHeight = RowDataCGFloatValue(@"imageHeight");
    if (!imageHeight) {
        imageHeight = RowDataCGFloatValue(@"height");
    }
    CGFloat imageWidth = RowDataCGFloatValue(@"imageWidth");
    UIImage *image = [self loadImageWithRowData:rowData dataName:@"image" width:imageWidth height:imageHeight];
    if (image) {
        cell.imageView.image = image;
        // Add rounded corners to image.
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 3.0;
    }
    else {
        cell.imageView.image = nil;
    }
    
    NSString *accessory = RowDataStringValue(@"accessory");
    if ([accessory isEqualToString:@"None"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([accessory isEqualToString:@"DisclosureIndicator"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([accessory isEqualToString:@"DetailButton"]) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else if ([accessory isEqualToString:@"Checkmark"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    UIImage *backgroundImage  = [self loadImageWithRowData:rowData dataName:@"backgroundImage"];
    UIImage *selectedImage    = [self loadImageWithRowData:rowData dataName:@"selectedBackgroundImage"];
    
    if (backgroundImage) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        cell.backgroundView.contentMode = UIViewContentModeCenter;
    }
    if (selectedImage) {
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedImage];
        cell.selectedBackgroundView.contentMode = UIViewContentModeCenter;
    }
    
    if (_decorator) {
        cell = [_decorator decorateCell:cell data:rowData factory:self];
    }
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [_tableData rowDataForIndexPath:indexPath];
    return RowDataCGFloatValue(@"height");
}

#pragma mark - private methods

- (UIImage *)loadImageWithRowData:(NSDictionary *)rowData dataName:(NSString *)dataName {
    UIImage *image = nil;
    NSString *imageName = [rowData getValueAsString:dataName];
    if (!imageName) {
        imageName = [_rowConfiguration getValueAsString:dataName];
    }
    if (imageName) {
        image = [imageCache objectForKey:imageName];
        if (!image) {
            image = [self dereferenceImage:imageName];
            if (image) {
                [imageCache setObject:image forKey:imageName];
            }
            else {
                [imageCache setObject:[NSNull null] forKey:imageName];
            }
        }
        else if ([[NSNull null] isEqual:image]) {
            // NSNull in the image cache indicates image not found, so return nil.
            image = nil;
        }
    }
    return image;
}

- (UIImage *)loadImageWithRowData:(NSDictionary *)rowData dataName:(NSString *)dataName width:(CGFloat)width height:(CGFloat)height {
    UIImage *image = nil;
    NSString *imageName = [rowData getValueAsString:dataName];
    if (!imageName) {
        imageName = [_rowConfiguration getValueAsString:dataName];
    }
    if (imageName) {
        NSString *cacheName = [NSString stringWithFormat:@"%@-%fx%f", imageName, width, height];
        image = [imageCache objectForKey:cacheName];
        if (!image) {
            image = [self dereferenceImage:imageName];
            // Scale the image if we have an image and width * height is not zero (implying that neither value is zero).
            if (image && (width * height)) {
                image = [[image scaleToWidth:width] cropToHeight:height];
                [imageCache setObject:image forKey:cacheName];
            }
            else {
                [imageCache setObject:[NSNull null] forKey:imageCache];
            }
        }
        else if ([[NSNull null] isEqual:image]) {
            // NSNull in the image cache indicates image not found, so return nil.
            image = nil;
        }
    }
    return image;
}

- (UIImage *)dereferenceImage:(NSString *)imageRef {
    UIImage *image = nil;
    if ([imageRef hasPrefix:@"@"]) {
        NSString* uri = [imageRef substringFromIndex:1];
        IFResource *imageRsc = [self.baseResource derefStringToResource:uri];
        if (imageRsc) {
            image = [imageRsc asImage];
        }
    }
    else {
        image = [IFTypeConversions asImage:imageRef];
    }
    return image;
}

@end
