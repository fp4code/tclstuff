#
# Points
#

namespace eval tpg::Point {

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
        set s [expr sin(0.017453293*$degres)]
        set c [expr cos(0.017453293*$degres)]
        return [list [expr round($x*$c - $y*$s)] [expr round($x*$s + $y*$c)]]
    }
}
