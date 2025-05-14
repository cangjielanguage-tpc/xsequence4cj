// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import xsequence4cj.*
import std.sync.*

@Test
public class TestSeqRange01 {
    @TestCase
    func test_SeqRange_101(): Unit {
        var sr=SeqRange(10,11)
        @Assert(sr.getAndIncrement(),10)
        @Assert(sr.getMin(),10)
        @Assert(sr.getMax(),11)
        @Assert(sr.isOver(),false)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 11, min: 10, value: 11")
    }
    @TestCase
    func test_SeqRange_102(): Unit {
        var sr=SeqRange(Int64.Min,11)
        @Assert(sr.getAndIncrement(),Int64.Min)
        @Assert(sr.getMin(),Int64.Min)
        @Assert(sr.getMax(),11)
        @Assert(sr.isOver(),false)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 11, min: ${Int64.Min}, value: ${Int64.Min+1}")

    }
    @TestCase
    func test_SeqRange_103(): Unit {
        var sr=SeqRange(Int64.Max,11)
        @Assert(sr.getAndIncrement(),-1)
        @Assert(sr.getMin(),Int64.Max)
        @Assert(sr.getMax(),11)
        @Assert(sr.isOver(),true)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 11, min: ${Int64.Max}, value: ${Int64.Min}")

    }
    @TestCase
    func test_SeqRange_104(): Unit {
        var sr=SeqRange(0,11)
        @Assert(sr.getAndIncrement(),0)
        @Assert(sr.getMin(),0)
        @Assert(sr.getMax(),11)
        @Assert(sr.isOver(),false)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 11, min: 0, value: 1")

    }
    @TestCase
    func test_SeqRange_105(): Unit {
        var sr=SeqRange(10,Int64.Min)
        @Assert(sr.getAndIncrement(),-1)
        @Assert(sr.getMin(),10)
        @Assert(sr.getMax(),Int64.Min)
        @Assert(sr.isOver(),true)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: ${Int64.Min}, min: 10, value: 11")
    }
    @TestCase
    func test_SeqRange_106(): Unit {
        var sr=SeqRange(10,Int64.Max)
        @Assert(sr.getAndIncrement(),10)
        @Assert(sr.getMin(),10)
        @Assert(sr.getMax(),Int64.Max)
        @Assert(sr.isOver(),false)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: ${Int64.Max}, min: 10, value: 11")

    }
    @TestCase
    func test_SeqRange_107(): Unit {
        var sr=SeqRange(10,0)
        @Assert(sr.getAndIncrement(),-1)
        @Assert(sr.getMin(),10)
        @Assert(sr.getMax(),0)
        @Assert(sr.isOver(),true)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 0, min: 10, value: 11")
    }
    @TestCase
    func test_SeqRange_108(): Unit {
        var sr=SeqRange(10,10)
        @Assert(sr.getAndIncrement(),10)
        @Assert(sr.getMin(),10)
        @Assert(sr.getMax(),10)
        @Assert(sr.isOver(),false)
        sr.setOver(true)
        @Assert(sr.isOver(),true)
        sr.setOver(false)
        @Assert(sr.isOver(),false)
        @Assert(sr.toString(),"max: 10, min: 10, value: 11")
    }
}