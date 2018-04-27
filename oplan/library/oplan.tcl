# $Id 18 février 2003 essais

package require suninterval 0.1
package require scplxi 0.1
namespace eval oplan {}
fidev_load ../src/libtcloplan.0.1 Oplan
package provide oplan 0.1

set rien {
package require fidev
package require oplan


set di_pi [di atan2 -1 0]
set di_2pi [di mul $di_pi 2]

set lambda [di interval_d 4.0]
set kx0N [di interval_d 0.0]
set k0 [list xy [di div $di_2pi $lambda]  [di interval_d 0.0]]
set d1 [di interval_d 0.5]
set d2 [di interval_d 0.5]
set eps1 [list xy [di interval_d 1.0] [di interval_d 0.0]]
set eps2 [list xy [di interval_d -598.4] [di interval_d 127.920]]
set kappaz [scplxi xy_mul $k0 [list xy [di interval_d 1.05024890425] [di interval_d 10.00521994144639]]]
set kx0 [scplxi xy_scalmul $k0 $kx0N]

proc f {zx zy} {
    global k0 kx0 eps1 eps2 d1 d2
    set kappaz [scplxi xy_mul $k0 [list xy $zx $zy]]
    set func [oplan::modetm $k0 $kx0 $kappaz $eps1 $eps2 $d1 $d2]
    set x [lindex $func 1]
    set y [lindex $func 2]
    set xm [di mid $x]
    set ym [di mid $y]
    set xw [di wid $x]
    set yw [di wid $y]
    return [list $x $y]
} 

f 10 {10 10.1}

set log [open ~/Z/t2.log w]
puts $log "\#x y xm ym xw yw"

set zx 1.05024890425
set zx 10
for {set zy 10.0} {$zy < 10.1} {set zy [expr {$zy + 0.001}]} {
    set kappaz [scplxi xy_mul $k0 [list xy [di interval_d $zx] [di interval_d $zy]]]
    # puts stderr {}
    set func [oplan::modetm $k0 $kx0 $kappaz $eps1 $eps2 $d1 $d2]
    set x [lindex $func 1]
    set y [lindex $func 2]
    set xm [di mid $x]
    set ym [di mid $y]
    set xw [di wid $x]
    set yw [di wid $y]
    puts $log "$zx $zy $xm $ym $xw $yw"
}
close $log





canvas .c
pack .c



}
