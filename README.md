<div align="center">
<h1>xsequence4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.60.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-95.8-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

xsequence4cj 是一个分布式序列号生成组件。

## 特性

- 支持 DB 方式生成序列号

## 软件架构

### 源码目录

```shell
├─doc                      
├─src                     
└── test
│   ├── HLT
│   ├── LLT
│   └── UT
├── CHANGELOG.md
├── LICENSE.txt
├── build.cj
├── cjpm.toml
├── README.md
├── README.OpenSource
```
- doc 文档目录，用于存放 API 接口等文档
- src 源码目录
- test 存放 HLT 测试用例、LLT 自测用例、 UT 单元测试用例、README 演示样例
- cjpm.toml 编译文件
- build.cj 构建扩展工具，用于测试使用
## 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)

## 使用说明

### 编译构建

```cangjie
cjpm clean 
cjpm build
```

### 功能示例

```cangjie
import mysqlclient_ffi.*
import std.database.sql.*
import std.time.*
import xsequence4cj.*

main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")

    let arr: Array<(String, String)> = Array<(String, String)>()

    // 通过connectionString和选项打开数据源
    let dataSource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        arr  
    )
    let sequence = DbSeqBuilder().dataSource(dataSource).tableName("tttable").bizName("userId").step(1000).stepStart(1000000).retryTimes(1000).build();
   
    for (i in 0..100) {
        println("++++++++++id: ${sequence.nextValue()}")
    }
    return 0
}
```
运行结果

```cangjie
++++++++++id: 1000001
++++++++++id: 1000002
++++++++++id: 1000003
++++++++++id: 1000004
++++++++++id: 1000005
++++++++++id: 1000006
++++++++++id: 1000007
++++++++++id: 1000008
++++++++++id: 1000009
++++++++++id: 1000010
++++++++++id: 1000011
++++++++++id: 1000012
++++++++++id: 1000013
++++++++++id: 1000014
++++++++++id: 1000015
++++++++++id: 1000016
++++++++++id: 1000017
++++++++++id: 1000018
++++++++++id: 1000019
++++++++++id: 1000020
++++++++++id: 1000021
++++++++++id: 1000022
++++++++++id: 1000023
++++++++++id: 1000024
++++++++++id: 1000025
++++++++++id: 1000026
++++++++++id: 1000027
++++++++++id: 1000028
++++++++++id: 1000029
++++++++++id: 1000030
++++++++++id: 1000031
++++++++++id: 1000032
++++++++++id: 1000033
++++++++++id: 1000034
++++++++++id: 1000035
++++++++++id: 1000036
++++++++++id: 1000037
++++++++++id: 1000038
++++++++++id: 1000039
++++++++++id: 1000040
++++++++++id: 1000041
++++++++++id: 1000042
++++++++++id: 1000043
++++++++++id: 1000044
++++++++++id: 1000045
++++++++++id: 1000046
++++++++++id: 1000047
++++++++++id: 1000048
++++++++++id: 1000049
++++++++++id: 1000050
++++++++++id: 1000051
++++++++++id: 1000052
++++++++++id: 1000053
++++++++++id: 1000054
++++++++++id: 1000055
++++++++++id: 1000056
++++++++++id: 1000057
++++++++++id: 1000058
++++++++++id: 1000059
++++++++++id: 1000060
++++++++++id: 1000061
++++++++++id: 1000062
++++++++++id: 1000063
++++++++++id: 1000064
++++++++++id: 1000065
++++++++++id: 1000066
++++++++++id: 1000067
++++++++++id: 1000068
++++++++++id: 1000069
++++++++++id: 1000070
++++++++++id: 1000071
++++++++++id: 1000072
++++++++++id: 1000073
++++++++++id: 1000074
++++++++++id: 1000075
++++++++++id: 1000076
++++++++++id: 1000077
++++++++++id: 1000078
++++++++++id: 1000079
++++++++++id: 1000080
++++++++++id: 1000081
++++++++++id: 1000082
++++++++++id: 1000083
++++++++++id: 1000084
++++++++++id: 1000085
++++++++++id: 1000086
++++++++++id: 1000087
++++++++++id: 1000088
++++++++++id: 1000089
++++++++++id: 1000090
++++++++++id: 1000091
++++++++++id: 1000092
++++++++++id: 1000093
++++++++++id: 1000094
++++++++++id: 1000095
++++++++++id: 1000096
++++++++++id: 1000097
++++++++++id: 1000098
++++++++++id: 1000099
++++++++++id: 1000100
```

## 约束与限制

在下述版本验证通过：

```cangjie
Cangjie Compiler: 0.60.5 (cjnative)
```

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE)，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。
