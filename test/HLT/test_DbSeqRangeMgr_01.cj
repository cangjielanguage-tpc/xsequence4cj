// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import std.sync.*

@Test
public class TestDbSeqRangeMgr01 {
    @TestCase
    func test_DbSeqRangeMgr_101(): Unit {
        var dsrm=DbSeqRangeMgr()
        @Assert(dsrm.getStep(),1000)
        @Assert(dsrm.getStepStart(),0)
        @Assert(dsrm.getRetryTimes(),100)
        @Assert(dsrm.getDataSource().isNone(),true)
        @Assert(dsrm.getTableName(),"range")
    }
    @TestCase
    func test_DbSeqRangeMgr_102(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setStep(Int32.Min)
        @Assert(dsrm.getStep(),Int32.Min)
        dsrm.setStep(Int32.Max)
        @Assert(dsrm.getStep(),Int32.Max)
        dsrm.setStep(0)
        @Assert(dsrm.getStep(),0)
    }
    @TestCase
    func test_DbSeqRangeMgr_103(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setStepStart(Int64.Min)
        @Assert(dsrm.getStepStart(),Int64.Min)
        dsrm.setStepStart(Int64.Max)
        @Assert(dsrm.getStepStart(),Int64.Max)
        dsrm.setStepStart(0)
        @Assert(dsrm.getStepStart(),0)
    }
    @TestCase
    func test_DbSeqRangeMgr_104(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setRetryTimes(Int32.Min)
        @Assert(dsrm.getRetryTimes(),Int32.Min)
        dsrm.setRetryTimes(Int32.Max)
        @Assert(dsrm.getRetryTimes(),Int32.Max)
        dsrm.setRetryTimes(0)
        @Assert(dsrm.getRetryTimes(),0)
    }
    @TestCase
    func test_DbSeqRangeMgr_105(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setDataSource(getDataSource())
        @Assert(dsrm.getDataSource().isNone(),false)
    }
    @TestCase
    func test_DbSeqRangeMgr_106(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setTableName("table_001")
        @Assert(dsrm.getTableName(),"table_001")
        dsrm.setTableName("table_001")
        @Assert(dsrm.getTableName(),"table_001")
    }
    @TestCase
    func test_DbSeqRangeMgr_107(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setTableName("")
        @Assert(dsrm.getTableName(),"")
    }
    @TestCase
    func test_DbSeqRangeMgr_108(): Unit {
        var dsrm=DbSeqRangeMgr()
        dsrm.setTableName("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        @Assert(dsrm.getTableName(),"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    }
}