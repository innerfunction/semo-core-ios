//
//  IFIOCProxyObject.h
//  SemoCore
//
//  Created by Julian Goacher on 09/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCProxy.h"
#import "IFContainer.h"

/**
 * A concrete implementation of the IOCProxy protocol. The main purpose of this class is to provide
 * a standard method for proxy class registration if IFContainer. Subclasses can invoke the
 * [registerConfigurationProxyClass: forClassName:] class method from their class [load] method;
 * IFContainer will then call the [registerProxyClasses] method on this class.
 * It's not required that configuration proxies extend this class, but implementations which don't
 * will then need to provide their own alternative registratio method.
 */
@interface IFIOCProxyObject : NSObject <IFIOCProxy>

+ (void)registerConfigurationProxyClass:(Class)proxyClass forClassName:(NSString *)className;

+ (NSDictionary *)registeredProxyClasses;

@end
