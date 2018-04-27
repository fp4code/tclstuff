# 2008-10-8

namespace eval isolant {}



proc isolant::initialise {} {
    smu1 write "F0,1XO0XF1,1XO0X" ; puts "ATTENTION : smu1 Local Sensing"
    smu3 write "F0,1XO0XF1,1XO0X" ; puts "ATTENTION : smu3 Local Sensing"
    smu1 I(V)
    smu2 I(V)
    smu3 I(V)
    smu1 trigOut none
    smu2 trigOut none
    smu3 trigOut none
    smu3 trigIn continuous
    smu2 dc
    smu1 trigIn continuous



    smu3 write "B0,0,0X"
    smu3 sweep  
}


proc isolant::une_mesure {tension delai npts} {
    smu3 fixedLevelSweep 0 $delai $npts
    smu1 sourceContinue $tension
    smu3 fire
    smu3 wait
    return [smu3 litFixedLevelSweep]
}

proc isolant::en_forme {canal secondes v ligne} {
    set m [lindex $ligne 1]
    if {[lindex $m 0] != "V I"} {error "attendu \"{V I} ... \", lu $m"}
    foreach mm [lrange $m 1 end] {
	puts $canal [list $secondes [lindex $mm 1] $v [lindex $mm 0] [lindex $mm 2]]
    }
}


proc isolant::mesures {canal blabla tensions delai npts} {
    set depart [clock seconds]
    puts $canal "@@$blabla"
    puts $canal "@s ms V I status"
    foreach tension $tensions {
	set secondes [expr {[clock seconds] - $depart}]
	set mesure [isolant::une_mesure $tension $delai $npts]
	isolant::en_forme $canal $secondes $tension $mesure
        flush $canal
    }
}

proc isolant::mesure {} {
    set canal [open "/home/asdex/A/data/ZnSe/G64/G64.11/300C/44-45_[clock seconds].spt" w]
    set m [list]
    for {set i 0} {$i <= 9} {incr i} {lappend m [expr {$i*0.1}]}
    for {set i 1} {$i <= 9} {incr i} {lappend m $i}
    for {set i 10} {$i <= 110} {incr i 10} {lappend m $i}
    for {set i 100} {$i >= 10} {incr i -10} {lappend m $i}
    for {set i 9} {$i >= 1} {incr i -1} {lappend m $i}
    for {set i 9} {$i >= -9} {incr i -1} {lappend m [expr {$i*0.1}]}
    for {set i -1} {$i >= -9} {incr i -1} {lappend m $i}
    for {set i -10} {$i >= -110} {incr i -10} {lappend m $i}
    for {set i -100} {$i <= -10} {incr i 10} {lappend m $i}
    for {set i -9} {$i <= -1} {incr i} {lappend m $i}
    for {set i -9} {$i <= 0} {incr i} {lappend m [expr {$i*0.1}]}
    isolant::initialise
    smu1 setCompliance 1e-6    ;# more than next one !
    smu3 setCompliance 1e-7 {} ;# auto-range
    smu3 SRQon Warning Error SweepDone
    smu3 operate
#    isolant::mesures $canal 44-45 {0 10 20 30 40} 1000 5
    isolant::mesures $canal 44-45 $m 5000 25
    close $canal
    smu1 repos
    smu2 repos
    smu3 repos
}








