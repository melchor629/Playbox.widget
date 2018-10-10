//
//  HTTPResponse.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "HTTPResponse.h"


//Based on https://stackoverflow.com/questions/13607343/nsdictionary-case-insensitive-objectforkey#13607604
@interface NSDictionary (NSDictionaryCaseInsensitive)
- (id) objectForCaseInsensitiveKey: (NSString *)key;
@end

@implementation NSDictionary (NSDictionaryCaseInsensitive)

- (id) objectForCaseInsensitiveKey: (NSString *) lkey {
    NSSet<NSString*>* keyOrNot = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return [key caseInsensitiveCompare:lkey] == NSOrderedSame;
    }];

    if([keyOrNot count] == 1) {
        return [self objectForKey:[keyOrNot anyObject]];
    }

    return nil;
}

@end


@implementation HTTPResponse {
    NSMutableDictionary* headers;
    ClientSocket* client;
    BOOL headersSent;
    NSMutableData* body;
}

@synthesize statusCode;

- (instancetype) initWithClient: (ClientSocket*) client {
    self = [super init];
    self->client = client;
    headers = [[NSMutableDictionary alloc] init];
    headersSent = false;
    body = [[NSMutableData alloc] init];
    statusCode = 200;
    return self;
}

- (void) setValue: (NSString*) value forHeader: (NSString*) key {
    [headers setValue:value forKey:key];
}

- (NSString*) valueForHeader: (NSString*) key {
    return [headers objectForCaseInsensitiveKey:key];
}

- (void) write: (NSString*) data {
    [self writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeData: (NSData*) data {
    [self writeRawData:[data bytes] withLength:[data length]];
}

- (void) writeRawData: (const void*) ptr withLength: (NSUInteger) length {
    [body appendBytes:ptr length:length];
}

- (void) end {
    if(!headersSent) {
        [self sendHeadersWithLength:[body length]];
    }

    [client writeAll:body];
}

- (void) sendHeadersWithLength: (NSUInteger) length {
    [self setValue:[[NSNumber numberWithUnsignedInteger:length] stringValue] forHeader:@"Content-Length"];
    [self sendHeaders];
}

- (void) sendHeaders {
    NSString* statusLine = [NSString stringWithFormat:@"HTTP/1.1 %lu :)\r\n", statusCode];
    [client writeAll:[statusLine dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableString* headers = [[NSMutableString alloc] init];
    for(NSString* key in self->headers) {
        [headers appendString:key];
        [headers appendString:@": "];
        [headers appendString:[self->headers valueForKey:key]];
        [headers appendString:@"\r\n"];
    }
    [headers appendString:@"\r\n"];

    [client writeAll:[headers dataUsingEncoding:NSUTF8StringEncoding]];

    headersSent = true;
}

@end
