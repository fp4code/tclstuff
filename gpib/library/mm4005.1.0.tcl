package provide mm4005 1.0

# 18 fevrier 2002 (FP) decharge mm -> microns 
# 29 mars 2002 (FP) mm4005::decharge debugge

namespace eval mm4005 {}

set mm4005_DELTAZ -2000

set info {
    Le terminateur de communication est "LF"   
    Désactiver le SRQ, qui ne respecte pas les normes
      (il s'active lorqu'il veut écrire, se désactive
       dès que l'on lit, sans SPE)

    La commande DH fixe une nouvelle position d'origine
    et met à jour les butées logicielles
    

    Si un mouvement arrive en butée physique, la tension des moteurs
    est coupée. Il faut la rétablir pas MO

    Dans de nombreux cas, on a "Q Fonction non autorise",
    alors j'ajoute un *** petit repos ***

}

proc ::mm4005::iniGlobals {} {
    variable mm4005SRQBitNames
    variable mm4005Messages

    # création des bits de SRQ

    set mm4005SRQBitNames(0) 0
    set mm4005SRQBitNames(1) 1
    set mm4005SRQBitNames(2) 2
    set mm4005SRQBitNames(3) 3
    set mm4005SRQBitNames(4) 4
    set mm4005SRQBitNames(5) 5
    set mm4005SRQBitNames(6) SRQ
    set mm4005SRQBitNames(7) 7
    return
}

proc ::mm4005::write {mm4005Name chaine} {
    upvar #0 $mm4005Name deviceArray
    # puts stderr "mm< \"${chaine}\""
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ${chaine}\n
}

proc ::mm4005::read {mm4005Name {len 512}} {
    upvar #0 $mm4005Name deviceArray
    set ret [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
    if {[string index $ret end] == "\n"} {
        set ret [string range $ret 0 end-1]
    }
    # puts stderr "mm> \"${ret}\""   
    return $ret
}

proc ::mm4005::serialPoll {mm4005Name} {
    upvar #0 $mm4005Name deviceArray
    return [GPIB::serialPoll $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}


proc ::mm4005::poll {mm4005Name} {
    upvar #0 $mm4005Name deviceArray
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
    return [mm4005::PollEnClair $mm4005Name $spByte]
}

set HELP(mm4005::iniZ) {
    1 février 2002 (FP)
    erreur mm4005 error = "C Parametre manque, hors limites ou incorrect"
    au moment de la mise de fin de course droite en 0
    refuse moins de 85
    J'écris 4SH-400. Maintenant on peut remettre la fin de course en -400
    Après un souci Q, iniZ marche. On laisse de côté le problème
}

proc mm4005::iniZ {mm4005Name} {
    set axe 4
#    $mm4005Name write ${axe}SL-20000
#    $mm4005Name write ${axe}SR20000

#    mm4005::gotoZeroMeca $mm4005Name $axe ;# met la position actuelle à 0
    puts stderr "*** modif fin de course - ***"
    mm4005::setFDCG $mm4005Name $axe -20000
    puts stderr "*** modif fin de course + ***"
    mm4005::setFDCD $mm4005Name $axe  20000
    mm4005::defVitesse $mm4005Name $axe 5000
    puts stderr "***     positionZero      ***"
    mm4005::positionZero $mm4005Name $axe ;# met la position actuelle à 0
    puts stderr "***     power             ***"
    mm4005::power $mm4005Name
    set etat [mm4005::etatAxe $mm4005Name $axe]
    if {![lindex $etat 4]} {
        puts stderr "***  move encore, etat = \"etat\" ***"
        mm4005::moveTo $mm4005Name $axe -10000
        puts stderr "***     power             ***"
        mm4005::power $mm4005Name
    }
    puts stderr [mm4005::etatSpecial $mm4005Name $axe]    
    set posb [mm4005::getPosReelle $mm4005Name $axe]

    puts stderr "***     petit repos         ***"
    bell
    after 2000
    bell

    puts stderr "*** montée vitesse moyenne ***"
    mm4005::moveTo $mm4005Name $axe [expr {$posb + 8000}]
    puts stderr "*** montée vitesse très lente ***"
    mm4005::defVitesse $mm4005Name $axe 1000
    mm4005::moveTo $mm4005Name $axe [expr {$posb + 12000}]
    set etat [mm4005::etatAxe $mm4005Name $axe]
    if {![lindex $etat 3]} {
        return -code error "On devrait être en FDC+ sur Z"
    }
    puts stderr "***     testError         ***"
    mm4005::testError $mm4005Name
    puts stderr "***     power             ***"
    mm4005::power $mm4005Name
    puts stderr "***     testError         ***"
    mm4005::testError $mm4005Name
    set posh [mm4005::getPosReelle $mm4005Name $axe]

    set ecartHaut 200
    set margeBas 500

    puts stderr "***     testError         ***"
    mm4005::testError $mm4005Name
    
    puts stderr "***     petit repos         ***"
    bell
    after 2000
    bell

    puts stderr "***     moveTo -200       ***"
    puts stderr [list mm4005::moveTo $mm4005Name $axe [expr {$posh-$ecartHaut}]]
    mm4005::moveTo $mm4005Name $axe [expr {$posh-$ecartHaut}]
    puts stderr "***     positionZero      ***"
    mm4005::positionZero $mm4005Name $axe
    puts stderr "*** modif fin de course + ***"
    mm4005::setFDCD $mm4005Name $axe 0
    puts stderr "*** modif fin de course - ***"
    puts stderr [list mm4005::setFDCG $mm4005Name $axe [expr {$posb-$posh+$ecartHaut+$margeBas}]]
    mm4005::setFDCG $mm4005Name $axe [expr {$posb-$posh+$ecartHaut+$margeBas}]

    mm4005::defVitesse $mm4005Name $axe 20000

# -9743 limite !?

}

proc mm4005::moveToOld {mm4005Name axe pos} {
    $mm4005Name write ${axe}TU
    set resol [string range [mm read] 3 end]
    $mm4005Name write ${axe}PA$pos
    set xposo [$mm4005Name getPosReelle $axe]
    set mso [clock clicks -milliseconds]
    set nb 0
    for {set i 0} {$i < 100} {incr i} {
        after 500
        set xpos [$mm4005Name getPosReelle $axe]
        set ms [clock clicks -milliseconds]
        if {abs($xpos - $pos) <= $resol} {
            break
        } else {
            set v [format %.4g [expr {1000.*double($xpos-$xposo)/double($ms - $mso)}]]
            puts stderr "$xpos $v"
            if {abs($xpos - $xposo) < $resol} {
                incr nb
                if {$nb > 10} {
                    return -code error "Bloquage d'axe $axe"
                }
            } else {
                set nb 0
            }            
            set xposo $xpos
            set mso $ms
        }
    }
}

proc mm4005::moveToDebug {mm axe pos} {
    $mm write ${axe}PA$pos
    set dort 0
    for {set i 1000} {$i > 0} {incr i -1} {
        set etat [mm4005::etatAxe $mm $axe]
        puts [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
        if {![lindex $etat 0]} {
            incr dort
            if {$dort > 20} {
                break
            }
        } else {
            set dort 0
        }
        after 10
    }
    if {$i == 0} {
        return -code error "Timeout on \"moveTo $axe $pos\""
    }
    bell
    puts [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
}

proc mm4005::moveTo {mm axe pos} {
    # puts stderr {}
    set etat [mm4005::etatAxe $mm $axe]
    # puts stderr [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
    if {[lindex $etat 1]} {
        return -code error "Erreur, rétablir d'abord la tension"
    }
    mm4005::write $mm ${axe}PA$pos
    mm4005::testError $mm
    set etat [mm4005::etatAxe $mm $axe]
    # puts stderr [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
    while {[lindex $etat 0]} {
        set etat [mm4005::etatAxe $mm $axe]
        # puts stderr [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
    }
    return [list [mm4005::etatSpecial $mm $axe] [mm4005::getPos $mm $axe]]
}

proc mm4005::moveToXY {mm x y} {
    global mm4005_DELTAZ
    # puts stderr {}
    set etat1 [mm4005::etatAxe $mm 1]
    set etat2 [mm4005::etatAxe $mm 2]
    set etat4 [mm4005::etatAxe $mm 4]
    if {[lindex $etat1 0] || [lindex $etat2 0] || [lindex $etat4 0]} {
        return -code error "déjà en mouvement"
    }
    set posZini [mm4005::getPosReelle $mm 4]
    if {abs($posZini) < 50} {
        set posZini 0
    } elseif {abs($posZini - $mm4005_DELTAZ) < 50} {
        set posZini $mm4005_DELTAZ
    } else {
        return -code error "ni en haut, ni en bas, Z = $posZsini"
    }

    if {$posZini != $mm4005_DELTAZ} {
        mm4005::moveTo $mm 4 $mm4005_DELTAZ
    }
    set pos [mm4005::getPosReelle $mm 4]
    if {abs($pos - $mm4005_DELTAZ) > 50} {
        return -code error "Z = $pos, donc pas descendu"
    }

    if {[lindex $etat1 1] || [lindex $etat2 1]} {
        return -code error "Erreur, rétablir d'abord la tension"
    }

    # puts stderr "*** [list mm4005::write $mm "1PA$x,2PA$y"] ***"
    mm4005::write $mm "1PA$x,2PA$y"
    mm4005::testError $mm
    set etat1 [mm4005::etatAxe $mm 1]
    set etat2 [mm4005::etatAxe $mm 2]
    # puts stderr [list\
            [mm4005::etatSpecial $mm 1] [mm4005::getPos $mm 1]\
            [mm4005::etatSpecial $mm 2] [mm4005::getPos $mm 2]]
    while {[lindex $etat1 0] || [lindex $etat2 0]} {
        set etat1 [mm4005::etatAxe $mm 1]
        set etat2 [mm4005::etatAxe $mm 2]
        puts stderr [list\
                [mm4005::etatSpecial $mm 1] [mm4005::getPos $mm 1]\
                [mm4005::etatSpecial $mm 2] [mm4005::getPos $mm 2]]
    }
    set etat1 [lrange $etat1 0 4]
    if {$etat1 != "0 0 0 0 0"} {
        return -code error "erreur sur X, etat = \"$etat1\" : \"[mm4005::etatSpecial $mm 1]\""
    }
    set etat2 [lrange $etat2 0 4]
    if {$etat2 != "0 0 0 0 0"} {
        return -code error "erreur sur Y, etat = \"$etat2\" :  \"[mm4005::etatSpecial $mm 2]\""
    }
    set xR [mm4005::getPosReelle $mm 1]
    if {abs($xR - $x) > 0.01} {
        return -code error "erreur X = $xR au lieu de $x"
    }
    set yR [mm4005::getPosReelle $mm 2]
    if {abs($yR - $y) > 0.01} {
        return -code error "erreur Y = $yR au lieu de $y"
    }
    
    if {$posZini != $mm4005_DELTAZ} {
        mm4005::moveTo $mm 4 $posZini
    }

    set zR [mm4005::getPosReelle $mm 4]
    if {abs($zR - $posZini) > 50} {
        return -code error "erreur Z = $zR au lieu de $posZini"
    }
}

proc ::mm4005::decharge {mm4005Name args} {
    upvar #0 $mm4005Name machine
    puts stderr "mm4005Name = $mm4005Name, args = $args"
    if {$args == ""} {
	mm4005::moveToXY $mm4005Name 25. 25.
    } elseif {$args == "left"} {
	mm4005::moveToXY $mm4005Name -25. 25.
    } else {
	error "argument de decharge incorrect"
    }
}

proc mm4005::PollEnClair {mm4005Name spByte} {
    variable mm4005SRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 7]} {
            set rep "RQ[expr {$spByte & 0x1f}]"
        } else {
            if {[isSet $spByte 0]} {
                lappend rep $mm4005SRQBitNames(0)
            }
            if {[isSet $spByte 1]} {
                lappend rep $mm4005SRQBitNames(1)
            }
            if {[isSet $spByte 2]} {
                lappend rep $mm4005SRQBitNames(2)
            }
            if {[isSet $spByte 3]} {
                lappend rep $mm4005SRQBitNames(3)
            }
            if {[isSet $spByte 4]} {
                lappend rep $mm4005SRQBitNames(4)
            }
            if {[isSet $spByte 5]} {
                lappend rep $mm4005SRQBitNames(5)
            }
        }
    }
    return $rep
}

proc mm4005::createIfNonExistent {} {
    global GPIB_board mm4005
    if {![info exists mm4005]} {
        GPIB::newGPIB mm4005 mm $GPIB_board 20

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
        set mm4005(getPosition) mm4005_getPosition
        ::aligned::new mm4005
        # mm4005::ini mm
    }
}

proc mm4005::getSomethingRaw {mm commande} {
    mm4005::write $mm $commande
    return [mm4005::read $mm]
}

proc mm4005::getSomething {mm commande} {
    set rep [mm4005::getSomethingRaw $mm $commande]
    set regexp "^${commande}(.*)\$"
    if {![regexp $regexp $rep tout ret]} {
        set error "réponse  à $commande = \"$rep\"\n"
        set reptb [mm4005::getSomethingRaw $mm TB]
        append error "réponse  à TB = \"$reptb\""
        return -code error $error
    }
    return $ret
}

proc mm4005::setSomething {mm commande val} {
    mm4005::write $mm ${commande}${val}
    if {$val == "?"} {
        set rep [mm4005::read $mm]
        set regexp "^${commande}(.*)\$"
        if {![regexp $regexp $rep tout ret]} {
            set error "réponse  à $commande = \"$rep\"\n"
            set reptb [mm4005::getSomethingRaw $mm TB]
            append error "réponse  à TB = \"$reptb\""
            return -code error $error
        } else {
            return $ret
        }
    }
    mm4005::testError $mm
}

proc mm4005::testError {mm} {
    set err [mm4005::getError $mm]
    if {[string index $err 0] != "@"} {
        puts stderr "$err"
        return -code error "mm4005 error = \"$err\""
    }
    return
}


namespace eval mm4005 {

    variable ACRO
    catch {unset ACRO}

    proc defGET  {acronyme procName info} {
        proc ${procName} {mm} "return \[mm4005::getSomething \$mm $acronyme\]"
        enregistre $acronyme [list $procName $info]
    }

    proc defGETx  {acronyme procName info} {
        proc ${procName} {mm axe} "return \[mm4005::getSomething \$mm \${axe}$acronyme\]"
        enregistre $acronyme [list $procName $info]
    }

    proc defIMM   {acronyme procName info} {
        proc ${procName} {mm} "mm4005::write \$mm $acronyme\nreturn"
        enregistre $acronyme [list $procName $info]
    }

    proc defIMM+  {acronyme procName info} {
        proc ${procName} {mm} "mm4005::write \$mm $acronyme\ntestError \$mm\nreturn"
        enregistre $acronyme [list $procName $info]
    }

    proc defIMMx  {acronyme procName info} {
        proc ${procName} {mm axe} "mm4005::write \$mm \${axe}$acronyme\nreturn"
        enregistre $acronyme [list $procName $info]
    }

    proc defIMMx+ {acronyme procName info} {
        proc ${procName} {mm axe} "mm4005::write \$mm \${axe}$acronyme\ntestError \$mm\nreturn"
        enregistre $acronyme [list $procName $info]
    }

    proc defSET  {acronyme procName info} {
        proc ${procName} {mm val}  "return \[mm4005::setSomething \$mm $acronyme \${val}\]"
        enregistre $acronyme [list $procName $info]
    }

    proc defSETx  {acronyme procName info} {
        proc ${procName} {mm axe val}  "return \[mm4005::setSomething \$mm \${axe}$acronyme \${val}\]"
        enregistre $acronyme [list $procName $info]
    }

    proc uncoded {args} {
        foreach acro $args {
            enregistre $acro unencoded
        }
    }

    proc enregistre {acro blabla} {
        variable ACRO
        if {[info exists ACRO($acro)] && $ACRO($acro) != $blabla} {
            puts stderr "\nWarning, \"$acro\" redefined\n  $ACRO($acro)\n->\n  $blabla"
        }
        set ACRO($acro) $blabla
    }

}

namespace eval mm4005 {

    # sélection du mode d'exécution
    uncoded CD CM MC ML MR RS

    defIMM   MF coupe   {arrêt d'urgence}
    defIMM+  MO power   {}

    # contrôle des positions et des déplacements
    uncoded SE

    defSETx  OR OR {recherche d'origine}
    defIMMx+ DH origineIci {fixe la position d'origine à la position courante}
    defIMMx+ ZP positionZero {position zéro}

    defSETx  PA deplAbsolu {}
    defSETx  PR deplRelatif {}

    defIMM   AB urgence {arrêt d'urgence}
    defIMMx+ ST arrêt {arrêt du déplacement en cours}

    # paramètres de définition des trajectoires
    uncoded DA DV OA VB

    defSETx  AC defAccel {définition de l'accélération}
    defSETx  VA defVitesse {définition de la vitesse}
    defGETx  DF getErreurPoursuite {}
    defGETx  DP getBut {lecture le la position à atteindre}
    defGETx  TH getPosTheo   {lecture le la position théorique}
    defGETx  TP getPosReelle {lecture de la position réelle}

    defSET   SD facteurPourcent {vitesse réduite en %}

    defSETx  MV deplInfini {déplacement infini}

    # paramètres de déplacement particuliers
    uncoded DM DO MH OH OL PB PE PI PS

    defSETx  SH setPositionOrigine {Penser à appeler OR2}
    defGETx  XH getPositionOrigine {}

    defSETx  SY synchro {0 ou 1}

    # mode trace
    uncoded AQ GQ NQ SP SQ TM TQ TT XN XQ XS

    # paramètres du filtre PID
    uncoded FE KD KI KP KS PW TF UF XD XF XI XP

    # paramètres relatifs aux motorisations
    uncoded BA SC SF SN

    defSETx  SL setFDCG {}
    defSETx  SR setFDCD {}
    defGETx  TA getName {}
    defGETx  TC getTypBA {type de boucle d'asservissement}
    defGETx  TL getFDCG  {fin de course logicielle gauche}
    defGETx  TN getUnits {}
    defGETx  TR getFDCD  {fin de course logicielle droite}
    defGETx  TU getResol {}
    defGETx  XB getHyster {}

    # fonctions d'entrée-sortie
    uncoded AM CB FT RA RB RO SB SO TG YO YP YR

    # programmation
    uncoded AP CP EO EP EX LP MP QP SM XL XM XX

    # séquencement et contrôle de flux
    uncoded DL IE JL KC OE RP RQ UH UL WA WE WF WG WH WK WL WP WS WT WY YE YG YL YN YW

    # manipulation de variables
    uncoded AS CS TY YA YB YC YD YF YK YM YP YQ YS YV YY

    # fonctions d'affichage
    uncoded DS DY FB FC FD NP RD RE

    # fonctions d'état
    uncoded ED TD TE TS TX
    
    defGET  TB getError {}
    defGET  VE getVersion {}
    defGETx MS MS {état des axes}

    # lecture d'une trajectoire
    uncoded AD AX AY CA CR CX CY EL FA LX LY MX MY NT

    # exécution d'une trajectoire
    uncoded ET VS VV WI WN

    # aide à la définition d'une trajectoire
    uncoded AT LT XA XE XT XU XV

    # définition du mode maître-esclave
    uncoded FF GR SS

    # mode trace sur la trajectoire
    uncoded NB NE NI NN NS
}


proc mm4005::getFDC {mm axe} {
    return [list\
            [mm4005::getFDCG $mm $axe]\
            [mm4005::getFDCD $mm $axe]]
}


proc mm4005::gotoZero {mm axe} {
    set etat [mm4005::etatAxe $mm $axe]
    if {[lindex $etat 1]} {
        return -code error "Erreur, rétablir d'abord la tension"
    }
    mm4005::OR $mm $axe 0
    mm4005::testError $mm
    set etat [mm4005::etatAxe $mm $axe]
    while {[lindex $etat 0]} {
        set etat [mm4005::etatAxe $mm $axe]
    }
}

proc mm4005::gotoTopZero {mm axe} {
    set etat [mm4005::etatAxe $mm $axe]
    if {[lindex $etat 1]} {
        return -code error "Erreur, rétablir d'abord la tension"
    }
    mm4005::OR $mm $axe 1
    mm4005::testError $mm
    set etat [mm4005::etatAxe $mm $axe]
    while {[lindex $etat 0]} {
        set etat [mm4005::etatAxe $mm $axe]
    }
}

proc mm4005::gotoZeroMeca {mm axe} {
    set etat [mm4005::etatAxe $mm $axe]
    if {[lindex $etat 1]} {
        return -code error "Erreur, rétablir d'abord la tension"
    }
    mm4005::OR $mm $axe 2
    mm4005::testError $mm
    set etat [mm4005::etatAxe $mm $axe]
    while {[lindex $etat 0]} {
        set etat [mm4005::etatAxe $mm $axe]
    }
}

proc mm4005::getPos {mm axe} {
    return [list\
            [mm4005::getBut $mm $axe]\
            [mm4005::getPosTheo $mm $axe]\
            [mm4005::getPosReelle $mm $axe]\
            ]
}

proc mm4005::etatAxe {mm axe} {
    set etat [mm4005::MS $mm $axe]
    if {![binary scan $etat c betat]} {
        return -code error "cannot binary scan \"$etat\""
    }
    set letat [list]
    lappend letat [expr {($betat & 1) != 0}]
    lappend letat [expr {($betat & 2) != 0}]
    lappend letat [expr {($betat & 4) != 0}]
    lappend letat [expr {($betat & 8) != 0}]
    lappend letat [expr {($betat & 16) != 0}]
    lappend letat [expr {($betat & 32) != 0}]
    lappend letat [expr {($betat & 64) != 0}]
    lappend letat [expr {($betat & 128) != 0}]
}

proc mm4005::etatSpecial {mm axe} {
    set etat [mm4005::MS $mm $axe]
    if {![binary scan $etat c betat]} {
        return -code error "cannot binary scan \"$etat\""
    }
    set letat [list]
    if {($betat & 1)} {
        set mvt Mouvement
        if {($betat & 4)} {
            append mvt +
        } else {
            append mvt -
        }
        lappend letat $mvt
    }
    if {($betat & 2)} {
        lappend letat PasDeJus
    }
    if {($betat & 8)} {
        lappend letat FDC+
    }
    if {($betat & 16)} {
        lappend letat FDC-
    }
    return $letat
}


proc  mm4005::bouge {mm axe} {
    set etat [mm4005::etatAxe $mm $axe]
    while {[lindex $etat 0]} {
        puts $etat
        set etat [mm4005::etatAxe $mm $axe]
    }
    bell
}

set origines {
    mm gotoTopZero 1   
    mm getPos 1 ;# 0.000 0.000 0.000
    mm origineIci 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -25 25

    mm moveTo 1 -10
    mm getPos 1 ;# -10.000 -10.000 -9.999
    mm getFDC 1 ;# -25 25

    mm origineIci 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -15 35

    mm gotoZero 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -15 35

    mm gotoTopZero 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -25 25

    mm moveTo 1 -10
    mm getPos 1 ;# -10.000 -10.000 -9.999
    mm getFDC 1 ;# -25 25

    mm origineIci 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -15 35

    mm gotoZero 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -15 35

    mm gotoZeroMeca 1
    mm getPos 1 ;# 0.000 0.000 0.000
    mm getFDC 1 ;# -25 25


    


####


    # permis

    mm defVitesse 4 ?
    mm defVitesse 4 5000
    mm defVitesse 4 ?

#####

    for {set i 100} {$i > 0} {incr i -1} {
        set x [expr {40*(rand()-0.5)}]
        set y [expr {40*(rand()-0.5)}]
        mm moveToXY $x $y
    }

}

# procédures publiques

proc mm4005_on {} {
    mm moveTo 4 0
}

proc mm4005_off {} {
    global mm4005_DELTAZ
    mm moveTo 4 $mm4005_DELTAZ
}

proc mm4005_power {} {
    mm power
}

proc mm4005_coupe {} {
    mm coupe
}

proc mm4005_iniZ {} {
    mm iniZ
}

proc mm4005_decharge {} {
    mm decharge
}

proc mm4005_iniXY {} {
    global mm4005_DELTAZ
    puts stderr {}

    set posZini [mm getPosReelle 4]
    if {abs($posZini) < 50} {
        set posZini 0
    } elseif {abs($posZini - $mm4005_DELTAZ) < 50} {
        set posZini $mm4005_DELTAZ
    } else {
        return -code error "ni en haut, ni en bas, Z = $posZsini"
    }

    if {$posZini != $mm4005_DELTAZ} {
        mm moveTo 4 $mm4005_DELTAZ
    }

    set pos [mm getPosReelle 4]
    if {abs($pos - $mm4005_DELTAZ) > 50} {
        return -code error "Z = $pos, donc pas descendu"
    }

    puts stderr "***     petit repos         ***"
    bell
    after 2000
    bell

    puts stderr [mm etatSpecial 1]    

    mm gotoTopZero 1
    mm testError

    puts stderr "***     petit repos         ***"
    bell
    after 2000
    bell

    puts stderr [mm etatSpecial 2]
    mm gotoTopZero 2

}

proc mm4005_getPosition {mm} {
    upvar #0 $mm mm4005 
    puts stderr [list mm = $mm]
    set xmm [mm getPosReelle 1]
    set ymm [mm getPosReelle 2]
    set x [expr {round(-1000.*$xmm)}]
    set y [expr {round(1000.*$ymm)}]
    set mm4005(xTheoUnaligned) $x
    set mm4005(yTheoUnaligned) $y
    return [list $x $y]
}

proc mm4005_moveTo {mm x y} {
     mm4005_moveToRaw $mm $x $y
}

proc mm4005_moveToRaw {mm x y} {
    upvar #0 $mm mm4005 
    puts stderr [list mm = $mm]
    set xmm [format %.3f [expr {-$x*0.001}]]
    set ymm [format %.3f [expr {$y*0.001}]]
    mm moveToXY $xmm $ymm
    set mm4005(xTheoUnaligned) $x
    set mm4005(yTheoUnaligned) $y
}


proc mm4005::specialFrame {f machine} {
    frame $f -relief sunken
    label ${f}.l -text MM4005
    button ${f}.p1 -text "POWER ON" -command mm4005_power
    button ${f}.p0 -text "POWER OFF" -command mm4005_coupe
    button ${f}.iniXY -text "INI XY" -command mm4005_iniXY
    button ${f}.iniZ -text "INI Z" -command mm4005_iniZ
    button ${f}.decharge -text "dech." -command mm4005_decharge
    pack ${f}.l -side left
    pack ${f}.p0 -side right
    pack ${f}.p1 -side right
    pack ${f}.iniXY -side right
    pack ${f}.iniZ -side right
    pack ${f}.decharge -side right
}
