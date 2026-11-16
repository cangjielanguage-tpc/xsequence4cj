// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/
// dependence: ./fake_db.cj

import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

@Test
public class TestDbSeqBuilder05 {
    @TestCase
    func test_DbSeqBuilder_501(): Unit {
        let builder = DbSeqBuilder()
        builder.dataSource(FakeDatasource())
        builder.bizName("retry")
        builder.retryTimes(49)

        let sequence = builder.build()
        let e: SeqException = @AssertThrows[SeqException](sequence.nextValue())
        @Assert(e.toString(), "SeqException: Retried too many times, retryTimes = 49")
    }
}
