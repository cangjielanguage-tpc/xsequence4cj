/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj
/**
 * 序列号生成器接口
 */
public interface Sequence {

    /**
     * 生成下一个序列号
     *
     * @return 序列号
     */
    func nextValue(): Int64
}