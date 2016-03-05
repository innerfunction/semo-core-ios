//
//  IFIOCLabelProxy.m
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFIOCLabelProxy.h"

@implementation IFIOCLabelProxy

- (void)beforeConfiguration:(IFConfiguration *)configuration inContainer:(IFContainer *)container {
    if (self->_isNewValue) {
        self.proxiedValue = [[UILabel alloc] init];
    }
}

@end
