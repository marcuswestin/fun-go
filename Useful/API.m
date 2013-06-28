//
//  API.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunAll.h"

#define log NSLog

NSError* checkHttpError(NSHTTPURLResponse* response) {
    if (response.statusCode >= 200 && response.statusCode < 300) { return nil; }
    return makeError([NSString stringWithFormat:@"API response code: %d", response.statusCode]);
}

@implementation API

static NSString* server;
static NSOperationQueue* queue;
static NSString* multipartBoundary;
static NSMutableDictionary* baseHeaders;

+ (void)setup:(NSString *)serverUrl {
    server = serverUrl;
}

+ (void)setHeaders:(NSDictionary *)headers {
    for (NSString* name in headers) {
        baseHeaders[name] = headers[name];
    }
}

+ (void)setup {
    multipartBoundary = @"_____FUNOBJ_BNDRY__";
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
}

+ (void)post:(NSString *)path json:(NSDictionary *)json callback:(APICallback)callback {
    [self send:@"POST" path:path contentType:@"application/json" data:json.toJsonData callback:callback];
}

+ (void)get:(NSString *)path queries:(NSDictionary *)queries callback:(APICallback)callback {
    path = [NSString stringWithFormat:@"%@?%@", path, queries.toQueryString];
    [self send:@"GET" path:path contentType:nil data:nil callback:callback];
}

+ (void) upload:(NSString *)path json:(NSDictionary *)jsonDict attachments:(NSDictionary *)attachments callback:(APICallback)callback {
    NSMutableArray* parts = [NSMutableArray array];
    
    if (jsonDict) {
        [parts addObject:@{
                           @"data":jsonDict.toJsonData,
                           @"content-type":@"application/json",
                           @"content-disposition":@"attachment; name=\"jsonParams\""
                           }];
    }
    
    for (NSString* name in attachments) {
        NSString* contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\" filename=\"%@\"", name, name];
        [parts addObject:@{
                           @"data": attachments[name],
                           @"content-type": @"application/octet-stream",
                           @"content-disposition": contentDisposition
                           }];
    }
    
    [API postMultipart:path parts:parts boundary:multipartBoundary callback:callback];
}

+ (void)postMultipart:(NSString *)path parts:(NSArray *)parts boundary:(NSString*)boundary callback:(APICallback)callback {
    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableData* httpData = [NSMutableData data];
    for (NSDictionary* part in parts) {
        NSData* data = [part valueForKey:@"data"];
        // BOUNDARY
        [httpData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // HEADERS
        [httpData appendData:[[NSString stringWithFormat:@"Content-Disposition: %@\r\n", [part valueForKey:@"Content-Disposition"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", [part valueForKey:@"Content-Type"]] dataUsingEncoding:NSUTF8StringEncoding]];
        // EMPTY
        [httpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        // CONTENT + newline
        [httpData appendData:[NSData dataWithData:data]];
        [httpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self send:@"POST" path:path contentType:contentType data:httpData callback:callback];
}


+ (void) send:(NSString*)method path:(NSString*)path contentType:(NSString*)contentType data:(NSData*)data callback:(APICallback)callback {
    if (!server) { [NSException raise:@"MissingServer" format:@"You must do [API setup:@\"https://your.server.com\""]; }
    NSString* url = [server stringByAppendingString:path];
    NSMutableURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = method;
    request.HTTPBody = data;
    request.allHTTPHeaderFields = [API headers:contentType data:data];
    NSLog(@"API %@ %@", method, path);
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *_response, NSData *data, NSError *connectionError) {
        if (connectionError) { return callback(connectionError, nil); }
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)_response;
        NSError* error = checkHttpError(response);
        if (error) { return callback(error, nil); }
        
        NSString* contentType = response.allHeaderFields[@"content-type"];
        if ([contentType isEqualToString:@"application/json"]) {
            id jsonRes = [JSON parseData:data];
            if (!jsonRes) { return callback(makeError(@"Bad JSON format"), nil); }
            NSLog(@"API got %@ %@ %@", method, path, jsonRes);
            callback(nil, jsonRes);
        } else if ([contentType isEqualToString:@"text/plain"]) {
            NSLog(@"API got %@ %@ %@", method, path, data.toString);
            callback(nil, data.toString);
        }
    }];    
}

+ (NSDictionary*)headers:(NSString*)contentType data:(NSData*)data {
    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:baseHeaders];
    if (contentType) {
        headers[@"content-type"] = contentType;
    }
    if (data && data.length) {
        headers[@"content-length"] = idInt(data.length);
    }
    return headers;
}

@end
