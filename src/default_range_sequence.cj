/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 序列号区间生成器接口默认实现
 */
public class DefaultRangeSequence <: RangeSequence {
    private static let MAX_RANGE_REFRESH_COUNT: Int64 = 100
    private static let RANGE_MGR_NOT_CONFIGURED_MESSAGE: String = "Sequence range manager is not configured."
    private static let INVALID_RANGE_MESSAGE: String = "Invalid sequence range"
    private static let RANGE_REFRESH_RETRY_MESSAGE: String = "Retried too many times to refresh sequence range"
    private static let SEQUENCE_VALUE_OVERFLOW_MESSAGE: String = "Sequence value overflow"

    /**
     * 获取区间是加一把独占锁防止资源冲突
     */
    private let lock: Mutex = Mutex()
    private let refreshCondition: Condition
     /**
     * 序列号区间管理器
     */
    private var seqRangeMgr: ?SeqRangeMgr = Option<SeqRangeMgr>.None
    /**
     * 当前序列号区间
     */
    private let currentRange: AtomicOptionReference<SeqRange> = AtomicOptionReference<SeqRange>(Option<SeqRange>.None)
    private var refreshing: Bool = false
    /**
     * 需要获取区间的业务名称
     */ 
    private var name: String = ""

    public init() {
        lock.lock()
        try {
            refreshCondition = lock.condition()
        } finally {
            lock.unlock()
        }
    }

    private func getValidRange(seqRangeMgr: SeqRangeMgr, name: String): SeqRange {
        let range = seqRangeMgr.nextRange(name)
        if (range.getMin() < 0 || range.getMax() < 0 || range.getMin() > range.getMax() || range.isOver()) {
            throw SeqException("${INVALID_RANGE_MESSAGE}, min = ${range.getMin()}, max = ${range.getMax()}")
        }
        return range
    }

    private func acquireRangeOrBeginRefresh(): RangeAcquisition {
        var acquisition: ?RangeAcquisition = None
        while (acquisition.isNone()) {
            lock.lock()
            try {
                if (let Some(range) <- currentRange.load()) {
                    if (!range.isOver()) {
                        acquisition = Some(RangeAcquisition(Some(range), None, ""))
                    }
                }

                if (acquisition.isNone() && !refreshing) {
                    if (let Some(seqRangeMgr) <- this.seqRangeMgr) {
                        refreshing = true
                        acquisition = Some(RangeAcquisition(None, Some(seqRangeMgr), name))
                    } else {
                        throw SeqException(RANGE_MGR_NOT_CONFIGURED_MESSAGE)
                    }
                }

                if (acquisition.isNone()) {
                    refreshCondition.wait()
                }
            } finally {
                lock.unlock()
            }
        }
        return acquisition.getOrThrow()
    }

    private func finishRefresh(): Unit {
        lock.lock()
        try {
            refreshing = false
            refreshCondition.notifyAll()
        } finally {
            lock.unlock()
        }
    }


    public override func nextValue(): Int64 {
        var nextValueOption: ?Int64 = None
        var refreshCount: Int64 = 0
        while (nextValueOption.isNone()) {
            if (let Some(range) <- currentRange.load()) {
                if (let Some(value) <- range.tryGetAndIncrement()) {
                    nextValueOption = Some(value)
                }
            }

            if (nextValueOption.isNone()) {
                let acquisition = acquireRangeOrBeginRefresh()
                if (let Some(range) <- acquisition.range) {
                    if (let Some(value) <- range.tryGetAndIncrement()) {
                        nextValueOption = Some(value)
                    } else {
                        refreshCount += 1
                        if (refreshCount > MAX_RANGE_REFRESH_COUNT) {
                            throw SeqException("${RANGE_REFRESH_RETRY_MESSAGE}, retryTimes = ${MAX_RANGE_REFRESH_COUNT}")
                        }
                    }
                } else {
                    refreshCount += 1
                    if (refreshCount > MAX_RANGE_REFRESH_COUNT) {
                        throw SeqException("${RANGE_REFRESH_RETRY_MESSAGE}, retryTimes = ${MAX_RANGE_REFRESH_COUNT}")
                    }

                    try {
                        let range = getValidRange(acquisition.seqRangeMgr.getOrThrow(), acquisition.name)
                        currentRange.store(Some(range))
                    } finally {
                        finishRefresh()
                    }
                }
            }
        }

        let value = nextValueOption.getOrThrow()
        if (value < 0) {
            throw SeqException("${SEQUENCE_VALUE_OVERFLOW_MESSAGE}, value = ${value}")
        }
        return value
    }

    public override func setSeqRangeMgr(seqRangeMgr: SeqRangeMgr): Unit {
        lock.lock()
        try {
            this.seqRangeMgr = seqRangeMgr
        } finally {
            lock.unlock()
        }
    }

    public override func setName(name: String): Unit {
        lock.lock()
        try {
            this.name = name
        } finally {
            lock.unlock()
        }
    }
}

private class RangeAcquisition {
    let range: ?SeqRange
    let seqRangeMgr: ?SeqRangeMgr
    let name: String

    public init(range: ?SeqRange, seqRangeMgr: ?SeqRangeMgr, name: String) {
        this.range = range
        this.seqRangeMgr = seqRangeMgr
        this.name = name
    }
}
