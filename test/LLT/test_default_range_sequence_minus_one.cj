// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import xsequence4cj.*

class RefreshToMinusOneRangeMgr <: SeqRangeMgr {
    private var calls: Int64 = 0

    public init() {
    }

    public override func nextRange(name: String): SeqRange {
        calls += 1
        if (calls == 1) {
            return SeqRange(0, 0)
        }
        return SeqRange(-1, -1)
    }
}

class SameExhaustedRangeMgr <: SeqRangeMgr {
    private let range: SeqRange = SeqRange(0, 0)

    public init() {
    }

    public override func nextRange(name: String): SeqRange {
        return range
    }
}

main(): Int64 {
    let minusOneRange = SeqRange(-1, -1)
    if (let Some(value) <- minusOneRange.tryGetAndIncrement()) {
        if (value != -1) {
            return -1
        }
    } else {
        return -1
    }
    if (!minusOneRange.tryGetAndIncrement().isNone()) {
        return -1
    }

    let maxRange = SeqRange(Int64.Max, Int64.Max)
    if (let Some(value) <- maxRange.tryGetAndIncrement()) {
        if (value != Int64.Max) {
            return -1
        }
    } else {
        return -1
    }
    if (!maxRange.tryGetAndIncrement().isNone()) {
        return -1
    }
    maxRange.setOver(false)
    if (!maxRange.tryGetAndIncrement().isNone()) {
        return -1
    }

    let noManagerSequence = DefaultRangeSequence()
    noManagerSequence.setName("no-manager")
    try {
        noManagerSequence.nextValue()
        return -1
    } catch (e: SeqException) {
        // Expected.
    }

    let exhaustedSequence = DefaultRangeSequence()
    exhaustedSequence.setName("exhausted")
    exhaustedSequence.setSeqRangeMgr(SameExhaustedRangeMgr())
    if (exhaustedSequence.nextValue() != 0) {
        return -1
    }
    try {
        exhaustedSequence.nextValue()
        return -1
    } catch (e: SeqException) {
        // Expected.
    }

    let sequence = DefaultRangeSequence()
    sequence.setName("test")
    sequence.setSeqRangeMgr(RefreshToMinusOneRangeMgr())
    if (sequence.nextValue() != 0) {
        return -1
    }
    try {
        sequence.nextValue()
        return -1
    } catch (e: SeqException) {
        return 0
    }
}
