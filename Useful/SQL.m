//
//  SQL.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunAll.h"

@implementation SQLBaseResult
@synthesize error;
@end

@implementation SQLRow
@synthesize row;
@end

@implementation SQLRows
@synthesize rows;
@end


@implementation SQL

static FMDatabaseQueue* queue;

+ (void) open:(NSString*)path {
    queue = [FMDatabaseQueue databaseQueueWithPath:path];
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
    
    if (multiRes.rows.count != 1) {
        result.error = makeError(@"Bad number of rows");
        return result;
    }
    
    result.row = multiRes.rows[0];
    return result;
}


//+ (void)update:(NSString *)sql args:(NSArray *)args callback:(Callback)callback {
//    [queue inDatabase:^(FMDatabase *db) {
//        BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
//        //        if (!success && ignoreDuplicates && db.lastErrorCode == SQLITE_CONSTRAINT) { success = YES; }
//        if (!success) { return callback(db.lastError, nil); }
//        callback(nil,nil);
//    }];
//}
//
//+ (void)updateOne:(NSString *)sql args:(NSArray *)args callback:(Callback)callback {
//    [queue inDatabase:^(FMDatabase *db) {
//        BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
//        //        if (!success && ignoreDuplicates && db.lastErrorCode == SQLITE_CONSTRAINT) { success = YES; }
//        if (!success) { return callback(db.lastError, nil); }
//        if (db.changes != 1) { return callback(@"Updated too many rows", nil); }
//        callback(nil, nil);
//    }];
//    
//}
//
//+ (void)insert:(NSString *)sql args:(NSArray *)args callback:(Callback)callback {
//    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
//        if (!success) { return callback(db.lastError, nil); }
//        callback(nil,nil);
//    }];
//}
//
//+ (void)insertMultiple:(NSString *)sql argsList:(NSArray *)argsList callback:(Callback)callback {
//    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        for (NSArray* args in argsList) {
//            BOOL success = [db executeUpdate:sql withArgumentsInArray:args];
//            if (!success) { return callback(db.lastError, nil); }
//        }
//        callback(nil,nil);
//    }];
//}
@end