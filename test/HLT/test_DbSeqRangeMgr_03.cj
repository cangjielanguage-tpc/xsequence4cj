// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import mysqlclient_ffi.*
import std.database.sql.*
import std.sync.*
import std.time.*
@Test
public class TestDbSeqRangeMgr03 {
    @TestCase
    func test_DbSeqRangeMgr_301(): Unit {
        var dsrm=DbSeqRangeMgr()
        var ds=getDataSource()
        dsrm.setDataSource(ds)
        dsrm.create()
        var rangeName="range"
        var sr=dsrm.nextRange(rangeName)
        @Assert(sr.getAndIncrement(),1)
        @Assert(sr.getMin(),1)
        @Assert(sr.getMax(),1000)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 1000, min: 1, value: 2")
        var tableName="range" //默认不设置
        clearDown(tableName)
    }
    @TestCase
    func test_DbSeqRangeMgr_302(): Unit {
        var dsrm=DbSeqRangeMgr()
        var ds=getDataSource()
        dsrm.setDataSource(ds)
        dsrm.create()
        var rangeName="range"
        var sr=dsrm.nextRange(rangeName)
        @Assert(sr.getAndIncrement(),1)
        @Assert(sr.getMin(),1)
        @Assert(sr.getMax(),1000)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 1000, min: 1, value: 2")
        var sr02=dsrm.nextRange(rangeName)
        @Assert(sr02.getAndIncrement(),1001)
        @Assert(sr02.getMin(),1001)
        @Assert(sr02.getMax(),2000)
        @Assert(sr02.isOver(),false)
        @Assert(sr02.toString(),"max: 2000, min: 1001, value: 1002")
        var tableName="range" //默认不设置
        clearDown(tableName)
    }
    @TestCase
    func test_DbSeqRangeMgr_303(): Unit {
        var dsrm=DbSeqRangeMgr()
        var ds=getDataSource()
        dsrm.setDataSource(ds)
        dsrm.create()
        var rangeName="range"
        var sr=dsrm.nextRange(rangeName)
        @Assert(sr.getAndIncrement(),1)
        @Assert(sr.getMin(),1)
        @Assert(sr.getMax(),1000)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 1000, min: 1, value: 2")
        rangeName="table02"
        var sr02=dsrm.nextRange(rangeName)
        var tableName="range"
        clearDown(tableName)
        @Assert(sr02.getAndIncrement(),1)
        @Assert(sr02.getMin(),1)
        @Assert(sr02.getMax(),1000)
        @Assert(sr02.isOver(),false)
        @Assert(sr02.toString(),"max: 1000, min: 1, value: 2")

    }
    @TestCase
    func test_DbSeqRangeMgr_304(): Unit {
        var dsrm=DbSeqRangeMgr()
        var ds=getDataSource()
        dsrm.setDataSource(ds)
        dsrm.create()
        var rangeName="range"
        var sr=dsrm.nextRange(rangeName)
        @Assert(sr.getAndIncrement(),1)
        @Assert(sr.getMin(),1)
        @Assert(sr.getMax(),1000)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 1000, min: 1, value: 2")
        var tableName="range"
        clearDown(tableName)
        var dsrm02=DbSeqRangeMgr()
        dsrm02.setDataSource(ds)
        dsrm02.setTableName("table01")
        dsrm02.create()
        var sr02=dsrm02.nextRange("range")
        @Assert(sr02.getAndIncrement(),1)
        @Assert(sr02.getMin(),1)
        @Assert(sr02.getMax(),1000)
        @Assert(sr02.isOver(),false)
        @Assert(sr02.toString(),"max: 1000, min: 1, value: 2")
        tableName="table01"
        clearDown(tableName)
    }
}