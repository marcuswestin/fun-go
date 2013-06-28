//
//  SQL.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface SQLBaseResult : NSObject
@property NSError* error;
@end

@interface SQLRow : SQLBaseResult
@property id row;
@end

@interface SQLRows :SQLBaseResult
@property NSArray* rows;
@end

@interface SQLConn : FunBase
@property FMDatabase* db;
- (SQLRows*)select:(NSString *)sql args:(NSArray *)args;
- (SQLRow*)selectOne:(NSString *)sql args:(NSArray *)args;
//- (void)update:(NSString*)sql args:(NSArray*)args;
//- (void)updateOne:(NSString*)sql args:(NSArray*)args callback:(Callback)callback;
//- (void)insert:(NSString*)sql args:(NSArray*)args callback:(Callback)callback;
//- (void)insertMultiple:(NSString*)sql argsList:(NSArray*)args callback:(Callback)callback;
@end

typedef void (^SQLSelectCallback)(id err, NSArray* rows);
typedef void (^SQLSelectOneCallback)(id err, id row);
typedef void (^SQLConnBlock)(SQLConn *conn);

@interface SQL : FunBase
+ (void)autocommit:(SQLConnBlock)block;
+ (void)open:(NSString*)path;
+ (NSString*) joinSelect:(NSDictionary*)tableColumns;
@end

