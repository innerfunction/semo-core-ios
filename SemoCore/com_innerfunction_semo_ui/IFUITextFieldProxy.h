//
//  IFIOCTextFieldProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCProxyObject.h"
#import "IFTextStyle.h"

@interface IFUITextFieldProxy : IFIOCProxyObject {
    UITextField *_textField;
}

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) IFTextStyle *style;
@property (nonatomic, strong) NSString *keyboard;
@property (nonatomic, strong) NSString *autocapitalization;
@property (nonatomic, assign) BOOL autocorrection;

@end
