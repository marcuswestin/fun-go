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
static int numRequests = 0;

+ (void)setup:(NSString *)serverUrl {
    server = serverUrl;
    baseHeaders = [NSMutableDictionary dictionary];
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
    NSLog(@"API POST %@ %@", path, json);
}

+ (void)get:(NSString *)path queries:(NSDictionary *)queries callback:(APICallback)callback {
    path = [NSString stringWithFormat:@"%@?%@", path, queries.toQueryString];
    NSLog(@"API GET %@", path);
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
        [httpData appendData:[[NSString stringWithFormat:@"content-disposition: %@\r\n", [part valueForKey:@"content-disposition"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpData appendData:[[NSString stringWithFormat:@"content-type: %@\r\n", [part valueForKey:@"content-type"]] dataUsingEncoding:NSUTF8StringEncoding]];
        // EMPTY
        [httpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        // CONTENT + newline
        [httpData appendData:[NSData dataWithData:data]];
        [httpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"API Upload %@", path);
    [self send:@"POST" path:path contentType:contentType data:httpData callback:callback];
}


+ (void) send:(NSString*)method path:(NSString*)path contentType:(NSString*)contentType data:(NSData*)data callback:(APICallback)callback {

    NSDictionary* devInterceptRes = [API _devIntercept:path];
    if (devInterceptRes) {
        return dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, devInterceptRes);
        });
    }
    
    if (!server) { [NSException raise:@"MissingServer" format:@"You must do [API setup:@\"https://your.server.com\""]; }
    NSString* url = [server stringByAppendingString:path];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = method;
    request.HTTPBody = data;
    request.allHTTPHeaderFields = [API headers:contentType data:data];

    [API _showSpinner];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [API _handleResponse:(NSHTTPURLResponse*)response forMethod:method path:path data:data error:connectionError callback:callback];
        });
    }];
}

+ (void)_handleResponse:(NSHTTPURLResponse*)response forMethod:(NSString*)method path:(NSString*)path data:(NSData*)data error:(NSError*)connectionError callback:(APICallback)callback {
    [API _hideSpinner];
    
    if (connectionError) { return callback(connectionError, nil); }
    NSError* error = checkHttpError(response);
    if (error) { return callback(error, nil); }
    
    NSString* contentType = response.allHeaderFields[@"content-type"];
    
    if ([contentType rangeOfString:@"application/json"].location == 0) {
        id jsonRes = [JSON parseData:data];
        if (!jsonRes) { return callback(makeError(@"Bad JSON format"), nil); }
        NSLog(@"API got json: %@ %@", method, path);
        callback(nil, jsonRes);
    } else if ([contentType rangeOfString:@"text/plain"].location == 0) {
        NSLog(@"API got text: %@ %@ %@", method, path, data.toString);
        callback(nil, data.toString);
    } else {
        NSLog(@"API got unknown: %@ %@ %@", method, path, contentType);
    }
}

+ (NSDictionary*)headers:(NSString*)contentType data:(NSData*)data {
    NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithDictionary:baseHeaders];
    if (contentType) {
        headers[@"content-type"] = contentType;
    }
    if (data && data.length) {
        headers[@"content-length"] = [num(data.length) stringValue];
    }
    return headers;
}

+ (void)_showSpinner {
    @synchronized(self) {
        if (numRequests == 0) {
            UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
        }
        numRequests += 1;
    }
}

+ (void)_hideSpinner {
    @synchronized(self) {
        numRequests -= 1;
        if (numRequests == 0) {
            UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
        }
    }
}

+ (NSDictionary*)_devIntercept:(NSString*)path {
    return nil;
}

@end
