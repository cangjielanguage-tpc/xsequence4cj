// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbHelperName01 {
    @TestCase
    func test_DbHelper_name_101(): Unit {
        let name = "user0000000000000000000000000001"
        DbHelper.insertRange(FakeDatasource(), "sequence", name, 0)
    }

    @TestCase
    func test_DbHelper_name_102(): Unit {
        let name = "user00000000000000000000000000001"
        let e: SeqException = @AssertThrows[SeqException](
            DbHelper.insertRange(FakeDatasource(), "sequence", name, 0))
        @Assert(e.toString(), "SeqException: [DbHelper-checkName] name is too long, max length = 32.")
    }
}
