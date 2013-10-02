//
//  NSString+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Fun)

- (NSArray*)splitByComma;
- (NSArray*)split:(NSString*)splitter;
- (NSData*)toData;
- (NSString*)stringByRemoving:(NSString*)needles;
- (NSString*)encodedURIComponent;
- (NSString*)stringByTrimmingWhitespace;
- (BOOL)isEmpty;
@end
