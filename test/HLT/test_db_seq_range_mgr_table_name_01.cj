// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqRangeMgrTableName01 {
    @TestCase
    func test_DbSeqRangeMgr_table_name_101(): Unit {
        let manager = DbSeqRangeMgr()
        let tableName = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        manager.setTableName(tableName)
        @Assert(manager.getTableName(), tableName)
    }

    @TestCase
    func test_DbSeqRangeMgr_table_name_102(): Unit {
        let manager = DbSeqRangeMgr()
        let tableName = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        let e: SeqException = @AssertThrows[SeqException](manager.setTableName(tableName))
        @Assert(e.toString(), "SeqException: [DbSeqRangeMgr-setTableName] tableName is too long, max length = 53 (11 chars are reserved for the 'x_sequence_' prefix).")
    }
}
