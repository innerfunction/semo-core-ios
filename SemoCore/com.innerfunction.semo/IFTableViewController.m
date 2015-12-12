//
//  IFTableViewController.m
//  SemoCore
//
//  Created by Julian Goacher on 24/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFTableViewController.h"
#import "IFContainer.h"
#import "UIViewController+Toast.h"
#import "NSDictionary+IFValues.h"
#import "IFLogging.h"

#define SectionHeaderHeight     (22.0f)
#define SectionHeaderViewHeight (18.0f)
#define SectionHeaderFontSize   (14.0f)

@interface IFTableViewController()

// Hide the search bar.
- (void)hideSearchBar;
// Get the table cell factory for the specified row position.
- (IFTableViewCellFactory *)cellFactoryForIndexPath:(NSIndexPath *)indexPath;
// Get the display mode for the table row at the specified position.
- (NSString *)displayModeForIndexPath:(NSIndexPath *)indexPath;
// Get the position of the first table row with the specified display mode.
- (NSIndexPath *)indexPathForFirstRowWithDisplayMode:(NSString *)displayMode;

@end

@implementation IFTableViewController

#pragma mark - IFTargetContainer

@synthesize parentTargetContainer, namedTargets;

#pragma mark - IFIOCConfigurationInitable

- (id)initWithConfiguration:(IFConfiguration *)configuration {
    UITableViewStyle style;
    NSString *value = [configuration getValueAsString:@"tableStyle" defaultValue:@"Plain"];
    if ([value isEqualToString:@"Grouped"]) {
        style = UITableViewStyleGrouped;
    }
    else {
        style = UITableViewStylePlain;
    }
    self = [super initWithStyle:style];
    if (self) {
        self.namedTargets = [NSDictionary dictionary];
        _tableData = [[IFTableData alloc] init];
    }
    return self;
}

#pragma mark - IFIOCTypeInspectable

- (Class)memberClassForCollection:(NSString *)propertyName {
    if ([@"cellFactoriesByDisplayMode" isEqualToString:propertyName]) {
        return [IFTableViewCellFactory class];
    }
    return nil;
}

#pragma mark - IFIOCConfigurable

- (void)beforeConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container {}

- (void)afterConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container {
    defaultFactory = (IFTableViewCellFactory *)[_cellFactoriesByDisplayMode objectForKey:@"default"];
    if (!defaultFactory) {
         defaultFactory = [[IFTableViewCellFactory alloc] init];
        [container configureObject:defaultFactory withConfiguration:configuration identifier:@"IFTableViewController.defaultFactory"];
         defaultFactory.tableData = _tableData;
    }
}

#pragma mark - configuration properties

- (void)setCellFactoriesByDisplayMode:(NSDictionary *)cellFactoriesByDisplayMode {
    _cellFactoriesByDisplayMode = cellFactoriesByDisplayMode;
    for (id name in [cellFactoriesByDisplayMode keyEnumerator]) {
        IFTableViewCellFactory *cellFactory = [cellFactoriesByDisplayMode objectForKey:name];
        cellFactory.tableData = _tableData;
    }
}

- (void)setContent:(id)content {
    _content = content;
    if ([content isKindOfClass:[NSArray class]]) {
        _tableData.data = (NSArray *)content;
    }
    else if ([content isKindOfClass:[IFResource class]]) {
        id data = [(IFResource *)content asJSONData];
        if ([data isKindOfClass:[NSArray class]]) {
            _tableData.data = (NSArray *)data;
        }
    }
    else {
        DDLogWarn(@"%@: Unable to set content of type %@", LogTag, [[content class] description]);
    }
    // Refresh the list view.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - view lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (_hasSearchBar) {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        searchBar.delegate = self;
        searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        self.tableView.tableHeaderView = searchBar;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_selectedID) {
        NSIndexPath *selectedPath = [_tableData pathForRowWithValue:_selectedID forField:@"id"];
        if (selectedPath) {
            [self.tableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            _scrollToSelected = YES;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstShow) {
        [self hideSearchBar];
        isFirstShow = NO;
    }
    if (_scrollToSelected) {
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_tableData sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData sectionSize:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_tableData sectionTitle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IFTableViewCellFactory *cellFactory = [self cellFactoryForIndexPath:indexPath];
    return [cellFactory resolveCellForTable:tableView indexPath:indexPath];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *action = [[_tableData rowDataForIndexPath:indexPath] getValueAsString:@"action"];
    if (action) {
        [self dispatchURI:action];
    }
    [_tableData clearFilter];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IFTableViewCellFactory *cellFactory = [self cellFactoryForIndexPath:indexPath];
    return [cellFactory heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [_tableData sectionCount] > 1 ? SectionHeaderHeight : 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_tableData sectionCount] == 1) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SectionHeaderViewHeight)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, tableView.frame.size.width, SectionHeaderViewHeight)];
    [label setFont:[UIFont boldSystemFontOfSize:SectionHeaderFontSize]];
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    [label setText:title];
    label.backgroundColor = [UIColor clearColor];
    if (_sectionTitleColor) {
        label.textColor = _sectionTitleColor;
    }
    [view addSubview:label];
    if (_sectionTitleBackgroundColor) {
        view.backgroundColor = _sectionTitleBackgroundColor;
    }
    return view;
}

#pragma mark - public methods

- (void)clearFilter {
    [_tableData clearFilter];
    [self.tableView reloadData];
    if (_clearFilterMessage) {
        [self showToastMessage:_clearFilterMessage];
    }
}

#pragma mark - private methods

- (IFTableViewCellFactory *)cellFactoryForIndexPath:(NSIndexPath *)indexPath {
    NSString *displayMode = [self displayModeForIndexPath:indexPath];
    IFTableViewCellFactory *cellFactory = (IFTableViewCellFactory *)[_cellFactoriesByDisplayMode valueForKey:displayMode];
    if (!cellFactory) {
        cellFactory = defaultFactory;
    }
    return cellFactory;
}

- (NSString *)displayModeForIndexPath:(NSIndexPath *)indexPath {
    return @"default";
}

- (NSIndexPath *)indexPathForFirstRowWithDisplayMode:(NSString *)displayMode {
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            if ([displayMode isEqualToString:[self displayModeForIndexPath:path]]) {
                return path;
            }
        }
    }
    return nil;
}

- (void)hideSearchBar {
    if (![_tableData isEmpty]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    [_tableData filterBy:searchText scope:scope];
}

- (void)reloadDataWithCompletion:(void(^)(void))completionBlock {
    [self.tableView reloadData];
    [self hideSearchBar];
    if (completionBlock) {
        completionBlock();
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSInteger idx = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:idx];
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:scope];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption];
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:scope];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_tableData clearFilter];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideSearchBar];
    });
}

#pragma mark - IFActionDispatcher

- (BOOL)dispatchURI:(NSString *)uri {
    return [self.parentTargetContainer dispatchURI:uri];
}

#pragma mark - IFTarget

- (void)doAction:(IFDoAction *)action {
    if ([@"load" isEqualToString:action.name]) {
        self.content = [action.parameters objectForKey:@"content"];
    }
}

@end