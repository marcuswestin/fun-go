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

+ (void)load {
    loading = [NSMutableDictionary dictionary];
    processing = [NSMutableDictionary dictionary];
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    noResize = CGSizeMake(0,0);
    noRadius = 0;
    
    cacheKeyBase = @"ImagesCache";
//    cacheKeyBase = [cacheKeyBase stringByAppendingFormat:@"%f", [NSDate new].timeIntervalSince1970];
}

+ (UIImage *)get:(NSString *)url resize:(CGSize)resize radius:(NSUInteger)radius {
    NSString* processedKey = [self _cacheKeyFor:url resize:resize radius:radius];
    NSData* data = [Cache get:processedKey];
    return (data ? [UIImage imageWithData:data] : nil);
}

+ (void)load:(NSString *)url resize:(CGSize)size callback:(ImageCallback)callback {
    [Images load:url resize:size radius:0 callback:callback];
}

+ (void)load:(NSString *)url resize:(CGSize)resize radius:(NSUInteger)radius callback:(ImageCallback)callback {
    // Processed cached
    callback = [self _mainThreadCallback:callback];
    asyncDefault(^{
        NSString* processedKey = [self _cacheKeyFor:url resize:resize radius:radius];
        NSData* processedData = [Cache get:processedKey];
        if (processedData) {
            callback(nil, [UIImage imageWithData:processedData]);
            return;
        }

        // Original cached
        NSString* originalKey = [self _cacheKeyFor:url resize:noResize radius:noRadius];
        NSData* originalData = [Cache get:originalKey];
        if (originalData) {
            [self _processAndCache:url data:originalData resize:resize radius:radius callback:callback];
            return;
        }
    
        // Fetch from network
        [self _fetch:url cacheKey:originalKey callback:^(id err, NSData* data) {
            if (err) { return callback(err,nil); }
            
            // Multiple load calls could have been made for the same un-fetched image with the same processing parameters
            NSData* processedData = [Cache get:processedKey];
            if (processedData) {
                callback(nil, [UIImage imageWithData:processedData]);
            }
            
            return [self _processAndCache:url data:data resize:resize radius:radius callback:callback];
        }];
    });
}

+ (ImageCallback)_mainThreadCallback:(ImageCallback)callback {
    return ^(NSError* err, UIImage* image) {
        asyncMain(^{
            callback(err, image);
        });
    };
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
        [Cache store:key data:UIImagePNGRepresentation(image)]; // Radius require PNG transparency
    }
    
    callback(nil, image);
}

+ (NSString*)_cacheKeyFor:(NSString*)url resize:(CGSize)resize radius:(NSUInteger)radius {
    return [NSString stringWithFormat:@"%@:url:%@+resize:%@+radius:%d", cacheKeyBase, url, NSStringFromCGSize(resize), radius];
}

@end
