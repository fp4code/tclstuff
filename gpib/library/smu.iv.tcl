
proc smuIniGlobals {} {
    global smu.sweep.delay
    global ssrq MessagesOfSmu SmuSRQBitNames
    set smu.sweep.delay 0

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

    set SmuSRQBitNames(0) Warning
    set SmuSRQBitNames(1) "Sweep Done"
    set SmuSRQBitNames(2) "Trigger Out"
    set SmuSRQBitNames(3) "Reading Done"
    set SmuSRQBitNames(4) "Ready for Trigger"
    set SmuSRQBitNames(5) "Error"
    set SmuSRQBitNames(6) "SRQ"
    set SmuSRQBitNames(7) "Compliance"
}

proc smu:write {smuName chaine} {
    upvar #0 $smuName smuArr
    GPIB:wrt $smuArr(gpibBoard) $smuArr(gpibAddr) $chaine
}

proc smu:read {smuName {len 512}} {
    upvar #0 $smuName smuArr
    return [GPIB:rd $smuArr(gpibBoard) $smuArr(gpibAddr) $len]
}

proc smu:readBin {smuName {len 512}} {
    upvar #0 $smuName smuArr
    return [GPIB:rdBin $smuArr(gpibBoard) $smuArr(gpibAddr) $len]
}

proc smu:serialPoll {smuName} {
    upvar #0 $smuName smuArr
    return [GPIB:serialPoll $smuArr(gpibBoard) $smuArr(gpibAddr)]
}

proc smu:get {smus} {

    GPIB:unl
    foreach smuName $smus {
        upvar #0 $smuName smuArr
        GPIB:mla $smuArr(gpibAddr)
    }
    GPIB:get
    GPIB:unl
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

proc smu:ini {smuName} {
# attention : les parametres pour F0 et F1 sont independants !!!
    upvar #0 $smuName smuArr
    global GPIB_boardAddress

    set addr $smuArr(gpibAddr)
    set board $smuArr(gpibBoard)
    
    GPIB:unt ; GPIB:unl ; GPIB:ren1
    GPIB:mla $addr
    GPIB:sdc
  puts stderr "eos.off \ pour la lecture en mode binaire a faire"
    GPIB:mta $GPIB_boardAddress($board)
    ::GPIBBoard::wrt $board "J0X"       ;# Set Factory Defaults ( SDC  est insuffisant )
    ::GPIBBoard::wrt $board "K0X"       ;# Enable EOI Enable Bus Hold-Off on X
    ::GPIBBoard::wrt $board "F1,1X"     ;# pour Source current and measure voltage, Sweep
    ::GPIBBoard::wrt $board "B0,0,0X"   ;# le calibre 100 mA pose un probleme de demarrage de rampe
    ::GPIBBoard::wrt $board "M163,0X"   ;# SRQ : warning, sweep_done, error, compliance
    ::GPIBBoard::wrt $board "P0X"       ;# Filter Disabled
    ::GPIBBoard::wrt $board "S0X"       ;# Fast, 4 digits
    ::GPIBBoard::wrt $board "XT1,0,0,0X";# Triger Get, Start Source, No Out, No Sweep End
    ::GPIBBoard::wrt $board "W1Y4Z0X"   ;# Default delay, noCRLF, No Suppression
    ::GPIBBoard::wrt $board "F0,1X"     ;# Source voltage and measure current, Sweep
    ::GPIBBoard::wrt $board "B0,0,0X"   ;# le calibre fort peut poser un pb. de demarrage de rampe
    ::GPIBBoard::wrt $board "M163,0X"   ;# SRQ : warn, sweep_done, ready_for_trig,err, compliane
    ::GPIBBoard::wrt $board "P0X"       ;# Filter Disabled
    ::GPIBBoard::wrt $board "S0X"       ;# Fast, 4 digits
    ::GPIBBoard::wrt $board "XT1,0,0,0X";# Triger Get, Start Source, No Out, No Sweep End
    ::GPIBBoard::wrt $board "W1Y4Z0X"   ;# Default delay, CRLF, No Suppression
    GPIB:unt ; GPIB:unl
}

proc smu:status {smuName} {
    smu:write $smuName "U3X"
    return [smu:read $smuName]
}

proc smu:params {smuName} {
    smu:write $smuName "U4X"
    return [smu:read $smuName]
} 

proc smu:getComplianceValue {smuName} {
    smu:write $smuName "U5X"
    return [smu:read $smuName]
}

proc smu:getSweepSize {smuName} {
    smu:write $smuName "U8X"
    set val [smu:read $smuName]
    if {[string range $val 0 2] != "DSS"} {
        error "ERREUR U8X : DSS attendu"
    }
    set val [string range $val 3 6]
    set val [string trimleft $val 0]
    return $val
}

proc smu:decrypte {smuName appel retour messages} {
    global MessagesOfSmu
    smu:write $smuName $appel
    set val [smu:read $smuName]
# puts stderr [list smu:decrypte $smuName $appel $retour $messages -> $val]
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

proc smu:warnings {smuName} {
    smu:decrypte $smuName XU9X WRS warnings
}

proc smu:errors {smuName} {
    smu:decrypte $smuName XU1X ERS errors
}

###

proc isSet {bits bit} {
    return [expr {($bits & (1 << $bit)) != 0}]
}


proc smu:repos {smuName} {
    smu:write $smuName "N0X"
}

proc smuPollEnClair {smuName spByte} {
    global SmuSRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            set w $SmuSRQBitNames(0)
            lappend w [smu:warnings $smuName]
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
            lappend w [smu:errors $smuName]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $SmuSRQBitNames(7)
        }
    }
    return $rep
}


proc smu:poll {smuName} {
    upvar #0 $smuName smuArr
    global GPIB_boardAddress

    GPIB:unt
    GPIB:unl
    GPIB:spe
    GPIB:mta $smuArr(gpibAddr)
    GPIB:mla $GPIB_boardAddress($smuArr(gpibBoard))
    set spByte [::GPIBBoard::rdBin $smuArr(gpibBoard) 1]
    GPIB:unt
    GPIB:unl
    GPIB:spd
    return [smuPollEnClair $smuName $spByte]
}

proc smu:wait {smuName} {

    set again true
    while {$again} {
        srq.wait
        set poll [smu:serialPoll $smuName]
puts stderr "while de smu:wait $smuName -> [format 0x%02x $poll]"
        if {$poll & 2} {       ;# reading done
            if {$poll & 128} { ;# compliance
                puts stderr "smu:wait : $smuName : Mesure avec Compliance"
            }
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "smu:wait : $smuName : Error : [smu:errors $smuName]"
            }
            if {$poll & 1} {  ;# warning
                error "smu:wait : $smuName : Warning : [smu:warnings $smuName]"
            }
            if {$poll & 128} {  ;# compliance
                puts stderr "smu:wait : $smuName : compliance"
            } else {
                error "smu:wait : $smuName : Pb. de synchro : GPIB:serialPoll = $poll"
            }
        }
    }
}


proc private.smu.rft {smuName} {

    set poll [smu:serialPoll $smuName]
puts stderr "private.smu.rft $smuName -> [format 0x%02x $poll]"
    if {!($poll & 64)} {
        return 0
    }
    if {$poll & 16} {       ;# reading done
        if {$poll & 128} { ;# compliance
            puts stderr "$smuName : private.smu.rft avec Compliance"
        }
        return 1 
    } else {
        if {$poll & 32} { ;# error
            error "$smuName : Error : [smu:errors $smuName]"
        }
        if {$poll & 1} {  ;# warning
            error "$smuName : Warning : [smu:warnings $smuName]"
        }
        if {$poll & 128} {  ;# compliance
            puts stderr "private.smu.rft : $smuName en compliance"
        } else {
            error "$smuName : Pb. de synchro : GPIB:serialPoll = $poll"
        }
    }
    return 1
}

proc smu:waitRft {smuName} {
    set again true
    while {$again} {
        srq.wait
        if {[private.smu.rft $smuName]} {
            set again false
        }
    }
}

proc smu:waitRft2 {args} { #; du rapide au lent
    set smus $args
    set trouve 0
    while {$smus != {}} {
#puts "smus = $smus"
        set i 0
        srq.wait
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

proc smu:waitRdRft {smuName} {

    srq.wait
    set poll [smu:serialPoll $smuName]
    if {$poll != 88} {
        if {$poll & 128} {  ;# compliance
#            iv:sourcesAuRepos .
#            error "SMU compliance !"
             puts stderr "smu:waitRdRft : $smuName compliance !"
             incr poll -128
        }
    }
    if {$poll != 88} {
        error "smu:waitRdRft : Pb. de synchro : GPIB:serialPoll = $poll"
    }
}

proc smu:declenche {smuName} {
    global ssrq
    smu:write $smuName $ssrq(nocom+rft)
    smu:waitRft $smuName
puts stderr "smu:waitRft is Done"
    smu:get $smuName
    smu:wait $smuName
puts stderr "smu:wait is Done"
    smu:write $smuName $ssrq(nocompliance)
}

proc smu:declenche2 {smuLent smuRapide} {
    global ssrq
    smu:write $smuLent $ssrq(nocom+rft)
    smu:write $smuRapide $ssrq(nocom+rft)
    smu:waitRft2 $smuRapide $smuLent
    smu:get $smuLentArr(gpibAddr) $smuLentArr(gpibAddr)
    smu:waitRft2 $smuRapide $smuLent
    smu:write $smuLent $ssrq(nocompliance)
    smu:write $smuRapide $ssrq(nocompliance)
}

proc smu:standby {smuName} {
    smu:write $smuName "N0X"
}

proc smu:operate {smuName} {
    smu:write $smuName "N1X"
}

proc smu:I(V) {smuName} {
    smu:write $smuName "F0,X"
}

proc smu:V(I) {smuName} {
    smu:write $smuName "F1,X"
}

proc smu:dc {smuName} {
    smu:write $smuName "F,0X"
}

proc smu:sweep {smuName} {
    smu:write $smuName "F,1X"
}

proc smu:source {smuName source} {
    global ssrq
    smu:write $smuName "B${source},0,0X"
    smu:write $smuName R0X
    smu:write $smuName T1,1,0,0X
    smu:operate $smuName
    smu:write $smuName R1X
    smu:write $smuName $ssrq(nocom+rft)
    smu:waitRft $smuName
    smu:get $smuName
    smu:waitRft $smuName ;# pour ne pas envoyer la commande suivante trop tot
    smu:write $smuName $ssrq(nocompliance)
    smu:write $smuName G1,2,0X ;# pour lire la source
    set resul [smu:read $smuName]
    return $resul
}

proc smu:mesure {smuName} {
    upvar #0 $smuName smuArr
    global ssrq
    smu:write $smuName R0X
    smu:write $smuName T1,4,0,0X
    smu:write $smuName R1X
    smu:write $smuName $ssrq(nocom+rft)
    smu:waitRft $smuName
    smu:get $smuName ;# on ne sait pas pourquoi, mais c'est necessaire
    smu:waitRft $smuName
    smu:get $smuName
    smu:waitRdRft $smuName ;# pour ne pas envoyer la commande suivante trop tot
    smu:write $smuName G4,2,0X ;# pour lire la mesure
    smu:waitRft $smuName ;# sans cesse ready for trigger
    set resul [smu:read $smuName]
    smu:write $smuName $ssrq(nocompliance) ;# il semble difficile
                               # de le mettre avant : efface l'affichage
    return $resul
}

proc smu:setCompliance {smuName compliance} {
    set chaine L${compliance},0X
    smu:write $smuName $chaine
}

proc smu:fixedLevelSweep {smuName val delay n} {
    set chaine Q0,${val},0,${delay},${n}X
    smu:write $smuName $chaine
}

proc smu:fixedLevelSweepAppend {smuName val delay n} {
    set chaine Q6,${val},0,${delay},${n}X
    smu:write $smuName $chaine
}

proc smu:linStairStep {smuName min max step} {
    global smu.sweep.delay
    set chaine Q1,${min},${max},${step},0,${smu.sweep.delay}X
    puts stderr $chaine    
    smu:write $smuName $chaine
}

proc smu:linStair {smuName min max n} {
    set step [expr {double($max - $min)/$n}]
    set step [format %.5f $step] ;# à revoir
    smu:linStairStep $smuName $min $max $step
}

proc smu:linStairStepAppend {smuName min max step} {
    global smu.sweep.delay
    set chaine Q7,${min},${max},${step},0,${smu.sweep.delay}X
    puts stderr $chaine    
    smu:write $smuName $chaine
}

proc smu:linStairAppend {smuName min max n} {
    set step [expr {double($max - $min)/$n}]
    set step [format %.5f $step] ;# à revoir
    smu:linStairStepAppend $smuName $min $max $step
}

# participe a la creation de la commande logarithmic stair
# a 5, 20, 25 ou 50
proc vppd {valeur} {
    switch -exact -- $valeur {
         5 {return 0}
         10 {return 1}
         25 {return 2}
         50 {return 3}
         default {error "vppd pour log stair de smu : doit valoir 5, 10, 25 ou 50"}
    }
}

proc smu:logStair {smuName min max nParDecade} {
    global smu.sweep.delay
    set chaine Q2,${min},${max},[vppd $nParDecade],0,${smu.sweep.delay}X
    puts stderr $chaine    
    smu:write $smuName $chaine
}

proc smu:logStairAppend {smuName min max nParDecade} {
    global smu.sweep.delay
    set chaine Q8,${min},${max},[vppd $nParDecade],0,${smu.sweep.delay}X
    puts stderr $chaine    
    smu:write $smuName $chaine
}

proc smu:fire {smuName} {
    smu:write $smuName "H0X"
}

proc convert.smu.mantisse {bytes} {
    set p0 [lindex $bytes 0]
    set p1 [lindex $bytes 1]
    set p2 [lindex $bytes 2]
    if {($p2 & 0x80) == 0} {
        set pp [expr {(($p2 & 0xff)<<16)|(($p1 & 0xff)<<8)|(($p0 & 0xff)<<0)}]
    } else {
        set pp [expr {0xff000000|($p2<<16)|($p1<<8)|($p0<<0)}]
    }
    return $pp
}

proc convert.smu.integer {bytes} {
    set p0 [lindex $bytes 0]
    set p1 [lindex $bytes 1]
    set p2 [lindex $bytes 2]
    set p3 [lindex $bytes 3]
    set pp [expr {(($p3 & 0xff)<<24)|(($p2 & 0xff)<<16)|(($p1 & 0xff)<<8)|(($p0 & 0xff)<<0)}]
    return $pp
}

proc test.convert.smu.mantisse {val} {
    set p0 [expr {$val & 0xff}]
    set p1 [expr {($val & 0xff00)>>8}]
    set p2 [expr {($val & 0xff0000)>>16}]
    set liste [list $p0 $p1 $p2]
    puts stderr $liste
    return [convert.smu.mantisse $liste]
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

proc smu:litSweep {smuName} {
    set len [smu:getSweepSize $smuName]
    smu:write $smuName "G13,4,2X" ;# source&mesure&time, IBM, all_lines_per_talk
    set NTERMINATORS 2 ;# à revoir Max de toutes facons
    set bytelen [expr {2 + $len * (4+4+4)}]
    set bubusmu [smu:readBin $smuName [expr {$bytelen + $NTERMINATORS}]]
    if {[llength $bubusmu] != $bytelen} {
        error "Attendu $bytelen octets, reçu [llength $bubusmu]"
    }
    set bytesNbytes [lrange $bubusmu 0 1]
    set Nbytes [expr {((([lindex $bytesNbytes 1] & 0xff)<<8)|[lindex $bytesNbytes 0] & 0xff)}]
    if {$Nbytes != 2 + $len * (4+4+4)} {
        error "litSweep : getSweepSize->$len, Nbytes->$Nbytes"
    }
    
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
        set mantisseSource [convert.smu.mantisse $source]
        set mantisseMesure [convert.smu.mantisse $mesure]
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
        set lstatus {}
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
        set msec [convert.smu.integer $msec]
        set source ${mantisseSource}e${resolSource}
        set mesure ${mantisseMesure}e${resolMesure}
        lappend smuSweep [list $source $mesure $msec $lstatus]
    }
    return $smuSweep
}

proc smu:engVal {mee} {
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

proc smu:litFixedLevelSweep {smuName} {
    set len [smu:getSweepSize $smuName]
    smu:write $smuName "G13,4,2X" ;# source&mesure&time, IBM, all_lines_per_talk
    set NTERMINATORS 2 ;# à revoir Max de toutes facons
    set bytelen [expr {2 + $len * (4+4+4)}]
    set bubusmu [smu:readBin $smuName [expr {$bytelen + $NTERMINATORS}]]
    if {[llength $bubusmu] != $bytelen} {
        error "Attendu $bytelen octets, reçu [llength $bubusmu]"
    }
    set bytesNbytes [lrange $bubusmu 0 1]
    set Nbytes [expr {((([lindex $bytesNbytes 1] & 0xff)<<8)|[lindex $bytesNbytes 0] & 0xff)}]
    if {$Nbytes != 2 + $len * (4+4+4)} {
        error "litFixedLevelSweep : getSweepSize->$len, Nbytes->$Nbytes"
    }
    set sourceRaw [lrange $bubusmu 2 5]
    set mantisseSource [convert.smu.mantisse $sourceRaw]
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
        set mantisseMesure [convert.smu.mantisse $mesure]
        set status [lindex $mesure 3]
        set resolMesure [expr {$status & 0x0f}]
        if {$IdeV} {
            incr resolMesure -14
        } else {
            incr resolMesure -5
        }
        set lstatus {}
        if {($status & 0x80) != 0} {
            lappend lstatus Compliance
        }
        if {($status & 0x40) != 0} {
            lappend lstatus Overlimit
        }
        if {($status & 0x20) != 0} {
            lappend lstatus {Suppression Enabled}
        }
        set mesure ${mantisseMesure}e${resolMesure}
        set timeStamp [convert.smu.integer $msec]
        lappend smuSweep [list $mesure $timeStamp $lstatus]
    }
    return [list $source $smuSweep]
}

# toujours mettre R0 avant de changer l'origine (Cf. doc.)
proc smu:trigOnGet {smuName} {
    smu:write $smuName "R0T1,,,R1X"
}

proc smu:trigOnExt {smuName} {
    smu:write $smuName "R0T3,,,R1X"
}

proc smu:trigOnFireOnly {smuName} {
    smu:write $smuName "R0T4,,,R1X"
}

proc smu:trigIn {smuName args} {
    set val 0
    set largs [llength $args]
    if {$largs == 0} {
        error "smu:trigIn sans argumenent A FAIRE"
    }
    foreach a $args {
        switch $a {
            Continuous {
                if {$largs != 1} {
                    error "smu:trigIn : Continuous est exclusif"
                }
                set val 0
            }
            singlePulse {
                if {$largs != 1} {
                    error "smu:trigIn : singlePulse est exclusif"
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
                error {smu:trigIn Continuous|singlePulse|([preSRC] [preDLY] [preMSR])}
            }
        }
    }
    smu:write $smuName "T,$val,,X"
}

proc smu:trigOut {smuName args} {
    set val 0
    set largs [llength $args]
    if {$largs == 0} {
        error "smu:trigOut sans argument A FAIRE"
    }
    foreach a $args {
        switch $a {
            None {
                if {$largs != 1} {
                    error "smu:trigOut : None est exclusif"
                }
                set val 0
            }
            pulseEnd {
                if {$largs != 1} {
                    error "smu:trigOut : pulseEnd est exclusif"
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
                error {smu:trigIn Continuous|singlePulse|([preSRC] [preDLY] [preMSR])}
            }
        }
    }
    smu:write $smuName "T,,$val,X"
}

proc smu:trigSweepEndOff {smuName} {
    smu:write $smuName "T,,,0X"
}

proc smu:trigSweepEndOn {smuName} {
    smu:write $smuName "T,,,1X"
}

proc smu:SRQon {smuName args} {
    set val 0
    set largs [llength $args]
    
    foreach a $args {
        switch $a {
            Nothing {
                if {$largs != 1} {
                    error "smu:SRQon : Nothing est exclusif"
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
                error {smu:SRQon Nothing|([Warning] [SweepDone] [TriggerOut] [ReadingDone] [ReadyForTrigger] [Error] [Compliance])}
            }
        }
    }
    smu:write $smuName "M$val,X"
}

set HELP(newSmu.old) {
   - Crée notamment la commandes "nomDuSmu"
}
proc newSmu.old {smu board addr} {
    upvar #0 $smu smuArr
    global gpibNames
    set smuArr(classe) smu
    set smuArr(gpibBoard) $board
    set smuArr(gpibAddr) $addr
    set gpibNames($board,$addr) $smu
    
    proc $smu {commande args} {
        set smuName [lindex [info level [info level]] 0]
        upvar #0 $smuName smuArr
        set board $smuArr(gpibBoard)
        set addr $smuArr(gpibAddr)
        if {[info commands smu:$commande] != {}} {
            eval smu:$commande $smuName $args
        } else {
            set goods {}
            foreach c [info commands smu:*] {
                lappend goods [string range $c 4 end]
            }
            set goods [lsort $goods]
            set message "l'option \"$commande\" est incorrecte: doit être [lindex $goods 0]"
            foreach g [lrange $goods 1 [expr {[llength $goods] - 2}]] {
                append message ", $g"
            }
            append message ", ou [lindex $goods end]"
        }
    }
}
