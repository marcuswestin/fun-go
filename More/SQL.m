//
//  SQL.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunObjc.h"
#import "SQL.h"
#import "FMDatabaseAdditions.h"
#import "Files.h"
#import "Log.h"

@implementation SQLRes
@end

static NSMutableDictionary* columnsCache;

@implementation SQLMigrations {
    NSMutableArray* _completedMigrations;
    NSUInteger _migrationIndex;
    NSMutableArray* _newMigrations;
}
static NSString* MigrationDoc = @"SQLMigrationInfo";
- (id)init {
    if (self = [super init]) {
        NSDictionary* migrationInfo = [Files readJsonDocument:MigrationDoc];
        _migrationIndex = 0;
        _newMigrations = [NSMutableArray array];
        if (migrationInfo) {
            _completedMigrations = [NSMutableArray arrayWithArray:migrationInfo[@"completedMigrations"]];
        } else {
            _completedMigrations = [NSMutableArray array];
        }
    }
    return self;
}
- (void)registerMigration:(NSString *)name withBlock:(MigrationBlock)block {
    if (_migrationIndex < _completedMigrations.count) {
        NSString* expectedMigraitonName = _completedMigrations[_migrationIndex];
        if (![name isEqualToString:expectedMigraitonName]) {
            [Log error:makeError(@"Bad migration order")];
            [NSException raise:@"BadMigration" format:@"Expected migration named %@ but found %@", expectedMigraitonName, name];
        }
    } else {
        [_newMigrations addObject:@{ @"name":name, @"block":block }];
    }
    _migrationIndex += 1;
}
- (void)_finish {
    [_newMigrations each:^(NSDictionary* migration, NSUInteger i) {
        NSLog(@"Running migration %@", migration[@"name"]);
        [SQL transact:^(SQLConn *conn, SQLRollbackBlock rollback) {
            MigrationBlock migrationBlock = migration[@"block"];
            @try {
                migrationBlock(conn);
            }
            @catch (NSException *exception) {
                [Log error:makeError(exception.reason)];
                rollback();
            }
        }];
        [_completedMigrations addObject:migration[@"name"]];
    }];
    
    [Files writeJsonDocument:MigrationDoc data:@{@"completedMigrations": _completedMigrations}];
}
@end

@implementation SQL

static FMDatabaseQueue* queue;

+ (void) open:(NSString*)path withMigrations:(SQLRegisterMigrations)migrationsFn {
    queue = [FMDatabaseQueue databaseQueueWithPath:path];
    columnsCache = [NSMutableDictionary dictionary];
    SQLMigrations* migrations = [[SQLMigrations alloc] init];
    migrationsFn(migrations);
    [migrations _finish];
}

+ (void)autocommit:(SQLAutocommitBlock)block {
    [queue inDatabase:^(FMDatabase *db) {
        SQLConn* conn = [[SQLConn alloc] init];
        conn.db = db;
        block(conn);
    }];
}

+ (void)transact:(SQLTransactionBlock)block {
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        SQLConn* conn = [[SQLConn alloc] init];
        conn.db = db;
        block(conn, ^{
            *rollback = YES;
        });
    }];
}

+ (SQLRes *)select:(NSString *)sql args:(NSArray *)args {
    __block SQLRes* result;
    [SQL autocommit:^(SQLConn *conn) {
        result = [conn select:sql args:args];
    }];
    return result;
}

+ (SQLRes *)selectOne:(NSString *)sql args:(NSArray *)args {
    __block SQLRes* result;
    [SQL autocommit:^(SQLConn *conn) {
        result = [conn selectOne:sql args:args];
    }];
    return result;
}

+ (NSString *)joinSelect:(NSDictionary *)tableColumns {
    NSMutableArray* selections = [NSMutableArray array];
    [tableColumns each:^(NSString* columnList, NSString* tableName) {
        [columnList.splitByComma each:^(NSString* columnName, NSUInteger i) {
            [selections addObject:[NSString stringWithFormat:@"%@.%@ AS %@", tableName, columnName, columnName]];
        }];
    }];
    return [@"SELECT " stringByAppendingString:selections.joinedByCommaSpace];
}

@end

static NSMutableDictionary* columns;

@implementation SQLConn

- (SQLRes*)select:(NSString *)sql args:(NSArray *)args {
    SQLRes* result = [[SQLRes alloc] init];

    FMResultSet* resultSet = [_db executeQuery:sql withArgumentsInArray:args];
    if (!resultSet) {
        result.error = _db.lastError;
        return result;
    }
    
    NSMutableArray* rows = [NSMutableArray array];
    while ([resultSet next]) {
        [rows addObject:[resultSet resultDictionary]];
    }
    
    result.rows = rows;
    if (rows.count == 1) {
        result.row = rows[0];
    }
    
    return result;
}

- (SQLRes*)selectOne:(NSString *)sql args:(NSArray *)args {
    SQLRes* result = [self select:sql args:args];
    
    if (result.error) { return result; }
    
    if (result.rows.count > 1) {
        result.error = makeError(@"Bad number of rows");
        return result;
    }
    
    return result;
}

- (NSError *)insert:(NSString *)sql args:(NSArray *)args {
    BOOL success = [_db executeUpdate:sql withArgumentsInArray:args];
    if (!success) { return _db.lastError; }
    return nil;
}

- (NSError *)insertMultiple:(NSString *)sql argsList:(NSArray *)argsList {
    for (NSArray* args in argsList) {
        BOOL success = [_db executeUpdate:sql withArgumentsInArray:args];
        if (!success) { return _db.lastError; }
    }
    return nil;
}

- (NSError*)insertOrReplaceMultipleInto:(NSString*)table items:(NSArray*)items {
    if (!items || items.count == 0) { return nil; }
    
    NSArray* columns = [self _columns:table];
    NSString* questionMarks = [@"?" stringByPaddingToLength:columns.count*2-1 withString:@",?" startingAtIndex:0];
    NSString* columnNames = [columns map:^id(id name, NSUInteger i) { return name; }].joinedByCommaSpace;
    NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)", table, columnNames, questionMarks];

    NSMutableArray* values = [NSMutableArray arrayWithCapacity:columns.count];
    for (id item in items) {
        [values removeAllObjects];
        for (NSString* column in columns) {
            [values addObject:item[column] ? item[column] : NSNull.null];
        }

        BOOL success = [_db executeUpdate:sql withArgumentsInArray:values];
        if (!success) { return _db.lastError; }
    }
    return nil;
}

- (NSError *)schema:(NSString *)sql {
    return [self update:sql args:nil];
}

- (NSError *)update:(NSString *)sql args:(NSArray *)args {
    BOOL success = [_db executeUpdate:sql withArgumentsInArray:args];
    return (success ? nil : _db.lastError);
}

- (NSError *)updateOne:(NSString *)sql args:(NSArray *)args {
    BOOL success = [_db executeUpdate:sql withArgumentsInArray:args];
    if (!success) { return _db.lastError; }
    if (_db.changes > 1) { return makeError(@"updateOne affected multipe rows"); }
    return nil;
}

- (NSArray*)_columns:(NSString*)table {
    if (columnsCache[table]) { return columnsCache[table]; }
    NSMutableArray* columns = [NSMutableArray array];
    FMResultSet* rs = [_db getTableSchema:table];
    if (!rs) { return nil; }
    while ([rs next]) {
        [columns addObject:[rs stringForColumn:@"name"]];
    }
    [rs close];
    return columnsCache[table] = columns;
}

@end