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
//  Created by Julian Goacher on 25/02/2016.
//  Copyright © 2016 InnerFunction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFURIHandling.h"

/**
 * An internal URI scheme handler for the _post:_ scheme.
 * The _post:_ scheme allows messages to be posted using a URI string description. For example,
 * the URI _post:open+view@make:WebView_, the message to be posted is named _open_ and has a
 * single parameter named _view_.
 */
@interface IFPostScheme : NSObject <IFSchemeHandler>

@end
