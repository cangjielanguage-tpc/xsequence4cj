import mysqlclient_ffi.*
import std.database.sql.*
import std.time.*
import xsequence4cj.*

//需要当前数据库在服务器上有服务，表
public func getDataSource():MysqlDatasource{
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
    let arr: Array<(String, String)> = Array<(String, String)>()

    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr
    )
    return mysqlDatasource
}
public func clearDown(tableName:String){
    var ds=getDataSource()
    let connFinal: MysqlConnection  = ds.connect()
    var sql="drop table if exists x_sequence_${tableName}"
    var statementDrop : MysqlStatement= connFinal.prepareStatement(sql)
    statementDrop.update()
    statementDrop.close()
    connFinal.close()
}
public func select(rangName:String,tableName: String,expId:Int32,expvalue:Int32){
    var ds=getDataSource()
    let connFinal: MysqlConnection  = ds.connect()
    var name = SqlNullableVarchar(rangName)
    let id = SqlInteger(0)
    var value = SqlNullableInteger(0)
    var statementSelect : MysqlStatement= connFinal.prepareStatement("select * from x_sequence_${tableName} where name=?")
    var arrselect:Array<SqlDbType>=[name]
    var qr=statementSelect.query(arrselect)
    var arrsNext:Array<SqlDbType>=[id,value]
    qr.next(arrsNext)
    @Assert(id.value,expId)
    @Assert(value.value,expvalue)
    statementSelect.update()
    statementSelect.close()
    connFinal.close()
}
