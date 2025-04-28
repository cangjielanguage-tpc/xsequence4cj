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
    let dataSource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr  
    )
    let sequence = DbSeqBuilder().dataSource(dataSource).tableName("tttable").bizName("userId").step(1000).stepStart(1000000).retryTimes(1000).build();
   
    for (i in 0..100) {
        println("++++++++++id: ${sequence.nextValue()}")
    }
    return 0
}
