//
//  IFIOCLabelProxy.m
//  SemoCore
//
//  Created by Julian Goacher on 04/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFUILabelProxy.h"
#import "IFContainer.h"

@implementation IFUILabelProxy

- (id)init {
    self = [super init];
    if (self) {
        _label = [UILabel new];
    }
    return self;
}

- (id)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _label = (UILabel *)value;
    }
    return self;
}

- (void)setText:(NSString *)text {
    _label.text = text;
}

- (NSString *)text {
    return _label.text;
}

- (id)unwrapValue {
    [_style applyToLabel:_label];
    return _label;
}

#pragma mark - Class loading

+ (void)load {
    [IFContainer registerConfigurationProxyClass:self forClassName:@"UILabel"];
}

@end
