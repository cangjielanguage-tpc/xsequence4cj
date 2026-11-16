# xsequence4cj 特性文档

## 介绍

xsequence4cj 是一个分布式序列号生成组件。

## 1 DB 序列号生成器

### 1.1 接口

#### 1.1.1 interface Sequence

序列号生成器接口

```cangjie
public interface Sequence {

    /**
     * 生成下一个序列号
     *
     * 返回值 Int64 - 序列号
     */
    func nextValue(): Int64
}
```

#### 1.1.2 interface SeqRangeMgr

区间管理器

```cangjie
public interface SeqRangeMgr {

    /**
     * 获取指定区间名的下一个区间
     *
     * 参数 name - 区间名
     * 返回值 SeqRange - 返回区间
     */
    func nextRange(name: String): SeqRange
}
```
#### 1.1.3 interface SeqBuilder

序列号生成器构建者

```cangjie
public interface SeqBuilder {

    /**
     * 构建一个序列号生成器
     *
     * 返回值 Sequence - 序列号生成器
     */
    func build(): Sequence
}
```

#### 1.1.4 interface RangeSequence <: Sequence

序列号区间生成器接口

```cangjie
public interface RangeSequence <: Sequence {

    /**
     * 设置区间管理器
     *
     * 参数 seqRangeMgr - 区间管理器
     * 返回值 Unit
     */
    func setSeqRangeMgr(seqRangeMgr: SeqRangeMgr): Unit

    /**
     * 设置获取序列号名称
     *
     * 参数 name - 名称
     * 返回值 Unit
     */
    func setName(name: String): Unit
}
```
### 1.2 类

#### 1.2.1 class SeqRange

序列号区间对象模型

```cangjie
public class SeqRange {

    /**
     * 区间序列号初始化
     *
     * 参数 min - 区间序列号开始值
     * 参数 max - 区间序列号结束值
     */
    public init(min: Int64, max: Int64)

    /**
     * 返回并递增下一个序列号
     *
     * 返回值 ?Int64 - 下一个序列号；区间耗尽时返回 None
     */
    public func tryGetAndIncrement(): ?Int64

    /**
     * 兼容旧接口：返回并递增下一个序列号
     *
     * 返回值 Int64 - 下一个序列号；区间耗尽时返回 -1
     */
    public func getAndIncrement(): Int64 

    /**
     * 获取区间序列号开始值
     *
     * 返回值 Int64 - 区间序列号开始值
     */
    public func getMin(): Int64
    
    /**
     * 获取区间序列号结束值
     *
     * 返回值 Int64 - 区间序列号结束值
     */
    public func getMax(): Int64

    /**
     * 区间的序列号是否分配完毕，每次分配完毕就会去重新获取一个新的区间
     *
     * 返回值 Bool - 区间序列号分配完返回 true,反之 false
     */
    public func isOver(): Bool

    /**
     * 设置区间序列号是否分配完毕
     *
     * 参数 over - true:区间序列号分配完毕，false:没有分配完毕
     * 返回值 Unit
     */
    public func setOver(over: Bool): Unit

    /**
     * 获取区间序列号字符串形式
     *
     * 返回值 String - 区间序列号字符串形式
     */
    public func toString(): String
}
```

注意：如果区间包含 -1，建议使用 `tryGetAndIncrement()`，以区分合法值和耗尽语义。

#### 1.2.2 class DbSeqRangeMgr <: SeqRangeMgr

DB 区间管理器

```cangjie
public class DbSeqRangeMgr <: SeqRangeMgr {

    /**
     * 获取指定业务名的下一个区间
     *
     * 参数 name - 业务名，不能为空，长度不能超过 32 个 rune
     * 返回值 SeqRange - 返回区间
     * @throws SeqException 业务名为空、超长、步长非法或数据库操作失败时抛出
     */
    public override func nextRange(name: String): SeqRange

    /**
     * 创建 DB 区间管理器，用在设置完一系列参数之后
     *
     * 返回值 Unit
     * @throws SeqException 配置非法或数据库操作失败时抛出
     */
    public func create(): Unit

    /**
     * 获取区间步长，默认 1000
     *
     * 返回值 Int32 - 区间步长
     */
    public func getStep(): Int32

    /**
     * 设置区间步长，默认 1000
     *
     * 参数 step - 区间步长
     * 返回值 Unit
     * @throws SeqException 配置已冻结（create() 之后不可修改）时抛出
     */
    public func setStep(step: Int32): Unit

    /**
     * 获取区间起始位置，从 stepStart + 1 开始
     *
     * 返回值 Int64 - 区间起始位置
     */
    public func getStepStart(): Int64

    /**
     * 设置区间起始位置，从 stepStart + 1 开始
     *
     * 参数 stepStart - 区间起始位置
     * 返回值 Unit
     * @throws SeqException 配置已冻结（create() 之后不可修改）时抛出
     */
    public func setStepStart(stepStart: Int64): Unit

    /**
     * 获取区间失败重试次数，默认 100
     *
     * 返回值 Int32 - 区间失败重试次数
     */
    public func getRetryTimes(): Int32

    /**
     * 设置区间失败重试次数，默认 100
     *
     * 参数 retryTimes - 区间是被重试次数
     * 返回值 Unit 
     * @throws SeqException 配置已冻结（create() 之后不可修改）时抛出
     */
    public func setRetryTimes(retryTimes: Int32): Unit

    /**
     * 获取 DB 来源
     *
     * 返回值 ?Datasource - DB 来源
     */
    public func getDataSource(): ?Datasource

    /**
     * 设置 DB 来源
     *
     * 参数 dataSource - DB 来源
     * 返回值 Unit
     * @throws SeqException 配置已冻结（create() 之后不可修改）时抛出
     */
    public func setDataSource(dataSource: Datasource): Unit

    /**
     * 获取表名，默认 range
     *
     * 返回值 String - 获取表名
     */
    public func getTableName(): String

    /**
     * 设置表名
     *
     * 参数 tableName - 表名，设置时会校验长度为 1-53 个 rune；空值与字符白名单在 create() 时校验
     * 返回值 Unit
     * @throws SeqException 配置已冻结（create() 之后不可修改）或表名超长时抛出；表名为空或包含非法字符时由 create() 抛出
     */
    public func setTableName(tableName: String): Unit
}
```

说明：

- `DbSeqRangeMgr` 内部会为表名追加固定前缀 `x_sequence_`，因此传入的 `tableName` 最长 53 个 rune，最终表名总长度不超过 64；长度在 `setTableName()` 时按 rune 校验，空值与字符白名单在 `create()` 建表时校验。
- `create()` 成功后配置会被冻结；`setStep`、`setStepStart`、`setRetryTimes`、`setDataSource`、`setTableName` 再次调用会抛出 `SeqException`。
- `create()` 建表期间不持有配置锁，读取配置不会被建表阻塞；`create()` 失败不会提交配置快照，也不会冻结配置。
- `nextRange(name)` 的 `name` 不能为空，且长度不能超过 32 个 rune；`step` 必须大于 0，即使未调用 `create()` 也会在 `nextRange(name)` 入口校验；`name` 全程通过 `SqlVarchar` 参数绑定，不做字符集白名单。

#### 1.2.3 class DefaultRangeSequence <: RangeSequence

序列号区间生成器接口默认实现

DefaultRangeSequence 仅接受非负区间；区间耗尽后会在有限次数内刷新，超过次数抛出 SeqException。

```cangjie
public class DefaultRangeSequence <: RangeSequence {

    /**
     * 生成下一个序列号
     *
     * 返回值 Int64 - 序列号
     */
    public override func nextValue(): Int64

    /**
     * 设置 DB 区间管理器
     *
     * 参数 seqRangeMgr - DB 区间管理器
     * 返回值 Unit
     */
    public override func setSeqRangeMgr(seqRangeMgr: SeqRangeMgr): Unit

    /**
     * 设置区间的业务名称
     *
     * 参数 name - 区间的业务名称
     * 返回值 Unit
     */
    public override func setName(name: String): Unit
}
```

#### 1.2.4 class DbSeqBuilder <: SeqBuilder

基于 DB 取步长，序列号生成器的构建者

```cangjie
public class DbSeqBuilder <: SeqBuilder {

    /**
     * 初始化序列号生成器构建者
     */
    public init()

    /**
     * 设置数据库的数据源，必选
     *
     * 参数 dataSource - 数据库的数据源
     * 返回值 DbSeqBuilder - 序列号生成器构建者
     */
    public func dataSource(dataSource: Datasource): DbSeqBuilder

    /**
     * 存放序列号步长的表，默认  x_sequence_sequence，可选
     *
     * 参数 tableName - 表名，build() 时会校验长度为 1-53 个 rune，建表时会校验字符白名单
     * 返回值 DbSeqBuilder- 序列号生成器构建者
     */
    public func tableName(tableName: String): DbSeqBuilder 

    /**
     * 并发时，区间生成失败重试的次数，默认 100，可选
     *
     * 参数 retryTimes - 失败重试的次数
     * 返回值 DbSeqBuilder - 序列号生成器的构建者
     */
    public func retryTimes(retryTimes: Int32): DbSeqBuilder

    /**
     * 设置步长，默认 1000，可选
     *
     * 参数 step - 步长
     * 返回值 DbSeqBuilder - 序列号生成器的构建者
     */
    public func step(step: Int32): DbSeqBuilder

    /**
     * 业务名称，默认空字符串，必选，必选
     *
     * 参数 bizName - 业务名称，不能为空，长度不能超过 32 个 rune
     * 返回值 DbSeqBuilder - 序列号生成器的构建者
     */
    public func bizName(bizName: String): DbSeqBuilder

    /**
     * 设置序列号分配起始值，默认 0，可选
     *
     * 参数 stepStart - 序列号分配起始值
     * 返回值 DbSeqBuilder - 序列号生成器的构建者
     */
    public func stepStart(stepStart: Int64): DbSeqBuilder 

    /**
     * 序列号生成器的构建者建立，用在设置参数之后
     *
     * 返回值 Sequence - 序列号生成器
     * @throws SeqException 配置非法或数据库操作失败时抛出
     */
    public override func build(): Sequence 
}
```

说明：

- `build()` 会创建表并冻结配置。
- `tableName` 传入后会追加 `x_sequence_` 前缀，因此有效长度为 1-53 个 rune，且仅允许 ASCII 字母、数字或下划线；长度在 `build()` 时校验，字符白名单在建表时校验。
- `bizName` 会在取号时按 32 个 rune 的上限校验。

## 2 示例

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

```
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
