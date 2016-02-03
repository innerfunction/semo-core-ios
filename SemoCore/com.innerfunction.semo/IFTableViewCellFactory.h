//
//  IFTableViewCellFactory.h
//  SemoCore
//
//  Created by Julian Goacher on 24/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTableData.h"
#import "IFConfiguration.h"

@class IFTableViewController;
@class IFTableViewCellFactory;

@protocol IFTableViewCellDecorator <NSObject>

- (UITableViewCell *)decorateCell:(UITableViewCell *)cell data:(NSDictionary *)data factory:(IFTableViewCellFactory *)factory;

@end

@interface IFTableViewCellFactory : NSObject {
    NSCache *imageCache;
}

@property (nonatomic, strong) id<IFTableViewCellDecorator> decorator;
@property (nonatomic, strong) IFTableData *tableData;

@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *detailTextColor;
@property (nonatomic, strong) UIColor *selectedDetailTextColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *imageWidth;
@property (nonatomic, strong) NSNumber *imageHeight;
@property (nonatomic, strong) NSString *accessory;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

- (UITableViewCell *)resolveCellForTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
