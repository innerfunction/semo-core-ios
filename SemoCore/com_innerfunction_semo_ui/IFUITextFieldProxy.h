//
//  IFIOCTextFieldProxy.h
//  SemoCore
//
//  Created by Julian Goacher on 08/03/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFIOCProxy.h"
#import "IFTextStyle.h"

@interface IFUITextFieldProxy : NSObject <IFIOCProxy> {
    UITextField *_textField;
}

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) IFTextStyle *style;

@end
