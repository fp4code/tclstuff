#!/bin/sh

# \
exec wish "$0" ${1+"$@"}

# 17 décembre 2001 (FP)

package require snack
package require fidev
package require blasObj
package require dblas1
package require hsplot
package require blasmath

puts stderr "packages OK"

set height 500
set width 500

sound s -changecommand plotFrame

# $tWin est la largeur temporelle de la fenêtre 
set tWin 0.005

set fPixelFenetre [expr {($width - 1)/$tWin}]

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

# $tEch est la période d'échantillonage
set fEch [lindex [s info] 1]
set tEch [expr {1.0/$fEch}]

# nombre de points des vecteurs
set N [expr {1+int(ceil(($tWin)/$tEch))}]

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

set av [blas::vector create double -length $N]
set tv [blas::vector create double -length $N]
set xy [blas::vector create short -length [expr 2*$N]]
set xyTmp  [blas::vector create short -length [expr 2*$N]]
set x [blas::subvector create 1 2 $N from xyTmp]
set y [blas::subvector create 2 2 $N from xyTmp]


set tSyncStart 0.0
# instants d'échantillonage =$tFirst + $i * $tEch
set tFirst 0.0

proc plotFrame {args} {
    global tWin tSyncStart fSync tFirst tEch
    global vv tv av x y N xy xyTmp
    global fPixelFenetre
    global height tIni

    set last [s length]
    set t [expr {double($last)*double($tEch)}]

    set tReal [expr {([clock clicks] - $tIni)*1e-6}]
    if {$tReal - $t > 0.1} {
	return
    }
    # puts "$tReal - $t = [expr {$tReal - $t}]"
    puts -nonewline stderr \r$tReal
    
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
	puts stderr wait
	return
    }

    # puts stderr "$iBegin $last"

    binary scan [s data -start $iBegin -end [expr {$iBegin + int($Ns) + 1}]] s* l
    # $l est la liste des amplitudes (int 16 bits)

    # puts stderr [llength $l]
    if {$l == {}} {
	return
    }

    set v [blas::vector create double $l]
    # $v est la liste des amplitudes (double)

    set min [blas::mathop min $v]
    set max [blas::mathop max $v]

    set min -2000.
    set max 2000.

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


}

proc essai {} {
    global fSync tStart fSyncMin fSyncMax
    global tIni

    raise .
    .fSync configure -from $fSyncMin -to $fSyncMax

    # $tSync est la période de synchro

    set tIni0 [clock clicks]
    s record
    set tIni [clock clicks]
    puts stderr [expr {($tIni - $tIni0)*1e-6}]
}

canvas .c -width 500 -height 500
pack .c
.c create hsplot 0 0 500 500 -xyblas xy

# essai 441.45

button .b -text start -command {essai}
pack .b

set fSyncMin 438
set fSyncMax 442
set fSync 440

entry .fSyncMin -textvariable fSyncMin
entry .fSyncMax -textvariable fSyncMax
scale .fSync -from $fSyncMin -to $fSyncMax -variable fSync -orient horizontal -resolution 0.01
pack .fSyncMin .fSync .fSyncMax

