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
            // id: int
            // uid: int
            // author: string
            // description: string
            // image: string
            // audio: string
            // create_date: string
            // update_date: string
            // sync_date: string
            // liked: int
            // disliked: int
            // remote: string
            // enable: int
            
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS stillsprofile (id INTEGER PRIMARY KEY, uid INTEGER, author TEXT, description TEXT, image TEXT, audio TEXT, create_date TEXT, update_date TEXT, sync_date TEXT, liked INTEGER, disliked INTEGER, remote TEXT, enable INTEGER)";
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

-(BOOL) saveData:(NSMutableDictionary*)data{
    int uid = [[data objectForKey:@"uid"] intValue];
    NSString *author = [data objectForKey:@"author"];
    NSString *description = [data objectForKey:@"description"];
    NSString *image = [data objectForKey:@"image"];
    NSString *audio = [data objectForKey:@"audio"];
    NSString *create_date = [data objectForKey:@"create_date"];
    NSString *update_date = [data objectForKey:@"update_date"];
    NSString *sync_date = [data objectForKey:@"sync_date"];
    int liked = [[data objectForKey:@"liked"] intValue];
    int disliked = [[data objectForKey:@"disliked"] intValue];
    NSString *remote = [data objectForKey:@"remote"];
    int enable = [[data objectForKey:@"enable"] intValue];
    
    const char *dpath = [databasePath UTF8String];
    if (sqlite3_open(dpath, &database) == SQLITE_OK){
        NSString *query = [NSString stringWithFormat:@"INSERT INTO stillsprofile (uid,author,description,image,audio,create_date,update_date,sync_date,liked,disliked,remote,enable) VALUES (\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\")",uid,author,description,image,audio,create_date,update_date,sync_date,liked,disliked,remote,enable];
        const char *query_stmt = [query UTF8String];
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            return YES;
        } else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    
    return NO;
}

@end
