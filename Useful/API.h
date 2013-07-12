//
//  API.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^APICallback)(NSError* err, id res);

@interface API : FunBase

+ (void)setup:(NSString*)serverUrl;
+ (void)setHeaders:(NSDictionary*)headers;
+ (void)post:(NSString*)path json:(NSDictionary*)json callback:(APICallback)callback;
+ (void)get:(NSString*)path queries:(NSDictionary*)queries callback:(APICallback)callback;
+ (void)upload:(NSString*)path json:(NSDictionary*)json attachments:(NSDictionary*)attachments callback:(APICallback)callback;

@end
