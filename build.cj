/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import std.process.*
import std.fs.*

/*
 * called after `cjpm build`
 */
func stagePostBuild(): Int64 {
    let structPath: String = Process.current.workingDirectory.toString()
    let buildPath: Path = Path("${structPath}/target/release/mysqlclient_ffi")
    let targetPath: Path = Path("${structPath}/target/release/mysqlclient_ffi")
    let testPath: Path = Path("${structPath}/test/LLT/mysqlclient_ffi")
    if (exists(targetPath)) {
        remove(targetPath, recursive: true)
    }
    copy(testPath, to: buildPath, overwrite: false)

    0
}
main(){
    
    match (Process.current.arguments[0]) {
        case "post-build" => stagePostBuild()
        case _ => 0
    }
}