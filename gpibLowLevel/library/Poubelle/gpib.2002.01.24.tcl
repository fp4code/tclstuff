
proc gpib_ui {} {
    if {[winfo exists .gpib]} {
        wm deiconify .gpib
        raise .gpib
    } else {
        toplevel .gpib
        gpib_lowlev_ui .gpib
        frame .gpib.frame_low_level
        low_level_ui .gpib.frame_low_level

        frame .gpib.frame_device_level
        device_level_ui .gpib.frame_device_level
    }
    GPIB_traceOff
    GPIB_lowLevel
    aide::nondocumente .gpib
}

proc GPIB_lowLevel {} {
    grid remove .gpib.frame_device_level
    grid .gpib.frame_low_level -in .gpib -row 3 -column 1
    .gpib.button_device_level configure -relief raised
    .gpib.button_low_level configure -relief sunken
}

proc GPIB_deviceLevel {} {
    grid remove .gpib.frame_low_level
    grid .gpib.frame_device_level -in .gpib -row 3 -column 1
    .gpib.button_device_level configure -relief sunken
    .gpib.button_low_level configure -relief raised
}

proc GPIB_renOff {} {
    global GPIB_board
    if {[winfo exists .gpib]} {
        .gpib.button_REN_On configure -relief raised
        .gpib.button_REN_Off configure -relief sunken
    }
    ::GPIBBoard::sre $GPIB_board false
}

proc GPIB_renOn {} {
    global GPIB_board
    if {[winfo exists .gpib]} {
        .gpib.button_REN_On configure -relief sunken
        .gpib.button_REN_Off configure -relief raised
    }
    ::GPIBBoard::sre $GPIB_board true
}

proc GPIB_traceOff {} {
    global GPIB_board
    if {[winfo exists .gpib]} {
        .gpib.button_trace_On configure -relief raised
        .gpib.button_trace_Off configure -relief sunken
    }
    ::GPIBBoard::TRACE_ON false
}

proc GPIB_traceOn {} {
    global GPIB_board
    if {[winfo exists .gpib]} {
        .gpib.button_trace_On configure -relief sunken
        .gpib.button_trace_Off configure -relief raised
    }
    ::GPIBBoard::TRACE_ON true
}

proc GPIB_IFC {} {
    global GPIB_board
    ::GPIBBoard::sic $GPIB_board
}

proc GPIB_read_Byte {} {
    global GPIB_board
    set rep [::GPIBBoard::rd $GPIB_board 1]
    .gpib.text_fromGPIB insert end "$rep\n"
    .gpib.text_fromGPIB see end
}

proc GPIB_readLine {} {
    global GPIB_board
    set rep [::GPIBBoard::rd $GPIB_board 512]
    set len [string length $rep]
    if {$len == 0} {
        .gpib.text_fromGPIB insert end "0 caractère\n"
    } else {
        if {$len == 1} {
            .gpib.text_fromGPIB insert end "1 caractère : "
        } else {
            .gpib.text_fromGPIB insert end "$len caractères : "
        }
        .gpib.text_fromGPIB insert end "$rep\n"
    }
    .gpib.text_fromGPIB see end
}


proc ini_GPIB_ARRAYS {} {
    global GPIB_Commands
    set GPIB_Commands(GTL) 0x01
    set GPIB_Commands(SDC) 0x04
    set GPIB_Commands(GET) 0x08
    set GPIB_Commands(TCT) 0x09
    set GPIB_Commands(LLO) 0x11
    set GPIB_Commands(DCL) 0x14
    set GPIB_Commands(SPE) 0x18
    set GPIB_Commands(SPD) 0x19
    set GPIB_Commands(MLA) 0x20
    set GPIB_Commands(UNL) 0x3f
    set GPIB_Commands(MTA) 0x40
    set GPIB_Commands(UNT) 0x5f
    
    global ConfigParam
    set ConfigParam(PAD)             0x01
    set ConfigParam(SAD)             0x02
    set ConfigParam(TMO)             0x03
    set ConfigParam(EOT)             0x04
    set ConfigParam(PPC)             0x05
    set ConfigParam(READDR)          0x06
    set ConfigParam(AUTOPOLL)        0x07
    set ConfigParam(CICPROT)         0x08
    set ConfigParam(IRQ)             0x09
    set ConfigParam(SC)              0x0a
    set ConfigParam(SRE)             0x0b
    set ConfigParam(EOSrd)           0x0c
    set ConfigParam(EOSwrt)          0x0d
    set ConfigParam(EOScmp)          0x0e
    set ConfigParam(EOSchar)         0x0f
    set ConfigParam(PP2)             0x10
    set ConfigParam(TIMING)          0x11
    set ConfigParam(DMA)             0x12
    set ConfigParam(ReadAdjust)      0x13
    set ConfigParam(WriteAdjust)     0x14
    set ConfigParam(SendLLO)         0x17
    set ConfigParam(SPollTime)       0x18
    set ConfigParam(PPollTime)       0x19
    set ConfigParam(EndBitsIsNormal) 0x1a
    set ConfigParam(UnAddr)          0x1b
    set ConfigParam(SignalNumber)    0x1c
    set ConfigParam(HSCableLength)   0x1f
    set ConfigParam(BNA)             0x200
    set ConfigParam(BaseAddr)        0x201
    set ConfigParam(DmaChannel)      0x202
    set ConfigParam(IRQLevel)        0x203
    
    global Signal
     set Signal(HUP)	1	;# /* hangup */
     set Signal(INT)	2	;# /* interrupt (rubout) */
     set Signal(QUIT)	3	;# /* quit (ASCII FS) */
     set Signal(ILL)	4	;# /* illegal instruction (not reset when caught) */
     set Signal(TRAP)	5	;# /* trace trap (not reset when caught) */
     set Signal(IOT)	6	;# /* IOT instruction */
     set Signal(ABRT) 6	;# /* used by abort, replace SIGIOT in the future */
     set Signal(EMT)	7	;# /* EMT instruction */
     set Signal(FPE)	8	;# /* floating point exception */
     set Signal(KILL)	9	;# /* kill (cannot be caught or ignored) */
     set Signal(BUS)	10	;# /* bus error */
     set Signal(SEGV)	11	;# /* segmentation violation */
     set Signal(SYS)	12	;# /* bad argument to system call */
     set Signal(PIPE)	13	;# /* write on a pipe with no one to read it */
     set Signal(ALRM)	14	;# /* alarm clock */
     set Signal(TERM)	15	;# /* software termination signal from kill */
     set Signal(USR1)	16	;# /* user defined signal 1 */
     set Signal(USR2)	17	;# /* user defined signal 2 */
     set Signal(CLD)	18	;# /* child status change */
     set Signal(CHLD)	18	;# /* child status change alias (POSIX) */
     set Signal(PWR)	19	;# /* power-fail restart */
     set Signal(WINCH) 20	;# /* window size change */
     set Signal(URG)	21	;# /* urgent socket condition */
     set Signal(POLL) 22	;# /* pollable event occured */
     set Signal(IO)	SIGPOLL	;# /* socket I/O possible (SIGPOLL alias) */
     set Signal(STOP) 23	;# /* stop (cannot be caught or ignored) */
     set Signal(TSTP) 24	;# /* user stop requested from tty */
     set Signal(CONT) 25	;# /* stopped process has been continued */
     set Signal(TTIN) 26	;# /* background tty read attempted */
     set Signal(TTOU) 27	;# /* background tty write attempted */
     set Signal(VTALRM) 28	;# /* virtual timer expired */
     set Signal(PROF) 29	;# /* profiling timer expired */
     set Signal(XCPU) 30	;# /* exceeded cpu limit */
     set Signal(XFSZ) 31	;# /* exceeded file size limit */
     set Signal(WAITING) 32	;# /* process's lwps are blocked */
     set Signal(LWP)	33	;# /* special signal used by thread library */
     set Signal(FREEZE) 34	;# /* special signal used by CPR */
     set Signal(THAW) 35	;# /* special signal used by CPR */
     set Signal(CANCEL) 36	;# /* thread cancellation signal used by libthread */
    
    global Lines
    set Lines(DAV) 0
    set Lines(NDAC) 1
    set Lines(NRFD) 2
    set Lines(IFC) 3
    set Lines(REN) 4
    set Lines(SRQ) 5
    set Lines(ATN) 6
    set Lines(EOI) 7

    global NI488_ErrorValues
    
    set NI488_ErrorValues(EDVR) 0
    set NI488_ErrorValues(ECIC) 1
    set NI488_ErrorValues(ENOL) 2
    set NI488_ErrorValues(EADR) 3
    set NI488_ErrorValues(EARG) 4
    set NI488_ErrorValues(ESAC) 5
    set NI488_ErrorValues(EABO) 6
    set NI488_ErrorValues(ENEB) 7
    set NI488_ErrorValues(EDMA) 8
    set NI488_ErrorValues(EBTO) 9
    set NI488_ErrorValues(EOIP) 10
    set NI488_ErrorValues(ECAP) 11
    set NI488_ErrorValues(EFSO) 12
    set NI488_ErrorValues(EOWN) 13
    set NI488_ErrorValues(EBUS) 14
    set NI488_ErrorValues(ESTB) 15
    set NI488_ErrorValues(ESRQ) 16
    set NI488_ErrorValues(ETAB) 20
    set NI488_ErrorValues(ELCK) 21

    global NI488_ErrorExplication
     
    set NI488_ErrorExplication($NI488_ErrorValues(EDVR)) "EDVR : System error"
    set NI488_ErrorExplication($NI488_ErrorValues(ECIC)) "ECIC : Function requires GPIB board to be Controller-In-Charge"
#    set NI488_ErrorExplication($NI488_ErrorValues(ECIC)) "ECIC : Not CIC (or lost CIC during command)"
    set NI488_ErrorExplication($NI488_ErrorValues(ENOL)) "ENOL : Function detected no Listeners"
#    set NI488_ErrorExplication($NI488_ErrorValues(ENOL)) "ENOL : Write detected no listeners"
    set NI488_ErrorExplication($NI488_ErrorValues(EADR)) "EADR : GPIB board is not addressed corectly"
#    set NI488_ErrorExplication($NI488_ErrorValues(EADR)) "EADR : Board not addressed correctly"
    set NI488_ErrorExplication($NI488_ErrorValues(EARG)) "EARG : Invalid argument to function call"
#    set NI488_ErrorExplication($NI488_ErrorValues(EARG)) "EARG : Bad argument to function call"
    set NI488_ErrorExplication($NI488_ErrorValues(ESAC)) "ESAC : Function requires board to be SAC"
    set NI488_ErrorExplication($NI488_ErrorValues(EABO)) "EABO : Asynchronous operation was aborted"
    set NI488_ErrorExplication($NI488_ErrorValues(ENEB)) "ENEB : GPIB interface offline"
    set NI488_ErrorExplication($NI488_ErrorValues(EDMA)) "EDMA : DMA hardware error detected"
    set NI488_ErrorExplication($NI488_ErrorValues(EBTO)) "EBTO : DMA hardware uP bus timeout"
    set NI488_ErrorExplication($NI488_ErrorValues(EOIP)) "EOIP : New I/O attempted with old I/O in progress"
    set NI488_ErrorExplication($NI488_ErrorValues(ECAP)) "ECAP : No capability for intended opeation"
    set NI488_ErrorExplication($NI488_ErrorValues(EFSO)) "EFSO : File system operation error"
    set NI488_ErrorExplication($NI488_ErrorValues(EOWN)) "EOWN : Shareable board exclusively owned"
    set NI488_ErrorExplication($NI488_ErrorValues(EBUS)) "EBUS : Bus error"
    set NI488_ErrorExplication($NI488_ErrorValues(ESTB)) "ESTB : Serial poll queue overflow"
    set NI488_ErrorExplication($NI488_ErrorValues(ESRQ)) "ESRQ : SRQ line 'stuck' on"
    set NI488_ErrorExplication($NI488_ErrorValues(ETAB)) "ETAB : The return buffer is full"
    set NI488_ErrorExplication($NI488_ErrorValues(ELCK)) "ELCK : Board or address is locked"


}

proc GPIB_Command { comm } {
    global GPIB_board GPIB_Commands
    ::GPIBBoard::1cmd $GPIB_board $GPIB_Commands($comm)
}

proc GPIB_Command2 { comm i } {
    global GPIB_board GPIB_Commands
# puts stderr "GPIB_Command2 $comm $i -> [expr $GPIB_Commands($comm) + $i]"
    ::GPIBBoard::1cmd $GPIB_board [expr $GPIB_Commands($comm) + $i]
}

proc GPIB_rescanBranches {} {
    global GPIB_board
    set GPIB_Branches {}
    GPIB_renOff ;# pour eviter que le TC revienne au menu (BUG du TC ?)
    
    global MACHTYPE
    if {$MACHTYPE == "Linux"} {
        puts stderr "::GPIBBoard::ln à faire"
        return "0 15 16 17 18"
    }
    for {set i 0} {$i<31} {incr i} {
        if {[::GPIBBoard::ln $GPIB_board $i 0]}  {
puts "$i est branché"
            lappend GPIB_Branches $i
        }
    }
    return $GPIB_Branches
}

proc GPIB_rescanDevices_lowLevel {} {
    global GPIB_board
    set GPIB_Branches [GPIB_rescanBranches]
    set zero [lsearch $GPIB_Branches 0]
    for {set i 1} {$i<31} {incr i} {
        destroy .gpib.button_MLA$i .gpib.button_MTA$i
    }
    if {$zero<0} {
        error "La carte n'est pas branchee en 0"
    }
    set ligne 1
    foreach d $GPIB_Branches {
        if {$d != "0"} {
            incr ligne
            button .gpib.button_MLA$d \
                -command "GPIB_Command2 MLA $d" \
		-text "MLA dev$d"
            button .gpib.button_MTA$d \
                -command "GPIB_Command2 MTA $d" \
		-text "MTA dev$d"
            grid .gpib.button_MLA$d -in .gpib.frame_low_level.frame_MLA_MTA \
                -row $ligne -column 2  \
		-sticky e
            grid .gpib.button_MTA$d -in .gpib.frame_low_level.frame_MLA_MTA \
                -row $ligne -column 1  \
		-sticky w
        }
    }
}

proc GPIB_Write {} {
    global GPIB_board
    set ecrit [.gpib.text_toGPIB get sel.first sel.last]
    ::GPIBBoard::wrt $GPIB_board $ecrit
}

proc GPIB:standardInit {board} {
    global Signal ConfigParam
    ::GPIBBoard::config $board $ConfigParam(SignalNumber) $Signal(USR1)
    ::GPIBBoard::config $board $ConfigParam(AUTOPOLL) 0
    ::GPIBBoard::config $board $ConfigParam(TIMING) 1
    ::GPIBBoard::config $board $ConfigParam(DMA) 0 ;# à supprimer
# * Le paramêtre natif varie de 0 à 15 et correspond aux durées :
# * infini, 0.01 ms, 0.03 ms, 0.1 ms ... 100 s.
    ::GPIBBoard::config $board $ConfigParam(TMO) 11
        
    ::GPIBBoard::sic $board ; # IFC pour 100 us INDISPENSABLE il me semble pour que la carte prenne le contrôle
}

proc GPIB:srqIsWritten {name1 name2 op} {
    upvar #0 $name1 srq
    global OLDSRQstatus SRQstatus variable_SRQ

    if {![info exists OLDSRQstatus] || $OLDSRQstatus != $SRQstatus} {
        puts stderr "SRQ ----------------------> $SRQstatus"
        set OLDSRQstatus $SRQstatus
        if {$SRQstatus} {
            set variable_SRQ "SRQ !!!"
        } else {
            set variable_SRQ {}
        }
    }
}

proc main {} {


global MACHTYPE

# initialisation de la carte
    global GPIB_board GPIB_boardAddress
if {$MACHTYPE == "Linux"} {
#        ::GPIBBoard::find "voltmeter" ;# bidon pour initialiser la carte, à revoir
    set GPIB_board [::GPIBBoard::find "gpib0"]
    if {[::GPIBBoard::isMaster $GPIB_board]} {
        puts "Opened 'gpib0' as master"
    } else {
        puts "device 'gpib0' is not set as master"
        exit
    }
    ::GPIBBoard::onl $GPIB_board 1
    ::GPIBBoard::sic $GPIB_board
    ::GPIBBoard::sre $GPIB_board 1
    
    
} else {
    set GPIB_board [::GPIBBoard::find "gpib0"]
}
# MTA MLA
    set GPIB_boardAddress($GPIB_board) 0

# initialisation de tableaux
    ini_GPIB_ARRAYS

#    [jniNewObject ()V l2m/fico/GPIB/Board]
    GPIB:standardInit $GPIB_board


# configuration de depart
    GPIB_renOff
    GPIB_traceOff
    
# prise en compte du SRQ au niveau de la carte

    global SRQstatus
    
    ::GPIBBoard::iniSRQ $GPIB_board
    trace variable SRQstatus w GPIB:srqIsWritten
    
}


proc ::GPIBBoard::scruteSRQ_periodic {board delai} {
    ::GPIBBoard::scruteSRQ $board
    after $delai ::GPIBBoard::scruteSRQ_periodic $board $delai
}

proc ::GPIBBoard::iniSRQ {board} {
    ::GPIBBoard::scruteSRQ_periodic $board 20
}

proc restart {} {
    destroy .gpib
    source gpib.tcl
}

proc debug {} {
    exec debugger [info nameofexecutable] [pid] &
}

proc kiki {} {
    exec kill -USR1 [pid]
}


set HELP(GPIB_wrt) {
    écriture haut niveau
}
proc GPIB_wrt {nom chaine} {
puts $nom
    upvar #0 $nom device
    GPIB:wrt $device(gpibBoard) $device(gpibAddr) $chaine
}

proc gpibRename {oldName newName} {
    upvar #0 $oldName oldArr
    
    if {$newName == {}} {
        if {[info exists oldArr]} {
            unset oldArr
        }
        if {[info commands $oldName] != {}} {
            rename $oldName {}
        }
        return
    }
    
    upvar #0 $newName newArr
    global gpibNames
    
    set newArr(gpibBoard) $oldArr(gpibBoard)
    set newArr(gpibAddr) $oldArr(gpibAddr)
    set newArr(classe) $oldArr(classe)
    
    set gpibNames($oldArr(gpibBoard),$oldArr(gpibAddr)) $newName
    unset oldArr
    rename $oldName $newName ;# procédure associée
}

set HELP(newGPIB) {
   - Crée notamment la commande "$nom"
}

proc newGPIB {classe nom board addr} {
    upvar #0 $nom Arr
    global gpibNames
    set Arr(classe) $classe
    set Arr(gpibBoard) $board
    set Arr(gpibAddr) $addr
    set gpibNames($board,$addr) $nom
    
    proc $nom {commande args} {
        set name [lindex [info level [info level]] 0]
        upvar #0 $name Arr
        set board $Arr(gpibBoard)
        set addr $Arr(gpibAddr)
	if {$Arr(classe) == "smu"} {
	    package require smu
	    set prefix ::smu::
	    set firstarg "smuName"
	} elseif {$Arr(classe) == "2361"} {
	    package require 2361
	    set prefix ::2361::
	    set firstarg "2361Name"
	} elseif {$Arr(classe) == "mm4005"} {
	    package require mm4005
	    set prefix ::mm4005::
	    set firstarg "mm4005Name"
	} else {
	    set prefix $Arr(classe):
	    set firstarg "$Arr(classe)Name"
	}
        if {[info commands $prefix$commande] != {}} {
            eval $prefix$commande $name $args
        } else {
            set goods {}
            foreach c [info commands ${prefix}*] {
		if {[lindex [info args $c] 0] == $firstarg} {
		    lappend goods [string range $c 4 end]
		} else {
puts stderr "écarté (normal): $c"
		}
            }
            set goods [lsort $goods]
            set message "l'option \"$commande\" est incorrecte: doit être [lindex $goods 0]"
            foreach g [lrange $goods 1 [expr [llength $goods] - 2]] {
                append message ", $g"
            }
            if {[llength $goods] >= 2} {
		append message ", ou [lindex $goods end]"
	    }
            error $message
        }
    }
}

proc GPIB:mla {device} {
    GPIB_Command2 MLA $device
}

proc GPIB:mta {device} {
    GPIB_Command2 MTA $device
}

proc GPIB:unl {} {
    GPIB_Command UNL
}

proc GPIB:unt {} {
    GPIB_Command UNT
}

proc GPIB:sdc {} {
    GPIB_Command SDC
}

proc GPIB:ren1 {} {
    GPIB_renOn 
}

proc GPIB:ren0 {} {
    GPIB_renOff
}

proc GPIB:spe {} {
    GPIB_Command SPE
}

proc GPIB:spd {} {
    GPIB_Command SPD
}

proc GPIB:get {} {
    GPIB_Command GET
}

proc GPIB:talk {chaine} {
    global GPIB_board
puts stderr "Utiliser ::GPIBBoard::wrt plutot que gpib.talk"
    ::GPIBBoard::wrt $GPIB_board $chaine
}

proc gpib.write {device chaine} {
    global GPIB_board GPIB_boardAddress
puts stderr "Utiliser GPIB:wrt plutot que gpib.write"
    GPIB:mta $GPIB_boardAddress($GPIB_board) ; GPIB:mla $device
    ::GPIBBoard::wrt $GPIB_board $chaine
    GPIB:unl ; GPIB:unt
}

proc GPIB:wrt {board device chaine} {
    global GPIB_boardAddress
    GPIB_Command2 MTA $GPIB_boardAddress($board)
    GPIB_Command2 MLA $device
    ::GPIBBoard::wrt $board $chaine
    GPIB:unl ; GPIB:unt
}

proc GPIB:rdBin {board device {len 512}} {
    global GPIB_boardAddress
    GPIB_Command2 MTA $device
    GPIB_Command2 MLA $GPIB_boardAddress($board)
    set rep [::GPIBBoard::rdBin $board $len]
    GPIB:unl ; GPIB:unt
    return $rep	;# retourne une liste
}

proc GPIB:rd {board device {len 512}} {
    global GPIB_boardAddress
    GPIB_Command2 MTA $device
    GPIB_Command2 MLA $GPIB_boardAddress($board)
    set rep [::GPIBBoard::rd $board $len]
    GPIB:unl ; GPIB:unt
    return $rep	;# retourne un ByteArray
}

proc GPIB:serialPoll {board device} { ;# renvoie la valeur du spb
    global GPIB_boardAddress
    GPIB:unt ; GPIB:unl ; GPIB:spe ; GPIB:mta $device
    GPIB:mla $GPIB_boardAddress($board)
    set rep [::GPIBBoard::rdBin $board 1]
    GPIB:unt ; GPIB:unl ; GPIB:spd
    return $rep
}

proc srq.wait {} {
    global variable_SRQ
    if {$variable_SRQ != {}} {
        puts stderr "direct return \"$variable_SRQ\""
        return $variable_SRQ
    }
    puts stderr "idle ?"
    after idle {
        if {$variable_SRQ != {}} {
            puts stderr "SRQ Set in after"
            set variable_SRQ $variable_SRQ ;# pour tkwait
        }
    }
    puts stderr "done, tkwait ?"
    tkwait variable variable_SRQ
    puts stderr "done = $variable_SRQ"
    return $variable_SRQ
}
