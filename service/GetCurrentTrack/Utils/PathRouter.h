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

//! Delegate for a path. Implement HTTPServerDelegate, the first parameter can be of type PathRequest instead.
@property id delegate;

/*!
 @brief Creates a router based on paths with the path regexes and selectors.
 @discussion
 Creates the router by specifying pairs of path regexes and selectors, that will apply
 in the order found in the arrays.

 The paths are can be defined as a regular expression with capture groups that will be
 passed in the first argument of the selector (PathRequest). The start and end of line
 characters cannot be used.

 The selectors must receive two parameters: an PathRequest and a HTTPResponse. If not,
 weird errors can happen.

 @param paths An array of path regexes.
 @param selectors An array of selectors that will be called when the path is matched.
 */
+ (PathRouter*) pathRouterWithPaths: (NSArray<NSString*>*) paths andSelectors: (NSArray<NSString*>*) selectors;

/*!
 @brief Adds a new selector that will be run when the path is matched.
 @param selector Selector to run on the delegate.
 @param path Path regex that will try to match.
 */
- (void) addSelector: (SEL) selector forPath: (NSString*) path;

/*!
 @brief Adds a new selector that will be run when the path is matched.
 @param selectorStr Selector (as string) to run on the delegate.
 @param path Path regex that will try to match.
 */
- (void) addSelectorString: (NSString*) selectorStr forPath: (NSString*) path;

/*!
 @discussion
 Tries to match a path with the request.

 When a path is matched, it's selector will be called. The selector will run in the
 delegate. If the delegate has not defined the selector, nothing will do.

 @param req The HTTP request obejct.
 @param res The HTTP response object.
 @return `true` if there's a path that matched any path regex.
 */
- (BOOL) performSelectorForRequest: (HTTPRequest*) req andResponse: (HTTPResponse*) res;

@end

NS_ASSUME_NONNULL_END
