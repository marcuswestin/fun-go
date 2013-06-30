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

@interface SQLRes : NSObject
@property NSError* error;
@property NSArray* rows;
@property NSDictionary* row;
@end

@interface SQLConn : FunBase
@property FMDatabase* db;
- (SQLRes*)select:(NSString *)sql args:(NSArray *)args;
- (SQLRes*)selectOne:(NSString *)sql args:(NSArray *)args;
//- (void)update:(NSString*)sql args:(NSArray*)args;
//- (void)updateOne:(NSString*)sql args:(NSArray*)args callback:(Callback)callback;
- (NSError*)insert:(NSString*)sql args:(NSArray*)args;
- (NSError*)insertMultiple:(NSString*)sql argsList:(NSArray*)argsList;
- (NSError*)insertOrReplaceMultipleInto:(NSString*)table items:(NSArray*)items;
@end

typedef void (^SQLSelectCallback)(id err, NSArray* rows);
typedef void (^SQLSelectOneCallback)(id err, id row);
typedef void (^SQLConnBlock)(SQLConn *conn);

@interface SQL : FunBase
+ (void)autocommit:(SQLConnBlock)block;
+ (void)open:(NSString*)path;
+ (NSString*) joinSelect:(NSDictionary*)tableColumns;
@end

