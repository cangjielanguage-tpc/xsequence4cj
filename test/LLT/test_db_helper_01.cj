// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.database.sql.*
import std.time.*
import xsequence4cj.*

main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
    let arr: Array<(String, String)> = Array<(String, String)>()

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr  
    )
    dropTable(mysqlDatasource, "my1TableName")
    DbHelper.createTable(mysqlDatasource, "my1TableName")
    DbHelper.insertRange(mysqlDatasource, "my1TableName", "lihao111", 11)
    DbHelper.insertRange(mysqlDatasource, "my1TableName", "lihao222", 22)
    
    if(!DbHelper.updateRange(mysqlDatasource, "my1TableName",33,11, "lihao111")) {
        return -1
    }

    if(DbHelper.selectRange(mysqlDatasource, "my1TableName", "lihao222", 22) != 22) {
        return -1
    }

    return 0
}

func dropTable(mysqlDatasource: MysqlDatasource, tableName: String): Unit {
    var SQL_DELETE_TABLE: String = "DROP TABLE IF EXISTS #tableName"
    let conn = mysqlDatasource.connect()
    var stmt = conn.prepareStatement(SQL_DELETE_TABLE.replace("#tableName", tableName))
    stmt.update()
    stmt.close()
    conn.close()
}
