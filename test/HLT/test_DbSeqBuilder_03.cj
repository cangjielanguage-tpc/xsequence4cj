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
public class TestDbSeqBuilder03 {
    @TestCase
    func test_DbSeqBuilder_301(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.stepStart(3)
        var sq=dbsbr.build()
        @Assert(sq.nextValue(),4)
        @Assert(sq.nextValue(),5)
        @Assert(sq.nextValue(),6)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_302(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.stepStart(Int64.Max) //问题,入参类型需是Int32
        var sq=dbsbr.build()
        let e:OverflowException=@AssertThrows[OverflowException](sq.nextValue())
        @Assert(e.toString().contains("OverflowException"),true)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_303(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.stepStart(0)
        var sq=dbsbr.build()
        @Assert(sq.nextValue(),1)
        @Assert(sq.nextValue(),2)
        @Assert(sq.nextValue(),3)
        clearDown("sequence")
    }
    @TestCase
    func test_DbSeqBuilder_304(): Unit {
        var dbsbr=DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("user00000000000000000000000000001")
        var illeagal:Array<Int64>=[-1,Int64.Min]
        for (val in illeagal){
            dbsbr.stepStart(val)
            let e:SeqException=@AssertThrows[SeqException](dbsbr.build())
            @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-setStepStart] stepStart < 0.")
        }
        clearDown("sequence")
    }
}