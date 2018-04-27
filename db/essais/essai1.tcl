load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so
proc dumpdb {db} {
    set cursor [$db cursor]
    set kv [$cursor get -first]
    set ret [list]
    while {$kv != {}} {
        if {[llength $kv] != 1} {
	    return -code error "Je n'ai rien compris à \"cursor get\" (retourne \"$kv\")"
        }
        set kv [lindex $kv 0]
        lappend ret [lindex $kv 0] [lindex $kv 1]
        set kv [$cursor get -next]
    }
    $cursor close
    return $ret
}

set env0 [berkdb env -recover -create -home .]

set env0 [berkdb env -recover -create -home bibi]


set db0 [berkdb open -env $env0 -btree -create foo.db]
$db0 put a a

set c0 [$db0 cursor]
$c0 get -first
$c0 put -current -partial {1 2} bb
$c0 close
$db0 close


