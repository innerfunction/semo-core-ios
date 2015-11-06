//
//  IFLocalSchemeHandler.m
//  EventPacComponents
//
//  Created by Julian Goacher on 13/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFLocalSchemeHandler.h"

@implementation IFLocalResource

@synthesize key, storage;

- (id)getData {
    return [storage objectForKey:key];
}

- (void)setData:(id)_data {
    self.data = _data;

    // TODO: It's not clear whether NSUserDefaults will perform correct type conversions when a value
    // set using setObject: is read back out using a type specific method.
    // For example, is an NSNumber is passed here, representing either a bool or a float, will a read
    // using the corresponding floatForKey: or bookForKey: methods return the correct value?
    // Testing is necessary to find out.
    [storage setObject:self.data forKey:key];
    
    // Send notification of the update.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IFNotificationLocalDataUpdate" object:key];
}

- (NSString *)asString {
    return [storage stringForKey:key];
}

@end

@implementation IFLocalSchemeHandler

- (id)init {
    self = [super init];
    if (self) {
        storage = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (id)dereference:(IFCompoundURI *)uri parameters:(NSDictionary *)params parent:(id<IFResourceContext>)parent {
    // Init resource with nil data - data will be resolved when data property is requested.
    IFLocalResource *resource = [[IFLocalResource alloc] initWithData:nil uri:uri parent:parent];
    resource.key = uri.name;
    resource.storage = storage;
    return resource;
}

@end
