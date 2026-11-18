/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj


/**
 * DB区间管理器
 */
public class DbSeqRangeMgr <: SeqRangeMgr {
    private let configLock: Mutex = Mutex()
    private let createLock: Mutex = Mutex()
    private var frozen: Bool = false
    private var creating: Bool = false
    private let configSnapshot: AtomicOptionReference<DbSeqRangeMgrConfig> =
        AtomicOptionReference<DbSeqRangeMgrConfig>(Option<DbSeqRangeMgrConfig>.None)
    private var unfrozenConfig: ?DbSeqRangeMgrConfig = Option<DbSeqRangeMgrConfig>.None


    /**
     * 表名前缀，为防止数据库表名冲突，默认带上这个前缀
     */
    private static let TABLENAME_PREFIX: String = SequenceConstraints.TABLE_NAME_PREFIX
    private static let MAX_USER_TABLE_NAME_LENGTH: Int64 =
        SequenceConstraints.MAX_TABLE_NAME_LENGTH - TABLENAME_PREFIX.size
    /**
     * 业务名最大长度，与 DB 表 name varchar(32) 保持一致。
     */
    private static let MAX_NAME_LENGTH: Int64 = SequenceConstraints.MAX_NAME_LENGTH

    /**
     * 区间步长
     */
    private var step: Int32 = 1000

    /**
     * 区间起始位置，真实从stepStart+1开始
     */
    private var stepStart: Int64 = 0

    /**
     * 获取区间失败重试次数
     */
    private var retryTimes: Int32 = 100

    /**
     * DB来源
     */
    private var dataSource: ?Datasource = Option<Datasource>.None

    /**
     * 表名，默认range
     */
    private var tableName: String = "range"

    /**
     * 获取指定业务名的下一个区间。
     *
     * @param name 业务名
     * @return 下一个区间
     * @throws SeqException 业务名为空、超长、步长非法或数据库操作失败时抛出
     */
    public override func nextRange(name: String): SeqRange {
        if (isEmpty(name)) {
            throw SeqException("[DbSeqRangeMgr-nextRange] name is empty.")
        }
        if (Int64(name.toRuneArray().size) > MAX_NAME_LENGTH) {
            throw SeqException("[DbSeqRangeMgr-nextRange] name is too long, max length = ${MAX_NAME_LENGTH.toString()}.")
        }
        let config = getConfig()
        if (config.step <= 0) {
            throw SeqException("[DbSeqRangeMgr-nextRange] step must greater than 0, step = ${config.step}")
        }
        var oldValue: Int64 
        var newValue: Int64

        for (_ in 0..config.retryTimes) {
            if(let Some(dataSource) <- config.dataSource) {
                oldValue = DbHelper.selectRange(dataSource, config.realTableName, name, config.stepStart) ?? continue
                let step = Int64(config.step)
                if (step > 0 && oldValue > Int64.Max - step) {
                    throw SeqException("Sequence value overflow, value = ${oldValue}, step = ${step}, please check table sequence ${config.realTableName}")
                }
                newValue = oldValue + step
                if (DbHelper.updateRange(dataSource, config.realTableName, newValue, oldValue, name)) {
                    return SeqRange(oldValue + 1, newValue)
                }
            }  
        }
        throw SeqException("Retried too many times, retryTimes = ${config.retryTimes.toString()}")
    }

    /**
     * 创建序列表并冻结当前配置。
     *
     * @throws SeqException 配置非法或数据库操作失败时抛出
     */
    public func create(): Unit {
        createLock.lock()
        try {
            let config = prepareConfig()

            try {
                if(let Some(dataSource) <- config.dataSource) {
                    DbHelper.createTable(dataSource, config.realTableName)
                }
            } catch (e: Exception) {
                abortCreating()
                throw e
            }

            configLock.lock()
            try {
                configSnapshot.store(Some(config))
                frozen = true
            } finally {
                creating = false
                configLock.unlock()
            }
        } finally {
            createLock.unlock()
        }
    }

    private func prepareConfig(): DbSeqRangeMgrConfig {
        configLock.lock()
        try {
            if (creating) {
                throw SeqException("Configuration is being created.")
            }
            checkParam()
            let config = DbSeqRangeMgrConfig(step, stepStart, retryTimes, dataSource, tableName, TABLENAME_PREFIX + tableName)
            creating = true
            return config
        } finally {
            configLock.unlock()
        }
    }

    private func abortCreating(): Unit {
        configLock.lock()
        try {
            creating = false
        } finally {
            configLock.unlock()
        }
    }

    private func isEmpty(str: String): Bool {
        return Int64(str.trimAscii().size) == 0
    }

    private func getConfig(): DbSeqRangeMgrConfig {
        if (let Some(config) <- configSnapshot.load()) {
            return config
        }

        configLock.lock()
        try {
            if (let Some(config) <- unfrozenConfig) {
                return config
            }
            let config = DbSeqRangeMgrConfig(step, stepStart, retryTimes, dataSource, tableName, TABLENAME_PREFIX + tableName)
            unfrozenConfig = Some(config)
            return config
        } finally {
            configLock.unlock()
        }
    }

    private func checkUserTableName(tableName: String): Unit {
        if (Int64(tableName.toRuneArray().size) > MAX_USER_TABLE_NAME_LENGTH) {
            throw SeqException("[DbSeqRangeMgr-setTableName] tableName is too long, max length = ${MAX_USER_TABLE_NAME_LENGTH.toString()} (${TABLENAME_PREFIX.size.toString()} chars are reserved for the '${TABLENAME_PREFIX}' prefix).")
        }
    }

    private func checkParam(): Unit {
        if (step <= 0) {
            throw SeqException("[DbSeqRangeMgr-checkParam] step must greater than 0.")
        }
        if (stepStart < 0) {
            throw SeqException("[DbSeqRangeMgr-setStepStart] stepStart < 0.")
        }
        if (retryTimes <= 0) {
            throw SeqException("[DbSeqRangeMgr-setRetryTimes] retryTimes must greater than 0.")
        }
        if (dataSource.isNone()) {
            throw SeqException("[DbSeqRangeMgr-setDataSource] dataSource is null.")
        }
        if (isEmpty(tableName)) {
            throw SeqException("[DbSeqRangeMgr-setTableName] tableName is empty.")
        }
    }

    public func getStep(): Int32 {
        if (let Some(config) <- configSnapshot.load()) {
            return config.step
        }

        configLock.lock()
        try {
            return step
        } finally {
            configLock.unlock()
        }
    }

    /**
     * 设置区间步长。
     *
     * @param step 区间步长
     * @throws SeqException 配置已冻结时抛出
     */
    public func setStep(step: Int32): Unit {
        configLock.lock()
        try {
            if (frozen || creating) {
                throw SeqException("Configuration cannot be changed after create().")
            }
            this.step = step
            unfrozenConfig = Option<DbSeqRangeMgrConfig>.None
        } finally {
            configLock.unlock()
        }
    }

    public func getStepStart(): Int64 {
        if (let Some(config) <- configSnapshot.load()) {
            return config.stepStart
        }

        configLock.lock()
        try {
            return stepStart
        } finally {
            configLock.unlock()
        }
    }

    /**
     * 设置区间起始位置。
     *
     * @param stepStart 区间起始位置
     * @throws SeqException 配置已冻结时抛出
     */
    public func setStepStart(stepStart: Int64): Unit {
        configLock.lock()
        try {
            if (frozen || creating) {
                throw SeqException("Configuration cannot be changed after create().")
            }
            this.stepStart = stepStart
            unfrozenConfig = Option<DbSeqRangeMgrConfig>.None
        } finally {
            configLock.unlock()
        }
    }

    public func getRetryTimes(): Int32 {
        if (let Some(config) <- configSnapshot.load()) {
            return config.retryTimes
        }

        configLock.lock()
        try {
            return retryTimes
        } finally {
            configLock.unlock()
        }
    }

    /**
     * 设置获取区间失败重试次数。
     *
     * @param retryTimes 重试次数
     * @throws SeqException 配置已冻结时抛出
     */
    public func setRetryTimes(retryTimes: Int32): Unit {
        configLock.lock()
        try {
            if (frozen || creating) {
                throw SeqException("Configuration cannot be changed after create().")
            }
            this.retryTimes = retryTimes
            unfrozenConfig = Option<DbSeqRangeMgrConfig>.None
        } finally {
            configLock.unlock()
        }
    }

    public func getDataSource(): ?Datasource {
        if (let Some(config) <- configSnapshot.load()) {
            return config.dataSource
        }

        configLock.lock()
        try {
            return dataSource
        } finally {
            configLock.unlock()
        }
    }

    /**
     * 设置数据库来源。
     *
     * @param dataSource 数据库来源
     * @throws SeqException 配置已冻结时抛出
     */
    public func setDataSource(dataSource: Datasource): Unit {
        configLock.lock()
        try {
            if (frozen || creating) {
                throw SeqException("Configuration cannot be changed after create().")
            }
            this.dataSource = dataSource
            unfrozenConfig = Option<DbSeqRangeMgrConfig>.None
        } finally {
            configLock.unlock()
        }
    }

    public func getTableName(): String {
        if (let Some(config) <- configSnapshot.load()) {
            return config.tableName
        }

        configLock.lock()
        try {
            return tableName
        } finally {
            configLock.unlock()
        }
    }

    /**
     * 设置表名。
     *
     * @param tableName 表名
     * @throws SeqException 配置已冻结时抛出
     */
    public func setTableName(tableName: String): Unit {
        configLock.lock()
        try {
            if (frozen || creating) {
                throw SeqException("Configuration cannot be changed after create().")
            }
            checkUserTableName(tableName)
            this.tableName = tableName
            unfrozenConfig = Option<DbSeqRangeMgrConfig>.None
        } finally {
            configLock.unlock()
        }
    }
}

private class DbSeqRangeMgrConfig {
    let step: Int32
    let stepStart: Int64
    let retryTimes: Int32
    let dataSource: ?Datasource
    let tableName: String
    let realTableName: String

    init(step: Int32, stepStart: Int64, retryTimes: Int32, dataSource: ?Datasource, tableName: String,
        realTableName: String) {
        this.step = step
        this.stepStart = stepStart
        this.retryTimes = retryTimes
        this.dataSource = dataSource
        this.tableName = tableName
        this.realTableName = realTableName
    }
}
