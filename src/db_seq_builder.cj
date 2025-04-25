/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

package xsequence4cj

/**
 * 基于DB取步长，序列号生成器构建者
 */
public class DbSeqBuilder <: SeqBuilder {
    /**
     * 数据库数据源[必选]
     */
    private var datasource: ?Datasource = Option<Datasource>.None
     /**
     * 业务名称[必选]
     */
    private var bizname: String = ""
    /**
     * 存放序列号步长的表[可选：默认：sequence]
     */
    private var tablename: String = "sequence"
    /**
     * 并发时数据使用了乐观策略，这个是失败重试的次数[可选：默认：100]
     */
    private var retrytimes = 100
    /**
     * 获取range步长[可选：默认：1000]
     */
    private var steps = 1000
    /**
     * 序列号分配起始值[可选：默认：0]
     */
    private var stepstart = 0

    public init(){}

    public func dataSource(dataSource: Datasource): DbSeqBuilder {
        this.datasource = dataSource
        return this
    }

    public func tableName(tableName: String): DbSeqBuilder {
        this.tablename = tableName
        return this
    }

    public func retryTimes(retryTimes: Int64): DbSeqBuilder {
        this.retrytimes = retryTimes
        return this
    }

    public func step(step: Int64): DbSeqBuilder {
        this.steps = step
        return this
    }

    public func bizName(bizName: String): DbSeqBuilder {
        this.bizname = bizName
        return this
    }

    public func stepStart(stepStart: Int64): DbSeqBuilder {
        this.stepstart = stepStart
        return this
    }

    public override func build(): Sequence {
        //利用DB获取区间管理器
        let dbSeqRangeMgr = DbSeqRangeMgr()
        if(let Some(datasource) <- this.datasource) {
            dbSeqRangeMgr.setDataSource(datasource)
        }
        dbSeqRangeMgr.setTableName(this.tablename)
        dbSeqRangeMgr.setRetryTimes(this.retrytimes)
        dbSeqRangeMgr.setStep(this.steps)
        dbSeqRangeMgr.setStepStart(stepstart)
        dbSeqRangeMgr.create()
        //构建序列号生成器
        let sequence = DefaultRangeSequence()
        sequence.setName(this.bizname)
        sequence.setSeqRangeMgr(dbSeqRangeMgr)
        return sequence
    }
}
