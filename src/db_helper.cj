/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 操作DB帮助类
 */
public class DbHelper {
    private static var DELTA: Int64 = 100000000

    private static var SQL_DELETE_TABLE: String = "DROP TABLE IF EXISTS #tableName"
    private static var SQL_CREATE_TABLE: String =
            "CREATE TABLE IF NOT EXISTS #tableName(id bigint(20) NOT NULL AUTO_INCREMENT,"+ 
            "value bigint(20) NOT NULL,name varchar(32) NOT NULL,gmt_create DATETIME NOT NULL,"+ 
            "gmt_modified DATETIME NOT NULL,PRIMARY KEY (`id`),UNIQUE uk_name (`name`))"
    
    private static var SQL_INSERT_RANGE: String =
            "INSERT IGNORE INTO #tableName(name,value,gmt_create,gmt_modified)" + " VALUE(?,?,?,?)"
    private static var SQL_UPDATE_RANGE: String =
            "UPDATE #tableName SET value=?,gmt_modified=? WHERE name=? AND " + "value=?"
    private static var SQL_SELECT_RANGE: String = "SELECT value FROM #tableName WHERE name=?"
    /**
     * 创建表
     *
     * @param dataSource DB来源
     * @param tableName  表名
     */
    public static func createTable(dataSource: Datasource, tableName: String): Unit {
        let conn = dataSource.connect()
        var stmt = conn.prepareStatement(SQL_DELETE_TABLE.replace("#tableName", tableName))   
        stmt.update()
        stmt.close()

        stmt = conn.prepareStatement(SQL_CREATE_TABLE.replace("#tableName", tableName)) 
        stmt.update()
        stmt.close()
        conn.close()
    }

    /**
     * 插入数据区间
     *
     * @param dataSource DB来源
     * @param tableName  表名
     * @param name       区间名称
     * @param stepStart  初始位置
     */
    public static func insertRange(dataSource: Datasource, tableName: String, name: String, stepStart: Int64): Unit {
        let conn = dataSource.connect()
        var stmt = conn.prepareStatement(SQL_INSERT_RANGE.replace("#tableName", tableName))   
        stmt.update([SqlVarchar(name), SqlBigInt(stepStart), SqlTimestamp(DateTime.now()), SqlTimestamp(DateTime.now())])
    
        stmt.close()
        conn.close()

    }

    /**
     * 更新区间，乐观策略
     *
     * @param dataSource DB来源
     * @param tableName  表名
     * @param newValue   更新新数据
     * @param oldValue   更新旧数据
     * @param name       区间名称
     * @return 成功/失败
     */ 
    public static func updateRange(dataSource: Datasource, tableName: String, newValue: Int64, oldValue: Int64, name: String): Bool {
        let conn = dataSource.connect()
        var stmt = conn.prepareStatement(SQL_UPDATE_RANGE.replace("#tableName", tableName))   
        var updateResult = stmt.update([SqlBigInt(newValue), SqlTimestamp(DateTime.now()), SqlVarchar(name), SqlBigInt(oldValue)])
        let affectedRows: Int64 = updateResult.rowCount

        if(affectedRows > 0) {  
            stmt.close()
            conn.close()  
            return true     
        }
        stmt.close()
        conn.close()
        return false
    }
    
    /**
     * 查询区间，如果区间不存在，会新增一个区间，由上层重新执行
     *
     * @param dataSource DB来源
     * @param tableName  来源
     * @param name       区间名称
     * @param stepStart  初始位置
     * @return 区间值
     */
    public static func selectRange(dataSource: Datasource, tableName: String, name: String, stepStart: Int64): Int64 {
        var oldValue: Int64 = -1
        let conn = dataSource.connect()
        var stmt = conn.prepareStatement(SQL_SELECT_RANGE.replace("#tableName", tableName))   
        
        let names = SqlVarchar(name)

        var s: SqlBigInt = SqlBigInt(0)
        var arr: Array<SqlDbType> = [s]
        
        var queryResult = stmt.query([names])
        if(!queryResult.next(arr)) {
            //没有此类型数据，需要初始化
            insertRange(dataSource, tableName, name, stepStart)   
            return stepStart 
        }  
       
        oldValue = (arr[0] as SqlBigInt).getOrThrow().value

        if (oldValue < 0) {
            let msg: String = "Sequence value cannot be less than zero, value = ${oldValue}, please check table sequence ${tableName}"
                    
            throw SeqException(msg)
        }

        if (oldValue > Int64.Max - DELTA) {
            let msg: String = "Sequence value overflow, value = ${oldValue} please check table sequence ${tableName}"
                    
            throw SeqException(msg)
        } 

        queryResult.close()
        stmt.close()
        conn.close()
        return oldValue
    }

}