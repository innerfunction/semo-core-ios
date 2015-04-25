//
//  AppContainerTest.m
//  SemoCore
//
//  Created by Julian Goacher on 25/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IFAppContainer.h"
#import "Animal.h"
#import "Color.h"
#import "Forest.h"
#import "Fruit.h"
#import "Plant.h"
#import "Thing.h"
#import "IOCConfigurable.h"
#import "Configurable.h"

@interface AppContainerTest : XCTestCase {
    IFAppContainer *container;
}

@end

@implementation AppContainerTest

- (void)setUp
{
    [super setUp];
    container = [IFAppContainer getAppContainer];
    [container loadConfiguration:@"app:/configuration.json"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMonkey {
    Animal *monkey = (Animal *)[container getNamed:@"monkey"];
    Fruit *banana = (Fruit *)[container getNamed:@"banana"];
    Color *yellow = (Color *)[container getNamed:@"yellow"];
    
    XCTAssertNotNil(monkey, @"Monkey not found");
    XCTAssertNotNil(banana, @"Banana not found");
    XCTAssertNotNil(yellow, @"Yellow not found");
    XCTAssertTrue(monkey.likes == banana, @"Monkey doesn't like banana");
    XCTAssertTrue(banana.color == yellow, @"Banana isn't yellow");
    XCTAssertEqualObjects(yellow.value, @"#00FFFF", @"Yellow isn't 00FFFF");
}

- (void)testTree {
    Plant *tree = (Plant *)[container getNamed:@"tree"];
    NSArray *contains = tree.contains;
    
    XCTAssertTrue([contains count] == 4, @"Tree doesn't contain 4 items");
    XCTAssertTrue([contains objectAtIndex:0] == [container getNamed:@"monkey"], @"Tree doesn't contain monkey");
    XCTAssertTrue([contains objectAtIndex:1] == [container getNamed:@"banana"], @"Tree doesn't contain banana");
    Thing *parrot = (Thing *)[contains objectAtIndex:3];
    XCTAssertEqualObjects(parrot.name, @"Parrot", @"Parrot isn't named Parrot");
}

- (void)testJungle {
    Forest *jungle = (Forest *)[container getNamed:@"jungle"];
    NSDictionary *things = jungle.thingsInTheForest;
    
    XCTAssertTrue([things count] > 0, @"Nothing in the jungle");
    XCTAssertTrue([things count] == 2, @"Expected two things in the jungle");
    XCTAssertTrue([container getNamed:@"tree"] == [things objectForKey:@"tree"], @"Tree not found in jungle");
    Thing *jaguar = (Thing *)[things objectForKey:@"jaguar"];
    XCTAssertEqualObjects(jaguar.name, @"Jaguar", @"Jaguar isn't named Jaguar");
}

- (void)testIOCConfigurableProtocol {
    IOCConfigurable *ioconfig = (IOCConfigurable *)[container getNamed:@"iocconfigurable"];
    
    XCTAssertTrue(ioconfig.beforeConfigureCalled, @"beforeConfigure not called");
    XCTAssertTrue(ioconfig.afterConfigureCalled, @"afterConfigure not called");
}

- (void)testConfigurableProtocol {
    Configurable *configurable = (Configurable *)[container getNamed:@"ConfigurableImplementation"];
    
    XCTAssertEqualObjects(configurable.value, @"two", @"Configurable value not 'two'");
    XCTAssertTrue(configurable.configured, @"Configurable not configured");
}
@end
