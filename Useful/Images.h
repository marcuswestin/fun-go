//
//  Images.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^ImageCallback)(id err, UIImage* image);

@interface Images : FunBase

+ (void)load:(NSString*)url resize:(CGSize)size callback:(ImageCallback)callback;

@end
