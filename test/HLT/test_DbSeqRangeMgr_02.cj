// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import std.sync.*

@Test
public class TestDbSeqRangeMgr02 {
    @TestCase
    func test_DbSeqRangeMgr_201(): Unit {
        var dsrm=DbSeqRangeMgr()
        var ds=getDataSource()
        let e:SeqException=@AssertThrows[SeqException](dsrm.create())
        @Assert(e.toString(),"SeqException: [DbSeqRangeMgr-setDataSource] dataSource is null.")
    }
}