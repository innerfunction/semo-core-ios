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

@end
