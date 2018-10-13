//
//  PathRouter.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "PathRouter.h"

@implementation PathRouter {
    NSMutableArray<NSArray*>* paths;
}

@synthesize delegate;

+ (PathRouter*) pathRouterWithPaths: (NSArray<NSString*>*) paths andSelectors: (NSArray<NSString*>*) selectors {
    PathRouter* pr = [[PathRouter alloc] init];

    if([paths count] != [selectors count]) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Paths and Selectors must have the same length" userInfo:nil];
    }

    for(NSUInteger i = 0; i < [paths count]; i++) {
        NSString* pathStr = [paths objectAtIndex:i];
        NSString* selectorStr = [selectors objectAtIndex:i];
        [pr addSelectorString:selectorStr forPath:pathStr];
    }

    return pr;
}

- (instancetype) init {
    self = [super self];

    if(self) {
        paths = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void) addSelector: (SEL) selector forPath: (NSString*) pathStr {
    [self addSelectorString:NSStringFromSelector(selector) forPath:pathStr];
}

- (void) addSelectorString: (NSString*) selectorStr forPath: (NSString*) pathStr {
    NSError* error = nil;
    NSString* fixedPathStr = [NSString stringWithFormat:@"^%@$", pathStr];
    NSRegularExpression* pathRegex = [NSRegularExpression regularExpressionWithPattern:fixedPathStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    if(pathRegex == nil) {
        @throw error;
    }

    [paths addObject:[NSArray arrayWithObjects:pathRegex, selectorStr, nil]];
}

- (BOOL) performSelectorForRequest: (HTTPRequest*) req andResponse: (HTTPResponse*) _res {
    NSString* path = req->path;
    for(NSArray* pair in paths) {
        NSRegularExpression* pathRegex = [pair objectAtIndex:0];
        SEL selector = NSSelectorFromString([pair objectAtIndex:1]);

        NSTextCheckingResult* res = [pathRegex firstMatchInString:path
                                                          options:0
                                                            range:NSMakeRange(0, [path length])];
        if(res != nil) {
            if([delegate respondsToSelector:selector]) {
                NSMutableArray* params = [[NSMutableArray alloc] init];
                for(NSUInteger i = 1; i < [res numberOfRanges]; i++) {
                    [params addObject:[path substringWithRange:[res rangeAtIndex:i]]];
                }

                PathRequest pr;
                pr.req.headers = req->headers;
                pr.req.method = req->method;
                pr.req.query = req->query;
                pr.req.path = req->path;
                pr.params = params;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [delegate performSelector:selector withObject:(__bridge id) (&pr) withObject:_res];
#pragma clang diagnostic pop
            }
        }
    }

    return false;
}

@end
