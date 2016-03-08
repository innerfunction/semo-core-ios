//
//  IFIOCProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFIOCProxy <NSObject>

- (id)initWithValue:(id)value;
- (id)unwrapValue;

@end
