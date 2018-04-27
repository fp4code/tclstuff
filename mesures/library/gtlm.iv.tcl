
proc gtlm.mes.xeq {nom} {}

proc gtlm.move.xyn {xy n} {
    global ghost_tlm_array TC
    set xy [sumXY $xy $ghost_tlm_array($n)]
    ::aligned::moveTo $TC(machine) [lindex $xy 0] [lindex $xy 1]
}

proc gtlm.move.licon {li co n} {
    gtlm.move.xyn [tc.coords.xeq $li $co] $n
}

proc mes.gtlm {nom} {
    global ghost_tlm_nmotifs
    global ghost_tlm_typesOfMotifs
    global TC
    set xydepart [::aligned::getPosition $TC(machine)]
    set mesures {}
    for {set i 0} {$i < $ghost_tlm_nmotifs} {incr i} {
        puts $i
        if {!$TC(go)} {
            ::aligned::moveTo $TC(machine) [lindex $xydepart 0] [lindex $xydepart 1]
            break
        }
        gtlm.move.xyn $xydepart $i
        set mesures [concat $mesures [gtlm.mes.xeq \
             ${nom}-${i}:$ghost_tlm_typesOfMotifs($i)]]
    }
    return $mesures
}
