/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 序列号区间生成器接口
 */
public interface RangeSequence <: Sequence {

    /**
     * 设置区间管理器
     *
     * @param seqRangeMgr 区间管理器
     */
    func setSeqRangeMgr(seqRangeMgr: SeqRangeMgr): Unit

    /**
     * 设置获取序列号名称
     *
     * @param name 名称
     */
    func setName(name: String): Unit
}