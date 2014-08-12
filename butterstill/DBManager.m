//
//  DBManager.m
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import "DBManager.h"
#import "StillProfile.h"

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
            
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS stillsprofile (id INTEGER PRIMARY KEY, uid INTEGER, author TEXT, description TEXT, image TEXT, audio TEXT, create_date INTEGER, update_date INTEGER, sync_date INTEGER, liked INTEGER, disliked INTEGER, remote TEXT, enable INTEGER)";
            
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
    int create_date = [[data objectForKey:@"create_date"] intValue];
    int update_date = [[data objectForKey:@"update_date"] intValue];
    int sync_date = [[data objectForKey:@"sync_date"] intValue];
    int liked = [[data objectForKey:@"liked"] intValue];
    int disliked = [[data objectForKey:@"disliked"] intValue];
    NSString *remote = [data objectForKey:@"remote"];
    int enable = [[data objectForKey:@"enable"] intValue];
    
    const char *dpath = [databasePath UTF8String];
    if (sqlite3_open(dpath, &database) == SQLITE_OK){
        NSLog(@"level1");
        NSString *query = [NSString stringWithFormat:@"INSERT INTO stillsprofile (uid,author,description,image,audio,create_date,update_date,sync_date,liked,disliked,remote,enable) VALUES (%d,\"%@\",\"%@\",\"%@\",\"%@\",%d,%d,%d,%d,%d,\"%@\",%d)",uid,author,description,image,audio,create_date,update_date,sync_date,liked,disliked,remote,enable];
        
        NSLog(@"%@",query);
        
        const char *query_stmt = [query UTF8String];
        NSLog(@"%s",query_stmt);
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"level2");
            return YES;
        } else { 
            NSLog(@"level3");
            return NO;
        }
        sqlite3_reset(statement);
    }
    
    return NO;
}

-(NSArray*) getDatas{
    const char *dpath = [databasePath UTF8String];
    if (sqlite3_open(dpath, &database) == SQLITE_OK){
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM stillsprofile WHERE enable=\"1\""];
        const char *query_stmt = [query UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, nil)){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 0)] forKey:@"id"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 1)] forKey:@"uid"];
                [data setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)] forKey:@"author"];
                [data setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)] forKey:@"description"];
                [data setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] forKey:@"image"];
                [data setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)] forKey:@"audio"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 6)] forKey:@"create_date"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 7)] forKey:@"update_date"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 8)] forKey:@"sync_date"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 9)] forKey:@"liked"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 10)] forKey:@"disliked"];
                [data setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)] forKey:@"remote"];
                [data setObject:[NSNumber numberWithInt:sqlite3_column_int(statement, 12)] forKey:@"enable"];
                
                StillProfile *temp = [[StillProfile alloc] initWithStillProfile:data];
                [resultArray addObject:temp];
                
            }
            sqlite3_reset(statement);
            
        }
        return resultArray;
    }
    return nil;
}

@end
