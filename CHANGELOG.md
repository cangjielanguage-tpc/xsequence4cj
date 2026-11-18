## V1.0.3

- 不兼容变更：`DbSeqRangeMgr.create()` 成功后会冻结配置，`setStep`、`setStepStart`、`setRetryTimes`、`setDataSource`、`setTableName` 在 `create()` 之后调用将抛出 `SeqException`。
- 不兼容变更：`DbSeqRangeMgr.nextRange(name)` 新增业务名校验，`name` 不能为空，且长度不能超过 32 个 rune。
- 不兼容变更：表名新增长度与白名单校验，用户传入的表名按 rune 计数需为 1-53 位，且仅允许 ASCII 字母、数字或下划线；长度在 `setTableName()` / `build()` 阶段校验，空值与字符白名单在建表阶段校验。
- 不兼容变更：`DbHelper.insertRange` / `updateRange` / `selectRange` 新增业务名长度校验，`name` 不能为空且长度不能超过 32 个 rune；`name` 全程通过 `SqlVarchar` 参数绑定，不做字符集白名单。
- 不兼容变更：`DbSeqRangeMgr.nextRange(name)` 会校验 `step` 必须大于 0；即使未调用 `create()`，非法步长也会抛出 `SeqException`，不会抛出 `OverflowException`。
- 性能与实现修正：`DbHelper` 的 SQL 模板与溢出阈值改为不可变常量；`DbSeqRangeMgr` 在 `create()` 后使用不可变配置快照，`nextRange()` 只读取一次配置；`create()` 建表期间不持有配置锁，建表失败不会提交快照或冻结配置。
- 文档订正：`getStep`、`setStep`、`getRetryTimes`、`setRetryTimes` 以及 `DbSeqBuilder.retryTimes` / `step` 的签名由 `Int64` 修正为 `Int32`。

## V1.0.2
升级仓颉1.2.0

## V1.0.1
升级仓颉1.0.0

## V1.0.0
支持 DB 方式生成序列号
