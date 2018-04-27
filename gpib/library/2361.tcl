package provide 2361 1.0

namespace eval 2361 {
    variable 2361SRQBitNames
    variable 2361Messages
}

proc ::2361::iniGlobals {} {
    variable 2361SRQBitNames
    variable 2361Messages

    # création des bits de SRQ

    set 2361SRQBitNames(0) DIGCHNG
    set 2361SRQBitNames(1) TRGCGRG
    set 2361SRQBitNames(2) {bit not used}
    set 2361SRQBitNames(3) {bit not used}
    set 2361SRQBitNames(4) Ready
    set 2361SRQBitNames(5) Error
    set 2361SRQBitNames(6) SRQ
    set 2361SRQBitNames(7) {bit not used}

    set 2361ErrorMessages(0) {Trigger Test Failed (TRGTEST)}
    set 2361ErrorMessages(1) {Digital I/O Test Failed (DIGTEST)}
    set 2361ErrorMessages(2) {ROM Test Failed (ROMTEST)}
    set 2361ErrorMessages(3) {RAM Test Failed (RAMTEST)}
    set 2361ErrorMessages(4) {bit not used}
    set 2361ErrorMessages(5) {bit not used}
    set 2361ErrorMessages(6) IDDCO
    set 2361ErrorMessages(7) IDDC

}


proc ::2361::ini {2361Name} {

    global GPIBAPP

    if {![info exists GPIBAPP(synchro)]} {
        puts {}
        puts "LA VARIABLE GPIBAPP(synchro) doit être mise typiquement à \"1*2*3\"\
                dans iv/valeursParDefaut/library/xxx.def.tcl.\
                On est tellement bon qu'on le fait pour vous..."
        puts {}
        set GPIBAPP(synchro) "1*2*3"
    }

    set lsync $GPIBAPP(synchro) ;# typiquement "1*2*3"
    puts "synchro sur $lsync"

    upvar #0 $2361Name deviceArray
    set addr $deviceArray(gpibAddr)
    set board $deviceArray(gpibBoard)
    GPIB::unt ; GPIB::unl ; GPIB::ren1
    GPIB::mla $addr
    GPIB::sdc
    GPIB::unt ; GPIB::unl
    $2361Name write "${lsync}>${lsync}X"
    puts stderr "A REVOIR : ::2361::ini : delai W4 pour que le vieu smu ne coince pas" 
    $2361Name write "W4X"
}

proc ::2361::write {2361Name chaine} {
    upvar #0 $2361Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) $chaine
}

proc ::2361::read {2361Name {len 512}} {
    upvar #0 $2361Name deviceArray
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::2361::serialPoll {2361Name} {
    upvar #0 $2361Name deviceArray
    return [GPIB::serialPoll $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::2361::fire {2361Name} {
    upvar #0 $2361Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) "P1P2P3X"
}

proc ::2361::poll {2361Name} {
    upvar #0 $2361Name deviceArray
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::spe
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    set spByte [::GPIBBoard::rdBin $deviceArray(gpibBoard) 1]
    GPIB::unt
    GPIB::unl
    GPIB::spd
    return [2361PollEnClair $2361Name $spByte]
}

proc 2361PollEnClair {2361Name spByte} {
    variable 2361SRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            set w $2361SRQBitNames(0)
            lappend w [::2361::warnings $2361Name]
            lappend rep $w
        }
        if {[isSet $spByte 1]} {
            lappend rep $2361SRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $2361SRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $2361SRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $2361SRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $2361SRQBitNames(5)
            lappend w [::2361::errors $2361Name]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $2361SRQBitNames(7)
        }
    }
    return $rep
}

proc ::2361::errors {2361Name} {
    upvar #0 $2361Name deviceArray
    global GPIB_boardAddress

    ::2361::write $2361Name XU1X
    GPIB::unt
    GPIB::unl
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    set spByte [::GPIBBoard::rdBin $deviceArray(gpibBoard) 1]
    GPIB::unt
    GPIB::unl
    return [::2361::errorEnClair $spByte]
}

proc ::2361::errorEnClair {spByte} {
    variable 2361ErrorMessages

    set rep [list]
    for {set i 0} {$i < 8} {incr i} {
        if {[isSet $spByte $i]} {
            lappend rep $2361ErrorMessages($i)
        }
    }
    return $rep
}
