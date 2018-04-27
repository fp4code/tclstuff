# 2003-05-16 (FP)

package require fidev
package require gpibLowLevel
package require a4156

proc ini0 {} {global GPIB_board ; GPIB::newGPIB a4156 a4 $GPIB_board 9}
# ::GPIBBoard::config $GPIB_board $GPIB::ConfigParam(TMO) 11

proc polarise {} {
    global v1 i1 v2 i2 v3 i3 v4 i4 N
    set N 4
    set irange 0
    a4 write "CN 1,2,3,4"
    a4 write "DV 1,11,$v1,$i1"
    a4 write "DV 2,11,$v2,$i2"
    a4 write "DV 3,11,$v3,$i3"
    a4 write "DV 4,11,$v4,$i4"
    a4 write "MM 1,1,2,3,4" 
    a4 write "CMM 1,1"
    a4 write "CMM 2,1"
    a4 write "CMM 3,1"
    a4 write "CMM 4,1"
    a4 write "RI 1,$irange"    
    a4 write "RI 2,$irange"    
    a4 write "RI 3,$irange"    
    a4 write "RI 4,$irange"
}

proc m {lambda} {
    global F N
    if {![info exists F]} {
	set F [open /home/incal/A/71H41-1/autrechose.dat a]
    }
    s1
    set rep [s2 $N]
    puts $F [concat $lambda $rep]
    flush $F
}


set v1 0.00 ;# back
set v2 0.00 ;# coax
set v3 0.04 ;# pointe
set i1 50e-9
set i2 50e-9
set i3 50e-9

set v4 -0.5
set i4 50e-6
set vp -0.5
set ip 50e-6

proc appliqueV {smu v} {
    a4 write "DV $smu,0,$v,1e-6,0"
}

proc v {smu} {
    set v [a4 spot $smu V 0]
    return [expr {[lindex $v 2]*[lindex $v 3]}]
}

proc i {smu} {
    return [a4 spot $smu I 0]
    return [expr {[lindex $v 2]*[lindex $v 3]}]
}

proc openShutter {} {
    a4 vsuTTL 1 1
}

proc closeShutter {} {
    a4 vsuTTL 1 0
}

proc polarise {} {
    a4 write "DV 4,0,-0.5,1.0e-5,0"
}

proc readRef {} {
    set r [a4 spotWithTimeStamp 4 I compliance]
    set t [lindex $r 0]
    set i [expr {-[lindex $r 3]*[lindex $r 4]}]
    return [list $t $i]
}

proc read1234 {} {
    set ret [list]
    for {set i 1} {$i <= 4} {incr i} {
	set r [::a4156::spotWithTimeStamp a4 $i I compliance]
	set t [lindex $r 0]
	set a [expr {[lindex $r 3]*[lindex $r 4]}]
	lappend ret $t $a [lindex $r 6]
    }
    return $ret
}

proc iniCanvas {} {
    upvar \#0 _T T
    upvar \#0 _T1 T1
    upvar \#0 _T2 T2
    upvar \#0 _T3 T3
    upvar \#0 _T4 T4

    catch {destroy .t}
    catch {unset T(STOP)}
    catch {font delete $T(font)}

    set T(font) [font create -family fixed -size 8]

    toplevel .t
    set c4 [canvas .t.c -width 300 -height 900 -background \#ffffff]
    pack .t.c -fill both
    
    # a revoir
    set T(CANVAS) $c4
    
    set T(xMIN) 1
    set T(xMAX) [$c4 cget -width]
    set T(yMAX) 1
    set T(yMIN) [$c4 cget -height]
    
    set T(tWIDTH) 20.
    catch {unset T(tPREV)}
    catch {unset T(STOP)}
    set T(iMIN_lin) 0
    set T(iMAX_lin) 0.5e-5
    set T(iMAX_log) 3e-6
    set T(iMIN_log) 1e-11

    for {set s -14} {$s <= -6} {incr s} {
	gradLeft_log T 1e$s $s
	gradLeft_log T 2e$s {}
	gradLeft_log T 3e$s {}
	gradLeft_log T 4e$s {}
	gradLeft_log T 5e$s {}
	gradLeft_log T 6e$s {}
	gradLeft_log T 7e$s {}
	gradLeft_log T 8e$s {}
	gradLeft_log T 9e$s {}
    }

    set T1(iobs)  0.0
    set T1(iobsD) 0.0
    set T1(iobs0) 0
    set T1(iobs1) 0.0
    set T1(iobs2) 0.0

    set T2(iobs)  0.0
    set T2(iobsD) 0.0
    set T2(iobs0) 0
    set T2(iobs1) 0.0
    set T2(iobs2) 0.0

    set T3(iobs)  0.0
    set T3(iobsD) 0.0
    set T3(iobs0) 0
    set T3(iobs1) 0.0
    set T3(iobs2) 0.0

    set T4(iobs)  0.0
    set T4(iobsD) 0.0
    set T4(iobs0) 0
    set T4(iobs1) 0.0
    set T4(iobs2) 0.0


    set T1(COLOR0) \#800000
    set T1(COLOR1) \#ff0000

    set T2(COLOR0) \#008000
    set T2(COLOR1) \#00ff00

    set T3(COLOR0) \#000080
    set T3(COLOR1) \#0000ff

    set T4(COLOR0) \#808080
    set T4(COLOR1) \#000000



    # puts stderr "iniCanvas"
    # parray T4

}

proc gradLeft_log {&T i text} {
    upvar ${&T} T
    set y [interpole_log $T(yMIN) $T(yMAX) $T(iMIN_log) $T(iMAX_log) $i]
    
    $T(CANVAS) create line [list 0 $y 5 $y] -fill black
    if {$text != {}} {
	$T(CANVAS) create text [list 10 $y] -text $text -anchor w -font $T(font)
    }
}

proc interpole {gMIN gMAX vMIN vMAX v} {
    set vv [expr {($gMIN*($vMAX - $v) + $gMAX*($v - $vMIN))/($vMAX-$vMIN)}]
    return $vv
}

proc interpole_log {gMIN gMAX vMIN vMAX v} {
    set vv [expr {($gMIN*log($vMAX/$v) + $gMAX*log($v/$vMIN))/log($vMAX/$vMIN)}]
    # puts stderr "$gMIN $gMAX $vMIN $vMAX -> $vv"
    return $vv
}

proc plotVal_log {&T TxName t0 i0 t1 i1 color width} {
    upvar ${&T}  T
    set x1 [interpole $T(xMIN) $T(xMAX) $T(tMIN) $T(tMAX) $t1]
    
    if {$i1 <= $T(iMIN_log)} {
	$T(CANVAS) create line [list $x1 $T(yMIN) [expr {$x1+1}] [expr {$T(yMIN)-20}]] -tags Val -fill $color -width 1
	$T(CANVAS) delete $TxName
    } elseif {$i1 >= $T(iMAX_log)} {
	$T(CANVAS) create line [list $x1 $T(yMAX) [expr {$x1+1}] [expr {$T(yMAX)+20}]] -tags Val -fill $color -width 1
	$T(CANVAS) delete $TxName
    } else {
	set y1 [interpole_log $T(yMIN) $T(yMAX) $T(iMIN_log) $T(iMAX_log) $i1]
	# $T(CANVAS) create line [list $x0 $y0 $x1 $y1] -tags Val
	# $T(CANVAS) create rectangle [list $x1 $y1 $x1 $y1] -tags Val
	$T(CANVAS) create line [list $x1 $y1 [expr {$x1+1}] $y1] -tags Val -fill $color -width $width
	set T(tPREV) $t1
	set T(iPREV) $i1
	$T(CANVAS) delete $TxName
	$T(CANVAS) create line [list $T(xMIN) $y1 $T(xMAX) $y1] -tags $TxName -fill $color
	$T(CANVAS) lower $TxName
    }
}

proc plotVal_lin {&T t0 i0 t1 i1 color} {
    upvar ${&T} T
    set x0 [interpole $T(xMIN) $T(xMAX) $T(tMIN) $T(tMAX) $t0]
    set x1 [interpole $T(xMIN) $T(xMAX) $T(tMIN) $T(tMAX) $t1]
    set y0 [interpole $T(yMIN) $T(yMAX) $T(iMIN_lin) $T(iMAX_lin) $i0]
    set y1 [interpole $T(yMIN) $T(yMAX) $T(iMIN_lin) $T(iMAX_lin) $i1]
    # $T(CANVAS) create line [list $x0 $y0 $x1 $y1] -tags Val
    # $T(CANVAS) create rectangle [list $x1 $y1 $x1 $y1] -tags Val
    $T(CANVAS) create line [list $x1 $y1 [expr {$x1+1}] $y1] -tags Val -fill $color -width 3
    set T(tPREV) $t1
    set T(iPREV) $i1
    $T(CANVAS) delete Tempo
    $T(CANVAS) create line [list $T(xMIN) $y1 $T(xMAX) $y1] -tags Tempo -fill $color
    $T(CANVAS) lower Tempo
}


proc plotNew {&T &Tx t i} {
    upvar ${&T} T
    upvar ${&Tx} Tx
    global TCHANGE SHUTTER_STATUS

    # puts stderr plotNew
    # parray Tx

    # puts stderr "${&Tx} $t $i"

    if {![info exists T(tPREV)]} {
	set t0 $t
	set i0 $i
	set T(tMIN) $t
	set T(tMAX) [expr {$T(tMIN) + $T(tWIDTH)}]
    } else {
	set t0 $T(tPREV)
	set i0 $T(iPREV)
    }
    if {$T(tMAX) < $t} {
	set dt [expr {$t - $T(tMAX)}]
	set dx [expr {-$dt*double($T(xMAX)-$T(xMIN))/double($T(tWIDTH))}]
	$T(CANVAS) move Val $dx 0
	$T(CANVAS) move ValT $dx 0 ;# N'améliore pas l'ensemble du mouvement
	set T(tMAX) $t
	set T(tMIN) [expr {$T(tMAX) - $T(tWIDTH)}]
    }
    if {![info exists TCHANGE] || ($t - $TCHANGE) < 0.2} {
	set color green
    } elseif {$SHUTTER_STATUS} {
	set color $Tx(COLOR0)
	# puts stderr "${&Tx} [expr {abs($i-$Tx(iobs))}]"
	plotVal_log T ${&Tx} $t0 [expr {$i0-$Tx(iobs)}] $t [expr {abs($i-$Tx(iobs))}] $Tx(COLOR1) 3
    } else {
	incr Tx(iobs0)
	set Tx(iobs1) [expr {$Tx(iobs1) + $i}]
	set Tx(iobs2) [expr {$Tx(iobs2) + $i*$i}]
	set color $Tx(COLOR0)
    }
    plotVal_log T ${&Tx} $t0 $i0 $t [expr {abs($i)}] $color 1
}

proc plotAll {&T &T1 &T2 &T3 &T4} {
    upvar ${&T} T
    upvar ${&T1} T1
    upvar ${&T2} T2
    upvar ${&T3} T3
    upvar ${&T4} T4
    global SHUTTER_STATUS TBEGIN TCHANGE
    set mes [read1234]
    set t [lindex $mes 0]
    # puts stderr plotAll
    # parray T4
    plotNew T T1 [lindex $mes 0] [lindex $mes 1]
    plotNew T T2 [lindex $mes 3] [lindex $mes 4]
    plotNew T T3 [lindex $mes 6] [lindex $mes 7]
    plotNew T T4 [lindex $mes 9] [lindex $mes 10]
    if {![info exists SHUTTER_STATUS]} {
	set SHUTTER_STATUS 0
	set TCHANGE $t
	set TBEGIN $t
    } else {
	set normsat [expr {int($t - $TBEGIN)%10} > 2]
	if {$normsat && !$SHUTTER_STATUS} {
	    openShutter
	    set SHUTTER_STATUS 1
	    set TCHANGE $t
	    puts stderr OPEN
	    calcobs T T4 $t
	    calcobs T T1 $t
	    calcobs T T2 $t
	    calcobs T T3 $t
	} elseif {!$normsat && $SHUTTER_STATUS} {
	    closeShutter
	    set SHUTTER_STATUS 0
	    set TCHANGE $t
	    puts stderr CLOSE
	    set T1(iobs0) 0
	    set T1(iobs1) 0.0
	    set T1(iobs2) 0.0
	    set T2(iobs0) 0
	    set T2(iobs1) 0.0
	    set T2(iobs2) 0.0
	    set T3(iobs0) 0
	    set T3(iobs1) 0.0
	    set T3(iobs2) 0.0
	    set T4(iobs0) 0
	    set T4(iobs1) 0.0
	    set T4(iobs2) 0.0
	    eval $T(CANVAS) delete [$T(CANVAS) find enclosed -1e99 -1e99 -50 1e99]
	}
    }
}

proc calcobs {&T &Tx t} {
    upvar ${&T}  T
    upvar ${&Tx} Tx

    if {$Tx(iobs0) != 0} {
	set Tx(iobs) [expr {$Tx(iobs1)/$Tx(iobs0)}]
	if {$Tx(iobs0) != 1} {
	    set Tx(iobsD) [expr {sqrt(($Tx(iobs2) - $Tx(iobs1)*$Tx(iobs1)/$Tx(iobs0))/($Tx(iobs0)-1))}]
	} else {
	    set Tx(iobsD) 0.0
	}
    }
    set x [interpole_log $T(xMIN) $T(xMAX) $T(tMIN) $T(tMAX) $t]
    set y [interpole_log $T(yMIN) $T(yMAX) $T(iMIN_log) $T(iMAX_log) [expr {abs($Tx(iobs))}]]
    $T(CANVAS) create text [list $x $y] -text [format %.4g $Tx(iobs)] -anchor se -fill $Tx(COLOR1) -tags ValT -font $T(font)
}


proc plotAgain {} {
    upvar \#0 _T T
    upvar \#0 _T1 T1
    upvar \#0 _T2 T2
    upvar \#0 _T3 T3
    upvar \#0 _T4 T4

    plotAll T T1 T2 T3 T4
    if {![info exists T(STOP)]} {
	after 0 plotAgain
    } else {
	unset T(STOP)
    }
}

proc stop {} {
    upvar \#0 _T T
    set T(STOP) {}
}

proc start {} {
    iniCanvas
    plotAgain
}

GPIB::main
ini0


# start

set rien {

    set _T1(COLOR0) \#ff0000
    set _T1(COLOR1) \#ff0000

    set _T2(COLOR0) \#00ff00
    set _T2(COLOR1) \#00ff00

    set _T3(COLOR0) \#0000ff
    set _T3(COLOR1) \#0000ff

    set _T4(COLOR0) \#000000
    set _T4(COLOR1) \#000000

}