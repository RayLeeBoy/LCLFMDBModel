//
//  LCLDataManager.m
//  LCLFMDBModel
//
//  Created by 云淡风轻 on 2018/11/8.
//  Copyright © 2018 北京正图数创科技股份有限公司. All rights reserved.
//

#import "LCLDataManager.h"

@interface LCLDataManager()

@property (nonatomic, strong) FMDatabase * database;
@property (nonatomic, strong) Class class;

@end

@implementation LCLDataManager

static LCLDataManager * _instance;

#pragma mark - 必须先拿单例对象, 再来操作数据库
+ (instancetype)shareManager {
    return [[self alloc] init];
}

#pragma mark - 创建数据库
- (FMDatabase *)createDatabaseWithName:(NSString *)databaseName {
    // 数据库存放路径
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * str = [NSString stringWithFormat:@"%@.db", databaseName];
    NSString * dbPath = [docPath stringByAppendingPathComponent:str];
    NSLog(@"%s - %@", __func__, dbPath);
    
    // 创建数据库
    FMDatabase * db = [FMDatabase databaseWithPath:dbPath];
    self.database = db;
    return db;
}

#pragma mark - 打开数据库
- (BOOL)openDatabase {
    // 打开数据库
    BOOL result = [self.database open];
    if (result) {
        NSLog(@"%s - 数据库: 打开成功", __func__);
    } else {
        NSLog(@"%s - 数据库: 打开失败", __func__);
    }
    return result;
}

#pragma mark - 关闭数据库
- (BOOL)closeDatabase {
    // 打开数据库
    BOOL result = [self.database close];
    if (result) {
        NSLog(@"%s - 数据库: 关闭成功", __func__);
    } else {
        NSLog(@"%s - 数据库: 关闭失败", __func__);
    }
    return result;
}

#pragma mark - 创建表
- (BOOL)createTableWithName:(NSString *)tableName class:(Class)class {
    self.class = class;
    NSMutableString * sql = [NSMutableString stringWithFormat:@"create table if not exists '%@' (", tableName];
    [sql appendString:@"'id' integer primary key autoincrement"];
    
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList(class, &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        NSString * key = [NSString stringWithUTF8String:name];
        [sql appendFormat:@",'%@' text not null", [key substringFromIndex:1]];
    }
    [sql appendString:@")"];
    
    BOOL result = [self.database executeUpdate:sql];
    if (result) {
        NSLog(@"%s - 表: 创建成功", __func__);
    } else {
        NSLog(@"%s - 表: 创建失败", __func__);
    }
    return result;
}

#pragma mark - 添加数据:单条添加
- (BOOL)insertWithTableName:(NSString *)tableName model:(id)model {
    
    unsigned int count = 0;
    NSMutableString * keys = [NSMutableString stringWithFormat:@"("];
    NSMutableString * values = [NSMutableString stringWithFormat:@"("];
    NSMutableArray * mArr = [NSMutableArray arrayWithCapacity:0];
    Ivar * ivars = class_copyIvarList([model class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        NSString * key = [NSString stringWithUTF8String:name];
        [keys appendFormat:@"%@, ", [key substringFromIndex:1]];
        [values appendFormat:@"?, "];
        [mArr addObject:[model valueForKey:key]];
    }
    [keys deleteCharactersInRange:NSMakeRange(keys.length - 2, 2)];
    [keys appendFormat:@")"];
    
    [values deleteCharactersInRange:NSMakeRange(values.length - 2, 2)];
    [values appendFormat:@")"];
    free(ivars);
    
    NSString * sql = [NSString stringWithFormat:@"insert into '%@' %@ values %@", tableName, keys, values];
    BOOL result = [self.database executeUpdate:sql withArgumentsInArray:mArr];
    if (result) {
        NSLog(@"%s - 表: 插入数据成功", __func__);
    } else {
        NSLog(@"%s - 表: 插入数据失败", __func__);
    }
    return result;
}

#pragma mark - 删除数据:单条删除
- (BOOL)removeWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value {
    NSString * sql = [NSString stringWithFormat:@"delete from '%@' where %@ = '%@'", tableName, key, value];
    BOOL result = [self.database executeUpdate:sql];
    if (result) {
        NSLog(@"%s - 表: 删除数据成功", __func__);
    } else {
        NSLog(@"%s - 表: 删除数据失败", __func__);
    }
    return result;
}

#pragma mark - 删除数据:全部删除
- (BOOL)removeAllWithTableName:(NSString *)tableName {
    NSString * sql = [NSString stringWithFormat:@"delete from '%@'", tableName];
    BOOL result = [self.database executeUpdate:sql];
    if (result) {
        NSLog(@"%s - 表: 删除全部数据成功", __func__);
    } else {
        NSLog(@"%s - 表: 删除全部数据失败", __func__);
    }
    return result;
}

#pragma mark - 更新数据:单条更新
- (BOOL)update:(NSString *)tableName model:(id)model primaryKey:(NSString *)primaryKey primaryValue:(NSString *)primaryValue {
    NSMutableString * sql = [NSMutableString stringWithFormat:@"update '%@' set ", tableName];
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList([model class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        NSString * key = [NSString stringWithUTF8String:name];
        [sql appendFormat:@"%@ = '%@', ", [key substringFromIndex:1], [model valueForKey:key]];
    }
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 2, 2)];
    [sql appendFormat:@" where %@ = '%@'", primaryKey, primaryValue];
    BOOL result = [self.database executeUpdate:sql];
    if (result) {
        NSLog(@"%s - 表: 更新数据成功", __func__);
    } else {
        NSLog(@"%s - 表: 更新数据失败", __func__);
    }
    return result;
}

#pragma mark - 更新数据:单值更新
- (BOOL)update:(NSString *)tableName primaryKey:(NSString *)primaryKey primaryValue:(NSString *)primaryValue updateKey:(NSString *)updateKey updateValue:(NSString *)updateValue  {
    
    NSMutableString * sql = [NSMutableString stringWithFormat:@"update '%@' set ", tableName];
    [sql appendFormat:@"%@ = '%@'", updateKey, updateValue];
    [sql appendFormat:@" where %@ = '%@'", primaryKey, primaryValue];
    BOOL result = [self.database executeUpdate:sql];
    if (result) {
        NSLog(@"%s - 表: 更新数据成功", __func__);
    } else {
        NSLog(@"%s - 表: 更新数据失败", __func__);
    }
    return result;
}

#pragma mark - 查询数据:单条数据
- (NSMutableArray *)query:(NSString *)tableName key:(NSString *)key value:(NSString *)value {
    // 查询数据
    NSString * sql = [NSString stringWithFormat:@"select * from '%@' where %@ = '%@'", tableName, key, value];
    FMResultSet * resultSet = [self.database executeQuery:sql];
    id model = nil;
    NSMutableArray * mArr = [NSMutableArray arrayWithCapacity:0];
    while ([resultSet next]) {
        model = [self.class new];
        
        unsigned int count = 0;
        Ivar * ivars = class_copyIvarList([model class], &count);
        for (int i = 0; i<count; i++) {
            Ivar ivar = ivars[i];
            const char * name = ivar_getName(ivar);
            NSString * key = [NSString stringWithUTF8String:name];
            [model setValue:[resultSet stringForColumn:[key substringFromIndex:1]] forKey:key];
        }
        [mArr addObject:model];
    }
    return mArr;
}

#pragma mark - 查询数据:全部数据
- (NSMutableArray *)queryWithTableName:(NSString *)tableName {
    NSString * sql = [NSString stringWithFormat:@"select * from '%@'", tableName];
    FMResultSet * resultSet = [self.database executeQuery:sql];
    id model = nil;
    NSMutableArray * mArr = [NSMutableArray arrayWithCapacity:0];
    while ([resultSet next]) {
        model = [self.class new];
        
        unsigned int count = 0;
        Ivar * ivars = class_copyIvarList([model class], &count);
        for (int i = 0; i<count; i++) {
            Ivar ivar = ivars[i];
            const char * name = ivar_getName(ivar);
            NSString * key = [NSString stringWithUTF8String:name];
            [model setValue:[resultSet stringForColumn:[key substringFromIndex:1]] forKey:key];
        }
        [mArr addObject:model];
    }
    return mArr;
}

#pragma mark - 单例创建
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

@end
