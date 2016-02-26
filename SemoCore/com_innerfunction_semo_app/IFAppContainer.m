//
//  IFAppContainer.m
//  SemoCore
//
//  Created by Julian Goacher on 23/04/2015.
//  Copyright (c) 2015 InnerFunction. All rights reserved.
//

#import "IFAppContainer.h"
#import "IFConfiguration.h"
#import "IFViewController.h"
#import "IFNewScheme.h"
#import "IFMakeScheme.h"
#import "IFPostScheme.h"
#import "IFCoreTypes.h"
#import "IFI18nMap.h"
#import "IFLogging.h"
#import "NSString+IF.h"

@implementation IFAppUIPostActionHandler

- (id)initWithAppContainer:(IFAppContainer *)appContainer {
    self = [super init];
    if (self) {
        _appContainer = appContainer;
    }
    return self;
}

- (void)dispatchAction:(IFPostAction *)postAction sender:(id)sender {
    id handler = sender;
    // Evaluate actions with relative target paths against the sender.
    while (handler) {
        if ([handler conformsToProtocol:@protocol(IFPostActionTargetContainer)]) {
            [(id<IFPostActionTargetContainer>)handler dispatchAction:postAction sender:sender];
            break;
        }
        if ([handler isKindOfClass:[UIViewController class]]) {
            // If action sender is a view controller then bubble the action up through the
            // view controller hierachy until a hander is found.
            handler = ((UIViewController *)handler).parentViewController;
        }
        else if ([handler isKindOfClass:[UIView class]]) {
            // If action sender is a view then bubble the action up through the view hierarchy.
            handler = [(UIView *)handler nextResponder];
        }
        else {
            // Can't process the action any further.
            break;
        }
    }
}

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender {
    BOOL handled = NO;
    id handler = sender;
    // Evaluate actions with relative target paths against the sender.
    while (!handled && handler) {
        if ([handler conformsToProtocol:@protocol(IFPostActionHandler)]) {
            handled = [(id<IFPostActionHandler>)handler handlePostAction:postAction sender:sender];
        }
        if ([handler isKindOfClass:[UIViewController class]]) {
            // If action sender is a view controller then bubble the action up through the
            // view controller hierachy until a hander is found.
            handler = ((UIViewController *)handler).parentViewController;
        }
        else if ([handler isKindOfClass:[UIView class]]) {
            // If action sender is a view then bubble the action up through the view hierarchy.
            handler = [(UIView *)handler nextResponder];
        }
        else {
            // Can't process the action any further.
            break;
        }
    }
    // Evaluate non-handled actions against the receiver, i.e. the app container, but only if no
    // target is specified. This means that actions generally addressed to 'ui' will bubble up to
    // the default action handlers in the app container.
    if (!handled && [postAction hasEmptyTarget]) {
        handled = [_appContainer handlePostAction:postAction sender:sender];
    }
    return handled;
}

@end

@interface IFAppContainer ()

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration;

@end

@implementation IFAppContainer

- (id)init {
    self = [super init];
    if (self) {
        self.appBackgroundColor = [UIColor redColor];
        self.uriHandler = [[IFStandardURIHandler alloc] init];
    }
    return self;
}

- (void)setWindow:(UIWindow *)window {
    _window = window;
    _window.rootViewController = [self getRootView];
    _window.backgroundColor = self.appBackgroundColor;
}

- (void)loadConfiguration:(id)configSource {
    IFConfiguration *configuration = nil;
    if ([configSource isKindOfClass:[IFConfiguration class]]) {
        // Configuration source is already a configuration.
        configuration = (IFConfiguration *)configSource;
    }
    else {
        // Test if config source specifies a URI.
        IFCompoundURI *uri = nil;
        if ([configSource isKindOfClass:[IFCompoundURI class]]) {
            uri = (IFCompoundURI *)configSource;
        }
        else if ([configSource isKindOfClass:[NSString class]]) {
            NSError *error = nil;
            uri = [[IFCompoundURI alloc] initWithURI:(NSString *)configSource error:&error];
            if (error) {
                DDLogCError(@"%@: Error parsing app container configuration URI: %@", LogTag, error);
                return;
            }
        }
        id configData = nil;
        if (uri) {
            // If a configuration source URI has been resolved then attempt loading the configuration from the URI.
            DDLogInfo(@"%@: Attempting to load app container configuration from %@", LogTag, uri);
            configData = [self.uriHandler dereference:uri];
        }
        else {
            configData = configSource;
        }
        // Create configuration from data.
        if ([configData isKindOfClass:[IFResource class]]) {
            configuration = [[IFConfiguration alloc] initWithResource:(IFResource *)configData];
            // Use the configuration's URI handler instead from this point on, to ensure relative URI's
            // resolve properly and also so that additional URI schemes added to this container are
            // available within the configuration.
            self.uriHandler = configuration.uriHandler;
        }
        else {
            configuration = [[IFConfiguration alloc] initWithData:configSource];
        }
    }
    if (configuration) {
        [self configureWith:configuration];
    }
    else {
        DDLogWarn(@"%@: Unable to resolve configuration from %@", LogTag, configSource);
    }
}

- (void)configureWith:(IFConfiguration *)configuration {
    
    // Setup template context.
    _globals = [self makeDefaultGlobalModelValues:configuration];
    configuration.context = _globals;
    
    // Set object type mappings.
    [self addTypes:[configuration getValueAsConfiguration:@"types"]];
    
    // Add additional schemes to the resolver/dispatcher.
    [_uriHandler addHandler:[[IFNewScheme alloc] initWithContainer:self] forScheme:@"new"];
    [_uriHandler addHandler:[[IFMakeScheme alloc] initWithContainer:self] forScheme:@"make"];
    [_uriHandler addHandler:[[IFNamedSchemeHandler alloc] initWithContainer:self] forScheme:@"named"];
    [_uriHandler addHandler:[[IFPostScheme alloc] init] forScheme:@"post"];
    // Additional configured schemes.
    IFConfiguration *dispatcherConfig = [configuration getValueAsConfiguration:@"schemes"];
    if (dispatcherConfig) {
        for (NSString *schemeName in [dispatcherConfig getValueNames]) {
            IFConfiguration *schemeConfig = [dispatcherConfig getValueAsConfiguration:schemeName];
            id handler = [self buildObjectWithConfiguration:schemeConfig identifier:schemeName];
            if ([handler conformsToProtocol:@protocol(IFSchemeHandler)]) {
                [_uriHandler addHandler:handler forScheme:schemeName];
            }
        }
    }
    
    // Default local settings.
    _locals = [[IFLocals alloc] initWithPrefix:@"semo"];
    NSDictionary *settings = (NSDictionary *)[configuration getValue:@"settings"];
    if (settings) {
        [_locals setValues:settings forceReset:ForceResetDefaultSettings];
    }
    
    [_named setObject:_uriHandler forKey:@"uriHandler"];
    [_named setObject:_globals forKey:@"globals"];
    [_named setObject:_locals forKey:@"locals"];
    [_named setObject:self forKey:@"container"];
    // Posted actions addressed to the UI are handled by the following object.
    [_named setObject:[[IFAppUIPostActionHandler alloc] initWithAppContainer:self] forKey:@"ui"];
    
    // Perform default container configuration.
    [super configureWith:configuration];
}

- (NSMutableDictionary *)makeDefaultGlobalModelValues:(IFConfiguration *)configuration {
    
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    float scale = [UIScreen mainScreen].scale;
    NSString *display = scale > 1.0 ? [NSString stringWithFormat:@"%f.0x", scale] : @"";
    NSDictionary *platformValues = @{
        @"name":            Platform,
        @"dispay":          display,
        @"defaultDisplay":  @"2x",
        @"full":            [NSString stringWithFormat:@"ios%@", display]
    };
    [values setObject:platformValues forKey:@"platform"];
    
    NSString *mode = [configuration getValueAsString:@"mode" defaultValue:@"LIVE"];
    DDLogInfo(@"%@: Configuration mode: %@", LogTag, mode);
    [values setObject:mode forKey:@"mode"];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *lang = nil;
    DDLogInfo(@"%@: Current locale is %@", LogTag, locale.localeIdentifier);
    
    // The 'assetLocales' setting can be used to declare a list of the locales that app assets are
    // available in. If the platform's default locale (above) isn't on this list then the code below
    // will attempt to find a supported locale that uses the same language; if no match is found then
    // the first locale on the list is used as the default.
    if ([configuration hasValue:@"assetLocales"]) {
        NSArray *assetLocales = [configuration getValue:@"assetLocales"];
        if ([assetLocales count] > 0 && ![assetLocales containsObject:locale.localeIdentifier]) {
            // Attempt to find a matching locale.
            // Always assigns the first item on the list (as the default option); if a later
            // item has a matching language then that is assigned and the loop is exited.
            NSString *lang = [locale objectForKey:NSLocaleLanguageCode];
            BOOL langMatch = NO, assignDefault;
            for (NSInteger i = 0; i < [assetLocales count] && !langMatch; i++) {
                NSString *assetLocale = [assetLocales objectAtIndex:0];
                NSArray *localeParts = [assetLocale split:@"_"];
                assignDefault = (i == 0);
                langMatch = [[localeParts objectAtIndex:0] isEqualToString:lang];
                if (assignDefault||langMatch) {
                    locale = [NSLocale localeWithLocaleIdentifier:assetLocale];
                }
            }
        }
        // Handle the case where the user's selected language is different from the locale.
        // See http://stackoverflow.com/questions/3910244/getting-current-device-language-in-ios
        NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
        if (![[locale objectForKey:NSLocaleLanguageCode] isEqualToString:preferredLang]) {
            // Use the user's selected language if listed in assetLocales.
            for (NSString *assetLocale in assetLocales) {
                NSArray *localeParts = [assetLocale split:@"_"];
                if ([[localeParts objectAtIndex:0] isEqualToString:preferredLang]) {
                    lang = preferredLang;
                    break;
                }
            }
        }
    }
    
    if (!lang) {
        // If the user's preferred language hasn't been selected, then use the current locale's.
        lang = [locale objectForKey:NSLocaleLanguageCode];
    }
    DDLogInfo(@"%@: Using language %@", LogTag, lang);
    
    NSDictionary *localeValues = @{
        @"id":       [locale objectForKey:NSLocaleIdentifier],
        @"lang":     lang,
        @"variant":  [locale objectForKey:NSLocaleCountryCode]
    };
    [values setObject:localeValues forKey:@"locale"];
    [values setObject:[IFI18nMap instance] forKey:@"i18n"];
    
    return values;
}

- (UIViewController *)getRootView {
    id rootView = [_named objectForKey:@"rootView"];
    if (!rootView) {
        DDLogError(@"%@: No component named 'rootView' found", LogTag);
    }
    else if ([rootView isKindOfClass:[UIView class]]) {
        // Promote UIView to a view controller.
        IFViewController *viewController = [[IFViewController alloc] initWithView:(UIView *)rootView];
        rootView = viewController;
    }
    else if (![rootView isKindOfClass:[UIViewController class]]) {
        DDLogError(@"%@: The component named 'rootView' is not an instance of UIView or UIViewController", LogTag);
        rootView = nil;
    }
    return rootView;
}

- (void)postAction:(NSString *)actionURI sender:(id)sender {
    // Parse the action URI.
    IFCompoundURI *uri = [IFCompoundURI parse:actionURI error:nil];
    if (uri) {
        // See if the URI resolves to an action object.
        id action = [_uriHandler dereference:uri];
        if ([action isKindOfClass:[IFPostAction class]]) {
            IFPostAction *postAction = (IFPostAction *)action;
            // Dispatch the action.
            [self dispatchAction:postAction sender:sender];
        }
    }
}

#pragma mark - Overrides

- (void)configureObject:(id)object withConfiguration:(IFConfiguration *)configuration identifier:(NSString *)identifier {
    [super configureObject:object withConfiguration:configuration identifier:identifier];
}

#pragma mark - IFPostActionHandler protocol

- (BOOL)handlePostAction:(IFPostAction *)postAction sender:(id)sender {
    if ([@"open-url" isEqualToString:postAction.message]) {
        NSURL *url = [[postAction parameterValue:@"url"] asURL];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if ([@"open" isEqualToString:postAction.message]) {
        id view = [postAction parameterValue:@"view"];
        if ([view isKindOfClass:[UIViewController class]]) {
            [UIView transitionWithView: self.window
                              duration: 0.5
                               options: UIViewAnimationOptionTransitionFlipFromLeft
                            animations: ^{
                                self.window.rootViewController = view;
                            }
                            completion:nil];
        }
    }
    return YES;
}

#pragma mark - Class statics

static IFAppContainer *instance;

+ (void)initialize {
    instance = [[IFAppContainer alloc] init];
    [instance addTypes:[IFCoreTypes types]];
}

+ (IFAppContainer *)getAppContainer {
    return instance;
}

+ (IFAppContainer *)bindToWindow:(UIWindow *)window {
    IFAppContainer *container = [IFAppContainer getAppContainer];
    [container loadConfiguration:@"app:config.json"];
    [container startService];
    container.window = window;
    return container;
}

@end
