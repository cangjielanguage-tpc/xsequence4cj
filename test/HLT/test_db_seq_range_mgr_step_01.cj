// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqRangeMgrStep01 {
    @TestCase
    func test_db_seq_range_mgr_step_101(): Unit {
        let manager = DbSeqRangeMgr()
        manager.setDataSource(FakeDatasource())
        manager.setStep(-50)

        let e: SeqException = @AssertThrows[SeqException](manager.nextRange("biz"))
        @Assert(e.toString(), "SeqException: [DbSeqRangeMgr-nextRange] step must greater than 0, step = -50")
    }
}
