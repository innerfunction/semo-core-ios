//
//  IFIOCTextFieldProxy.m
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFUITextFieldProxy.h"
#import "IFContainer.h"

#define Number(i)   ([NSNumber numberWithInteger:i])

@implementation IFUITextFieldProxy

static NSDictionary *IFUITextFieldProxy_autocapitalizationLabels;
static NSDictionary *IFUITextFieldProxy_keyboardLabels;

+ (void)initialize {
    IFUITextFieldProxy_autocapitalizationLabels = @{
        @"none":        Number(UITextAutocapitalizationTypeNone),
        @"words":       Number(UITextAutocapitalizationTypeWords),
        @"sentences":   Number(UITextAutocapitalizationTypeSentences),
        @"all":         Number(UITextAutocapitalizationTypeAllCharacters)
    };
    IFUITextFieldProxy_keyboardLabels = @{
        @"default":     Number(UIKeyboardTypeDefault),
        @"web":         Number(UIKeyboardTypeURL),
        @"number":      Number(UIKeyboardTypeNumberPad),
        @"phone":       Number(UIKeyboardTypePhonePad),
        @"email":       Number(UIKeyboardTypeEmailAddress)
    };
}

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

- (void)setAutocapitalization:(NSString *)autocapitalization {
    NSNumber *type = IFUITextFieldProxy_autocapitalizationLabels[[autocapitalization lowercaseString]];
    if (type) {
        _textField.autocapitalizationType = [type integerValue];
    }
}

- (NSString *)autocapitalization {
    NSNumber *value = [NSNumber numberWithInteger:_textField.autocapitalizationType];
    return [[IFUITextFieldProxy_autocapitalizationLabels allKeysForObject:value] firstObject];
}

- (void)setKeyboard:(NSString *)keyboard {
    NSNumber *type = IFUITextFieldProxy_keyboardLabels[[keyboard lowercaseString]];
    if (type) {
        _textField.keyboardType = [type integerValue];
    }
}

- (NSString *)keyboard {
    NSNumber *value = [NSNumber numberWithInteger:_textField.keyboardType];
    return [[IFUITextFieldProxy_keyboardLabels allKeysForObject:value] firstObject];
}

- (void)setAutocorrection:(BOOL)autocorrection {
    _textField.autocorrectionType = autocorrection ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
}

- (BOOL)autocorrection {
    return _textField.autocorrectionType == UITextAutocorrectionTypeYes;
}

#pragma mark - IFIOCProxy

- (id)unwrapValue {
    [_style applyToTextField:_textField];
    return _textField;
}

#pragma mark - Class loading

+ (void)load {
    [IFIOCProxyObject registerConfigurationProxyClass:self forClassName:@"UITextField"];
}

@end
