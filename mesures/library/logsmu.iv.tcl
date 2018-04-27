proc mes.log.old {nom} {
    global temperature gloglo
    
# SIMPLIFIE POUR ROLAND     set mesures [list "@@ $nom"]
    set smu $gloglo(smu)
    
    smupoll $smu

    smu.V(I) $smu
    
    set vdm [expr abs($gloglo(-vdmax))]
    set vdp [expr abs($gloglo(+vdmax))]
    set.smu.compliance $smu [expr $vdm>$vdp ? $vdm : $vdp]

    log.stair $smu $gloglo(-idmax) $gloglo(+idmax) $gloglo(logsmu.npts)
     
    smu.operate $smu
    smu.declenche $smu
    smu.standby $smu
# SIMPLIFIE POUR ROLAND   lappend mesures {@ date instant msec statut V I}
    set mesure [lit.sweep $smu]
# SIMPLIFIE POUR ROLAND    set mesures [concat $mesures $mesure]
    set simple {}
    foreach l $mesure {
        lappend simple [lrange $l 2 3]
    }
    plot $mesure 3 2 x y mes
#    return $mesures
    return $simple
}

proc mes.log {nom} {
    global temperature gloglo
    
    set mesures [list "@@ $nom"]
    set smu $gloglo(smu)
    
    $smu write "D0X"
    $smu poll

    $smu V(I)
    
    $smu setCompliance $gloglo(+vmax)
    
    $smu logStair $gloglo(+imin) $gloglo(+imax) $gloglo(logsmu.npts) 0
     
    $smu operate
    $smu declenche
    $smu repos
#    lappend mesures {@    I          V           instant             msec statut}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    plot [lrange $mesure 1 end] 1 0 x y mes
    return $mesures
}
