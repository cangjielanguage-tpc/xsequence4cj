/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 序列号区间生成器接口默认实现
 */
public class DefaultRangeSequence <: RangeSequence {
    /**
     * 获取区间是加一把独占锁防止资源冲突
     */
    private let lock: ReentrantMutex = ReentrantMutex()
     /**
     * 序列号区间管理器
     */
    private var seqRangeMgr: ?SeqRangeMgr = Option<SeqRangeMgr>.None
    /**
     * 当前序列号区间
     */
    private var currentRange: ?SeqRange = Option<SeqRange>.None
    /**
     * 需要获取区间的业务名称
     */ 
    private var name: String = ""

    public override func nextValue(): Int64 {
        if (currentRange.isNone()) {
            lock.lock()
            try {
                if (currentRange.isNone()) {
                    if(let Some(seqRangeMgr) <- this.seqRangeMgr) {
                        currentRange = seqRangeMgr.nextRange(name)    
                    }
                    
                }
            } finally {
                lock.unlock()
            }
        }
        //当value值为-1时，表明区间的序列号已经分配完，需要重新获取区间
        var value = currentRange().getAndIncrement()
        if (value == -1) {
            lock.lock()
            try {
                while (true) {
                    if (currentRange().isOver()) {
                        if(let Some(seqRangeMgr) <- this.seqRangeMgr) {
                            currentRange = seqRangeMgr.nextRange(name)    
                        }
                    }
                    value = currentRange().getAndIncrement()
                    if (value == -1) {
                        continue
                    }
                    break
                }
            } finally {
                lock.unlock()      
            }
        }
        if (value < 0) {
            throw SeqException("Sequence value overflow, value = ${value}")
        }
        return value
    }

    public override func setSeqRangeMgr(seqRangeMgr: SeqRangeMgr): Unit {
        this.seqRangeMgr = seqRangeMgr
    }

    public override func setName(name: String): Unit {
        this.name = name
    }
}
