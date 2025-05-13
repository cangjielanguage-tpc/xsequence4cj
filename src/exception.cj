/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

public class SeqException <: Exception {
    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public override func toString(): String {
        if (message == "") {
            return "SeqException"
        } else {
            return "SeqException: ${message}"
        }
    }
}