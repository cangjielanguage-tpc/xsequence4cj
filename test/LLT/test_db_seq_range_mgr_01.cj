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

    //利用DB获取区间管理器
    let dbSeqRangeMgr: DbSeqRangeMgr = DbSeqRangeMgr()
    dbSeqRangeMgr.setDataSource(mysqlDatasource)
    
    try {
        dbSeqRangeMgr.setTableName("")
    }catch(e: SeqException){
        if(!e.toString().contains("SeqException: [DbSeqRangeMgr-setTableName] tableName is empty.")) {
            return -1
        }
    }
    return 0
}
