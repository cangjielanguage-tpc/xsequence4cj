/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 区间管理器
 */
public interface SeqRangeMgr {

    /**
     * 获取指定区间名的下一个区间
     *
     * @param name 区间名
     * @return 返回区间
     * @throws SeqException 异常
     */
    func nextRange(name: String): SeqRange
}