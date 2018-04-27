
proc mes.ecomPretri {nom} {
    set ret [concat [list "@@ diodeBE $nom"] [mes.ecom.diodeBE.pretri $nom]]
return $ret
}

proc mes.ecom {nom} {
    set ret [concat [list "@@ ecom $nom"] [mes.ecom.IcVbe@IbSweepVce $nom]]
    return $ret
}

proc 2smuEtape0 {} {
    global ssrq
    smuB write $ssrq(minimal)
    smuC write $ssrq(minimal)
    smuC repos
    smuB repos
    smuB write "D0X" ;# sinon bloque les smus recents
    smuC write "D0X"
}

proc 2smuEtape1 {} {
    smuB trigOn ext
    smuC trigOn ext
    smuB trigIn preSRC
    smuC trigIn preSRC
    smuB trigOut postMSR
    smuC trigOut postMSR
    smuB sweep
    smuC sweep
}

# Synchros a voir

# 00---------S1 D1 M1 ts-------S2 D2 M2 ts-------Sn Dn Mn ts------
# 00---S1 D1 ts-------M1 S2 D2 ts-------M2 Sn Dn ts-------Mn------ 

# 00---S0 D0 M0 ts-------S1 D1 M1 ts-------S2 D2 M2 ts-------Sn Dn Mn ts------ 
# 00------------S1 D1 M1 ts-------S2 D2 M2 ts-------Sn Dn Mn ts-------00------

# SMU I(V) Danger : la compliance réelle est limitée par
# la gamme de la mesure de courant qui va suivre.
# Dans le cas de rampe en autorange, pB si le second smu
# veut imposer un courant plus grand que la gamme de la mesure
# qui a précédé  

proc 2smuEtapeMesure {smu1 smu2} {
    global ssrq
    $smu1 trigSweepEnd 1
    $smu2 trigSweepEnd 0
    $smu1 operate
    $smu2 operate
    $smu2 write $ssrq(rft)
    $smu2 waitRft
    $smu2 write $ssrq(minimal)
    $smu1 write $ssrq(rft)
    $smu1 waitRft
    $smu1 write $ssrq(done)
    set jour [getJour]
    set heure [getHeure]
    $smu1 fire
    $smu1 wait
    $smu1 write $ssrq(minimal)
    $smu2 repos
    $smu1 repos
    return [list $jour $heure]
}


proc mes.ecom.diodeBE.pretri {nom} {
    global gloglo
    global ssrq

    smuB write $ssrq(minimal)
    smuC write $ssrq(minimal)
    smuB repos
    smuB write "D0X" ;# sinon bloque les smus recents
    smuC write "D0X"

    smuB I(V)
    smuC V(I)

    smuC trigOut none
    smuC setCompliance $gloglo(+vcemax)
    smuC dc 
    smuC source 0
    smuC trigIn continuous
    smuC fire

    smuB trigOut none
    smuB setCompliance $gloglo(+ibmax)
    
    smuB sweep 
    smuB trigIn continuous
    smuB fixedLevelSweep 0.2 0 1
    smuB fixedLevelSweepAppend 0.5 0 1
    smuB operate
    smuB write $ssrq(rft)
    smuB waitRft
    smuB write $ssrq(minimal)
    smuB write $ssrq(rft)
    smuB waitRft
    smuB write $ssrq(done)
    smuB fire
    smuB wait
    smuB repos
    set b [smuB litSweep]
    if {[lindex $b 0] != [list @ V I instant statut]} {
         error "conflit mes.ecom.diodeBE.i(v)/::smu::litSweep sur smuB"
    }
    set ibTest1 [::smu::engVal [lindex [lindex $b 1] 1]]
    set ibTest2 [::smu::engVal [lindex [lindex $b 2] 1]]
puts stderr "******************  ibTest1 = $ibTest1, ibTest2 = $ibTest2"
    if {$ibTest2 < 1e-8} {
        smuC repos
        puts stderr "*** OUVERT !!! $nom : $ibTest2 à 0.5 V"
        return {{@defaut} {OUVERT}}
    }
    if {$ibTest1 > 0.9*$gloglo(+ibmax)} {
        smuC repos
        puts stderr "*** CC !!! $nom : $ibTest1 à 0.2 V"
#        return
    }
        
    set npts $gloglo(vbe.npts)
    smuB linStair 0.0 $gloglo(+vbmax) $npts
    smuB linStairAppend $gloglo(+vbmax) 0.0 $npts
    
    smuB operate
    smuB write $ssrq(rft)
    smuB waitRft
    smuB write $ssrq(minimal)
    smuB write $ssrq(rft)
    smuB waitRft
    smuB write $ssrq(done)
    set jour [getJour]
    set heure [getHeure]
    smuB fire
    smuB wait
    smuB repos
    smuC repos

    set jourHeure [list $jour $heure]
    set b [smuB litSweep]
    if {[lindex $b 0] != [list @ V I instant statut]} {
         error "conflit mes.ecom.diodeBE.i(v)/::smu::litSweep sur smuB"
    }
    set retour [list "# mesure Ib(Vce, Ic=0)"]
    lappend retour \
        [list @ {     Ib    } {     Vbe      } { jour   } { heure   } instant_b statut_b]
    # il y a une mesure de plus sur le collecteur on saute donc la ligne 1
    foreach lb [lrange $b 1 end] {
        lappend retour [list [::smu::engVal [lindex $lb 1]] \
                             [::smu::engVal [lindex $lb 0]] \
                           [lindex $jourHeure 0] [lindex $jourHeure 1] \
                           [lindex $lb 2] [lindex $lb 3]]
    }
    return $retour
    plot [lrange $retour 3 end] 0 1 x y mes
}

proc mes.ecom.IcVbe@IbSweepVce {nom} {
    global gloglo
    set retour \
        [list [list @ {     Ib    } {     Vbe     } {    Ic      } {   Vce    } { jour   } { heure   } instant_b instant_c statut_b statut_c]]
    foreach ib $gloglo(ibList) {
         set retour [concat $retour [mes.ecom.IcVbe@IbSweepVce.1pt $nom $ib]]
    }
    return $retour
}

proc mes.ecom.IcVbe@IbSweepVce.1pt {nom ib} {
    global gloglo
    global ssrq
    global smu.sweep.delay
    set smu.sweep.delay 0

    2smuEtape0

    smuB V(I)
    smuC I(V)

    smuB trigOut none
    smuC trigOut none

    2smuEtape1

    smuC setCompliance $gloglo(+icmax)
    smuB setCompliance $gloglo(+vbmax)
           
    set npts $gloglo(vce.npts)

    smuC linStair 0.0 $gloglo(+vcemax) $npts
    smuC linStairAppend $gloglo(+vcemax) 0.0 $npts

    smuB fixedLevelSweep $ib [expr 0] [expr 2*$npts + 2]

    set jourHeure [2smuEtapeMesure smuB smuC]

    set b [smuB litSweep]
    if {[lindex $b 0] != [list @ I V instant statut]} {
         error "conflit mes.ecom.IcVbe@IbSweepVce/::smu::litSweep sur smuB"
    }
    set c [smuC litSweep]
    if {[lindex $c 0] != [list @ V I instant statut]} {
         error "conflit mes.ecom.IcVbe@IbSweepVce/::smu::litSweep sur smuC"
    }
    set retour [list "# mesure Ic,Vbe(Vce, Ib=$ib)"]
    # il y a une mesure de plus sur le collecteur on saute donc la ligne 1
    foreach lb [lrange $b 2 end] lc [lrange $c 1 [expr 2*$npts + 1]] {
        lappend retour [list [::smu::engVal [lindex $lb 0]] \
                             [::smu::engVal [lindex $lb 1]] \
                             [::smu::engVal [lindex $lc 1]] \
                             [::smu::engVal [lindex $lc 0]] \
                           [lindex $jourHeure 0] [lindex $jourHeure 1] \
                           [lindex $lb 2] [lindex $lc 2] [lindex $lb 3] [lindex $lc 3]]
    }
    return $retour
    plot [lrange $retour 3 end] 0 1 x y mes
}

proc mes.ecom.IcVbe@IbSweepVce.old {nom ib} {
    global gloglo
    global smu.sweep.delay
    set smu.sweep.delay 0
    2smuEtape0
    smuC I(V)
    smuB V(I)
    2smuEtape1
    smuB setCompliance [expr abs($gloglo(+vbmax))]
    smuC setCompliance [expr abs($gloglo(+vcemax))]
    set npts $gloglo(sweepVce.npts)
    smuB linStair $gloglo(+vbmin) $gloglo(+vbmax) $npts
    smuC fixedLevelSweep [expr 0] 0 1
    smuC linStairAppend [expr 0] [expr $gloglo(+ibmax)] $npts
... suivre

    set jourHeure [2smuEtapeMesure]
    set c [smuC litSweep]
    set b [smuB litSweep]
    if {[lindex $c 0] != [list @ I V instant statut]} {
         error "conflit litSweep sur smuC"
    }
    if {[lindex $b 0] != [list @ V I instant statut]} {
         error "conflit litSweep sur smuB"
    }
    set retour [list "# mesure contrôle smus"]
    lappend retour \
        [list @ {     Ib    } {     Vb      } {    Ic      } {   Vc    } { jour   } { heure   } instant_b instant_c statut_b statut_c]
    # il y a une mesure de plus sur le collecteur on saute donc la ligne 1
    foreach lb [lrange $b 1 end] lc [lrange $c 2 end] {
        lappend retour [list [::smu::engVal [lindex $lb 1]] \
                             [::smu::engVal [lindex $lb 0]] \
                             [::smu::engVal [lindex $lc 0]] \
                             [::smu::engVal [lindex $lc 1]] \
                           [lindex $jourHeure 0] [lindex $jourHeure 1] \
                           [lindex $lb 2] [lindex $lc 2] [lindex $lb 3] [lindex $lc 3]]
    }
    return $retour
    plot [lrange $retour 3 end] 0 1 x y mes
}



