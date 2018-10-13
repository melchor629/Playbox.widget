//
//  HTTPResponse.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "HTTPResponse.h"
#import "../Utils/NSDictionary+CaseInsensitive.h"


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
    [headers setValue:value forKeyCaseInsensitive:key];
}

- (NSString*) valueForHeader: (NSString*) key {
    return [headers objectForCaseInsensitiveKey:key];
}

- (void) write: (NSString*) data {
    [self writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeAndEnd: (NSString*) data {
    [self writeDataAndEnd:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) writeData: (NSData*) data {
    [self writeRawData:[data bytes] withLength:[data length]];
}

- (void) writeDataAndEnd: (NSData*) data {
    [self writeRawDataAndEnd:[data bytes] withLength:[data length]];
}

- (void) writeRawData: (const void*) ptr withLength: (NSUInteger) length {
    [body appendBytes:ptr length:length];
}

-  (void) writeRawDataAndEnd: (const void*) ptr withLength: (NSUInteger) length {
    if(!headersSent) {
        [self sendHeadersWithLength:[body length] + length];
    }

    if([body length] > 0) {
        [client writeAll:body];
    }
    [client writeAllRawData:ptr withLength:length];
}

- (void) writeJsonAndEnd: (NSDictionary*) dict {
    [self writeJsonAndEnd:dict withStatus:200];
}

- (void) writeJsonAndEnd: (NSDictionary*) dict withStatus: (NSUInteger) statusCode {
    self.statusCode = statusCode;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [self writeData:data];
    [self end];
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

    [headers setObject:@"close" forKey:@"Connection"];
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
