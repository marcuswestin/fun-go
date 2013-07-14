//
//  FunFiles.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Files.h"
#import "FunAll.h"

@implementation Files

static NSString* _documentsDirectory;
static NSString* _cachesDirectory;

+ (void)setup {
    _documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
+ (id)readJsonDocument:(NSString *)filename {
    return [Files readDocument:filename].toJsonObject;
}
+ (id)readJsonDocument:(NSString *)filename property:(NSString *)property {
    return [Files readJsonDocument:filename][property];
}
+ (void)writeJsonDocument:(NSString *)filename data:(id)data {
    [Files writeDocument:filename data:[JSON toData:data]];
}
+ (void)writeJsonDocument:(NSString *)filename property:(NSString *)property data:(id)data {
    id readDoc = [Files readJsonDocument:filename];
    NSMutableDictionary* doc = [(readDoc ? readDoc : @{}) mutableCopy];
    doc[property] = data;
    [Files writeJsonDocument:filename data:doc];
}
+ (NSData*)readDocument:(NSString*)name {
    return [NSData dataWithContentsOfFile:[self documentPath:name]];
}
+ (NSData*)readCache:(NSString*)name {
    return [NSData dataWithContentsOfFile:[self cachePath:name]];
}
+ (BOOL)writeCache:(NSString*)name data:(NSData*)data {
    return [data writeToFile:[self cachePath:name] atomically:YES];
}
+ (BOOL)writeDocument:(NSString *)name data:(NSData *)data {
    return [data writeToFile:[self documentPath:name] atomically:YES];
}
+ (NSString*)cachePath:(NSString*)filename {
    return [_cachesDirectory stringByAppendingPathComponent:filename];
}
+ (NSString*)documentPath:(NSString*)filename {
    return [_documentsDirectory stringByAppendingPathComponent:filename];
}
+ (NSString *)readResource:(NSString *)name {
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}
@end
