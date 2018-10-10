//
//  PathRouter.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Network/HTTPServer.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _PathRequest {
    HTTPRequest req;
    NSArray<NSString*>* params;
} PathRequest;

@interface PathRouter : NSObject

@property id delegate;

+ (PathRouter*) pathRouterWithPaths: (NSArray<NSString*>*) paths andSelectors: (NSArray<NSString*>*) selectors;

- (void) addSelector: (SEL) selector forPath: (NSString*) path;
- (void) addSelectorString: (NSString*) selectorStr forPath: (NSString*) path;
- (BOOL) performSelectorForRequest: (HTTPRequest*) req andResponse: (HTTPResponse*) res;

@end

NS_ASSUME_NONNULL_END
