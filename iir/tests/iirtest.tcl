# 1 janvier 2003 (FP)

proc f2 {lignes} {
    # lignes issues de ellf

    set lignes [split $lignes \n]
    if {[lindex $lignes 0] != {z plane Denominator      Numerator}} {
	return -code error "Attendu \"z plane Denominator      Numerator\""
    }
    if {[lindex $lignes end] != {}} {
	return -code error "Attendu ligne vide, reçu \"[lindex $lignes end]\""
    }

    set num [list]
    set denom [list]
    set i 0

    foreach l [lrange $lignes 1 end-1] {
	if {[lindex $l 0] != $i} {
	    return -code error "attendu \"$i\""
	}
	lappend denom [lindex $l 1]
	lappend num [lindex $l 2]
	incr i
    }
    return [list $num $denom]
}

proc reponse {numdenom input} {
    set num [lindex $numdenom 0]
    set denom [lindex $numdenom 1]
    set denom0 [lindex $denom 0]
    set denom [lrange $denom 1 end]

    set output [list]
    
    for {set i 0} {$i < [llength $input]} {incr i} {
	set out [expr {0.0}]
	set ii $i
	foreach p $num {
	    set out [expr {$out + $p * [lindex $input $ii]}]
	    incr ii -1
	    if {$ii < 0} break
	}
	set ii $i
	foreach q $denom {
	    incr ii -1
	    if {$ii < 0} break
	    set out [expr {$out - $q * [lindex $output $ii]}]
	}
	set out [expr {$out/$denom0}]
	lappend output $out
    }
    return $output
}

proc sinus {fech f N} {
    set ret [list]
    set PHI [expr {2.0*acos(-1.0)*double($f)/double($fech)}]
    for {set i 0} {$i < $N} {incr i} {
	lappend ret [expr {sin($PHI*$i)}]
    }
    return $ret
}

proc temps {fech N} {
    set ret [list]
    set tau [expr {1.0/$fech}]
    for {set i 0} {$i < $N} {incr i} {
	lappend ret [expr {$i*$tau}]
    }
    return $ret
}

proc plot {args} {
    global g
    set N [llength $args]
    if {$N % 2 || $N == 0} {
	return -code error "Il faut un nombre pair et non nul d'arguments" 
    }
    foreach {xl yl} $args {
	if {[llength $xl] != [llength $yl]} {
	    return -code error "Il faut que les paires d'arguments aient même longueur" 
	}
    }
    set first 1
    for {set i $N} {$i > 0} {incr i -2} {
	if {$first} {
	    set first 0
	    puts -nonewline $g "plot"
	} else {
	    puts -nonewline $g ","
	}
	puts -nonewline $g " \"-\" with lines"
    }
    puts $g {}
    foreach {xl yl} $args {
	foreach x $xl y $yl {
	    puts $g "$x $y"
	}
	puts $g e
    }
    flush $g
}

proc compare {fech f numdenom N} {
    set t [temps $fech $N]
    set s [sinus $fech $f $N]
    plot $t $s $t [reponse $numdenom $s]
}

set g [open "|gnuplot" w]

puts INSTABLES:

set numdenom [f2 {z plane Denominator      Numerator
 0   1.0   8.905251790E-07
 1  -7.778507383E+00   0.000000000E+00
 2   2.652881262E+01  -3.562100716E-06
 3  -5.181357176E+01   0.000000000E+00
 4   6.338531747E+01   5.343151074E-06
 5  -4.973389373E+01   0.000000000E+00
 6   2.444197603E+01  -3.562100716E-06
 7  -6.879005381E+00   0.000000000E+00
 8   8.488721641E-01   8.905251790E-07
}]

set numdenom [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   1.571036346E-01
 1  -1.192617023E+01  -1.878050496E+00
 2   6.521539027E+01   1.029701259E+01
 3  -2.162129813E+02  -3.423993986E+01
 4   4.840426456E+02   7.690603046E+01
 5  -7.708844831E+02  -1.229213330E+02
 6   8.955464234E+02   1.433583534E+02
 7  -7.646446092E+02  -1.229213330E+02
 8   4.762382724E+02   7.690603046E+01
 9  -2.110050271E+02  -3.423993986E+01
10   6.312938320E+01   1.029701259E+01
11  -1.145125065E+01  -1.878050496E+00
12   9.524067339E-01   1.571036346E-01
}]

compare 44100 440 $numdenom 1000 
compare 44100 11025 $numdenom 200

f 2f 3f 4f 5f 6f 7f 8f

# Butterworth Band 2 900 1100

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   1.989714060E-04
 1  -3.919983054E+00   0.000000000E+00
 2   5.801656038E+00  -3.979428121E-04
 3  -3.841781366E+00   0.000000000E+00
 4   9.605029194E-01   1.989714060E-04
}]
compare 44100 500 $f2 400
compare 44100 900 $f2 400
compare 44100 950 $f2 400
compare 44100 1000 $f2 400
compare 44100 1050 $f2 400
compare 44100 1100 $f2 400
compare 44100 2000 $f2 400


# Butterworth Band 2 990 1010
# Lent à monter en régime

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   2.025853702E-06
 1  -3.955484918E+00   0.000000000E+00
 2   5.907439375E+00  -4.051707403E-06
 3  -3.947522976E+00   0.000000000E+00
 4   9.959782831E-01   2.025853702E-06
}]
compare 44100 500 $f2 400
compare 44100 900 $f2 400
compare 44100 950 $f2 2000
compare 44100 1000 $f2 5000
compare 44100 1050 $f2 2000
compare 44100 1100 $f2 400
compare 44100 2000 $f2 4000

# Butterworth Band 3 950 1050

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   3.564250120E-07
 1  -5.911148622E+00   0.000000000E+00
 2   1.461886227E+01  -1.069275036E-06
 3  -1.936035980E+01   0.000000000E+00
 4   1.448066180E+01   1.069275036E-06
 5  -5.799914255E+00   0.000000000E+00
 6   9.719067528E-01  -3.564250120E-07
}]
compare 44100 500 $f2 4000
compare 44100 900 $f2 4000
compare 44100 950 $f2 2000
compare 44100 1000 $f2 5000
compare 44100 1050 $f2 2000
compare 44100 1100 $f2 400
compare 44100 1500 $f2 4000
compare 44100 2000 $f2 4000

# Elliptic Band order3  0.5ripple 900/1100Hz -100dB

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   1.301520913E-05
 1  -5.903872145E+00  -4.348216422E-05
 2   1.458306228E+01   4.792312153E-05
 3  -1.928964675E+01   5.779913938E-21
 4   1.441055784E+01  -4.792312153E-05
 5  -5.765025906E+00   4.348216422E-05
 6   9.649326144E-01  -1.301520913E-05
}]
compare 44100 500 $f2 4000
compare 44100 900 $f2 4000
compare 44100 950 $f2 2000
compare 44100 1000 $f2 5000
compare 44100 1050 $f2 2000
compare 44100 1100 $f2 400
compare 44100 1500 $f2 4000
compare 44100 2000 $f2 4000


# Butterworth Low 5 70

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000E+00   3.034260343E-12
 1  -4.967725730E+00   1.517130171E-11
 2   9.871423121E+00   3.034260343E-11
 3  -9.807909808E+00   3.034260343E-11
 4   4.872453206E+00   1.517130171E-11
 5  -9.682407882E-01   3.034260343E-12
}]
compare 44100 66 $f2 1000
# INSTABLE C'est dû à un manque de précision dans l'affichage de ellf

set f2 [f2 {z plane Denominator      Numerator
 0   1.000000000000000E+00   3.034260342982265E-12
 1  -4.967725729871709E+00   1.517130171491132E-11
 2   9.871423120653825E+00   3.034260342982265E-11
 3  -9.807909808244787E+00   3.034260342982265E-11
 4   4.872453205762786E+00   1.517130171491132E-11
 5  -9.682407882030184E-01   3.034260342982265E-12
}]
compare 44100 66 $f2 10000

# Butterworth Low 6 70
set f2 [f2 {z plane Denominator      Numerator
 0   1.00000000000000000E+00   1.50521956010507552E-14
 1  -5.96146612047072377E+00   9.03131736063045309E-14
 2   1.48080723308374260E+01   2.25782934015761327E-13
 3  -1.96176190770375030E+01   3.01043912021015103E-13
 4   1.46190845241742959E+01   2.25782934015761327E-13
 5  -5.81027053785529368E+00   9.03131736063045309E-14
 6   9.62198880352762687E-01   1.50521956010507552E-14
}]
compare 44100 66 $f2 10000

# Butterworth Low 7 70
set f2 [f2 {z plane Denominator      Numerator
 0   1.00000000000000000E+00   1.08420217248550443E-16
 1  -6.95518037790590427E+00   7.58941520739853104E-16
 2   2.07320858711716056E+01   2.27682456221955931E-15
 3  -3.43327092476404445E+01   3.79470760369926552E-15
 4   3.41135859805877004E+01   3.79470760369926552E-15
 5  -2.03376554980605349E+01   2.27682456221955931E-15
 6   6.73604295650152007E+00   7.58941520739853104E-16
 7  -9.56169684653928598E-01   1.08420217248550443E-16
}]
compare 44100 132 $f2 10000

# Butterworth Low 8 70 INSTABLE !!!
set f2 [f2 {z plane Denominator      Numerator
 0   1.00000000000000000E+00  -8.23993651088983370E-18
 1  -7.94887852206600432E+00  -6.59194920871186696E-17
 2   2.76434554644332486E+01  -2.30718222304915344E-16
 3  -5.49342621971434184E+01  -4.61436444609830687E-16
 4   6.82302275445754702E+01  -5.76795555762288359E-16
 5  -5.42366492210831552E+01  -4.61436444609830687E-16
 6   2.69458213641309534E+01  -2.30718222304915344E-16
 7  -7.64987738973464637E+00  -6.59194920871186696E-17
 8   9.50162956887552590E-01  -8.23993651088983370E-18
}]
compare 44100 66 $f2 10000
