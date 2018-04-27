package require smu 1.0

proc 2000:iniGlobals {} {
    global 2000SRQBitNames
    
    set 2000SRQBitNames(0) "Measurement Summary"
    set 2000SRQBitNames(1) "-"
    set 2000SRQBitNames(2) "Error"
    set 2000SRQBitNames(3) "Questionable Summary"
    set 2000SRQBitNames(4) "Message"
    set 2000SRQBitNames(5) "Event Summary"
    set 2000SRQBitNames(6) "SRQ"
    set 2000SRQBitNames(7) "Operation Summary"
}

proc 2000:write {name chaine} {
    upvar #0 $name arr
    GPIB::wrt $arr(gpibBoard) $arr(gpibAddr) $chaine
}

proc 2000:read {name {len 512}} {
    upvar #0 $name arr
    return [GPIB::rd $arr(gpibBoard) $arr(gpibAddr) $len]
}

proc 2000:pollEnClair {name spByte} {
    global 2000SRQBitNames

    set rep {}
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            lappend rep $2000SRQBitNames(0)
        }
        if {[isSet $spByte 1]} {
            lappend rep $2000SRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $2000SRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $2000SRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $2000SRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $2000SRQBitNames(5)
            lappend w [::smu::errors $name]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $2000SRQBitNames(7)
        }
    }
    return $rep
}

proc 2000:poll {name} {
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

