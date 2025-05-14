/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj


/**
 * DB区间管理器
 */
public class DbSeqRangeMgr <: SeqRangeMgr {

    /**
     * 表名前缀，为防止数据库表名冲突，默认带上这个前缀
     */
    private static let TABLENAME_PREFIX: String = "x_sequence_"

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

    public override func nextRange(name: String): SeqRange {
        if (isEmpty(name)) {
            throw SeqException("[DbSeqRangeMgr-nextRange] name is empty.")
        }
        var oldValue: Int64 
        var newValue: Int64

        for (_ in 0..getRetryTimes()) {
            if(let Some(dataSource) <- getDataSource()) {
                oldValue = DbHelper.selectRange(dataSource, getRealTableName(), name, getStepStart())
                newValue = oldValue + Int64(getStep())
                if (DbHelper.updateRange(dataSource, getRealTableName(), newValue, oldValue, name)) {
                    return SeqRange(oldValue + 1, newValue)
                }
            }  
        }
        throw SeqException("Retried too many times, retryTimes = ${getRetryTimes().toString()}")
    }

    public func create(): Unit {
        checkParam()
        if(let Some(dataSource) <- getDataSource()) { 
            DbHelper.createTable(dataSource, getRealTableName())
        }
       
    }

    private func isEmpty(str: String): Bool {
        return Int64(str.trimAscii().size) == 0
    }

    private func getRealTableName(): String {
        return TABLENAME_PREFIX + (getTableName())
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
        return step
    }

    public func setStep(step: Int32): Unit {
        this.step = step
    }

    public func getStepStart(): Int64 {
        return stepStart
    }

    public func setStepStart(stepStart: Int64): Unit {
        this.stepStart = stepStart
    }

    public func getRetryTimes(): Int32 {
        return retryTimes
    }

    public func setRetryTimes(retryTimes: Int32): Unit {
        this.retryTimes = retryTimes
    }

    public func getDataSource(): ?Datasource {
        return dataSource
    }

    public func setDataSource(dataSource: Datasource): Unit {
        this.dataSource = dataSource
    }

    public func getTableName(): String {
        return tableName
    }

    public func setTableName(tableName: String): Unit {
        this.tableName = tableName
    }
}
