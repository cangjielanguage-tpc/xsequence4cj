/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 操作DB帮助类
 */
public class DbHelper {
    private static let DELTA: Int64 = 100000000

    private static let SQL_CREATE_TABLE: String = "CREATE TABLE IF NOT EXISTS #tableName(id bigint(20) NOT NULL AUTO_INCREMENT," +
        "value bigint(20) NOT NULL,name varchar(32) NOT NULL,gmt_create DATETIME NOT NULL," +
        "gmt_modified DATETIME NOT NULL,PRIMARY KEY (`id`),UNIQUE uk_name (`name`))"

    private static let SQL_INSERT_RANGE: String = "INSERT IGNORE INTO #tableName(name,value,gmt_create,gmt_modified)" +
        " VALUE(?,?,?,?)"
    private static let SQL_UPDATE_RANGE: String = "UPDATE #tableName SET value=?,gmt_modified=? WHERE name=? AND " +
        "value=?"
    private static let SQL_SELECT_RANGE: String = "SELECT value FROM #tableName WHERE name=?"

    private static func checkTableName(tableName: String): Unit {
        let tableNameLength = Int64(tableName.toRuneArray().size)
        if (tableNameLength == 0 || tableNameLength > SequenceConstraints.MAX_TABLE_NAME_LENGTH) {
            throw SeqException("Table name must contain 1 to 64 runes.")
        }

        for (byte in tableName) {
            if (!((byte >= b'A' && byte <= b'Z') ||
                (byte >= b'a' && byte <= b'z') ||
                (byte >= b'0' && byte <= b'9') ||
                byte == b'_')) {
                throw SeqException("Table name can only contain letters, digits, and underscores.")
            }
        }
    }

    private static func checkName(name: String): Unit {
        let nameLength = Int64(name.toRuneArray().size)
        if (nameLength == 0) {
            throw SeqException("[DbHelper-checkName] name is empty.")
        }
        if (nameLength > SequenceConstraints.MAX_NAME_LENGTH) {
            throw SeqException(
                "[DbHelper-checkName] name is too long, max length = ${SequenceConstraints.MAX_NAME_LENGTH.toString()}.")
        }

        // name is always sent as a bound SqlVarchar parameter, so it is
        // intentionally not restricted to ASCII characters.
    }

    /**
     * 创建表
     *
     * @param dataSource DB来源
     * @param tableName  表名
     * @throws SeqException 表名非法或数据库操作失败时抛出
     */
    public static func createTable(dataSource: Datasource, tableName: String): Unit {
        checkTableName(tableName)
        var conn0: ?Connection = None
        var stmt0: ?Statement = None
        try {
            let conn = dataSource.connect()
            conn0 = conn
            let stmt = conn.prepareStatement(SQL_CREATE_TABLE.replace("#tableName", tableName))
            stmt0 = stmt
            stmt.update()
        } finally {
            try {
                stmt0?.close()
            } finally {
                conn0?.close()
            }
        }
    }

    /**
     * 插入数据区间
     *
     * @param dataSource DB来源
     * @param tableName  表名
     * @param name       区间名称，长度不能超过 32 个 rune
     * @param stepStart  初始位置
     * @throws SeqException 表名/name 非法或数据库操作失败时抛出
     */
    public static func insertRange(dataSource: Datasource, tableName: String, name: String, stepStart: Int64): Unit {
        checkTableName(tableName)
        checkName(name)
        executeInsertRange(dataSource, tableName, name, stepStart)
    }

    private static func executeInsertRange(dataSource: Datasource, tableName: String, name: String,
        stepStart: Int64): Unit {
        var conn0: ?Connection = None
        var stmt0: ?Statement = None
        try {
            let conn = dataSource.connect()
            conn0 = conn
            let stmt = conn.prepareStatement(SQL_INSERT_RANGE.replace("#tableName", tableName))
            stmt0 = stmt
            stmt.update(
                [SqlVarchar(name), SqlBigInt(stepStart), SqlTimestamp(DateTime.now()), SqlTimestamp(DateTime.now())])
        } finally {
            try {
                stmt0?.close()
            } finally {
                conn0?.close()
            }
        }
    }

    /**
     * 更新区间，乐观策略
     *
     * @param dataSource DB来源
     * @param tableName  表名
     * @param newValue   更新新数据
     * @param oldValue   更新旧数据
     * @param name       区间名称，长度不能超过 32 个 rune
     * @return 成功/失败
     * @throws SeqException 表名/name 非法或数据库操作失败时抛出
     */
    public static func updateRange(dataSource: Datasource, tableName: String, newValue: Int64, oldValue: Int64,
        name: String): Bool {
        checkTableName(tableName)
        checkName(name)
        var conn0: ?Connection = None
        var stmt0: ?Statement = None
        try {
            let conn = dataSource.connect()
            conn0 = conn
            let stmt = conn.prepareStatement(SQL_UPDATE_RANGE.replace("#tableName", tableName))
            stmt0 = stmt
            var updateResult = stmt.update(
                [SqlBigInt(newValue), SqlTimestamp(DateTime.now()), SqlVarchar(name), SqlBigInt(oldValue)])
            let affectedRows: Int64 = updateResult.rowCount

            if (affectedRows > 0) {
                return true
            }
        } finally {
            try {
                stmt0?.close()
            } finally {
                conn0?.close()
            }
        }
        return false
    }

    /**
     * 查询区间，如果区间不存在，会新增一个区间，由上层重新执行
     *
     * @param dataSource DB来源
     * @param tableName  来源
     * @param name       区间名称，长度不能超过 32 个 rune
     * @param stepStart  初始位置
     * @return 区间值
     * @throws SeqException 表名/name 非法或数据库操作失败时抛出
     */
    public static func selectRange(dataSource: Datasource, tableName: String, name: String, stepStart: Int64): ?Int64 {
        checkTableName(tableName)
        checkName(name)
        var oldValue: Int64 = -1
        var conn0: ?Connection = None
        var stmt0: ?Statement = None
        var queryResult0: ?QueryResult = None
        try {
            let conn = dataSource.connect()
            conn0 = conn
            let stmt = conn.prepareStatement(SQL_SELECT_RANGE.replace("#tableName", tableName))
            stmt0 = stmt

            let names = SqlVarchar(name)

            var s: SqlBigInt = SqlBigInt(0)
            var arr: Array<SqlDbType> = [s]

            let queryResult = stmt.query([names])
            queryResult0 = queryResult

            if (!queryResult.next(arr)) {
                //没有此类型数据，需要初始化
                executeInsertRange(dataSource, tableName, name, stepStart)
                return None
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
        } finally {
            try {
                queryResult0?.close()
            } finally {
                try {
                    stmt0?.close()
                } finally {
                    conn0?.close()
                }
            }
        }
        return oldValue
    }
}
