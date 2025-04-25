/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 序列号区间对象模型
 */
public class SeqRange {

    /**
     * 区间的序列号开始值
     */
    private var min: Int64
    /**
     * 区间的序列号结束值
     */
    private var max: Int64
    /**
     * 区间的序列号当前值
     */
    private var value: AtomicInt64
    /**
     * 区间的序列号是否分配完毕，每次分配完毕就会去重新获取一个新的区间
     */
    private var over: Bool = false

    public init(min: Int64, max: Int64) {
        this.min = min
        this.max = max
        this.value = AtomicInt64(min)
    }

    /**
     * 返回并递增下一个序列号
     *
     * @return 下一个序列号，如果返回-1表示序列号分配完毕
     */
    public func getAndIncrement(): Int64 {
        let currentValue: Int64 = value.fetchAdd(1)
        if (currentValue > max) {
            over = true
            return -1
        }

        return currentValue
    }

    public func getMin(): Int64 {
        return min
    }

    public func getMax(): Int64 {
        return max
    }

    public func isOver(): Bool {
        return over
    }

    public func setOver(over: Bool): Unit {
        this.over = over
    }

    public func toString(): String {
        return "max: ${max}, min: ${min}, value: ${value.load()}"
    }
}