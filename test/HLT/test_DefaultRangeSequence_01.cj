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
public class TestDefaultRangeSequence01 {
    @TestCase
    func test_DefaultRangeSequence_101(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("user0001")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        @Assert(defaultRangeSequence.nextValue(),1)
        clearDown("range")
    }
    @TestCase
    func test_DefaultRangeSequence_102(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("user0001")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        @Assert(defaultRangeSequence.nextValue(),1)
        @Assert(defaultRangeSequence.nextValue(),2)
        @Assert(defaultRangeSequence.nextValue(),3)
        clearDown("range")
    }
    @TestCase
    func test_DefaultRangeSequence_103(): Unit {
        var dbsb=DbSeqBuilder()
        var dbsrm=DbSeqRangeMgr()
        dbsrm.setDataSource(getDataSource())
        dbsrm.create()
        let defaultRangeSequence: DefaultRangeSequence = DefaultRangeSequence()
        defaultRangeSequence.setName("user0001")  //这里指的是range名字
        defaultRangeSequence.setSeqRangeMgr(dbsrm)
        clearDown("range")
        let e:SqlException=@AssertThrows[SqlException](defaultRangeSequence.nextValue())
        @Assert(e.toString(),"SqlException: Table 'mysql.x_sequence_range' doesn't exist, errorCode: 0")
    }
}