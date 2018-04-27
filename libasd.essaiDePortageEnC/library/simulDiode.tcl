#!/usr/local/bin/tclsh

proc Vdiode {coef_name i v} {
    upvar #0 $coef_name c
    set n 0
    set eps 1e-5
    set v_old -1e99
    while {abs($v_old-$v) > $v*$eps} {
        set v_old $v
        
        set v \
           [expr $c(nkT)*log( ($i-$v_old/$c(Rp)) /$c(I0) + 1) + $c(Rs)*$i]
#        puts "      $v"
        incr n
        if {$n > 20} {
            error "ne converge plus"
        }
    }
    puts -nonewline "[format %2d $n] cycles : "
    return $v
}

proc Idiode {coef_name i v} {
    upvar #0 $coef_name c
    set n 0
    set eps 1e-5
    set Idiode_old 1.
    while {abs($i-$Idiode_old) > $i*$eps} {
        set Idiode_old $i
        set i \
           [expr $c(I0)*(exp(($v-$c(Rs)*$Idiode_old)/$c(nkT))-1)+$v/$c(Rp)]
#        puts "        $i"
        incr n
        if {$n > 20} {
            error "ne converge plus"
        }
    }
    puts -nonewline "[format %2d $n] cycles : "
    return $i
}

proc simulDiode {coefName iemax iemin die dv} {

    set v 0.0
    set iexp {}
    set vexp {}
    for {set ie $iemax} {$ie>$iemin} {set ie [expr $ie-$die]} {
        set i [expr pow(10., $ie)]
        if {[catch {Vdiode $coefName $i $v} resul]} {
            break
        }
        set v $resul
        lappend iexp $i
        lappend vexp $v
    puts "[format %8.3e $i] [format %7.4f $v]"
    }

    puts $resul 

    set i [lindex $iexp end]
    for {} {$v >= 0} {set v [expr $v-$dv]} {
        lappend vexp $v
        if {[catch {Idiode $coefName $i $v} resul]} {
            break
        }
        set i $resul
        lappend iexp $i
    puts "[format %8.3e $i] [format %7.4f $v]"
    }
    return [list $i $v]
}


set coef(I0) 1e-9
set coef(nkT) 0.02586
set coef(Rs) 10
set coef(Rp) 1e7

simulDiode coef 1. -15. 0.1 0.01
