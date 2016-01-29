//
//  IFTableViewController.h
//  SemoCore
//
//  Created by Julian Goacher on 24/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTableData.h"
#import "IFTableViewCellFactory.h"
#import "IFIOCTypeInspectable.h"
#import "IFIOCConfigurationInitable.h"
#import "IFIOCConfigurable.h"
#import "IFTarget.h"
#import "IFTargetContainer.h"

// A basic table view component.
// Recognized configuration keys are:
// * tableStyle:    "Grouped" or "Plain"; see UITableViewStyle.
// * rowStyle:     The default table cell style. See values for table cell 'style' property described below.
// * rowBackgroundImage:
// * rowSelectedBackgroundImage:
// * rowHeight
//
// Implements the EPContentView protocol and accepts array data in two formats, depending on the table style.
// * Plain tables:   Data should be an NSArray of table cell data.
// * Grouped tables: Data should be an NSArray of table sections, where each section is an NSArray of table cell data.
//
// Each table cell data item must be an NSDictionary with the following properties:
// * title:             The main text displayed on the cell.
// * description:       Additional text displayed below the title (Optional).
// * image:             URI of an image to display on the LHS of the cell (Optional).
// * accessory:         Type of the accessory view displayed on the RHS of the cell (Optional).
//                      Takes the following values, corresponding to the values defined for UITableViewCellAccessoryType:
//                      + None
//                      + DisclosureIndicator
//                      + DetailButton
//                      + Checkmark
// * style:             The cell style. Overrides the style specified in the configuration when supplied (Optional).
//                      Has the following values, corresponding to the values defined by UITableViewCellStyle:
//                      + Default
//                      + Style1
//                      + Style2
//                      + Subtitle
// * backgroundImage:   URI of the cell background image. Overrides any value specified in the configuration. (Optional).
// * selectedBackgroundImage: URI of the cell background image when selected. (Optional).
// * height:            The row height.
// * action:            A dispatch URI which is invoked when a table cell is selected.
@interface IFTableViewController : UITableViewController <UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, IFIOCTypeInspectable, IFIOCConfigurationInitable, IFIOCConfigurable, IFTarget, IFTargetContainer> {
    
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    IFTableViewCellFactory *defaultFactory;
    BOOL isFirstShow;
}

@property (nonatomic, strong) NSDictionary *cellFactoriesByDisplayMode;
@property (nonatomic, strong) UIColor *sectionTitleColor;
@property (nonatomic, strong) UIColor *sectionTitleBackgroundColor;
@property (nonatomic, assign) BOOL scrollToSelected;
@property (nonatomic, strong) IFTableData *tableData;
@property (nonatomic, strong) NSString *selectedID;
@property (nonatomic, assign) BOOL hasSearchBar;
@property (nonatomic, strong) NSString *clearFilterMessage;
@property (nonatomic, strong) id content;

// Format incoming list data.
// Principally intended as a mechanism for subclasses to interface with specific data sources.
- (NSArray *)formatData:(NSArray *)data;
// Clear any currently applied table data filter.
- (void)clearFilter;

@end
