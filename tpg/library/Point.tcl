#
# Points
#
set HELP(tpg::Point) {
    Un Point est une liste de deux entiers
}

namespace eval tpg::Point {

    proc identite {x y} {
        return [list $x $y]
    }

    proc miroir.axex {x y} {
        return [list $x [expr -$y]]
    }

    proc miroir.axey {x y} {
        return [list [expr -$x] $y]
    }

    proc rotation90 {x y} {
        return [list [expr -$y] $x]
    }

    proc rotation180 {x y} {
        return [list [expr -$x] [expr -$y]]
    }

    proc rotation270 {x y} {
        return [list $y [expr -$x]]
    }

    proc rotation {x y degres} {
        set s [expr sin(0.0174532925199432953*$degres)]
        set c [expr cos(0.0174532925199432953*$degres)]
        return [list [expr round($x*$c - $y*$s)] [expr round($x*$s + $y*$c)]]
    }
}
