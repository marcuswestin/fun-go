//
//  Images.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Images.h"
#import "Cache.h"

@implementation Images

static NSOperationQueue* queue;
static NSMutableDictionary* loading;
static NSMutableDictionary* processing;
static CGSize noResize;
static NSUInteger noRadius;
static NSString* cacheKeyBase;

+ (void)setup {
    loading = [NSMutableDictionary dictionary];
    processing = [NSMutableDictionary dictionary];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    noResize = CGSizeMake(0,0);
    noRadius = 0;
    
    cacheKeyBase = @"Images";
//    cacheKeyBase = [cacheKeyBase stringByAppendingFormat:@"%f", [NSDate new].timeIntervalSince1970];
}


+ (void)load:(NSString *)url resize:(CGSize)size callback:(ImageCallback)callback {
    [Images load:url resize:size radius:0 callback:callback];
}

+ (void)load:(NSString *)url resize:(CGSize)resize radius:(NSUInteger)radius callback:(ImageCallback)callback {
    NSData* data;
    // Processed cached
    NSString* processedKey = [self _cacheKeyFor:url resize:resize radius:radius];
    data = [Cache get:processedKey];
    if (data) {
//        NSLog(@"Found resized cached %@", processedKey);
        return callback(nil, [UIImage imageWithData:data]);
    }

    // Original cached
    NSString* originalKey = [self _cacheKeyFor:url resize:noResize radius:noRadius];
    data = [Cache get:originalKey];
    if (data) {
//        NSLog(@"Found original cached %@", originalKey);
        return [self _processAndCache:url data:data resize:resize radius:radius callback:callback];
    }
    
    // Fetch from network
    [self _fetch:url cacheKey:originalKey callback:^(id err, NSData* data) {
        if (err) { return callback(err,nil); }
        
        // Multiple load calls could have been made for the same un-fetched image with the same processing parameters
        NSData* processedData = [Cache get:processedKey];
        if (processedData) { return callback(nil, [UIImage imageWithData:processedData]); }
        
        return [self _processAndCache:url data:data resize:resize radius:radius callback:callback];
    }];
}

+ (void)_fetch:(NSString*)url cacheKey:(NSString*)key callback:(DataCallback)callback {
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
        
        [Cache store:key data:netData];

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
    UIImage* image = [UIImage imageWithData:data];
    if (resize.width || resize.height || radius) {
        image = [image thumbnailSize:CGSizeMake(resize.width*2, resize.height*2) transparentBorder:0 cornerRadius:radius interpolationQuality:kCGInterpolationDefault];
        NSString* key = [self _cacheKeyFor:url resize:resize radius:radius];
        if (radius) {
            // Radius require PNG transparency
            [Cache store:key data:UIImagePNGRepresentation(image)];
        } else {
            [Cache store:key data:UIImageJPEGRepresentation(image, 1.0)];
        }
    }
    callback(nil, image);
}

+ (NSString*)_cacheKeyFor:(NSString*)url resize:(CGSize)resize radius:(NSUInteger)radius {
    return [NSString stringWithFormat:@"%@:url:%@+resize:%@+radius:%d", cacheKeyBase, url, NSStringFromCGSize(resize), radius];
}

@end
