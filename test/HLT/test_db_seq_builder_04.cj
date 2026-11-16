// 3rd_party_lib:xsequence4cj/target/release/mysqlclient_ffi/
// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./common.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqBuilder04 {
    @TestCase
    func test_DbSeqBuilder_401(): Unit {
        var dbsbr = DbSeqBuilder()
        dbsbr.dataSource(getDataSource())
        dbsbr.bizName("range001")
        dbsbr.tableName("range SET value=0 WHERE name='any' -- ")
        let e: SeqException = @AssertThrows[SeqException](dbsbr.build())
        @Assert(e.toString(), "SeqException: Table name can only contain letters, digits, and underscores.")
    }
}
