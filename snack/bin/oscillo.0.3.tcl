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
}

package require snack
package require fidev
package require blasObj
package require dblas1
package require hsplot
package require blasmath

puts stderr "packages OK"

set height 200
set width 500

sound s -rate 44100

# $tWin est la largeur temporelle de la fenêtre 
set tWin 0.02

# $tRetardMax est le délai max entre l'entrée dans la procédure d'affichage et
# l'affichage proprement dit
set tRetardMax 0.0001

set rien {
proc affiche {last} {
    set new [clock clicks]
    set dt [expr {$new-$last}]
    puts stderr "$dt $new"
    after 0 "affiche $new"
}
affiche 0
}

set HELP(rien) {
    La base de temps est supposée donnée en microsecondes, int16

    On veut afficher dans une fenêtre de largeur $tWin.
    La période de synchro est $tSync.
    Il faut une durée de mesure de ($tWin + $tSync)
    Si la période d'échantillonage est $tEch,
    il faut $N = ($tWin + $tSync)/$tEch points

    Entre la décision d'affichage et l'affichage proprement dit,
    il peut s'écouler $tRetardMax
}


proc plotFrame {iFirst} {
    global tWin tSyncStart fSync tFirst tEch
    global vv tv av x y N xy xyTmp
    global fPixelFenetre
    global height tIni
    global Stop

    # puts stderr "iFirst = $iFirst"

    set iLast [s length]
    set t [expr {double($iLast)*double($tEch)}]

    set tReal [expr {([clock clicks] - $tIni)*1e-6}]
    if {0 && $tReal - $t > 0.1} {
	return
    }
    # puts "$tReal - $t = [expr {$tReal - $t}]"
    # puts -nonewline stderr \r$tReal
    
    # On est à l'instant $t relativement au début.
    # On veut afficher dans la fenêtre.
    # Il faut aller chercher l'instant de synchro précédent
    # $tSyncStart + $Ns * $tSync
    # égal à $t - $tWin + frac * $tSync
    set Ns [expr {floor (($t - $tWin - $tSyncStart)*$fSync)}]
    # puts stderr "Ns = floor (($t - $tWin - $tSyncStart)*$fSync) = $Ns"
    
    # index de l'instant $t dans le son
    # puts stderr "floor(($Ns/$fSync - $tFirst)/$tEch) == [expr {floor(($Ns/$fSync - $tFirst)/$tEch)}]"
    set iBegin [expr {int(floor(($Ns/$fSync - $tFirst)/$tEch))}]
    
    # instants relatifs au début de fenêtre
    blas::mathsvop tv fill1 [expr {$tFirst + $iBegin * $tEch - $tSyncStart - $Ns/$fSync}] $tEch 
    
    # idem en coordonnées fenêtre
    blas::mathsvop tv *scal $fPixelFenetre
    blas::mathsvop x <-double $tv

    # puts stderr "$iBegin [lindex $x 0]"

    if {$iBegin < 0} {
	puts stderr "iBegin = $iBegin"
	set l {}
    } else {

	# puts stderr "$iBegin [expr {$iBegin + int($N) + 1}] $iLast"
	
	binary scan [s data -start $iBegin -end [expr {$iBegin + int($N) + 1}]] s* l
	# $l est la liste des amplitudes (int 16 bits)
    }

    # puts stderr [llength $l]
    if {[llength $l] >= $N} {

	set v [blas::vector create double $l]
	# $v est la liste des amplitudes (double)
	
	set min [blas::mathop min $v]
	set max [blas::mathop max $v]
	
	if {$max < 1000.} {
	    set max 1000.
	}
	if {$min > -1000.} {
	    set min -1000.
	}

	blas::mathsvop v +scal [expr {-$max}]
	blas::mathsvop v *scal [expr {-($height-1)/($max-$min)}]
	# $v est normalisé de 0 à $height
	
	# bug qui interdit blas::subvector getvector $v
	set vv $v
	# set vv [lindex $v 3] ; set rien 0
	
	# puts stderr "$Ns $N [expr {$iBegin + 1}] 1 $N"
	blas::dcopy [blas::subvector create 1 1 $N $vv] av
	
	blas::mathsvop y <-double $av
	
	blas::mathsvop x ddif
	blas::mathsvop y ddif
	
	set xy $xyTmp
	set iFirst [incr iLast]
    } else {
	puts stderr "l:[llength $l], N=$N"	
    }
    if {!$Stop} {
	after 20 plotFrame $iFirst
    } else {
	s stop
    }
}

proc stop {} {
    global Stop
    set Stop 1
}

proc essai {} {
    global fSync tStart fSyncMin fSyncMax
    global tIni
    global Stop
    set Stop 0
    global oscillo
    global width tWin tEch tSyncStart tFirst fPixelFenetre
    global vv tv av x y N xy xyTmp

    set fPixelFenetre [expr {($width - 1)/$tWin}]

    # $tEch est la période d'échantillonage
    set fEch [lindex [s info] 1]
    set tEch [expr {1.0/$fEch}]
    
    # nombre de points des vecteurs
    set N [expr {1+int(ceil(($tWin)/$tEch))}]
    
    set av [blas::vector create double -length $N]
    set tv [blas::vector create double -length $N]
    set xy [blas::vector create short -length [expr 2*$N]]
    set xyTmp  [blas::vector create short -length [expr 2*$N]]
    set x [blas::subvector create 1 2 $N from xyTmp]
    set y [blas::subvector create 2 2 $N from xyTmp]
    
    set tSyncStart 0.0
    # instants d'échantillonage =$tFirst + $i * $tEch
    set tFirst 0.0
    
    .c delete all
    set oscillo [.c create hsplot 0 0 500 500 -xyblas xy]

    raise .
    .fSync configure -from $fSyncMin -to $fSyncMax

    # $tSync est la période de synchro

    set tIni0 [clock clicks]
    s record
    set tIni [clock clicks]
    # puts stderr [expr {($tIni - $tIni0)*1e-6}]
    after 50 plotFrame 0
}

canvas .c -width $width -height $height
pack .c

# essai 441.45

frame .f
pack .f

button .f.start -text start -command {essai}
button .f.stop -text stop -command {stop}
pack .f.start .f.stop -side left

set fSyncMin 54
set fSyncMax 56
set fSync 55.18

frame .fs
entry .fs.fSyncMin -textvariable fSyncMin -width 8
entry .fs.fSyncMax -textvariable fSyncMax -width 8
entry .fs.fSync_e -textvariable fSync -width 8
scale .fSync -from $fSyncMin -to $fSyncMax -variable fSync -orient horizontal -resolution 0.01
scale .tWin -from 0.001 -to 0.1 -variable tWin -orient horizontal -resolution 0.001
pack .fs.fSyncMin .fs.fSync_e .fs.fSyncMax -side left
pack .fs .fSync .tWin

