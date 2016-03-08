//
//  IFIOCTextFieldProxy.m
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFUITextFieldProxy.h"
#import "IFContainer.h"

@implementation IFUITextFieldProxy

- (id)init {
    self = [super init];
    if (self) {
        _textField = [UITextField new];
    }
    return self;
}

- (id)initWithValue:(id)value {
    self = [super init];
    if (self) {
        _textField = (UITextField *)value;
    }
    return self;
}

- (void)setText:(NSString *)text {
    _textField.text = text;
}

- (NSString *)text {
    return _textField.text;
}

- (id)unwrapValue {
    [_style applyToTextField:_textField];
    return _textField;
}

#pragma mark - Class loading

+ (void)load {
    [IFContainer registerConfigurationProxyClass:self forClassName:@"UITextField"];
}

@end
