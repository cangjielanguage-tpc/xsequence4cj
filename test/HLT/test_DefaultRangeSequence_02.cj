// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import std.sync.*
import std.database.sql.*

@Test
public class TestDefaultRangeSequence02 {
    @TestCase
    func test_DefaultRangeSequence_201(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        let e:SeqException=@AssertThrows[SeqException](defaultRangeSequence.nextValue())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-nextRange] name is empty.")
        clearDown("range")
    }
    @TestCase
    func test_DefaultRangeSequence_202(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("user0000000000000000000000000001")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        @Assert(defaultRangeSequence.nextValue(),1)
        clearDown("range")
    }
    @TestCase
    func test_DefaultRangeSequence_203(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("user00000000000000000000000000001")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        let e:SeqException=@AssertThrows[SeqException](defaultRangeSequence.nextValue())
        @Assert(e.toString(),"SeqException: Retried too many times, retryTimes = 100")
        clearDown("range")
    }
}