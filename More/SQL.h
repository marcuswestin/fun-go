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
- (NSError*)update:(NSString*)sql args:(NSArray*)args;
- (NSError*)updateOne:(NSString*)sql args:(NSArray*)args;
- (NSError*)insert:(NSString*)sql args:(NSArray*)args;
- (NSError*)insertMultiple:(NSString*)sql argsList:(NSArray*)argsList;
- (NSError*)insertOrReplaceMultipleInto:(NSString*)table items:(NSArray*)items;
- (NSError*)schema:(NSString*)sql;
@end

typedef void (^MigrationBlock)(SQLConn* conn);
@interface SQLMigrations : FunBase
@property SQLConn* conn;
- (void) registerMigration:(NSString*)name withBlock:(MigrationBlock)migrationBlock;
@end

typedef void (^SQLRegisterMigrations)(SQLMigrations* migrations);
typedef void (^SQLSelectCallback)(id err, NSArray* rows);
typedef void (^SQLSelectOneCallback)(id err, id row);
typedef void (^SQLAutocommitBlock)(SQLConn *conn);
typedef void (^SQLRollbackBlock)();
typedef void (^SQLTransactionBlock)(SQLConn *conn, SQLRollbackBlock rollback);

@interface SQL : FunBase
+ (void)autocommit:(SQLAutocommitBlock)block;
+ (void)transact:(SQLTransactionBlock)block;
+ (SQLRes*)select:(NSString*)sql args:(NSArray*)args;
+ (SQLRes*)selectOne:(NSString*)sql args:(NSArray*)args;
+ (void)open:(NSString*)path withMigrations:(SQLRegisterMigrations)migrationsFn;
+ (NSString*) joinSelect:(NSDictionary*)tableColumns;
@end

