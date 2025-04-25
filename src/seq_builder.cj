/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 序列号生成器构建者
 */
public interface SeqBuilder {

    /**
     * 构建一个序列号生成器
     *
     * @return 序列号生成器
     */
    func build(): Sequence
}
