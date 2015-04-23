//
//  IFAppContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFAppContainer.h"
#import "IFConfiguration.h"
#import "IFLogging.h"

@interface IFAppContainer ()

- (NSDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration;

@end

@implementation IFAppContainer

- (id)init {
    self = [super init];
    if (self) {
        resolver = [[IFStandardURIResolver alloc] init];
    }
    return self;
}

- (void)loadConfiguration:(id)configSource {
    IFConfiguration *configuration = nil;
    if ([configSource isKindOfClass:[IFConfiguration class]]) {
        configuration = (IFConfiguration *)configSource;
    }
    else {
        IFCompoundURI *uri = nil;
        if ([configSource isKindOfClass:[IFCompoundURI class]]) {
            uri = (IFCompoundURI *)configSource;
        }
        else if ([configSource isKindOfClass:[NSString class]]) {
            NSError *error = nil;
            uri = [[IFCompoundURI alloc] initWithURI:(NSString *)configSource error:&error];
            if (error) {
                DDLogCError(@"Error parsing app container configuration URI: %@", error);
                return;
            }
        }
        
        if (uri) {
            DDLogInfo(@"Loading app container configuration from %@", uri);
            IFResource *resource = [resolver resolveURI:uri];
            configuration = [[IFConfiguration alloc] initWithResource:resource];
        }
        else {
            DDLogInfo(@"Attempting to configure app container with data...");
            configuration = [[IFConfiguration alloc] initWithData:configSource];
        }
    }
    [self configureWith:configuration];
}


@end
