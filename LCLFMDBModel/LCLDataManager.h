//
//  LCLDataManager.h
//  LCLFMDBModel
//
//  Created by 云淡风轻 on 2018/11/8.
//  Copyright © 2018 北京正图数创科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface LCLDataManager : NSObject

/**
 创建单例对象

 @return 返回创建好的单例对象
 */
+ (instancetype)shareManager;

/**
 创建数据库

 @param databaseName 数据库名称
 @return 返回创建好的数据库存
 */
- (FMDatabase *)createDatabaseWithName:(NSString *)databaseName;

/**
 打开数据库

 @return 打开数据库是否成功
 */
- (BOOL)openDatabase;

/**
 关闭数据库

 @return 关闭数据库是否成功
 */
- (BOOL)closeDatabase;

/**
 创建表

 @param tableName 表名
 @param class 模型:根据传入的模型属性来确定表里的字段
 @return 创建表是否成功
 */
- (BOOL)createTableWithName:(NSString *)tableName class:(Class)class;

/**
 插入数据:单条数据

 @param tableName 表名
 @param model 模型
 @return 插入数据是否成功
 */
- (BOOL)insertWithTableName:(NSString *)tableName model:(id)model;

/**
 删除数据: 单条条数据

 @param tableName 表名
 @param key 字段名
 @param value 字段对应的值
 @return 删除数据是否成功
 */
- (BOOL)removeWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value;

/**
 删除数据: 全部数据

 @param tableName 表名
 @return 删除数据是否成功
 */
- (BOOL)removeAllWithTableName:(NSString *)tableName;

/**
 更新数据: 单条更新

 @param tableName 表名
 @param model 模型
 @param primaryKey 字段名
 @param primaryValue 字段对应的值
 @return 更新数据是否成功
 */
- (BOOL)update:(NSString *)tableName model:(id)model primaryKey:(NSString *)primaryKey primaryValue:(NSString *)primaryValue;

/**
 更新数据: 单值更新

 @param tableName 表名
 @param primaryKey 字段名
 @param primaryValue 字段对应的值
 @param updateKey 要更新的字段名
 @param updateValue 要更新的值
 @return 更新数据是否成功
 */
- (BOOL)update:(NSString *)tableName primaryKey:(NSString *)primaryKey primaryValue:(NSString *)primaryValue updateKey:(NSString *)updateKey updateValue:(NSString *)updateValue;

/**
 查询数据: 单条查询

 @param tableName 表名
 @param key 字段名
 @param value 字段对应的值
 @return 查询出来的数据
 */
- (NSMutableArray *)query:(NSString *)tableName key:(NSString *)key value:(NSString *)value;

/**
 查询数据:全部数据

 @param tableName 表名
 @return 查询出来的数据
 */
- (NSMutableArray *)queryWithTableName:(NSString *)tableName;



@end
