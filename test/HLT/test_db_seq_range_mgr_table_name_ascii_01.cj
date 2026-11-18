// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqRangeMgrTableNameAscii01 {
    @TestCase
    func test_db_seq_range_mgr_table_name_ascii_101(): Unit {
        let manager = DbSeqRangeMgr()
        manager.setDataSource(FakeDatasource())
        manager.setTableName("中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中中" + "中" + "中")

        let e: SeqException = @AssertThrows[SeqException](manager.create())
        @Assert(e.toString(), "SeqException: Table name can only contain letters, digits, and underscores.")
    }
}
