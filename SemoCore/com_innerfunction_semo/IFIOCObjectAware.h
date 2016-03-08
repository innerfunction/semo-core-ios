//
//  IFIOCObjectAware.h
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol implemented by property values that wish to be aware of their property's parent object.
@protocol IFIOCObjectAware <NSObject>

// Notify a value that it is about to be injected into an object using the specified property.
- (void)notifyIOCObject:(id)object propertyName:(NSString *)propertyName;

@end
