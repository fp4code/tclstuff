package provide 37xxx 0.1

namespace eval 37xxx {
    variable 37xxx
}

proc ::37xxx::iniGlobals {} {
}


#############################################################################################################################
# Il est très important pour "GPIB::newGPIB" que le premier argument soit "37xxx" et que les procédures soient ::37xxx::... #
#############################################################################################################################


proc ::37xxx::write {37xxxName chaine} {
    upvar #0 $37xxxName deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) $chaine
}

proc ::37xxx::read {37xxxName {len 512}} {
    upvar #0 $37xxxName deviceArray
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::37xxx::readBin {37xxxName {len 512}} {
    upvar #0 $37xxxName deviceArray
    return [GPIB::rdBin $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::37xxx::serialPoll {37xxxName} {
    upvar #0 $37xxxName deviceArray
    return [GPIB::serialPoll $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::37xxx::poll {37xxxName} {
    upvar #0 $37xxxName deviceArray
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::spe
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    set spByte [::GPIBBoard::rdBin $deviceArray(gpibBoard) 1]
    puts stderr "spByte = $spByte"
    GPIB::unt
    GPIB::unl
    GPIB::spd
    return [::37xxx::pollEnClair $37xxxName $spByte]
}


# qqchose à lire
proc ::37xxx::waitMAV {37xxxName} {
    set again true
    while {$again} {
        GPIB::srqWait
        set poll [::37xxx::serialPoll $37xxxName]
        if {$poll & 16} {       ;# qqchose à lire
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "::37xxx::wait : $37xxxName : Error : [::37xxx::getErrors $37xxxName]"
            }
        }
    }
}

proc ::37xxx::DCL {37xxxName} {
    upvar #0 $37xxxName deviceArray
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    GPIB::Command DCL
    GPIB::unt
    GPIB::unl
}

proc ::37xxx::pollEnClair {_37xxxName spByte} {
    variable 37xxxSRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            set w $37xxxSRQBitNames(0)
#            lappend w [::37xxx::warnings $_37xxxName]
            lappend rep $w
        }
        if {[isSet $spByte 1]} {
            lappend rep $37xxxSRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $37xxxSRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $37xxxSRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $37xxxSRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $37xxxSRQBitNames(5)
            lappend w [::37xxx::getErrors $_37xxxName]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $37xxxSRQBitNames(7)
        }
    }
    return $rep
}

proc ::37xxx::getErrors {37xxxName} {
    upvar #0 $37xxxName deviceArray
    global GPIB_boardAddress

    ::37xxx::write $37xxxName "*ESR?"
    set rep [::37xxx::readBin $37xxxName]
    if {[llength $rep] != 2} {
	return -code error "Attendu deux octets, reçu [llength $rep]"
    }
    if {[lindex $rep 1] != 10} {
	return -code error "Attendu octets \"xx 10\", reçu \"$rep\""
    }
    set r1 [::37xxx::errorStatusEnClair [lindex $rep 0]]
    set r2 [::37xxx::errorsEnClair [::37xxx::getErrorRegister $37xxxName]]
    set rep [list $r1 $r2]
}

proc ::37xxx::errorsEnClair {list} {
    variable 37xxxErrorMessages

    set ret [list]
    foreach i $list {
	if {$i == 0} continue
	if {[info exists 37xxxErrorMessages($i)]} {
	    lappend ret "$i - $37xxxErrorMessages($i)"
	} else {
	    lappend ret $i
	}
    }
    return $ret
}

proc ::37xxx::errorStatusEnClair {spByte} {
    variable 37xxxErrorStatus

    set rep [list]
    for {set i 0} {$i < 8} {incr i} {
        if {[isSet $spByte $i]} {
            lappend rep $37xxxErrorStatus($i)
        }
    }
    return $rep
}
