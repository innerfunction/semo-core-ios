//
//  IFCompoundURI.m
//  EventPacComponents
//
//  Created by Julian Goacher on 10/03/2013.
//  Copyright (c) 2013 InnerFunction. All rights reserved.
//

#import "IFCompoundURI.h"
#import "IFRegExp.h"
#import "NSDictionary+IF.h"

#define URIEncode(s) ((NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(\
                        NULL, (__bridge CFStringRef)s, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8)))
#define URIDecode(s) ((NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(\
                        NULL, (__bridge CFStringRef)s, NULL, kCFStringEncodingUTF8)))

@implementation IFCompoundURI

@synthesize scheme, name, fragment, parameters;

- (id)initWithURI:(NSString *)uri error:(NSError *__autoreleasing *)error {
    return [self initWithURI:uri trailing:nil error:error];
}

- (id)initWithURI:(NSString *)uri trailing:(NSString *__autoreleasing *)trailing error:(NSError *__autoreleasing *)error {
    self = [super init];
    if (self) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        // Following regex pattern matches the following groups:
        // 1. An optional opening '['. Indicates that the URI is bracketed, and should have a matching ] after its close.
        // 2. An optional URI scheme of one or more word characters. Must be followed by ':'.
        // 3. A URI name of zero or more word characters. Following non-word characters also allowed: . / % - _ ~
        // 4. An optional URI fragment. The # prefix indicates the presence of a fragment. Fragment can contain the same
        //    set of characters as a name.
        // 5. An optional parameter list, composed of all trailing characters.
        IFRegExp *schemeRegex = [[IFRegExp alloc] initWithPattern:@"^(\\[)?(?:(\\w+):)?([\\w.,/%_~-]*)(#[\\w./%_~-]*)?(.*)$"];
        NSArray *groups = [schemeRegex match:uri];
        if (groups) {
            BOOL bracketed = [[groups objectAtIndex:1] isEqualToString:@"["];
            BOOL parseParams = YES;
            self.scheme = [groups objectAtIndex:2];
            if (![self.scheme length]) {
                self.scheme = @"s";
                parseParams = NO;
            }
            self.name = [groups objectAtIndex:3];
            NSString* frag = [groups objectAtIndex:4];
            self.fragment = [frag length] > 0 ? [frag substringFromIndex:1] : nil;
            // Parse parameters.
            NSString *paramString = [groups objectAtIndex:5];
            if (trailing) {
                *trailing = paramString;
            }
            if (parseParams) {
                IFRegExp *paramRegex = [[IFRegExp alloc] initWithPattern:@"^\\+(\\w+)@(.*)$"];
                while ([paramString length] && !*error) {
                    groups = [paramRegex match:paramString];
                    if (groups) {
                        NSString *pname = [groups objectAtIndex:1];
                        NSString *value = [groups objectAtIndex:2];
                        IFCompoundURI *uri = [[IFCompoundURI alloc] initWithURI:value trailing:&paramString error:error];
                        [params setValue:uri forKey:pname];
                    }
                    else if ([paramString hasPrefix:@"]"]) {
                        if (bracketed) {
                            // If URI is bracketed - i.e. starts with [ - then this is the closing bracket.
                            paramString = [paramString substringFromIndex:1];
                            if (trailing) {
                                *trailing = paramString;
                            }
                            if ([paramString length] && !trailing) {
                                // If still chars after the closing bracket then they belong to the parent URI (implied by *trailing)
                                // Otherwise if this URI isn't nested, then must be a parse error.
                                if (error) {
                                    NSString *message = [NSString stringWithFormat:@"Unbalanced ]: %@", paramString];
                                    *error = [NSError errorWithDomain:@"IFCompoundURI"
                                                                 code:IFCompoundURIUnbalancedBracket
                                                             userInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]];
                                }
                            }
                        }
                        else if (trailing) {
                            // If trailing exists then implies a nested URI - the closing bracket might belong to a parent.
                            *trailing = paramString;
                        }
                        else if (error) {
                            // Else this URI isn't bracketed or nested, so parse error.
                            NSString *message = [NSString stringWithFormat:@"Unbalanced ]: %@", paramString];
                            *error = [NSError errorWithDomain:@"IFCompoundURI"
                                                         code:IFCompoundURIUnbalancedBracket
                                                     userInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]];
                            
                        }
                        // Whatever the situation, a ] indicates the end of this URI so break out of the parse loop.
                        break;
                    }

                    else if (error) {
                        NSString *message = [NSString stringWithFormat:@"Parse error: %@", paramString];
                        *error = [NSError errorWithDomain:@"IFCompoundURI"
                                                     code:IFCompoundURIParseError
                                                 userInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]];
                    }
                }
            }
        }
        else if (error) {
            NSString *message = [NSString stringWithFormat:@"Invalid URI: %@", uri];
            *error = [NSError errorWithDomain:@"IFCompoundURI"
                                         code:IFCompoundURIInvalidNameRef
                                     userInfo:[NSDictionary dictionaryWithObject:message forKey:@"message"]];
        }
        self.parameters = params;
        self.name = URIDecode(self.name);
    }
    return self;
}

- (id)initWithScheme:(NSString *)_scheme name:(NSString *)_name {
    self = [super init];
    if (self) {
        self.scheme = _scheme;
        self.name = _name;
        self.parameters = [NSDictionary dictionary];
    }
    return self;
}

- (id)initWithScheme:(NSString *)_scheme uri:(IFCompoundURI *)uri {
    self = [super init];
    if (self) {
        self.scheme = _scheme;
        self.name = uri.name;
        self.fragment = uri.fragment;
        self.parameters = uri.parameters;
    }
    return self;
}

- (void)addURIParameters:(NSDictionary *)params {
    self.parameters = [self.parameters extendWith:params];
}

- (NSString*)canonicalForm {
    // Alphabetically sort parameter keys.
    NSArray *keys = [[self.parameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(id k1, id k2) {
        return [k1 compare:k2];
    }];
    // Generate a string containing the serialized form of all parameters.
    NSMutableString *serializedParams = [[NSMutableString alloc] init];
    for (NSString *key in keys) {
        IFCompoundURI *uri = [self.parameters valueForKey:key];
        [serializedParams appendString:@"+"];
        [serializedParams appendString:URIEncode(key)];
        [serializedParams appendString:@"@["];
        [serializedParams appendString:[uri canonicalForm]];
        [serializedParams appendString:@"]"];
    }
    NSString *frag = self.fragment ? [NSString stringWithFormat:@"#%@", URIEncode(self.fragment)] : @"";
    return [NSString stringWithFormat:@"%@:%@%@%@", URIEncode(self.scheme), URIEncode(self.name), frag, serializedParams];
}

- (IFCompoundURI*)copyOf {
    IFCompoundURI* copy = [[IFCompoundURI alloc] init];
    copy.scheme = self.scheme;
    copy.name = self.name;
    copy.fragment = self.fragment;
    copy.parameters = [self.parameters copy];
    return copy;
}

- (IFCompoundURI *)copyOfWithFragment:(NSString *)_fragment {
    IFCompoundURI *uri = [self copyOf];
    if (uri.fragment) {
        uri.fragment = [NSString stringWithFormat:@"%@.%@", uri.fragment, _fragment];
    }
    else {
        uri.fragment = _fragment;
    }
    return uri;
}

+ (IFCompoundURI*)parse:(NSString *)uri error:(NSError *__autoreleasing *)error {
    NSError *_error;
    IFCompoundURI *result = [[IFCompoundURI alloc] initWithURI:uri error:&_error];
    if (error && _error) {
        *error = _error;
        return nil;
    }
    return result;
}

- (NSString*)description {
    return [self canonicalForm];
}

- (NSUInteger)hash {
    return [[self description] hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[IFCompoundURI class]] && [[self description] isEqualToString:[object description]];
}

@end
