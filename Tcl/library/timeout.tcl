10 sept 2002 : essai de timeout
rien finalisé

proc execWithTimeout {command timeout} {
    set afterIdExec [after 0 execIt DONE afterIdKill $command]
    set AA [after $timeout killIt $a0]
    vwait DONE
}

proc execIt {DONE& AA& command} {
    upvar ${DONE&} DONE
    upvar ${AA&} AA
    set ret [eval $command]
    puts stderr "ret = \"$ret\""
    set DONE 1   
}

proc killIt {DONE& aa} {
    upvar ${DONE&} DONE
    after kill $aa
    set DONE 0
}

for {set i 1} {$i < 255} {incr i} {
    foreach j {5 6 7 8} {
        set a 10.$j.0.$i
        puts stderr $a
        set err [catch {exec telnet $a 80} m]
        puts stderr "$err $m"
    }
}

proc try80 {a} {
    set err [catch {exec telnet $a 80} m]
    return [list $err $m]
}

