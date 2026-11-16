// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqRangeMgrFrozen01 {
    @TestCase
    func test_db_seq_range_mgr_frozen_101(): Unit {
        let manager = DbSeqRangeMgr()
        manager.setDataSource(FakeDatasource())
        manager.create()

        let stepException: SeqException = @AssertThrows[SeqException](manager.setStep(2000))
        @Assert(stepException.toString(), "SeqException: Configuration cannot be changed after create().")

        let stepStartException: SeqException = @AssertThrows[SeqException](manager.setStepStart(100))
        @Assert(stepStartException.toString(), "SeqException: Configuration cannot be changed after create().")

        let retryTimesException: SeqException = @AssertThrows[SeqException](manager.setRetryTimes(50))
        @Assert(retryTimesException.toString(), "SeqException: Configuration cannot be changed after create().")

        let dataSourceException: SeqException = @AssertThrows[SeqException](manager.setDataSource(FakeDatasource()))
        @Assert(dataSourceException.toString(), "SeqException: Configuration cannot be changed after create().")

        let tableNameException: SeqException = @AssertThrows[SeqException](manager.setTableName("other"))
        @Assert(tableNameException.toString(), "SeqException: Configuration cannot be changed after create().")
    }
}
