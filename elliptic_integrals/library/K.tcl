namespace eval elliptic_integral {}

set HELP(::elliptic_integral::K) {
    retourne K($x) avec une précision de 3e-5
    pour 0<=$x<1
}
proc ::elliptic_integral::K_AS1 {m} {
    if {$m < 0 || $m >= 1} {
	error "Bad Range"
    }
    set m1 [expr {(1.0 - $m)}]
    return [expr {(.0725296*$m1 + .1119723)*$m1 + 1.3862944 - ((0.0288729*$m1 + 0.1213478)*$m1 + .5)*log($m1)}]
}
proc ::elliptic_integral::K_ACM55 {x} {
    if {$x < 0 || $x >= 1} {
	error "Bad Range"
    }
    set t [expr {(1.0 - $x*$x)}]
    return [expr {(((0.032024666*$t + 0.054555509)*$t + 0.097932891)*$t + 1.3862944)\
	    -(((0.010944912*$t + 0.060118519)*$t + 0.12475074)*$t + 0.5)*log($t)}]
}

for {set i 0} {$i < 100} {incr i} {
    set m [expr {(0.01*$i)}]
    set x [expr {sqrt($m)}]
    puts "[format %.2f $m] [format %.8f $x] [::elliptic_integral::K_ACM55 $x] [::elliptic_integral::K_AS1 $m] [expr {([::elliptic_integral::K_ACM55 $x] - [::elliptic_integral::K_AS1 $m])/3e-5}]"
}

for {set i 1} {$i < 100} {incr i} {
    set x [expr {(0.99+0.0001*$i)}]
    puts "[format %.5f $x] [expr {377.*  [::elliptic_integral::K_ACM55 [expr {sqrt(1.0 - $x*$x)}]]/[::elliptic_integral::K_ACM55 $x] }]"
}
