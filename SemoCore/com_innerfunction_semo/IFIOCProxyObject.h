//
//  IFIOCProxyObject.h
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCProxy.h"

@interface IFIOCProxyObject : NSObject <IFIOCProxy> {
    NSString *_propertyName;
    id _object;
    BOOL _isNewValue;
}

@property (nonatomic, strong) id proxiedValue;

@end
