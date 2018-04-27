# 2008-12-23 (FP) Passage à int 64 bits (Tcl >= 8.4)
# 2013-03-27 (FP) Introduction de :smu::waitRdRft
# 2013-05-23 (FP) Introduction de :smu::_missingRft_V1 et :smu::waitRft_with_delay
# 2014-06-02 (FP) sourceContinue impose trigOut = none

package require arrayUtils 1.0

set modifs {
    IRangeFromIndex
    IRangeValues
    VRangeFromIndex
    VRangeValues
    bestIRange
    splitCleanIRange 
    splitIRange 

    2004-02-04 (FP) suppression de la variable smu.sweep.delay qui n'est plus utilisée

}

namespace eval ::smu {

    # $Modele($smuName) -> 236, 237 ou 238
    variable Modele

    # Etat(smuE,function) -> I(V) ou V(I)
    variable Etat

    variable DEBUG 0

    variable ssrq

    # minimal
    set ssrq(minimal) "M33,X"

    # ready for trigger
    set ssrq(rft) "M49,X"

    # sweep done
    set ssrq(done) "M35,X"

    # en commun : warning, sweep done, error
    set ssrq(nocompliance) "M35,X"

    # + compliance, durant toutes les phases
    set ssrq(standard) "M163,X"

    # + ready for trigger
    set ssrq(nocom+rft) "M51,X"

    # + ready for trigger et compliance
    set ssrq(+rft) "M179,X"

    variable MessagesOfSmu

    set MessagesOfSmu(warnings) [list \
      {Uncalibrated} \
      {Temporary Cal} \
      {Value Out of Range} \
      {Sweep Buffer Filled} \
      {No Sweep Points, Must Create...} \
      {Puse Times Not Met} \
      {Not In Remote} \
      {Mesure Range Changed Due to 1kV...} \
      {Measurement Overflow (OFLO)} \
      {Pending Trigger}]

    set MessagesOfSmu(errors) [list \
      {Trigger Overrun} \
      {IDDC} \
      {IDCCO} \
      {Interlock Present} \
      {Illegal Measure Range} \
      {Illegal Source Range} \
      {Invalid Sweep Mix} \
      {Log Cannot Cross Zero} \
      {Autoranging Source With Pulse Sweep} \
      {In Calibration" cr then} \
      {In Standby} \
      {Unit is a 236} \
      {IOU DPRAM Failed} \
      {IOU EEPROM Failed} \
      {IOU Cal Checksum Error} \
      {DPRAM Lookup} \
      {DPRAM Link Error} \
      {Cal ADC Zero Error} \
      {Cal ADC Gain Error} \
      {Cal SRC Zero Error} \
      {Cal SRC Gain Error} \
      {Cal Common Mode Error} \
      {Cal Compliance Error} \
      {Cal Value Error} \
      {Cal Constants Error} \
      {Cal Invalid Error}]

    # création des bits de SRQ

    variable SmuSRQBitNames

    set SmuSRQBitNames(0) Warning
    set SmuSRQBitNames(1) "Sweep Done"
    set SmuSRQBitNames(2) "Trigger Out"
    set SmuSRQBitNames(3) "Reading Done"
    set SmuSRQBitNames(4) "Ready for Trigger"
    set SmuSRQBitNames(5) "Error"
    set SmuSRQBitNames(6) "SRQ"
    set SmuSRQBitNames(7) "Compliance"

    variable U4

    set U4(LI00) "Auto"
    set U4(LI01) 1e-9
    set U4(LI02) 10e-9
    set U4(LI03) 100e-9
    set U4(LI04) 1e-6
    set U4(LI05) 10e-6
    set U4(LI06) 100e-6
    set U4(LI07) 1e-3
    set U4(LI08) 10e-3
    set U4(LI09) 100e-3
    set U4(LI10) 1.0

    set U4(LV00) "Auto"
    set U4(LV01) 1.1
    set U4(LV02) 11.
    set U4(LV03) 110.
    set U4(LV04) 1100.

    set U4(FS0) "Dc"
    set U4(FS1) "Sweep"

    set U4(O0) "Local"
    set U4(O1) "Remote"

    set U4(P0) 1
    set U4(P1) 2
    set U4(P2) 4
    set U4(P3) 8
    set U4(P4) 16
    set U4(P5) 32

    set U4(S0) "0.416e-3"
    set U4(S1) "4e-3"
    set U4(S2) "16.67e-3"
    set U4(S3) "20e-3"

    set U4(W0) "Disable"
    set U4(W1) "Enable"

    set U4(Z0) "Disable"
    set U4(Z1) "Enable"

    variable IRangeFromIndex

    set IRangeFromIndex(236,0) "Auto"
    set IRangeFromIndex(236,1) "1 nA"  
    set IRangeFromIndex(236,2) "10 nA"
    set IRangeFromIndex(236,3) "100 nA"
    set IRangeFromIndex(236,4) "1 uA"
    set IRangeFromIndex(236,5) "10 uA"
    set IRangeFromIndex(236,6) "100 uA"
    set IRangeFromIndex(236,7) "1 mA"
    set IRangeFromIndex(236,8) "10 mA"
    set IRangeFromIndex(236,9) "100 mA"

    set IRangeFromIndex(237,0) "Auto"
    set IRangeFromIndex(237,1) "1 nA"  
    set IRangeFromIndex(237,2) "10 nA"
    set IRangeFromIndex(237,3) "100 nA"
    set IRangeFromIndex(237,4) "1 uA"
    set IRangeFromIndex(237,5) "10 uA"
    set IRangeFromIndex(237,6) "100 uA"
    set IRangeFromIndex(237,7) "1 mA"
    set IRangeFromIndex(237,8) "10 mA"
    set IRangeFromIndex(237,9) "100 mA"

    set IRangeFromIndex(238,0) "Auto"
    set IRangeFromIndex(238,1) "1 nA"  
    set IRangeFromIndex(238,2) "10 nA"
    set IRangeFromIndex(238,3) "100 nA"
    set IRangeFromIndex(238,4) "1 uA"
    set IRangeFromIndex(238,5) "10 uA"
    set IRangeFromIndex(238,6) "100 uA"
    set IRangeFromIndex(238,7) "1 mA"
    set IRangeFromIndex(238,8) "10 mA"
    set IRangeFromIndex(238,9) "100 mA"
    set IRangeFromIndex(238,10) "1 A"

    variable IRangeValues

    set IRangeValues(236) [list "Auto"]
    set IRangeValues(237) [list "Auto"]
    set IRangeValues(238) [list "Auto"]

    for {set i 1} {$i <= 9} {incr i} {
	set courant [expr {pow(10., $i-10)}]
	lappend IRangeValues(236) $courant
 	lappend IRangeValues(237) $courant
	lappend IRangeValues(238) $courant
    }
    lappend IRangeValues(238) [expr {1.0}]

    variable DefaultDelay

    # en ms
    set DefaultDelay(1) 360
    set DefaultDelay(2)  75
    set DefaultDelay(3)  20
    set DefaultDelay(4)   5
    set DefaultDelay(5)   2
    set DefaultDelay(6)   0
    set DefaultDelay(7)   0
    set DefaultDelay(8)   0
    set DefaultDelay(9)   0
    set DefaultDelay(10)  0

    variable VRangeFromIndex

    set VRangeFromIndex(236,0) "Auto"
    set VRangeFromIndex(236,1) "1.1 V"
    set VRangeFromIndex(236,2) "11 V"
    set VRangeFromIndex(236,3) "110 V"

    set VRangeFromIndex(237,0) "Auto"
    set VRangeFromIndex(237,1) "1.1 V"
    set VRangeFromIndex(237,2) "11 V"
    set VRangeFromIndex(237,3) "110 V"

    set VRangeFromIndex(238,0) "Auto"
    set VRangeFromIndex(238,1) "1.5 V"
    set VRangeFromIndex(238,2) "15 V"
    set VRangeFromIndex(238,3) "110 V"
    set VRangeFromIndex(238,4) "1100 V"

    variable VRangeValues

    set VRangeValues(236) [list "Auto"]
    set VRangeValues(237) [list "Auto"]
    set VRangeValues(238) [list "Auto"]

    for {set i 1} {$i <= 2} {incr i} {
	lappend VRangeValues(236) [expr {1.1*pow(10., $i-1)}]
	lappend VRangeValues(237) [expr {1.1*pow(10., $i-1)}]
	lappend VRangeValues(238) [expr {1.5*pow(10., $i-1)}]
    }
    lappend VRangeValues(236) [expr {1.1*pow(10., $i-1)}]
    lappend VRangeValues(237) [expr {1.1*pow(10., $i-1)}]
    lappend VRangeValues(238) [expr {1.1*pow(10., $i-1)}]
    incr i
    lappend VRangeValues(238) [expr {1.1*pow(10., $i-1)}]

    variable IndexFromRange

    set IndexFromRange(Auto) 0
    set IndexFromRange(1\ nA) 1
    set IndexFromRange(10\ nA) 2
    set IndexFromRange(100\ nA) 3
    set IndexFromRange(1\ uA) 4
    set IndexFromRange(10\ uA) 5
    set IndexFromRange(100\ uA) 6
    set IndexFromRange(1\ mA) 7
    set IndexFromRange(10\ mA) 8
    set IndexFromRange(100\ mA) 9
    set IndexFromRange(1\ A) 9
    set IndexFromRange(1.1\ V) 1
    set IndexFromRange(1.5\ V) 1
    set IndexFromRange(11\ V) 2
    set IndexFromRange(15\ V) 2
    set IndexFromRange(110\ V) 3
    set IndexFromRange(1100\ V) 4
    set IndexFromRange(0) 0
    set IndexFromRange(1) 1
    set IndexFromRange(2) 2
    set IndexFromRange(3) 3
    set IndexFromRange(4) 4
    set IndexFromRange(5) 5
    set IndexFromRange(6) 6
    set IndexFromRange(7) 7
    set IndexFromRange(8) 8
    set IndexFromRange(9) 9
    set IndexFromRange(10) 10

}

proc ::smu::write {smuName chaine} {
    upvar #0 $smuName smuArr
    variable DEBUG
    if {$DEBUG} {
	puts stderr [list SMU DEBUG: $smuName write $chaine]
    }
    GPIB::ren1
    GPIB::wrt $smuArr(gpibBoard) $smuArr(gpibAddr) $chaine
}

proc ::smu::read {smuName {len 512}} {
    upvar #0 $smuName smuArr
    variable DEBUG
    if {$DEBUG} {
	puts -nonewline stderr [list SMU DEBUG: $smuName read $len ->]
    }
    GPIB::ren1
    set ret [GPIB::rd $smuArr(gpibBoard) $smuArr(gpibAddr) $len]
    if {$DEBUG} {
	puts stderr " [list $ret]"
    }
    return $ret
}

proc ::smu::readBin {smuName {len 512}} {
    upvar #0 $smuName smuArr
    variable DEBUG
    if {$DEBUG} {
	puts -nonewline stderr "[list SMU DEBUG: $smuName readBin $len ->] "
    }
    GPIB::ren1
    set ret [GPIB::rdBin $smuArr(gpibBoard) $smuArr(gpibAddr) $len]
    if {$DEBUG} {
	puts stderr " [llength $ret] bytes"
    }
    return $ret
}

proc ::smu::serialPoll {smuName} {
    upvar #0 $smuName smuArr
    variable DEBUG
    variable SmuSRQBitNames
    if {$DEBUG} {
	puts -nonewline stderr [list SMU DEBUG: $smuName seriallPoll ->]
    }
    GPIB::ren1
    set ret [GPIB::serialPoll $smuArr(gpibBoard) $smuArr(gpibAddr)]
    if {$DEBUG} {
	puts -nonewline stderr " $ret"
	for {set i 0 } {$i <= 7} {incr i} {
	    if {[isSet $ret $i]} {
		puts -nonewline stderr " [list $SmuSRQBitNames($i)]"
	    }
	}
	puts stderr {}
    }
    return $ret
}

proc ::smu::get {smus} {

    variable DEBUG
    if {$DEBUG} {
	puts stderr [list SMU DEBUG: get $smus]
    }
    GPIB::ren1
    GPIB::unl
    foreach smuName $smus {
        upvar #0 $smuName smuArr
        GPIB::mla $smuArr(gpibAddr)
    }
    GPIB::get
    GPIB::unl
}

#   1 : warning
#   2 : sweep done
#   4 : trigger out
#   8 : reading done
#  16 : ready for trigger
#  32 : error
#  64 : serial-poll en cours (normalisé, pas de masque)
# 128 : compliance

#                  \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
#                   \          Initialisation             \
#                    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \

proc ::smu::ini {smuName} {
# attention : les parametres pour F0 et F1 sont independants !!!
    upvar #0 $smuName smuArr

    variable Modele

    set addr $smuArr(gpibAddr)
    set board $smuArr(gpibBoard)
    
    GPIB::unt ; GPIB::unl ; GPIB::ren1
    GPIB::mla $addr
    GPIB::sdc
    GPIB::unt

  puts stderr "eos.off \ pour la lecture en mode binaire a faire"
    

    $smuName write "J0X"       ;# Set Factory Defaults ( SDC  est insuffisant )
    $smuName write "K0X"       ;# Enable EOI Enable Bus Hold-Off on X

    $smuName V(I)
    $smuName sweep
    $smuName write "B0,0,0X"   ;# le calibre 100 mA pose un probleme de demarrage de rampe
    $smuName write "M163,0X"   ;# SRQ : warning, sweep_done, error, compliance
    $smuName write "P0X"       ;# Filter Disabled
    $smuName write "S0X"       ;# Fast, 4 digits
    $smuName trigOn get
    $smuName trigIn continuous
    $smuName trigOut none
    $smuName trigSweepEnd 0
    $smuName write "W1Y4Z0X"   ;# Default delay, noCRLF, No Suppression

    $smuName I(V)
    $smuName sweep
    $smuName write "B0,0,0X"   ;# le calibre fort peut poser un pb. de demarrage de rampe
    $smuName write "M163,0X"   ;# SRQ : warning, sweep_done, error, compliance
    $smuName write "P0X"       ;# Filter Disabled
    $smuName write "S0X"       ;# Fast, 4 digits
    $smuName trigOn get
    $smuName trigIn continuous
    $smuName trigOut none
    $smuName trigSweepEnd 0
    $smuName write "W1Y4Z0X"   ;# Default delay, noCRLF, No Suppression

    # une initialisation à déplacer peut-être
    set Modele($smuName) [lindex [$smuName modele] 0]
}

##########################
# Informations générales #
##########################

proc ::smu::modele {smuName} {
    ::smu::write $smuName "U0X"
    set rep [::smu::read $smuName]
    if {![regexp {(...)(...)  $} $rep tout modele revision]} {
        error "ERREUR U0X : reponse = \"$rep\""
    }
    return [list $modele $revision]
}

proc ::smu::status {smuName} {
    ::smu::write $smuName "U3X"
    return [::smu::read $smuName]
}

proc ::smu::measurementParameters {smuName arrayName} {
    # le #0 est indispensable tant que les commandes de type
    #     smuC measurementParameters toto
    # ne se font pas dans un uplevel
    upvar #0 $arrayName array
    variable U4

    ::smu::write $smuName "U4X"
    set rep [::smu::read $smuName]
# IMPL,0F0,1O0P0S3W1Z0
#  puts "$smuName $rep"
    if {![regexp {^([IV])MPL,([01]*[0-9])F([01]),([01])O([01])P([0-5])S([0-3])W([01])Z([01])$} $rep tout im l fs ff o p s w z]} {
        error "ERREUR U0X (measurementParameters) : reponse = \"$rep\""
    }
    # patch pour les vieux
    if {[string length $l] == 1} {
	set l 0$l
    }
    if {$im == "I"} {
	set array(range) $U4(LI$l)
	if {$fs != 0} {
	    error "U4X : IMPL et F1"
	}
	set array(function) I(V)
    } else {
	set array(range) $U4(LV$l)
	if {$fs != 1} {
	    error "U4X : VMPL et F0"
	}
	set array(function) V(I)
    }
    set array(source) $U4(FS$fs)
    set array(sense) $U4(O$o)
    set array(filter) $U4(P$p)
    set array(integration) $U4(S$s)
    set array(delay) $U4(W$w)
    set array(suppression) $U4(Z$z)
    return
} 

proc ::smu::getComplianceValue {smuName} {
    ::smu::write $smuName "U5X"
    return [::smu::read $smuName]
}

proc ::smu::getSweepSize {smuName} {
    ::smu::write $smuName "U8X"
    set val [::smu::read $smuName]
    puts stderr "debug : $smuName attendu DSSnnnn, lu \"$val\""
    if {[string range $val 0 2] != "DSS"} {
        error "ERREUR U8X (getSweepSize) : DSS attendu"
    }
    set val [string range $val 3 6]
    set val [string trimleft $val 0]
    return $val
}

########################################
# décrypte les erreurs ou les warnings #
########################################

proc ::smu::decrypte {smuName appel retour messages} {
    variable MessagesOfSmu
    ::smu::write $smuName $appel
    set val [::smu::read $smuName]
# puts stderr [list ::smu::decrypte $smuName $appel $retour $messages -> $val]
    if {[string range $val 0 2] != $retour} {
        error "ERREUR $messages : $retour attendu"
    }
    set rep [list]
    set i 3
    foreach f $MessagesOfSmu($messages) {
        if {[string index $val $i] == 1} {
            lappend rep $f
        }
        incr i
    }
    return $rep
}

proc ::smu::warnings {smuName} {
    ::smu::decrypte $smuName XU9X WRS warnings
}

proc ::smu::errors {smuName} {
    ::smu::decrypte $smuName XU1X ERS errors
}

######################
# Gestion du polling #
######################

proc isSet {bits bit} {
    return [expr {($bits & (1 << $bit)) != 0}]
}

proc ::smu::pollEnClair {smuName spByte} {
    variable SmuSRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            set w $SmuSRQBitNames(0)
            lappend w [::smu::warnings $smuName]
            lappend rep $w
        }
        if {[isSet $spByte 1]} {
            lappend rep $SmuSRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $SmuSRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $SmuSRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $SmuSRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $SmuSRQBitNames(5)
            lappend w [::smu::errors $smuName]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $SmuSRQBitNames(7)
        }
    }
    return $rep
}

proc ::smu::poll {smuName} {
    return [::smu::pollEnClair $smuName [$smuName serialPoll]]
}

proc ::smu::wait {smuName} {
    puts stderr "TESTER LE REMPLACEMENT DE ::smu::wait par ::smu::waitRdRft"
    set again true
    while {$again} {
        GPIB::srqWait
        set poll [::smu::serialPoll $smuName]
	puts stderr "while de ::smu::wait $smuName -> [::smu::pollEnClair $smuName $poll]"
        if {$poll & 2} {       ;# reading done
            if {$poll & 128} { ;# compliance
                puts stderr "::smu::wait : $smuName : Mesure avec Compliance"
            }
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "::smu::wait : $smuName : Error : [::smu::errors $smuName]"
            }
            if {$poll & 1} {  ;# warning
                error "::smu::wait : $smuName : Warning : [::smu::warnings $smuName]"
            }
            if {$poll & 128} {  ;# compliance
                puts stderr "::smu::wait : $smuName : compliance"
            } else {
                error "::smu::wait : $smuName : Pb. de synchro : GPIB::serialPoll = $poll"
            }
        }
    }
}


proc private.smu.rft {smuName} {

    set poll [::smu::serialPoll $smuName]
    puts stderr "private.smu.rft $smuName \{[::smu::pollEnClair $smuName $poll]\}"
    # puts stderr    "... from [info level 0]|[info level 1] | [info level 2] | [info level 3] | [info level 4]"
    if {!($poll & 64 )} {
        return 0
    }
    if {$poll & 16} {       ;# ready for trigger
        if {$poll & 128} { ;# compliance
            puts stderr "$smuName : private.smu.rft avec Compliance"
        }
        return 1 
    } else {
        if {$poll & 32} { ;# error
            error "$smuName : Error : [::smu::errors $smuName]"
        }
        if {$poll & 1} {  ;# warning
            error "$smuName : Warning : [::smu::warnings $smuName]"
        }
        if {$poll & 128} {  ;# compliance
            puts stderr "private.smu.rft : $smuName en compliance"
        } else {
            error "$smuName : Pb. de synchro : GPIB::serialPoll = $poll"
        }
    }
    return 1
}

proc ::smu::waitRft {smuName} {
    puts stderr "::smu::waitRft"
    set again true
    while {$again} {
        GPIB::srqWait
        if {[private.smu.rft $smuName]} {
            set again false
        }
    }
}

proc ::smu::waitRft2 {args} { #; du rapide au lent
    set smus $args
    set trouve 0
    while {$smus != {}} {
#puts "smus = $smus"
        set i 0
        GPIB::srqWait
        foreach s $smus {
#puts $s
            if {[private.smu.rft $s]} {
                set smus [lreplace $smus $i $i]
                set trouve 1
                break
            } else {
                incr i
            }
        }
        if {!$trouve} {
            error "Problème de synchro"
        }
    }
}

proc ::smu::waitRdRft_old {smuName} {

    GPIB::srqWait
    set poll [::smu::serialPoll $smuName]
    if {$poll != 88} {
        if {$poll & 128} {  ;# compliance
#            iv:sourcesAuRepos .
#            error "SMU compliance !"
             puts stderr "::smu::waitRdRft : $smuName compliance !"
             incr poll -128
        }
    }
    if {$poll != 88} {
        error "::smu::waitRdRft_old : Pb. de synchro : GPIB::serialPoll = $poll"
    }
}

proc ::smu::_missingRft_V1 {smuName} {
    puts stderr "in __missingRft"
    ::smu::waitRft $smuName
    puts stderr "out _missingRft"		    
   
}

proc ::smu::_missingRft_V0 {smuName} {
    puts stderr "in __missingRft"
    if {$::variable_SRQ != {}} {
	puts stderr "again SRQ"
	set poll [::smu::serialPoll $smuName]
	puts stderr "poll = [::smu::pollEnClair $smuName $poll]"
    } else {
	puts stderr "strange, no SRQ"
    }
    puts stderr "out _missingRft"		    
}

proc ::smu::waitRdRft {smuName} {
    set again true
    while {$again} {
        GPIB::srqWait
        set poll [::smu::serialPoll $smuName]
	puts stderr "while de ::smu::waitRdRft $smuName -> [::smu::pollEnClair $smuName $poll]"
        if {$poll & 2} {       ;# reading done
            if {$poll & 128} { ;# compliance
                puts stderr "::smu::waittRdRft  : $smuName : Mesure avec Compliance"
            }
	    # purge de ready for trigger
	    if {!($poll & 16)} {
		puts stderr "waiting for Ready For Trigger after Reading Done"
                bell;after 200
                bell;after 200
                bell;after 200
		puts stderr ""
		after idle "::smu::_missingRft_V1 $smuName"
		bell;after 200
                bell;after 200
                bell;after 200
	    }
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "::smu::wait : $smuName : Error : [::smu::errors $smuName]"
            }
            if {$poll & 1} {  ;# warning
                error "::smu::wait : $smuName : Warning : [::smu::warnings $smuName]"
            }
            if {$poll & 128} {  ;# compliance
                puts stderr "::smu::wait : $smuName : compliance"
            } else {
                error "::smu::wait : $smuName : Pb. de synchro : GPIB::serialPoll = $poll"
            }
        }
    }
}

proc ::smu::waitRdRft_with_delay {smuName delai} {
    set again true
    while {$again} {
        GPIB::srqWait
	puts stderr "smuName = $smuName, delai=$delai"
	after $delai
        set poll [::smu::serialPoll $smuName]
	puts stderr "while de ::smu::waitRdRft $smuName -> [::smu::pollEnClair $smuName $poll]"
        if {$poll & 2} {       ;# reading done
            if {$poll & 128} { ;# compliance
                puts stderr "::smu::waittRdRft  : $smuName : Mesure avec Compliance"
            }
	    # purge de ready for trigger
	    if {!($poll & 16)} {
		puts stderr "waiting for Ready For Trigger after Reading Done"
                bell;after 200
                bell;after 200
                bell;after 200
		puts stderr ""
		after idle "::smu::_missingRft_V1 $smuName"
		bell;after 200
                bell;after 200
                bell;after 200
	    }
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "::smu::wait : $smuName : Error : [::smu::errors $smuName]"
            }
            if {$poll & 1} {  ;# warning
                error "::smu::wait : $smuName : Warning : [::smu::warnings $smuName]"
            }
            if {$poll & 128} {  ;# compliance
                puts stderr "::smu::wait : $smuName : compliance"
            } else {
                error "::smu::wait : $smuName : Pb. de synchro : GPIB::serialPoll = $poll"
            }
        }
    }
}

proc ::smu::fire {smuName} {
    ::smu::write $smuName "H0X"
}

proc ::smu::declenche {smuName} {
    variable ssrq
    ::smu::write $smuName $ssrq(nocom+rft)
    ::smu::waitRft $smuName
puts stderr "::smu::waitRft is Done -> get in declenche"
    ::smu::get $smuName
puts stderr "pre ::smu::waitRdRft_with_delay in declenche"
    ::smu::waitRdRft_with_delay $smuName 500
puts stderr "post ::smu::waitRdRft in declenche"
    ::smu::write $smuName $ssrq(nocompliance)
}

proc ::smu::declenche2 {smuLent smuRapide} {
    variable ssrq
    ::smu::write $smuLent $ssrq(nocom+rft)
    ::smu::write $smuRapide $ssrq(nocom+rft)
    ::smu::waitRft2 $smuRapide $smuLent
    ::smu::get $smuLentArr(gpibAddr) $smuLentArr(gpibAddr)
    ::smu::waitRft2 $smuRapide $smuLent
    ::smu::write $smuLent $ssrq(nocompliance)
    ::smu::write $smuRapide $ssrq(nocompliance)
}

proc ::smu::repos {smuName} {
    ::smu::write $smuName "N0X"
}

proc ::smu::operate {smuName} {
    ::smu::write $smuName "N1X"
}

proc ::smu::I(V) {smuName} {
    variable Etat
    ::smu::write $smuName "F0,X"
    set Etat($smuName,function) I(V)
}

proc ::smu::V(I) {smuName} {
    variable Etat
    ::smu::write $smuName "F1,X"
    set Etat($smuName,function) V(I)
}

proc ::smu::dc {smuName} {
    ::smu::write $smuName "F,0X"
}

proc ::smu::sweep {smuName} {
    ::smu::write $smuName "F,1X"
}

###################################
# 
###################################


proc ::smu::sourceContinue {smuName source} {
    variable ssrq

    $smuName write $ssrq(minimal)

    $smuName trigOn fire
    $smuName trigIn continuous
    $smuName trigOut none

    $smuName dc
    $smuName write "D0X"
    $smuName write "B${source},0,0XH0X"

    $smuName operate

    $smuName write "G1,2,0X" ;# pour lire la source
    set resul [$smuName read]

    return $resul
}

proc ::smu::mesure {smuName} {
    upvar #0 $smuName smuArr
    variable ssrq

    ::smu::dc $smuName
    ::smu::write $smuName "D0X"

    ::smu::trigOn $smuName get
    ::smu::trigIn $smuName preMSR
    ::smu::trigOut $smuName none
    ::smu::trigSweepEnd $smuName 1

    ::smu::write $smuName $ssrq(nocom+rft)
    ::smu::waitRft $smuName

    ::smu::get $smuName ;# on ne sait pas pourquoi, mais c'est nécessaire
    ::smu::waitRft $smuName
    ::smu::get $smuName
    puts stderr "TESTER LE REMPLACEMENT DE ::smu::waitRdRft_old par ::smu::waitRdRft"
    ::smu::waitRdRft_old $smuName ;# pour ne pas envoyer la commande suivante trop tot 

    ::smu::write $smuName G4,2,0X ;# pour lire la mesure
    ::smu::waitRft $smuName ;# sans cesse ready for trigger

    set resul [::smu::read $smuName]
    ::smu::write $smuName $ssrq(nocompliance) ;# il semble difficile
                               # de le mettre avant : efface l'affichage
    return $resul
}

####################
# gammes de mesure #
####################

set HELP(::smu::setCompliance) {
    $compliance : valeur de la compliance
    $args : si présent, Cf. ::smu::interpretRange.
            également autorisé : "-range best"
}

proc ::smu::setCompliance {smuName compliance args} {
    variable Etat
    if {$args == [list -range best]} {
	if {$Etat($smuName,function) == "I(V)"} {
	    set IouV "I"
	} elseif {$Etat($smuName,function) == "V(I)"} {
	    set IouV "V"
	} else {
	    error "\$Etat($smuName,function) = \"$Etat($smuName,function)\", should be \"I(V)\" or \"V(I)\""
	}
	
	set args [list -range bestOf $IouV $compliance]
    }
    set r [::smu::interpretRange $smuName $args]
    set chaine L${compliance},${r}X
    ::smu::write $smuName $chaine
    # puts stderr [list $compliance $args -> $smuName $chaine]
}


set HELP(::smu::interpretRange) {
    Cette procédure a évolué

    On autorise  {} -> autorange
                 -range 0
                 -range 1
                 ...
                 -range "1 mA"
                 -range "1.1 V"
                 ...
                 -range bestOf V -3.14
                 -range bestOf V [list -1.0 0.5 12.1]
}

proc ::smu::interpretRange {smuName list} {
    variable IndexFromRange
    # a éliminer ou contrôler

    puts stderr [list list = $list]

    if {$list == {} || $list == {{}}} {
	return 0
	# range Auto
    }
    if {[llength $list] < 2 || [lindex $list 0] != "-range"} {
	error "::smu::interpretRange : syntax ...sweep \[-range range\]"
    }
    set range [lindex $list 1]
    if {[info exists IndexFromRange($range)]} {
	return $IndexFromRange($range)
    }
    if {[lindex $list 1] == "bestOf"} {
	if {[llength $list] != 4} {
	    error "... bestOf ... missing valueList"
	}
	return [::smu::bestRangeFromList $smuName [lindex $list 2] [lindex $list 3]]
    }

    error "illegal \"range\" : $range"
}

proc ::smu::bestIRange {smuName value args} {
    variable IRangeFromIndex
    variable IRangeValues
    variable Modele

    if {$args == {}} {
	set stringRet 1
    } elseif {$args == "-code"} {
	set stringRet 0
    } else {
	error "if exists, \"args\" should be \"-code\"" 
    }

    set value [expr {abs($value)}]

    set i 0
    foreach val [lrange $IRangeValues($Modele($smuName)) 1 end] {
	incr i
	if {$value <= $val} {
	    if {$stringRet} {
		return $IRangeFromIndex($Modele($smuName),$i)
	    } else {
		return $i
	    }
	}
    }
    error "Un courant de \"$value A\", c'est trop !"
}

proc ::smu::splitIRange {smuName i1 i2 factor subfactor} {
    # factor doit être <= 1
    set cas {
	 0 <= i1 <= i2
	 0 <= i2 <  i1
	i2 <= i1 <=  0
        i1 <  i2 <=  0
        i1 <   0 <  i2
        i2 <   0 <  i1
    }

    if {0 <= $i1 && $i1 <= $i2} {
	set l [::smu::splitCleanIRange $smuName $i1 $i2 $factor $subfactor]
	return [::smu::inflatingSplittedIRange $l +1]
    }
    if {0 <= $i2 && $i2 <= $i1} {
	set l [::smu::splitCleanIRange $smuName $i2 $i1 $factor $subfactor]
	return [::smu::deflatingSplittedIRange $l +1]
    }
    if {$i2 <= $i1 && $i1 <= 0} {
	set l [::smu::splitCleanIRange $smuName [expr {-$i1}] [expr {-$i2}] $factor $subfactor]
	return [::smu::inflatingSplittedIRange $l -1]
    }
    if {$i1 <  $i2 && $i2 <= 0} {
	set l [::smu::splitCleanIRange $smuName [expr {-$i2}] [expr {-$i1}] $factor $subfactor]
	return [::smu::deflatingSplittedIRange $l -1]
    }
    if {$i1 < 0.0 && 0.0 < $i2} {
	set l1 [::smu::splitCleanIRange $smuName 0.0 [expr {-$i1}] $factor $subfactor]
	set l2 [::smu::splitCleanIRange $smuName 0.0 $i2 $factor $subfactor]
	return [concat [::smu::deflatingSplittedIRange $l1 -1] [::smu::inflatingSplittedIRange $l2 +1]]
    }
    if {$i2 < 0.0  && 0.0 < $i1} {
	set l1 [::smu::splitCleanIRange $smuName 0.0 [expr {-$i2}] $factor $subfactor]
	set l2 [::smu::splitCleanIRange $smuName 0.0 $i1 $factor $subfactor]
 	return [concat [::smu::deflatingSplittedIRange $l1 -1] [::smu::inflatingSplittedIRange $l2 +1]]
    }
    error "erreur de programmation: i1=$i1 i2=$i2"
}

proc ::smu::inflatingSplittedIRange {l sign} { 
    if {$sign == 1} {
	return $l
    }
    if {$sign != -1} {
	error "sign should be -1 or +1"
    }
    set ret [list]
    foreach e $l {
	lappend ret [list [expr {-[lindex $e 0]}] [expr {-[lindex $e 1]}] [lindex $e 2]]
    }
    return $ret
}

proc ::smu::deflatingSplittedIRange {l sign} {
    if {abs($sign) != 1} {
	error "sign should be -1 or +1"
    }
    set ret [list]
    set i [llength $l]
    for {incr i -1} {$i >= 0} {incr i -1} {
	set e [lindex $l $i]
	lappend ret [list [expr {$sign*[lindex $e 1]}] [expr {$sign*[lindex $e 0]}] [lindex $e 2]]	
    }
    return $ret
}

set HELP(::smu::splitCleanIRange) {
    coupe par morceaux une gamme de courants $imin..$imax
    # hypothèse:
    # 0 <= imin <= imax
    # 0 < factor <= 1
    renvoie une liste formée des morceaux
    chaque morceau est une liste de 3 éléments imin_i imax_i irange_i
    irange_i est l'index de range
    subfactor <= 1.0 permet un recouvrement
}

proc ::smu::splitCleanIRange {smuName imin imax factor subfactor} {
    variable IRangeFromIndex
    variable IRangeValues
    variable Modele

    if {$imax > [lindex $IRangeValues($Modele($smuName)) end]} {
	error "imax is too large: $imax"
    }

    set imin0 $imin
    set ret [list]

    set i 1
    puts stderr "patch factor = 0.2 pour gamme 1 nA (sinon Ib en compliance à 0.3 nA !)"
#    set val [expr {$factor*[lindex $IRangeValues($Modele($smuName)) $i]}]
    set val [expr {0.2*[lindex $IRangeValues($Modele($smuName)) $i]}]
    while {$imin > $val} {
	incr i
	set val [expr {$factor*[lindex $IRangeValues($Modele($smuName)) $i]}]
    }

    # le cas spécial une seule gamme de courant est bien traité
    
    while {$val < $imax} {
	if {$i+1 >= [llength $IRangeValues($Modele($smuName))]} {
	    break
	}
	set imin [expr {$subfactor*$imin}]
	if {$imin < $imin0} {
	    set imin $imin0
	}
	lappend ret [list $imin $val $i]
	set imin $val
	incr i
	set val [expr {$factor*[lindex $IRangeValues($Modele($smuName)) $i]}]
    }
    lappend ret [list $imin $imax $i]
    return $ret
}

proc ::smu::bestVRange {smuName value args} {
    variable VRangeFromIndex
    variable VRangeValues
    variable Modele

    if {$args == {}} {
	set stringRet 1
    } elseif {$args == "-code"} {
	set stringRet 0
    } else {
	error "if exists, \"args\" should be \"-code\"" 
    }

    set value [expr {abs($value)}]

    set i 0
    foreach val [lrange $VRangeValues($Modele($smuName)) 1 end] {
	incr i
	if {$value <= $val} {
	    if {$stringRet} {
		return $VRangeFromIndex($Modele($smuName),$i)
	    } else {
		return $i
	    }
	}
    }

    error "Une tension de \"$value V\", c'est trop !"
}

proc ::smu::bestRangeFromList {smuName IouV list} {
    variable IRangeValues
    variable VRangeValues
    variable Modele
    set max 0.0
    foreach v $list {
	set va [expr {abs($v)}]
	if {$max < $va} {
	    set max $va
	}
    }
    if {$IouV == "I"} {
	set ranges $IRangeValues($Modele($smuName))
    } elseif {$IouV == "V"} {
	set ranges $VRangeValues($Modele($smuName))
    } else {
	error "::smu::bestRangeFromList: argum \"IouV\" should be \"I\" or \"V\", not \"$IouV\""
    }

    # on saute "Auto"
    set i 1
    foreach v [lrange $ranges 1 end] {
	if {$v >= $max} {
	    return $i
	}
	incr i
    }
    error "for \"$IouV\": value $max is too large (from $list)"
}

##########
# rampes #
##########


proc ::smu::fixedLevelSweep {smuName val delay n args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q0,${val},$r,${delay},${n}X
    ::smu::write $smuName $chaine

}

proc ::smu::fixedLevelSweepAppend {smuName val delay n args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q6,${val},$r,${delay},${n}X
    ::smu::write $smuName $chaine
}

proc ::smu::linStairStep {smuName min max step delay args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q1,${min},${max},${step},$r,${delay}X
    puts stderr "pb. premier point si partie entiere vaut 2,4,6 (Ha) $chaine "   
    ::smu::write $smuName $chaine
}

proc ::smu::linStair {smuName min max n delay args} {
    set step [expr {double($max - $min)/$n}]
    set step [format %.3g $step] ;# à revoir
    eval [list ::smu::linStairStep $smuName $min $max $step $delay] $args
}

proc ::smu::linStairStepAppend {smuName min max step delay args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q7,${min},${max},${step},$r,${delay}X
    puts stderr $chaine    
    ::smu::write $smuName $chaine
}

proc ::smu::linStairAppend {smuName min max n delay args} {
    set step [expr {double($max - $min)/$n}]
    puts "step = $step"
    set step [format %.3g $step] ;# à revoir
    puts "step3g = $step"
    eval [list ::smu::linStairStepAppend $smuName $min $max $step $delay] $args
}

# participe a la création de la commande logarithmic stair
# a 5, 20, 25 ou 50
proc ::smu::vppd {valeur} {
    switch -exact -- $valeur {
         5 {return 0}
         10 {return 1}
         25 {return 2}
         50 {return 3}
         default {error "vppd pour log stair de smu : doit valoir 5, 10, 25 ou 50"}
    }
}

proc ::smu::logStair {smuName min max nParDecade delay args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q2,${min},${max},[vppd $nParDecade],$r,${delay}X
    puts stderr $chaine    
    ::smu::write $smuName $chaine
}

proc ::smu::logStairAppend {smuName min max nParDecade delay args} {
    set r [::smu::interpretRange $smuName $args]
    set chaine Q8,${min},${max},[vppd $nParDecade],$r,${delay}X
    puts stderr $chaine    
    ::smu::write $smuName $chaine
}

proc ::smu::convertMantisse {bytes} {
    set p0 [lindex $bytes 0]
    set p1 [lindex $bytes 1]
    set p2 [lindex $bytes 2]
    if {($p2 & 0x80) == 0} {
        set pp [expr {(($p2 & 0xff)<<16)|(($p1 & 0xff)<<8)|(($p0 & 0xff)<<0)}]
    } else {
        set pp [expr {0xffffffffff000000|($p2<<16)|($p1<<8)|($p0<<0)}]
    }
    return $pp
}

proc ::smu::convertInteger {bytes} {
    set p0 [lindex $bytes 0]
    set p1 [lindex $bytes 1]
    set p2 [lindex $bytes 2]
    set p3 [lindex $bytes 3]
    set pp [expr {(($p3 & 0xff)<<24)|(($p2 & 0xff)<<16)|(($p1 & 0xff)<<8)|(($p0 & 0xff)<<0)}]
    return $pp
}

proc ::smu::testConvertMantisse {val} {
    set p0 [expr {$val & 0xff}]
    set p1 [expr {($val & 0xff00)>>8}]
    set p2 [expr {($val & 0xff0000)>>16}]
    set liste [list $p0 $p1 $p2]
    puts stderr $liste
    return [::smu::convertMantisse $liste]
}

proc getInstant {} {
    return [clock format [clock seconds] -format "%Y/%m/%d_%H:%M:%S"]
}

proc getJour {} {
    return [clock format [clock seconds] -format "%Y/%m/%d"]
}

proc getHeure {} {
    return [clock format [clock seconds] -format "%H:%M:%S"]
}

proc ::smu::bubuRead {smuName len} {
    ::smu::write $smuName "G13,4,2X" ;# source&mesure&time, IBM, all_lines_per_talk
    set NTERMINATORS 2 ;# à revoir Max de toutes facons
    set bytelen [expr {2 + $len * (4+4+4)}]
    set bubusmu [::smu::readBin $smuName [expr {$bytelen + $NTERMINATORS}]]
    if {[llength $bubusmu] != $bytelen} {
        error "\"bubuRead $smuName $len\" Attendu $bytelen octets, reçu [llength $bubusmu]"
    }
    set bytesNbytes [lrange $bubusmu 0 1]
    set Nbytes [expr {((([lindex $bytesNbytes 1] & 0xff)<<8)|[lindex $bytesNbytes 0] & 0xff)}]
    set Nexpected [expr {2 + $len * (4+4+4)}]
    if {$Nbytes != $Nexpected} {
        error "\"bubuRead $smuName $len\" -> Nbytes = $Nbytes, $Nexpected = $Nexpected"
    }
    return $bubusmu
}

proc ::smu::litSweep {smuName} {
    set len [::smu::getSweepSize $smuName]
    set bubusmu [::smu::bubuRead $smuName $len]
    
    set status [lindex $bubusmu 9]
    set IdeV [expr {$status & 0x10}]
    if {$IdeV} {
        set smuSweep [list [list @ V I instant statut]]   
    } else {
        set smuSweep [list [list @ I V instant statut]]   
    }

    for {set i 0; set ip 2} {$i < $len} {incr i 1} {
        set source [lrange $bubusmu $ip [expr {$ip+3}]]
        incr ip 4
        set mesure [lrange $bubusmu $ip [expr {$ip+3}]]
        incr ip 4
        set msec [lrange $bubusmu $ip [expr {$ip+3}]]
        incr ip 4
        set mantisseSource [::smu::convertMantisse $source]
        set mantisseMesure [::smu::convertMantisse $mesure]
        set resolSource [lindex $source 3]
        set status [lindex $mesure 3]
        set resolMesure [expr {$status & 0x0f}]
        if {$IdeV} {
            incr resolSource -5
            incr resolMesure -14
        } else {
            incr resolSource -14
            incr resolMesure -5
        }
	# puts [format "$smuName: status = 0x%02x" $status]
        set lstatus [list]
        if {($status & 0x80) != 0} {
            lappend lstatus Compliance
        }
        if {($status & 0x40) != 0} {
            lappend lstatus Overlimit
        }
        if {($status & 0x20) != 0} {
            lappend lstatus {Suppression Enabled}
        }
        if {$lstatus == {}} {
            set lstatus {{}}
        }
	# puts $lstatus
        set msec [::smu::convertInteger $msec]
        set source ${mantisseSource}e${resolSource}
        set mesure ${mantisseMesure}e${resolMesure}
        lappend smuSweep [list $source $mesure $msec $lstatus]
    }
    # puts $smuSweep
    return $smuSweep
}

proc ::smu::engVal {mee} {
#puts stderr $mee
    set ie [string first "e" $mee]
    if {$ie < 0} {
        error "$mee is no MeE"
    }
    set mantisse [string range $mee 0 [expr {$ie - 1}]]
    set exposant [string range $mee [expr {$ie + 1}] end]
    if {$mantisse < 0} {
        set mantisse [expr {-$mantisse}]
        set signe -
    } else {
        set signe {}
    }
    set mod [expr {$exposant % 3}]
    if {$mod != 0} {
        set mod [expr {3 - $mod}]
    }
    incr exposant $mod
    set lap [expr {[string length $mantisse] - $mod}]
    if {$lap > 0} {
        set i3 [expr {3*($lap/3)}]
        incr exposant $i3
        set lap [expr {$lap - $i3}]
        set reste [string range $mantisse $lap end]
        if {$reste != {}} {
            set mantisse ${signe}[string range $mantisse 0 [expr {$lap - 1}]].${reste}
        } else {
            set mantisse ${signe}[string range $mantisse 0 [expr {$lap - 1}]]
        }
    } else {
        set ret "${signe}."
        for {} {$lap < 0} {incr lap} {
            append ret "0"
        }
        set mantisse $ret${mantisse}
    }
    set ret {}
    set avant [string length $mantisse]
    for {} {$avant < 8} {incr avant} {
        append ret " "
    }
    append ret ${mantisse}
    if {$exposant == 0} {
        append ret "    "
    } else {
        append ret e$exposant
        set apres [string length $exposant]
        for {} {$apres < 3} {incr apres} {
            append ret " "
        }
    }
    return $ret
}

proc ::smu::litFixedLevelSweep {smuName} {
    set len [::smu::getSweepSize $smuName]
    set bubusmu [::smu::bubuRead $smuName $len]

    set sourceRaw [lrange $bubusmu 2 5]
    set mantisseSource [::smu::convertMantisse $sourceRaw]
    set resolSource [lindex $sourceRaw 3]
    set status [lindex $bubusmu 9]
    set IdeV [expr {$status & 0x10}]
    if {$IdeV} {
        incr resolSource -5
        set smuSweep [list [list V I]]   
    } else {
        incr resolSource -14
        set smuSweep [list [list I V]]   
    }
    set source ${mantisseSource}e${resolSource}
    for {set i 0; set ip 2} {$i < $len} {incr i 1} {
        if {[lrange $bubusmu $ip [expr {$ip+3}]] != $sourceRaw} {
            error "Not a Fixed Sweep !"
        }
        incr ip 4
        set mesure [lrange $bubusmu $ip [expr {$ip+3}]]
        incr ip 4
        set msec [lrange $bubusmu $ip [expr {$ip+3}]]
        incr ip 4
        set mantisseMesure [::smu::convertMantisse $mesure]
        set status [lindex $mesure 3]
        set resolMesure [expr {$status & 0x0f}]
        if {$IdeV} {
            incr resolMesure -14
        } else {
            incr resolMesure -5
        }
        set lstatus {}
        if {($status & 0x80) != 0} {
            lappend lsta    $smuName trigIn continuous
tus Compliance
        }
        if {($status & 0x40) != 0} {
            lappend lstatus Overlimit
        }
        if {($status & 0x20) != 0} {
            lappend lstatus {Suppression Enabled}
        }
        set mesure ${mantisseMesure}e${resolMesure}
        set timeStamp [::smu::convertInteger $msec]
        lappend smuSweep [list $mesure $timeStamp $lstatus]
    }
    return [list $source $smuSweep]
}

# toujours mettre R0 avant de changer l'origine (Cf. doc.)
proc ::smu::trigOn {smuName what} {
    switch $what {
	"X" {set w 0}
	"get" {set w 1}
	"talk" {set w 2}
	"ext" {set w 3}
	"fire" {set w 4}
	"default" {error "should be \"trigOn X | get | talk | ext | fire\""}
    }
    ::smu::write $smuName "R0X"
    ::smu::write $smuName "T$w,,,X"
    ::smu::write $smuName "R1X"
}

proc ::smu::trigIn {smuName args} {
    set val 0
    set largs [llength $args]
    if {$largs == 0} {
        error "::smu::trigIn sans argument A FAIRE"
    }
    foreach a $args {
        switch $a {
            continuous {
                if {$largs != 1} {
                    error "::smu::trigIn : continuous est exclusif"
                }
                set val 0
            }
            singlePulse {
                if {$largs != 1} {
                    error "::smu::trigIn : singlePulse est exclusif"
                }
                set val 8
            }
            preSRC {
                set val [expr {$val | 1}]
            }
            preDLY {
                set val [expr {$val | 2}]
            }
            preMSR {
                set val [expr {$val | 4}]
            }
            default {
                error {::smu::trigIn continuous | singlePulse | ([preSRC] [preDLY] [preMSR])}
            }
        }
    }
    ::smu::write $smuName "T,$val,,X"
}

proc ::smu::trigOut {smuName args} {
    set val 0
    set largs [llength $args]
    if {$largs == 0} {
        error "::smu::trigOut sans argument A FAIRE"
    }
    foreach a $args {
        switch $a {
            none {
                if {$largs != 1} {
                    error "::smu::trigOut : none est exclusif"
                }
                set val 0
            }
            pulseEnd {
                if {$largs != 1} {
                    error "::smu::trigOut : pulseEnd est exclusif"
                }
                set val 8
            }
            postSRC {
                set val [expr {$val | 1}]
            }
            postDLY {
                set val [expr {$val | 2}]
            }
            postMSR {
                set val [expr {$val | 4}]
            }
            default {
                error {::smu::trigOut none | pulseE | ([postSRC] [postDLY] [postMSR])}
            }
        }
    }
    ::smu::write $smuName "T,,$val,X"
}

proc ::smu::trigSweepEnd {smuName tf} {
    if {$tf} {
	::smu::write $smuName "T,,,1X"
    } else {
	::smu::write $smuName "T,,,0X"
    }
}

proc ::smu::SRQon {smuName args} {
    set val 0
    set largs [llength $args]
    
    foreach a $args {
        switch $a {
            Nothing {
                if {$largs != 1} {
                    error "::smu::SRQon : Nothing est exclusif"
                }
                set val 0
            }
            Warning {
                set val [expr {$val | 1}]
            }
            SweepDone {
                set val [expr {$val | 2}]
            }
            TriggerOut {
                set val [expr {$val | 4}]
            }
            ReadingDone {
                set val [expr {$val | 8}]
            }
            ReadyForTrigger {
                set val [expr {$val | 16}]
            }
            Error {
                set val [expr {$val | 32}]
            }
            Compliance {
                set val [expr {$val | 128}]
            }
            default {
                error {::smu::SRQon Nothing|([Warning] [SweepDone] [TriggerOut] [ReadingDone] [ReadyForTrigger] [Error] [Compliance])}
            }
        }
    }
    ::smu::write $smuName "M$val,X"
}

###################
# Vieilles choses #
###################

proc ::smu::source.old {smuName source} {
    variable ssrq

    $smuName write $ssrq(minimal)

    $smuName dc
    $smuName write "D0X"
    $smuName write "B${source},0,0X"

    $smuName trigOn get
    $smuName trigIn preSRC
    $smuName trigOut none
    $smuName trigSweepEnd 0

    $smuName operate

    $smuName write "$ssrq(nocom+rft)"
    $smuName waitRft
    $smuName get
    $smuName waitRft ;# pour ne pas envoyer la commande suivante trop tot
    $smuName write "$ssrq(nocompliance)"
    $smuName write "G1,2,0X" ;# pour lire la source
    set resul [$smuName read]
    return $resul
}

proc ::smu::poll.old {smuName} {
    upvar #0 $smuName smuArr
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::spe
    GPIB::mta $smuArr(gpibAddr)
    GPIB::mla $GPIB_boardAddress($smuArr(gpibBoard))
    set spByte [::GPIBBoard::rdBin $smuArr(gpibBoard) 1]
    GPIB::unt
    GPIB::unl
    GPIB::spd
    return [::smu::pollEnClair $smuName $spByte]
}

proc ::smu::standby {smuName} {
    puts stderr "OBSOLETE : ::smu::standby, utiliser ::smu::repos"
}

package provide smu 1.2
