package provide histo 0.1

namespace eval histo {}

proc histo::plotcumul {rlist args} {
    global gg

    set rlist [lsort -real $rlist]
    
    set icum 0
    set plotlist [list]
    set unSurN [expr {1.0/[llength $rlist]}] 
    
    append plotlist "0.0 0\n"
    
    foreach r $rlist {
	incr icum
	append plotlist "$r [expr {$unSurN*$icum}]\n"
    }
    
    if {![info exists gg]} {
        set gg [open "|gnuplot 2>@ stderr" w]
        fconfigure $gg -buffering line
    }    

    array set options $args

    if {[info exists options(-min)]} {
        set min $options(-min)
    } else {
        set min "*"
    }

    if {[info exists options(-max)]} {
        set max $options(-max)
    } else {
        set max "*"
    }

    puts $gg "set xrange \[$min:$max\]"    
    puts $gg {set yrange [0:1.0]}    

    puts $gg "plot \"-\" with lines"
    puts $gg ${plotlist}e
}

proc histo::plothisto {rlist min max pas} {
    global gg

    set N [expr {double($max - $min)/double($pas)}]

    set histo(min) 0
    set histo(max) 0
    for {set i 0} {$i < $N} {incr i} {
	set histo($i) 0
    }

    foreach r $rlist {
        set i [expr {int(floor(double($r - $min)/double($pas)))}]
	if {$i < 0} {
	    incr histo(min)
	    if {![info exists mimin] || $r < $mimin} {
		set mimin $r
	    }
	} elseif {$i >= $N} {
	    incr histo(max)
	    if {![info exists mamax] || $r > $mamax} {
		set mamax $r
	    }
	} else {
	    incr histo($i)
	}
    }

    set plotlist ""

    if {$histo(min) != 0} {
#	append plotlist "[expr {0.5*($mimin + $min)}] $histo(min)\n"
	append plotlist "[expr {$min - 0.5*$pas}] $histo(min)\n"
    }
    for {set i 0} {$i <$N} {incr i} {
        append plotlist "[expr {$min + ($i+0.5)*$pas}] $histo($i)\n"
    }
    if {$histo(max) != 0} {
#	append plotlist "[expr {0.5*($mamax + $max)}] $histo(max)\n"
	append plotlist "[expr {$max + 0.5*$pas}] $histo(max)\n"
    }

    if {![info exists gg]} {
        set gg [open "|gnuplot 2>@ stderr" w]
        fconfigure $gg -buffering line
    }    

    set rmin [expr {$min - 0.5*$pas}]
    set rmax [expr {$max + 0.5*$pas}]

    puts $gg "set xrange \[$rmin:$rmax\]"    
    puts $gg {set yrange [0:*]}    

    puts $gg "plot \"-\" with boxes"
    puts $gg ${plotlist}e

    puts $plotlist

}


