/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import std.os.posix.*
import std.fs.*
import std.os.*

/*
 * called after `cjpm build`
 */
func stagePostBuild(): Int64 {
    let structPath: String = getcwd()
    let buildPath: Path = Path("${structPath}/target/release/mysqlclient_ffi")
    let targetPath: Path = Path("${structPath}/target/release/mysqlclient_ffi")
    let testPath: Path = Path("${structPath}/test/LLT/mysqlclient_ffi")
    if (Directory.exists(targetPath)) {
        Directory.delete(targetPath, recursive: true)
    }
    Directory.copy(testPath, buildPath, false)

    0
}
main(){
    
    match (getArgs()[0]) {
        case "post-build" => stagePostBuild()
        case _ => 0
    }
}