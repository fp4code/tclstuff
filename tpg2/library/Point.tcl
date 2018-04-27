#
# Points
#

set HELP(tpg::Point) {
    Un Point est une liste de deux entiers
}

snit::type tpg::Point {
    typevariable x [expr {double(0.0)}]
    typevariable y [expr {double(0.0)}]
    
    constructor {xx yy} {
	typevariable x $xx
	typevariable y $yy	
    }

    method miroir.axex {} {
	typevariable y  [expr -$y]
    }

}
