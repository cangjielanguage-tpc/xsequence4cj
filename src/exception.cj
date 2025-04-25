/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

public class SeqException <: SqlException {

    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public init(message: String, sqlState: String, errorCode: Int64) {
        super(message, sqlState, errorCode)
    }

}