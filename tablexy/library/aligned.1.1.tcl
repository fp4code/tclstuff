package provide aligned 1.1
package require isometrie 1.1

namespace eval aligned {
}

proc aligned::new {name} {
    upvar #0 $name machine
    set machine(iso) [::isometrie::new isoOf$name]
    return $name
}

proc aligned::moveTo {name x y} {
    upvar #0 $name machine
    set tcp [::isometrie::echToMec $machine(iso) $x $y]
    $machine(moveTo) $name [lindex $tcp 0] [lindex $tcp 1]
    set machine(xTheo) $x
    set machine(yTheo) $y
}

proc aligned::getPosition {name} {
    upvar #0 $name machine
    return [list $machine(xTheo) $machine(yTheo)]
}

proc aligned::corrigeIci {name} {
    upvar #0 $name machine

    puts stderr [list machine(iso) = $machine(iso)]
    puts stderr [list $machine(getPosition) $name = [$machine(getPosition) $name]]
    puts stderr [list getPosition $name = [getPosition $name]]

    ::isometrie::insertLast $machine(iso) \
            [$machine(getPosition) $name] \
            [getPosition $name]
}

proc aligned::corrigeIciTranslation {name} {
    upvar #0 $name machine
    ::isometrie::translateOnly $machine(iso) \
            [$machine(getPosition) $name] \
            [aligned::getPosition $name]
}

proc aligned::moveRel {name x y} {
    upvar #0 $name machine
    $machine(moveTo) $name [expr $machine(xTheo) + $x] [expr $machine(yTheo) + $y]
}

