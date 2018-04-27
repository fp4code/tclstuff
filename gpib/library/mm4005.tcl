package provide mm4005 1.0

namespace eval mm4005 {}

set info {
    

}

proc ::mm4005::write {mm4005Name chaine} {
    upvar #0 $mm4005Name deviceArray
    GPIB:wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) $chaine
}

proc ::mm4005::read {mm4005Name {len 512}} {
    upvar #0 $mm4005Name deviceArray
    return [GPIB:rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::mm4005::serialPoll {mm4005Name} {
    upvar #0 $mm4005Name deviceArray
    return [GPIB:serialPoll $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc mm4005::createIfNonExistent {} {
    global GPIB_board mm4005
    if {![info exists mm4005]} {
        newGPIB mm4005 mm $GPIB_board 20

        set rien {
            set mm4005(classe) mm4005
            set mm4005(board) $board
            #    set mm4005(name) $nickname
            set mm4005(gpibAddr) $addr
            global gpibNames
            set gpibNames($board,$addr) $name 
        }
        set mm4005(inverseY) -1
        set mm4005(moveTo) mm4005_moveTo
        set mm4005(moveToRaw) mm4005_moveToRaw
        set mm4005(manual) mm4005_manual
        set mm4005(getPosition) unAlignedMM4005:getPosition
        ::aligned::new mm4005
        mm4005::ini $mm4005
    }
}
