//
//  Images.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Images.h"
#import "Cache.h"
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"

@implementation Images

static NSOperationQueue* queue;
static NSMutableDictionary* loading;
static NSMutableDictionary* processing;
static CGSize noResize;

+ (void)setup {
    loading = [NSMutableDictionary dictionary];
    processing = [NSMutableDictionary dictionary];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    noResize = CGSizeMake(0,0);
}


+ (void)load:(NSString *)url resize:(CGSize)size callback:(ImageCallback)callback {
    [Images load:url resize:size radius:0 callback:callback];
}

+ (void)load:(NSString *)url resize:(CGSize)resize radius:(NSUInteger)radius callback:(ImageCallback)callback {
    NSString* key;
    NSData* data;
    // Resized cached
    key = [self _cacheKeyFor:url resize:resize radius:radius];
    data = [Cache get:key];
    if (data) {
//        NSLog(@"Found resized cached %@", key);
        return callback(nil, [UIImage imageWithData:data]);
    }

    // Original cached
    key = [self _cacheKeyFor:url resize:noResize radius:radius];
    data = [Cache get:key];
    if (data) {
//        NSLog(@"Found original cached %@", key);
        return [self _processAndCache:url data:data resize:resize radius:radius callback:callback];
    }
    
    // Fetch from network
    [self _fetch:url callback:^(id err, NSData* data) {
        if (err) { return callback(err,nil); }
        return [self _processAndCache:url data:data resize:resize radius:radius callback:callback];
    }];
}

+ (void)_fetch:(NSString*)url callback:(DataCallback)callback {
    @synchronized(loading) {
        if (loading[url]) {
            [loading[url] addObject:callback];
            return;
        }
        loading[url] = [NSMutableArray arrayWithObject:callback];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    NSLog(@"Fetch %@", url);
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *netRes, NSData *netData, NSError *netErr) {
        if (netErr) {
            return [self _onFetched:url error:netErr data:nil];
        }
        if (!netData || !netData.length) {
            return [self _onFetched:url error:@"Error getting image :(" data:nil];
        }
        [self _onFetched:url error:nil data:netData];
    }];
}

+ (void) _onFetched:(NSString*)url error:(id)error data:(NSData*)data {
//    NSLog(@"Fetched %@ %@ %d", url, error, (data ? data.length : -1));
    NSArray* callbacks;
    @synchronized(loading) {
        callbacks = loading[url];
        [loading removeObjectForKey:url];
    }
    for (DataCallback callback in callbacks) {
        callback(error, data);
    }
}

+ (void) _processAndCache:(NSString*)url data:(NSData*)data resize:(CGSize)resize radius:(NSUInteger)radius callback:(ImageCallback)callback {
    [self _cache:url resize:noResize radius:radius data:data];
    UIImage* image = [UIImage imageWithData:data];
    if (resize.width && resize.height) {
//        NSLog(@"Resize image %@", NSStringFromCGSize(resize));
        image = [image thumbnailSize:CGSizeMake(resize.width*2, resize.height*2) transparentBorder:0 cornerRadius:radius interpolationQuality:kCGInterpolationDefault];
        [self _cache:url resize:resize radius:radius data:UIImageJPEGRepresentation(image, 1.0)];
    }
    callback(nil, image);
}

+ (void) _cache:(NSString*)url resize:(CGSize)resize radius:(NSUInteger)radius data:(NSData*)data {
    [Cache store:[self _cacheKeyFor:url resize:resize radius:radius] data:data];
}

+ (NSString*)_cacheKeyFor:(NSString*)url resize:(CGSize)resize radius:(NSUInteger)radius {
    return [NSString stringWithFormat:@"Images:url:%@+resize:%@+radius:%d", url, NSStringFromCGSize(resize), radius];
}

@end
