proc mes.diode {nom} {
    global temperature gloglo
    
    set mesures [list "@@ $nom"]
    set smu $gloglo(smu)
    $smu write "D0X"
    $smu poll

    $smu V(I)
    $smu setCompliance $gloglo(+vmax)
    $smu logStair $gloglo(+imin) $gloglo(+imax) $gloglo(logsmu.npts) 0
    $smu logStairAppend $gloglo(+imax) $gloglo(+imin) $gloglo(logsmu.npts) 0
     
    $smu operate
    $smu declenche
    $smu repos

#    lappend mesures {@    I          V           instant             msec statut}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    plot [lrange $mesure 1 end] 1 0 x y mes
    
    $smu I(V)
    $smu setCompliance $gloglo(-imax)
    $smu linStairStep $gloglo(+vmin) [expr {-$gloglo(-vmax)}] [expr {-$gloglo(dv)}] 0
    $smu linStairStepAppend [expr {-$gloglo(-vmax)}] $gloglo(+vmin) $gloglo(dv) 0

    $smu operate
    $smu declenche
    $smu repos

    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    
    return $mesures
}
proc mes.diodeDir {nom} {
    global temperature gloglo
    
    set mesures [list "@@ $nom"]
    set smu $gloglo(smu)
    $smu write "D0X"
    $smu poll

    $smu V(I)
    $smu setCompliance $gloglo(+vmax)
    $smu logStair $gloglo(+imin) $gloglo(+imax) $gloglo(logsmu.npts) 0
    $smu logStairAppend $gloglo(+imax) $gloglo(+imin) $gloglo(logsmu.npts) 0
     
    $smu operate
    $smu declenche
    $smu repos

#    lappend mesures {@    I          V           instant             msec statut}
    set mesure [$smu litSweep]
    set mesures [concat $mesures $mesure]
    plot [lrange $mesure 1 end] 1 0 x y mes
     
    return $mesures
}
