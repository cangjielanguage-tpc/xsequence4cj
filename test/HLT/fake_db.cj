import std.collection.*
import std.database.sql.*

class FakeDatasource <: Datasource {
    public func connect(): Connection {
        return FakeConnection()
    }

    public func setOption(key: String, value: String): Unit {
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

class FakeConnection <: Connection {
    public func prepareStatement(sql: String): Statement {
        return FakeStatement()
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

class FakeStatement <: Statement {
    public func update(): UpdateResult {
        return FakeUpdateResult()
    }

    public func update(params: Array<SqlDbType>): UpdateResult {
        return FakeUpdateResult()
    }

    public func query(): QueryResult {
        return FakeQueryResult()
    }

    public func query(params: Array<SqlDbType>): QueryResult {
        return FakeQueryResult()
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

class FakeUpdateResult <: UpdateResult {
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

class FakeQueryResult <: QueryResult {
    public func next(): Bool {
        return false
    }

    public func next(out: Array<SqlDbType>): Bool {
        return false
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

class FakeTransaction <: Transaction {
    public func begin(): Unit {
    }

    public func commit(): Unit {
    }

    public func rollback(): Unit {
    }

    public func rollback(savePointName: String): Unit {
    }

    public func save(savePointName: String): Unit {
    }

    public func release(savePointName: String): Unit {
    }

    public mut prop isoLevel: TransactionIsoLevel {
        get() {
            return TransactionIsoLevel.Unspecified
        }
        set(value) {
        }
    }

    public mut prop accessMode: TransactionAccessMode {
        get() {
            return TransactionAccessMode.Unspecified
        }
        set(value) {
        }
    }

    public mut prop deferrableMode: TransactionDeferrableMode {
        get() {
            return TransactionDeferrableMode.Unspecified
        }
        set(value) {
        }
    }
}
