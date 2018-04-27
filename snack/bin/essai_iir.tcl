# 26 octobre 2002 (FP)

# A LANCER INTERACTIVEMENT AVEC WISH
# penser à ouvrir le mixer.

package require snack
snack::sound s -rate 44100

s record
s stop 
s play

sound s2

set PI [expr {acos(-1.0)}]

# instable pour r > 0.55
proc f {f r} {

    global gloglo PI
    set fx [expr {cos(2*$PI*$f/double([s cget -rate]))}]
    set a0 [expr {(1.0-$r)*sqrt($r*($r - 4*$fx*$fx + 2.0) + 1.0)}]
    set b1 [expr {2*$r*$fx}]
    set b2 [expr {-$r*$r}]
    
    puts stderr "-numerator $a0 -denominator [list 1.0 $b1 $b2]"

    s2 filter [snack::filter iir -numerator $a0  -denominator [list 1.0 $b1 $b2]]
    puts "[s2 min] [s2 max]"

}

proc f2 {s lignes} {
    # lignes issues de ellf

    set lignes [split $lignes \n]
    if {[lindex $lignes 0] != {z plane Denominator      Numerator}} {
	return -code error "Attendu \"z plane Denominator      Numerator\""
    }

    set num [list]
    set denom [list]
    set i 0

    foreach l [lrange $lignes 1 end] {
	if {[lindex $l 0] != $i} {
	    return -code error "attendu \"$i\""
	}
	lappend denom [lindex $l 1]
	lappend num [lindex $l 2]
	incr i
    }

    puts stderr "snack::filter iir  -numerator $num -denominator $denom"

    s2 copy $s
    s2 filter  [snack::filter iir  -numerator $num -denominator $denom] -continuedrain 0
    s2 play
}

set g [open "|/usr/bin/gnuplot" w]

proc ps {s args} {
    global g
    puts $g "plot \"-\" with lines"
    if {$args == {}} {
	set n [$s length]
    } else {
	set n $args
    }
    for {set i 0} {$i < $n} {incr i} {
	puts $g [$s sample $i]
    }
    puts $g e
    flush $g
}

proc pl {l args} {
    global g
    puts $g "plot \"-\" with lines"
    if {$args == {}} {
	set n [llength $l]
    } else {
	set n $args
    }
    for {set i 0} {$i < $n} {incr i} {
	puts $g [lindex $l $i]
    }
    puts $g e
    flush $g
}

sound sc -rate 44100
sc length 2001
sc filter [snack::filter generator 440 1000 0.5 rectangular] -continuedrain 0
sc play
f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   1.422732485E-03
 1  -1.993233476E+00   0.000000000E+00
 2   9.971545350E-01  -1.422732485E-03} ;# instable >


f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   4.426474124E-04
 1  -3.942009086E+00   0.000000000E+00
 2   5.834691073E+00  -8.852948248E-04
 3  -3.843167245E+00   0.000000000E+00
4   9.504961902E-01   4.426474124E-04}

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   1.453877383E-03
 1  -1.889284249E+00   2.907754765E-03
2   8.950997587E-01   1.453877383E-03}

set diverge {
1 Butterworth
1 low pass
Order of filter 2
Sampling frequency = 4.410000000E+04 ? 
Passband edge = 7.000000000E+02 ? 
s plane poles:
-7.071067812E-01 7.071067812E-01
s plane zeros:
adding zero at Nyquist frequency
adding zero at Nyquist frequency
order = 2
constant gain factor     2.3211887895738E-03
z plane Denominator      Numerator
 0   1.000000000E+00   2.321188790E-03
 1  -1.859166732E+00   4.642377579E-03
 2   8.684514871E-01   2.321188790E-03
poles and zeros with corresponding quadratic factors


pole      9.2958336597544E-01     6.5774256445411E-02
q. f.
z**2     8.6845148710918E-01
z**1    -1.8591667319509E+00
f0   4.95796122E+02  gain   9.6405E+01  DC gain   1.0770E+02

zero     -1.0000000000000E+00     0.0000000000000E+00
q. f.
z**2     0.0000000000000E+00
z**1     1.0000000000000E+00
f0   2.20500000E+04  gain   0.0000E+00  DC gain   2.0000E+00

zero     -1.0000000000000E+00     0.0000000000000E+00
q. f.
z**2     0.0000000000000E+00
z**1     1.0000000000000E+00
f0   2.20500000E+04  gain   0.0000E+00  DC gain   2.0000E+00
}


# POURTANT NE DIVERGE PAS :

set sample 44100.
set x {}
for {set i 0} {$i < 2001} {incr i} {
    if {int(floor($i*440./$sample*2.)) % 2} {
	lappend x 1000
    } else {
	lappend x -1000
    }
}

pl $x

proc y {x numer denom} {
    set y [list]
    
    for {set i 0} {$i < [llength $x]} {incr i} {
	set yn  0.0
	set j $i
	foreach n $numer {
	    set yn [expr {$yn + double($n)*double([lindex $x $j])}]
	    puts stderr "+=double($n)*double([lindex $x $j]) -> $yn"
	    incr j -1
	    if {$j < 0} break
	}
	set j $i
	foreach d [lrange $denom 1 end] {
	    incr j -1
	    if {$j < 0} break
	    set yn [expr {$yn - double($d)*double([lindex $y $j])}]
	    puts stderr "-=double($d)*double([lindex $y $j]) -> $yn"
    
	}
	set yn [expr {$yn/double([lindex $denom 0])}]
	lappend y $yn
	puts stderr "........... -> $yn"
    }
    return $y
}

pl [y $x {2.321188790E-03 4.642377579E-03 2.321188790E-03} {1.000000000E+00 -1.859166732E+00 8.684514871E-01}]

# NE COLLE PAS :

package require snack

proc f2 {s lignes} {
    # lignes issues de ellf

    set lignes [split $lignes \n]
    if {[lindex $lignes 0] != {z plane Denominator      Numerator}} {
	return -code error "Attendu \"z plane Denominator      Numerator\""
    }

    set num [list]
    set denom [list]
    set i 0

    foreach l [lrange $lignes 1 end] {
	if {[lindex $l 0] != $i} {
	    return -code error "attendu \"$i\""
	}
	lappend denom [lindex $l 1]
	lappend num [lindex $l 2]
	incr i
    }

    puts stderr "snack::filter iir  -numerator $num -denominator $denom"

    s2 copy $s
    s2 filter  [snack::filter iir  -numerator $num -denominator $denom] -continuedrain 0
    s2 play
}

sound sc -rate 44100
sc length 2001
sc filter [snack::filter generator 440 1000 0.5 rectangular] -continuedrain 0
sc play
sound s2

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   2.321188790E-03
 1  -1.859166732E+00   4.642377579E-03
 2   8.684514871E-01   2.321188790E-03}



#######iirFlowProc est bogué dans snack2.2b1

# réparé le 31 décembre 2002 (FP)

package require snack 2.2
sound sc -rate 44100
sc record ;# monter une gamme
sc stop 

# elff band stop 400-500
f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00  -5.766509434E-01
 1  -1.589464900E+01   9.207692072E+00
 2   1.184572404E+02  -6.893625685E+01
 3  -5.494600874E+02   3.212239226E+02
 4   1.775438135E+03  -1.042707069E+03
 5  -4.237610402E+03   2.500127990E+03
 6   7.728315787E+03  -4.580468656E+03
 7  -1.098569003E+04   6.540871744E+03
 8   1.230094526E+04  -7.357485433E+03
 9  -1.088585840E+04   6.540871744E+03
10   7.588493056E+03  -4.580468656E+03
11  -4.123130219E+03   2.500127990E+03
12   1.711775932E+03  -1.042707069E+03
13  -5.249438767E+02   3.212239226E+02
14   1.121433929E+02  -6.893625685E+01
15  -1.491071213E+01   9.207692072E+00
    16   9.295715325E-01  -5.766509434E-01}
f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   9.858533169E-01
 1  -5.959387186E+00  -5.903116439E+00
 2   1.480973695E+01   1.473983462E+01
 3  -1.964474339E+01  -1.964514293E+01
 4   1.466973202E+01   1.473983462E+01
 5  -5.847245079E+00  -5.903116439E+00
    6   9.719067528E-01   9.858533169E-01}

sc length 2001
sc filter [snack::filter generator 440 1000 0.5 rectangular] -continuedrain 0

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   9.405043312E-04
 1  -1.911398195E+00   1.881008662E-03
    2   9.151602127E-01   9.405043312E-04}

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   6.802149075E-06
 1  -2.945101041E+00   2.040644723E-05
 2   2.893013685E+00   2.040644723E-05
    3  -9.478582268E-01   6.802149075E-06}


f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   2.025853693E-06
 1  -3.988124801E+00   0.000000000E+00
 2   5.972259065E+00  -4.051707387E-06
 3  -3.980097159E+00   0.000000000E+00
    4   9.959782831E-01   2.025853693E-06}


 0   1.000000000E+00   2.883947590E-09
 1  -5.982532221E+00   0.000000000E+00
 2   1.492453694E+01  -8.651842770E-09
 3  -1.987268829E+01   0.000000000E+00
 4   1.489621202E+01   8.651842770E-09
 5  -5.959845563E+00   0.000000000E+00
    6   9.943171725E-01  -2.883947590E-09}

 0   1.000000000E+00   9.129964854E-04
 1  -7.980885853E+00  -7.288372906E-03
 2   2.788204743E+01   2.547040229E-02
 3  -5.569345608E+01  -5.089419654E-02
 4   6.956766746E+01   6.359834134E-02
 5  -5.564605179E+01  -5.089419654E-02
 6   2.783460321E+01   2.547040229E-02
 7  -7.960524056E+00  -7.288372906E-03
    8   9.965996872E-01   9.129964854E-04}

###########################
demos/tcl/xs.tcl
-> ~/Z/la.wav

package require snack 2.2
sound sc
sc read ~/Z/la.wav
sc play

# Butterworth Low 3 450

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   3.092919481E-05
 1  -2.871793611E+00   9.278758444E-05
 2   2.751674262E+00   9.278758444E-05
    3  -8.796332176E-01   3.092919481E-05}

s2 write ~/Z/lapur.wav

# Butterworth Pass 3 600 1100

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   4.213570170E-05
 1  -5.818342807E+00   0.000000000E+00
 2   1.414508410E+01  -1.264071051E-04
 3  -1.839171245E+01   0.000000000E+00
 4   1.348875443E+01   1.264071051E-04
 5  -5.290963367E+00   0.000000000E+00
 6   8.671823317E-01  -4.213570170E-05}

s2 write ~/Z/laH2.wav
# Pas très filtré

# Butterworth Pass 3 860 900

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   4.213570170E-05
 1  -5.818342807E+00   0.000000000E+00
 2   1.414508410E+01  -1.264071051E-04
 3  -1.839171245E+01   0.000000000E+00
 4   1.348875443E+01   1.264071051E-04
 5  -5.290963367E+00   0.000000000E+00
    6   8.671823317E-01  -4.213570170E-05}

s2 write ~/Z/laH2.wav

# Butterworth Pass 6 660 1100

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   1.284388942E-09
 1  -1.167123330E+01   0.000000000E+00
 2   6.251980944E+01  -7.706333655E-09
 3  -2.032521774E+02   0.000000000E+00
 4   4.466378870E+02   1.926583414E-08
 5  -6.988939727E+02   0.000000000E+00
 6   7.985298085E+02  -2.568777885E-08
 7  -6.712349219E+02   0.000000000E+00
 8   4.119857993E+02   1.926583414E-08
 9  -1.800635113E+02   0.000000000E+00
10   5.319521371E+01  -7.706333655E-09
11  -9.537550680E+00   0.000000000E+00
    12   7.848493751E-01   1.284388942E-09}

s2 write ~/Z/laH2b.wav

# Instable !

# Butterworth Pass 4 660 1100

f2 sc {z plane Denominator      Numerator
 0   0.99   8.905251790E-07
 1  -7.778507383E+00   0.000000000E+00
 2   2.652881262E+01  -3.562100716E-06
 3  -5.181357176E+01   0.000000000E+00
 4   6.338531747E+01   5.343151074E-06
 5  -4.973389373E+01   0.000000000E+00
 6   2.444197603E+01  -3.562100716E-06
 7  -6.879005381E+00   0.000000000E+00
8   8.488721641E-01   8.905251790E-07}
s2 write ~/Z/laH2b.wav
