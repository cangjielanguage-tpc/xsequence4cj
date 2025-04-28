// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import xsequence4cj.*

main(): Int64 {
    let seqRange: SeqRange = SeqRange(10,100)
    let next: Int64 = seqRange.getAndIncrement()
    let mins: Int64 = seqRange.getMin()
    let maxs: Int64 = seqRange.getMax()
    let over: Bool = seqRange.isOver()

    if(!seqRange.toString().contains("max: 100, min: 10, value: 11") ) {
        return -1
    }
    return 0
}
