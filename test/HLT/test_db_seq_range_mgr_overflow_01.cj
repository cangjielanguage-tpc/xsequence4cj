// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.collection.*
import std.database.sql.*
import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

class OverflowDatasource <: Datasource {
    public func connect(): Connection {
        return OverflowConnection()
    }

    public func setOption(key: String, value: String): Unit {
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

class OverflowConnection <: Connection {
    public func prepareStatement(sql: String): Statement {
        return OverflowStatement()
    }

    public prop state: ConnectionState {
        get() {
            return ConnectionState.Connected
        }
    }

    public func getMetaData(): Map<String, String> {
        return HashMap<String, String>()
    }

    public func createTransaction(): Transaction {
        return FakeTransaction()
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

class OverflowStatement <: Statement {
    public func update(): UpdateResult {
        return OverflowUpdateResult()
    }

    public func update(params: Array<SqlDbType>): UpdateResult {
        return OverflowUpdateResult()
    }

    public func query(): QueryResult {
        return OverflowQueryResult()
    }

    public func query(params: Array<SqlDbType>): QueryResult {
        return OverflowQueryResult()
    }

    public prop parameterColumnInfos: Array<ColumnInfo> {
        get() {
            return Array<ColumnInfo>()
        }
    }

    public func setOption(key: String, value: String): Unit {
    }

    public func set<T>(index: Int64, value: T): Unit {
    }

    public func setNull(index: Int64): Unit {
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

class OverflowUpdateResult <: UpdateResult {
    public prop rowCount: Int64 {
        get() {
            return 1
        }
    }

    public prop lastInsertId: Int64 {
        get() {
            return 0
        }
    }
}

class OverflowQueryResult <: QueryResult {
    public func next(): Bool {
        return true
    }

    public func next(out: Array<SqlDbType>): Bool {
        out[0] = SqlBigInt(Int64.Max - 100000001)
        return true
    }

    public prop columnInfos: Array<ColumnInfo> {
        get() {
            return Array<ColumnInfo>()
        }
    }

    public func get<T>(index: Int64): T {
        throw SqlException("not implemented")
    }

    public func getOrNull<T>(index: Int64): ?T {
        return None
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

@Test
public class TestDbSeqRangeMgrOverflow01 {
    @TestCase
    func test_db_seq_range_mgr_overflow_101(): Unit {
        let manager = DbSeqRangeMgr()
        manager.setDataSource(OverflowDatasource())
        manager.setStep(200000000)

        let e: SeqException = @AssertThrows[SeqException](manager.nextRange("biz"))
        @Assert(e.toString().contains("Sequence value overflow"), true)
    }
}
