//
//  DBManager.m
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance){
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL) createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"stills.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath:databasePath]){
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK){
            char *errMsg;
            //TODO: real database set up
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS stillsprofile (id INTEGER PRIMARY KEY, image TEXT, audio TEXT, date TEXT)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
                isSuccess = NO;
                NSLog(@"Fail to create table");
            }
            sqlite3_close(database);
            return isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Fail to open/create database");
        }
    }
    
    return isSuccess;
}

@end
