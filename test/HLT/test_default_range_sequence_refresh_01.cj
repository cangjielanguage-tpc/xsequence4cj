// 3rd_party_lib:xsequence4cj/target/release/xsequence4cj/

import std.sync.*
import std.unittest.*
import std.unittest.testmacro.*
import xsequence4cj.*

class EventuallySuccessfulRangeMgr <: SeqRangeMgr {
    private let callCount = AtomicInt64(0)

    public func nextRange(name: String): SeqRange {
        var current = callCount.load()
        while (!callCount.compareAndSwap(current, current + 1)) {
            current = callCount.load()
        }

        if (current < 101) {
            throw SeqException("range refresh failed")
        }
        return SeqRange(1, 101)
    }
}

@Test
public class TestDefaultRangeSequenceRefresh01 {
    @TestCase
    func test_default_range_sequence_refresh_101(): Unit {
        let sequence = DefaultRangeSequence()
        sequence.setSeqRangeMgr(EventuallySuccessfulRangeMgr())
        sequence.setName("biz")

        let failureFuture: Future<Int64> = spawn {
            var failureCount = 0
            while (failureCount < 101) {
                try {
                    sequence.nextValue()
                } catch (e: SeqException) {
                    failureCount += 1
                }
            }
            return failureCount
        }

        @Assert(failureFuture.get(), 101)
        @Assert(sequence.nextValue(), 1)
    }
}
