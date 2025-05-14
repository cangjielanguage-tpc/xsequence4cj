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
public class TestDbSeqBuilder02 {
    
    @TestCase
    func test_DbSeqBuilder_201(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.step(3)
        var sq=dbsbr.build()
        @Assert(sq.nextValue(),1)
        @Assert(sq.nextValue(),2)
        @Assert(sq.nextValue(),3)
        @Assert(sq.nextValue(),4)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_202(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.step(Int32.Max)
        var sq=dbsbr.build()
        @Assert(sq.nextValue(),1)
        @Assert(sq.nextValue(),2)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_203(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("user00000000000000000000000000001")
        var illeagal:Array<Int32>=[0,-1,Int32.Min]
        for (val in illeagal){
            dbsbr.step(val)
            let e:SeqException=@AssertThrows[SeqException](dbsbr.build())
            @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-checkParam] step must greater than 0.")
        }
        clearDown("sequence")
    }
}