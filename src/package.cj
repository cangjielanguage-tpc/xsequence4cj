/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

internal import std.database.sql.*
internal import std.time.*
internal import std.sync.*

extend<T> Option<T> {
    operator func()(): T {
        this.getOrThrow()
    }
}

