// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.database.sql.*
import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

class CreateFailureDatasource <: Datasource {
    public func connect(): Connection {
        throw SeqException("create failed")
    }

    public func setOption(key: String, value: String): Unit {
    }

    public func isClosed(): Bool {
        return false
    }

    public func close(): Unit {
    }
}

@Test
public class TestDbSeqRangeMgrCreate01 {
    @TestCase
    func test_db_seq_range_mgr_create_101(): Unit {
        let manager = DbSeqRangeMgr()
        manager.setDataSource(CreateFailureDatasource())

        let failure: SeqException = @AssertThrows[SeqException](manager.create())
        @Assert(failure.toString(), "SeqException: create failed")

        manager.setStep(456)
        @Assert(manager.getStep(), 456)

        manager.setDataSource(FakeDatasource())
        manager.create()

        let frozen: SeqException = @AssertThrows[SeqException](manager.setStep(789))
        @Assert(frozen.toString(), "SeqException: Configuration cannot be changed after create().")
        @Assert(manager.getStep(), 456)
    }
}
