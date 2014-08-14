//
//  DBManager.h
//  butterstill
//
//  Created by Paper on 8/11/14.
//  Copyright (c) 2014 Paper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(BOOL)saveData:(NSMutableDictionary *)data;
-(NSMutableArray *)getDatas;
-(BOOL)deleteData:(NSInteger)row_id;

@end
