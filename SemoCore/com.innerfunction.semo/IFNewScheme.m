//
//  IFNewScheme.m
//  SemoCore
//
//  Created by Julian Goacher on 22/10/2015.
//  Copyright © 2015 InnerFunction. All rights reserved.
//

#import "IFNewScheme.h"

@implementation IFNewScheme

- (id)initWithContainer:(IFContainer *)_container {
    self = [super init];
    if (self) {
        container = _container;
    }
    return self;
}

- (IFCompoundURI *)resolve:(IFCompoundURI *)uri against:(IFCompoundURI *)reference {
    return uri;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(IFResource *)parent {
    NSString *className = uri.name;
    IFConfiguration *config = [[IFConfiguration alloc] initWithData:params];
    id result = [container newInstanceForClassName:className withConfiguration:config];
    if (result) {
        [container configureObject:result withConfiguration:config identifier:[uri description]];
    }
    return result;
}

@end
