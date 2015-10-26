//
//  IFTableViewCellFactory.h
//  SemoCore
//
//  Created by Julian Goacher on 24/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTableData.h"
#import "IFResource.h"
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
@property (nonatomic, strong) IFResource *baseResource;
@property (nonatomic, strong) IFConfiguration *rowConfiguration;

- (UITableViewCell *)resolveCellForTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
