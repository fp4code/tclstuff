#!/bin/sh

# \
exec wish "$0" ${1+"$@"}

set HELP(oscillo.0.2.tcl) {
    # 17 décembre 2001 (FP)
}
set HELP(oscillo.0.3.tcl) {
    # 20 décembre 2001 (FP)
    Passage de sound ... -change command à after 50
    La version précédente avait un décalage temporel intolérable
    # octobre 2002 (FP)
}

package require snack
package require fidev
package require blasObj
package require dblas1
package require hsplot
package require blasmath

puts stderr "packages OK"

set PI [expr {acos(-1.0)}]

set gloglo(height) 200
set gloglo(width) 500

sound s -rate 44100
set gloglo(iir_filter) [snack::filter iir] 

# $gloglo(tWin) est la largeur temporelle de la fenêtre 
set gloglo(tWin) 0.02

# $tRetardMax est le délai max entre l'entrée dans la procédure d'affichage et
# l'affichage proprement dit
set tRetardMax 0.0001

set HELP(oscillo) {
    La base de temps est supposée donnée en microsecondes, int16

    On veut afficher dans une fenêtre de largeur $gloglo(tWin).
    La période de synchro est $tSync.
    Il faut une durée de mesure de ($gloglo(tWin) + $tSync)
    Si la période d'échantillonage est $gloglo(tEch),
    il faut $gloglo(N) = ($gloglo(tWin) + $tSync)/$gloglo(tEch) points

    Entre la décision d'affichage et l'affichage proprement dit,
    il peut s'écouler $tRetardMax


    $gloglo(tEch) = période d'échantillonage



}


proc plotFrame {iFirst} {
    global gloglo

    set iLast [s length]
    set t [expr {double($iLast)*double($gloglo(tEch))}]

    set tReal [expr {([clock clicks] - $gloglo(tIni))*1e-6}]
    if {0 && $tReal - $t > 0.1} {
	return
    }
    # puts "$tReal - $t = [expr {$tReal - $t}]"
    # puts -nonewline stderr \r$tReal
    
    # On est à l'instant $t relativement au début.
    # On veut afficher dans la fenêtre.
    # Il faut aller chercher l'instant de synchro précédent
    # $gloglo(tSyncStart) + $Ns * $tSync
    # égal à $t - $gloglo(tWin) + frac * $tSync

    set Ns [expr {floor (($t - $gloglo(tWin) - $gloglo(tSyncStart))*$gloglo(fSync))}]
    
    # index de l'instant $t dans le son

    set iBegin [expr {int(floor(($Ns/$gloglo(fSync) - $gloglo(tFirst))/$gloglo(tEch)))}]
    
    # instants relatifs au début de fenêtre
    blas::mathsvop gloglo(tv) fill1 [expr {$gloglo(tFirst) + $iBegin * $gloglo(tEch) - $gloglo(tSyncStart) - $Ns/$gloglo(fSync)}] $gloglo(tEch) 
    
    # idem en coordonnées fenêtre
    blas::mathsvop gloglo(tv) *scal $gloglo(fPixelFenetre)
    blas::mathsvop gloglo(x) <-double $gloglo(tv)

    if {$iBegin < 0} {
	puts stderr "iBegin = $iBegin"
	set l {}
    } else {
	
	binary scan [s data -start $iBegin -end [expr {$iBegin + int($gloglo(N)) + 1}]] s* l
	# $l est la liste des amplitudes (int 16 bits)
    }

    if {[llength $l] >= $gloglo(N)} {

	set v [blas::vector create double $l]
	# $v est la liste des amplitudes (double)
	
	if {$gloglo(autoy)} {
	    set min [blas::mathop min $v]
	    set max [blas::mathop max $v]
	    
	    if {$max < 1000.} {
		set max 1000.
	    }
	    if {$min > -1000.} {
		set min -1000.
	    }
	} else {
	    set min -10000.
	    set max 10000.
	}
	blas::mathsvop v +scal [expr {-$max}]
	blas::mathsvop v *scal [expr {-($gloglo(height)-1)/($max-$min)}]
	# $v est normalisé de 0 à $gloglo(height)
	
	# bug qui interdit blas::subvector getvector $v
	set gloglo(vv) $v
	
	blas::dcopy [blas::subvector create 1 1 $gloglo(N) $gloglo(vv)] gloglo(av)
	
	blas::mathsvop gloglo(y) <-double $gloglo(av)
	
	blas::mathsvop gloglo(x) ddif
	blas::mathsvop gloglo(y) ddif
	
	set gloglo(xy) $gloglo(xyTmp)
	set iFirst [incr iLast]
    } else {
	puts stderr "l:[llength $l], N=$gloglo(N)"	
    }
    if {!$gloglo(Stop)} {
	after 20 plotFrame $iFirst
    } else {
	s stop
    }
}

proc stop {} {
    global gloglo
    set gloglo(Stop) 1
}

proc essai {} {
    global gloglo

    set gloglo(Stop) 0
    set gloglo(fPixelFenetre) [expr {($gloglo(width) - 1)/$gloglo(tWin)}]

    set fEch [lindex [s info] 1]
    set gloglo(tEch) [expr {1.0/$fEch}]
    
    # nombre de points des vecteurs
    set gloglo(N) [expr {1+int(ceil(($gloglo(tWin))/$gloglo(tEch)))}]
    
    set gloglo(av) [blas::vector create double -length $gloglo(N)]
    set gloglo(tv) [blas::vector create double -length $gloglo(N)]
    set gloglo(xy) [blas::vector create short -length [expr 2*$gloglo(N)]]
    set gloglo(xyTmp)  [blas::vector create short -length [expr 2*$gloglo(N)]]
    set gloglo(x) [blas::subvector create 1 2 $gloglo(N) from gloglo(xyTmp)]
    set gloglo(y) [blas::subvector create 2 2 $gloglo(N) from gloglo(xyTmp)]
    
    set gloglo(tSyncStart) 0.0
    # instants d'échantillonage =$gloglo(tFirst) + $i * $gloglo(tEch)
    set gloglo(tFirst) 0.0
    
    .c delete all
    set gloglo(oscillo) [.c create hsplot 0 0 500 500 -xyblas gloglo(xy)]

    raise .
    .fSync configure -from $gloglo(fSyncMin) -to $gloglo(fSyncMax)

    # $tSync est la période de synchro

    set tIni0 [clock clicks]
    s record
    set gloglo(tIni) [clock clicks]
    # puts stderr [expr {($gloglo(tIni) - $tIni0)*1e-6}]
    after 50 plotFrame 0
}

canvas .c -width $gloglo(width) -height $gloglo(height)
pack .c

# essai 441.45

frame .f
pack .f

button .f.start -text start -command {essai}
button .f.stop -text stop -command {stop}
checkbutton .f.autoy -text "auto y" -variable gloglo(autoy)
pack .f.start .f.stop .f.autoy -side left

set gloglo(fSyncMin) 54
set gloglo(fSyncMax) 56
set gloglo(fSync) 55.
set gloglo(iir_freq) 110
set gloglo(iir_r) 0.999

frame .fs
entry .fs.fSyncMin -textvariable gloglo(fSyncMin) -width 8
entry .fs.fSyncMax -textvariable gloglo(fSyncMax) -width 8
entry .fs.fSync_e -textvariable gloglo(fSync) -width 8
scale .fSync -from $gloglo(fSyncMin) -to $gloglo(fSyncMax) -variable gloglo(fSync) -orient horizontal -resolution 0.01
button .fs.reconf -text {set bornes} -command reconf
scale .tWin -from 0.001 -to 0.1 -variable gloglo(tWin) -orient horizontal -resolution 0.001
pack .fs.fSyncMin .fs.fSync_e .fs.fSyncMax .fs.reconf -side left
pack .fs .fSync .tWin
frame .ff
entry .ff.num -textvariable gloglo(iir_num) -width 80
entry .ff.denim -textvariable gloglo(iir_denom) -width 80
checkbutton .ff.onoff -variable gloglo(iir_onoff) -command iir_onoff
pack .ff.num .ff.denom .ff.onoff
pack .ff

# set gloglo(map_filter) [snack::filter map 1.0]
set gloglo(map_filter) [snack::filter generator 440. 20000 0.0 sine -1]

proc iir_onoff {} {
    global gloglo

    if {$gloglo(iir_onoff)} {
	s filter $gloglo(iir_filter)
    } else {
	s filter $gloglo(map_filter)
    }
}

proc reconf {} {
    global gloglo PI
    .fSync configure -from $gloglo(fSyncMin) -to $gloglo(fSyncMax)
    
set rien {    set fx [expr {cos(2*$PI*$gloglo(iir_freq)/[s cget -rate])}]
    puts stderr "fx = $fx"
    set a0 [expr {(1.0-$gloglo(iir_r))*sqrt($gloglo(iir_r)*($gloglo(iir_r) - 4*$fx*$fx+2.0)+ 1.0)}]
    set b1 [expr {2*$gloglo(iir_r)*$fx}]
    set b2 [expr {-$gloglo(iir_r)*$gloglo(iir_r)}]
}
    $gloglo(iir_filter) configure -denominator $gloglo(iir_denom) -numerator $gloglo(iir_num)
    if {$gloglo(iir_onoff)} {
	s filter $gloglo(iir_filter)
    }
}



