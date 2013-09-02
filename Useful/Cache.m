//
//  Cache.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Cache.h"
#import "Files.h"

@implementation Cache

static NSCharacterSet* illegalFileNameCharacters = nil;
//static NSString* _path;

+ (void)load {
    illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<> {}"];
//    _path = [Files cachePath:@"Caches"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:NULL error:NULL];
}

+ (void)store:(NSString*)key data:(NSData*)data {
    [self store:key data:data cacheInMemory:NO];
}
+ (void)store:(NSString *)key data:(NSData *)data cacheInMemory:(BOOL)cacheInMemory {
    [Files writeCache:[self _filename:key] data:data];
}
+ (NSData*)get:(NSString*)key {
    return [self get:key cacheInMemory:NO];
}
+ (NSData *)get:(NSString *)key cacheInMemory:(BOOL)cacheInMemory {
    return [Files readCache:[self _filename:key]];
}

+ (NSString *)_filename:(NSString *)key {
    NSString* filename = [[key componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
//    return [_path stringByAppendingString:filename];
    return filename;
}
@end
