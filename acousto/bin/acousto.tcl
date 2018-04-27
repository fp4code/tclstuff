set PI [expr {4*atan(1)}]
set gp [open "|gnuplot" w]
fconfigure $gp -buffering line

set NU 16000.
set Feta 440.


proc pp {gp NU Feta Q c} {
    global PI

    set etalist [list]
    for {set it 0} {$it < 1.*$NU} {incr it} {
        lappend etalist [expr {sin($it*2*$PI*$Feta/$NU)}]
    }
    set NU [expr {double($NU)}]
    set Q [expr {double($Q)}]
    set Feta [expr {double($Feta)}]
    set c [expr {double($c)}]

    set F [expr {$Feta*(1+$c/[expr {1./(pow(2.,1./53.) - 1.)}])}]
    
    set Fact1 [expr {2*$PI*$F*sqrt(1 + 1./(4.*$Q*$Q))/$NU}]
    set Fact2 [expr {(2*$PI*$F)/($Q*$NU)*(1 + 1./(2.*$Q))/(1 + 1./(2.*$Q*$Q))}]
    set Fact3 [expr {exp(-$PI*$F/($Q*$NU))}]
    
    set repu [list 0.0]
    set repphi [list 0.0]
    
    foreach eta $etalist {
        set u0 [lindex $repu end]
        set phi0 [lindex $repphi end]
        set usf [expr {$u0*sin($phi0)}]
        set P [expr {$Fact2*$eta}]
        set x [expr {$u0*cos($phi0)}]
        set y [expr {$usf - $P}]
        if {$x == 0. && $y == 0.} {
            set phi1 $phi0
        } else {
            set phi1 [expr {atan2($y, $x)}] 
        }
        set u1 [expr {sqrt($u0*$u0 + $P*($P-2.*$usf))}]
        set u [expr {$Fact3*$u1}]
        set phi [expr {$phi1 + $Fact1}]
        lappend repu $u
        lappend repphi $phi
    }
    plot $gp $NU $repu $repphi
}

proc plot {gp NU repu repphi} {
    puts $gp {plot "-" with dots}
    set it 0
    foreach u $repu phi $repphi {
        # puts $gp "[expr {$it/double($NU)}] [expr {$u*cos($phi)}]"
        puts $gp "[expr {$it/double($NU)}] $u"
        incr it
    }
    puts $gp e
}

set Q [expr {1./(pow(2.,1./53.) - 1.)}]
pp $gp 44100 440 $Q 3
pp $gp 16000 440 10 3
