// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main
import mysqlclient_ffi.*
import std.database.sql.*
import std.time.*
import xsequence4cj.*

@Test
func test1(): Unit {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

    let arr: Array<(String, String)> = Array<(String, String)>()

    // 通过connectionString和选项打开数据源
    let dataSource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr
    )
    clearDown(dataSource,"tttable")
    var sequence = DbSeqBuilder().dataSource(dataSource).tableName("tttable").bizName("userId1").build()
    @Assert(sequence.nextValue(),1)
    sequence = DbSeqBuilder().dataSource(dataSource).tableName("tttable").bizName("userId1").build()
    @Assert(sequence.nextValue(),1001)
    clearDown(dataSource,"tttable")
}

public func clearDown(ds: MysqlDatasource,tableName:String){
    let connFinal: MysqlConnection  = ds.connect()
    var sql="drop table if exists x_sequence_${tableName}"
    var statementDrop : MysqlStatement= connFinal.prepareStatement(sql)
    statementDrop.update()
    statementDrop.close()
    connFinal.close()
}