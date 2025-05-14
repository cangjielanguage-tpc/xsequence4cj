// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import std.sync.*
import std.sync.*
import std.database.sql.*

@Test
public class TestDbSeqBuilder01 {
    
    @TestCase
    func test_DbSeqBuilder_101(): Unit {
        var dbsbr=DbSeqBuilder()
        let e:SeqException=@AssertThrows[SeqException](dbsbr.build())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-setDataSource] dataSource is null.")
    }
    @TestCase
    func test_DbSeqBuilder_102(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        var sq=dbsbr.build()
        let e:SeqException=@AssertThrows[SeqException](sq.nextValue())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-nextRange] name is empty.")
    }
    @TestCase
    func test_DbSeqBuilder_103(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        var sq=dbsbr.build()
        @Assert(sq.nextValue(),1)
        //public func select(rangName:String,tableName: String,expId:Int32,expvalue:Int32)
        //select("range001","sequence",1,1000)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_104(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("user00000000000000000000000000001")
        var sq=dbsbr.build()
        let e:SeqException=@AssertThrows[SeqException](sq.nextValue())
        @Assert(e.toString(),"SeqException: Retried too many times, retryTimes = 100")
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_105(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("")
        var sq=dbsbr.build()
        let e:SeqException=@AssertThrows[SeqException](sq.nextValue())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-nextRange] name is empty.")
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_106(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("  ")
        var sq=dbsbr.build()
        let e:SeqException=@AssertThrows[SeqException](sq.nextValue())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-nextRange] name is empty.")
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_107(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("user00000000000000000000000000001")
        var illeagal:Array<Int32>=[0,-1,Int32.Min]
        for (val in illeagal){
            dbsbr.retryTimes(val)
            let e:SeqException=@AssertThrows[SeqException](dbsbr.build())
            @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-setRetryTimes] retryTimes must greater than 0.")
        }
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_108(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("user00000000000000000000000000001")
        dbsbr.retryTimes(49)
        var sq=dbsbr.build()
        let e:SeqException=@AssertThrows[SeqException](sq.nextValue())
        @Assert(e.toString(),"SeqException: Retried too many times, retryTimes = 49")
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_109(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.tableName("")
        let e:SeqException=@AssertThrows[SeqException](dbsbr.build())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-setTableName] tableName is empty.")
        clearDown("sequence")
    }
}