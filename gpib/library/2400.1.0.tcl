# package require smu 1.0
package provide 2400 1.0

namespace eval 2400 {}

proc 2400::iniGlobals {} {
    global 2400SRQBitNames
    
    set 2400SRQBitNames(0) "Measurement Summary"
    set 2400SRQBitNames(1) "-"
    set 2400SRQBitNames(2) "Error"
    set 2400SRQBitNames(3) "Questionable Summary"
    set 2400SRQBitNames(4) "Message"
    set 2400SRQBitNames(5) "Event Summary"
    set 2400SRQBitNames(6) "SRQ"
    set 2400SRQBitNames(7) "Operation Summary"
}

proc 2400::write {name chaine} {
    upvar #0 $name arr
    GPIB::wrt $arr(gpibBoard) $arr(gpibAddr) $chaine
}

proc 2400::read {name {len 512}} {
    upvar #0 $name arr
    return [GPIB::rd $arr(gpibBoard) $arr(gpibAddr) $len]
}

proc 2400::pollEnClair {name spByte} {
    global 2400SRQBitNames

    set rep {}
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            lappend rep $2400SRQBitNames(0)
        }
        if {[isSet $spByte 1]} {
            lappend rep $2400SRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $2400SRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $2400SRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $2400SRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $2400SRQBitNames(5)
            lappend w [::smu::errors $name]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $2400SRQBitNames(7)
        }
    }
    return $rep
}

proc 2400::poll {name} {
    upvar #0 $name arr
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::spe
    GPIB::mta $arr(gpibAddr)
    GPIB::mla $GPIB_boardAddress($arr(gpibBoard))
    set spByte [::GPIBBoard::rdBin $arr(gpibBoard) 1]
    GPIB::unt
    GPIB::unl
    GPIB::spd
    return [smuPollEnClair $name $spByte]
}

