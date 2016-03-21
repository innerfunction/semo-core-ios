// Copyright 2016 InnerFunction Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Julian Goacher on 17/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import "IFTextStyle.h"

#define DefaultFontSize (17.0f)

@implementation IFTextStyle

- (void)applyToLabel:(UILabel *)label {
    CGFloat fontSize = DefaultFontSize;
    if (_fontSize) {
        fontSize = [_fontSize floatValue];
    }
    UIFont *font = label.font;
    if (_fontName) {
        font = [UIFont fontWithName:_fontName size:fontSize];
    }
    else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    if (_bold || _italic) {
        // See http://stackoverflow.com/a/21777132
        UIFontDescriptorSymbolicTraits traits = 0x00;
        if (_bold) {
            traits |= UIFontDescriptorTraitBold;
        }
        if (_italic) {
            traits |= UIFontDescriptorTraitItalic;
        }
        UIFontDescriptor *fontDesc = [font.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
        // Note, size: 0 below means keep current size.
        font = [UIFont fontWithDescriptor:fontDesc size:0];
    }
    label.font = font;
    if (_textColor) {
        label.textColor = _textColor;
    }
    if (_backgroundColor) {
        label.backgroundColor = _backgroundColor;
    }
    if ([@"right" isEqualToString:_textAlign]) {
        label.textAlignment = NSTextAlignmentRight;
    }
    else if ([@"center" isEqualToString:_textAlign]) {
        label.textAlignment = NSTextAlignmentCenter;
    }
    else {
        label.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)applyToTextField:(UITextField *)textField {
    CGFloat fontSize = DefaultFontSize;
    if (_fontSize) {
        fontSize = [_fontSize floatValue];
    }
    UIFont *font;
    if (_fontName) {
        font = [UIFont fontWithName:_fontName size:fontSize];
    }
    else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    if (_bold || _italic) {
        // See http://stackoverflow.com/a/21777132
        UIFontDescriptorSymbolicTraits traits = 0x00;
        if (_bold) {
            traits |= UIFontDescriptorTraitBold;
        }
        if (_italic) {
            traits |= UIFontDescriptorTraitItalic;
        }
        UIFontDescriptor *fontDesc = [font.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
        // Note, size: 0 below means keep current size.
        font = [UIFont fontWithDescriptor:fontDesc size:0];
    }
    textField.font = font;
    if (_textColor) {
        textField.textColor = _textColor;
    }
    if (_backgroundColor) {
        textField.backgroundColor = _backgroundColor;
    }
    if ([@"right" isEqualToString:_textAlign]) {
        textField.textAlignment = NSTextAlignmentRight;
    }
    else if ([@"center" isEqualToString:_textAlign]) {
        textField.textAlignment = NSTextAlignmentCenter;
    }
    else {
        textField.textAlignment = NSTextAlignmentLeft;
    }
}

@end
