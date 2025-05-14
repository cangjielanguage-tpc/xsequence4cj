// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
import mysqlclient_ffi.*
import std.database.sql.*
import std.time.*
import xsequence4cj.*

main(): Int64 {
    try {
        MyClass.judgmentNum("")
    }catch(e: SeqException) {
        if(!e.toString().contains("SeqException: Num cannot be empty.")) {
            return -1
        }
    }
    return 0
}

class MyClass{
    static func judgmentNum(num: String): Int64 {
        if(num.size <= 0) {
            throw SeqException("Num cannot be empty.")
        }
        return 0
    }
}
