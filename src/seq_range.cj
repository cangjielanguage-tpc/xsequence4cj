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
    private var over: AtomicBool = AtomicBool(false)
    /**
     * 记录 Int64.Max 已经发放，避免 setOver(false) 后重复发放边界值。
     */
    private var maxValueIssued: AtomicBool = AtomicBool(false)

    public init(min: Int64, max: Int64) {
        this.min = min
        this.max = max
        this.value = AtomicInt64(min)
    }

    /**
     * 返回并递增下一个序列号；None 表示区间已耗尽。
     */
    public func tryGetAndIncrement(): ?Int64 {
        var currentValue = value.load()
        while (!over.load() && currentValue <= max) {
            if (currentValue == Int64.Max) {
                over.store(true)
                if (maxValueIssued.compareAndSwap(false, true)) {
                    return Some(currentValue)
                }
                return None
            }

            if (value.compareAndSwap(currentValue, currentValue + 1)) {
                return Some(currentValue)
            }
            currentValue = value.load()
        }

        over.store(true)
        return None
    }

    /**
     * 兼容旧接口：返回下一个序列号；区间耗尽时返回 -1。
     */
    public func getAndIncrement(): Int64 {
        if (let Some(currentValue) <- tryGetAndIncrement()) {
            return currentValue
        }
        return -1
    }

    public func getMin(): Int64 {
        return min
    }

    public func getMax(): Int64 {
        return max
    }

    public func isOver(): Bool {
        return over.load()
    }

    public func setOver(over: Bool): Unit {
        this.over.store(over || maxValueIssued.load())
    }

    public func toString(): String {
        return "max: ${max}, min: ${min}, value: ${value.load()}"
    }
}
