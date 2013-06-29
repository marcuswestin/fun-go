//
//  SQL.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunAll.h"
#import "FMDatabaseAdditions.h"

@implementation SQLBaseResult
@synthesize error;
@end

@implementation SQLRow
@synthesize row;
@end

@implementation SQLRows
@synthesize rows;
@end

static NSMutableDictionary* columnsCache;

@implementation SQL

static FMDatabaseQueue* queue;

+ (void) open:(NSString*)path {
    queue = [FMDatabaseQueue databaseQueueWithPath:path];
    columnsCache = [NSMutableDictionary dictionary];
}

+ (void)autocommit:(SQLConnBlock)block {
    [queue inDatabase:^(FMDatabase *db) {
        SQLConn* conn = [[SQLConn alloc] init];
        conn.db = db;
        block(conn);
    }];
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

@synthesize db;

- (SQLRows*)select:(NSString *)sql args:(NSArray *)args {
    SQLRows* result = [[SQLRows alloc] init];

    FMResultSet* resultSet = [db executeQuery:sql withArgumentsInArray:args];
    if (!resultSet) {
        result.error = db.lastError;
        return result;
    }
    
    NSMutableArray* rows = [NSMutableArray array];
    while ([resultSet next]) {
        [rows addObject:[resultSet resultDictionary]];
    }
    
    result.rows = rows;
    return result;
}

- (SQLRow *)selectOne:(NSString *)sql args:(NSArray *)args {
    SQLRows* multiRes = [self select:sql args:args];
    SQLRow* result = [[SQLRow alloc] init];
    
    if (multiRes.error) {
        result.error = multiRes.error;
        return result;
    }
    
    if (multiRes.rows.count > 1) {
        result.error = makeError(@"Bad number of rows");
        return result;
    }
    
    result.row = multiRes.rows.count ? multiRes.rows[0] : nil;
    
    return result;
}

- (NSError *)insert:(NSString *)sql args:(NSArray *)args {
    BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
    if (!success) { return db.lastError; }
    return nil;
}

- (NSError *)insertMultiple:(NSString *)sql argsList:(NSArray *)argsList {
    for (NSArray* args in argsList) {
        BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
        if (!success) { return db.lastError; }
    }
    return nil;
}

- (NSError*)insertOrReplaceMultipleInto:(NSString*)table items:(NSArray*)items {
    if (!items || items.count == 0) { return nil; }
    
    NSArray* columns = [self _columns:table];
    NSString* questionMarks = [@"?" stringByPaddingToLength:columns.count*2-1 withString:@",?" startingAtIndex:0];
    NSString* columnNames = [columns map:^id(id name, NSUInteger i) { return name; }].joinedByCommaSpace;
    NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)", table, columnNames, questionMarks];

    NSMutableArray* values;
    for (id item in items) {
        values = [NSMutableArray arrayWithCapacity:items.count];
        
        for (NSString* column in columns) {
            [values addObject:item[column] ? item[column] : NSNull.null];
        }

        BOOL success = [db executeUpdate:sql withArgumentsInArray:values];
        if (!success) { return db.lastError; }
    }
    return nil;
}

- (NSArray*)_columns:(NSString*)table {
    if (columnsCache[table]) { return columnsCache[table]; }
    NSMutableArray* columns = [NSMutableArray array];
    FMResultSet* rs = [db getTableSchema:table];
    if (!rs) { return nil; }
    while ([rs next]) {
        [columns addObject:[rs stringForColumn:@"name"]];
    }
    [rs close];
    return columnsCache[table] = columns;
}

@end