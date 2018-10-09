//
//  ParsePseudoYaml.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSRegularExpression* lineRegex = nil, *numberRegex = nil;

static inline void init_vars() {
    if(lineRegex == nil) {
        lineRegex = [[NSRegularExpression alloc] initWithPattern:@"^(\\w[a-z0-9_\\-]+): +(.+)$"
                                                         options:NSRegularExpressionCaseInsensitive
                                                           error:nil];
    }

    if(numberRegex == nil) {
        numberRegex = [[NSRegularExpression alloc] initWithPattern:@"\\d+[.,]?\\d*"
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:nil];
    }
}

static NSArray<NSString*>* splitLine(NSString* string) {
    NSArray<NSTextCheckingResult*>* matches = [lineRegex matchesInString:string
                                                                 options:0
                                                                   range:NSMakeRange(0, [string length])];
    NSMutableArray<NSString*>* res = [[NSMutableArray alloc] initWithCapacity:3];
    for(int i = 0; i < [[matches objectAtIndex:0] numberOfRanges]; i++) {
        [res addObject:[string substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:i]]];
    }
    return res;
}

NSDictionary* pseudoYaml_parse(NSString* yaml) {
    init_vars();

    NSMutableDictionary* res = [[NSMutableDictionary alloc] init];
    NSArray<NSString*>* lines = [yaml componentsSeparatedByString:@"\n"];
    for(int i = 0; i < [lines count]; i++) {
        NSString* line = [lines objectAtIndex:i];
        NSArray<NSString*>* values = splitLine(line);
        NSString* key = [values objectAtIndex:1];
        NSString* value = [values objectAtIndex:2];
        if([value isEqualToString:@"true"]) {
            [res setObject:@true forKey:key];
        } else if([value isEqualToString:@"false"]) {
            [res setObject:@false forKey:key];
        } else if([numberRegex firstMatchInString:value options:0 range:NSMakeRange(0, [value length])] != nil) {
            if([value rangeOfString:@","].location == NSNotFound) {
                [res setObject:[[NSNumber alloc] initWithDouble:[value doubleValue]] forKey:key];
            } else {
                id newValue = [value stringByReplacingOccurrencesOfString:@"," withString:@"."];
                [res setObject:[[NSNumber alloc] initWithDouble:[newValue doubleValue]] forKey:key];
            }
        } else if(![value isEqualToString:@"null"]) {
            [res setObject:value forKey:key];
        }
    }

    return res;
}
