#!/bin/sh

# \
exec wish "$0" ${1+"$@"}

# 16 décembre 2001 (FP)

package require snack
package require fidev
package require blasObj
package require dblas1
package require hsplot
package require blasmath

puts stderr "packages OK"

# lecture d'un son enregistré
snack::sound s -rate 44100
s read ~/Z/la.raw
# s play

puts stderr "son lu"

binary scan [s data] s* l
# $l est la liste des amplitudes (int 16 bits)

puts stderr "son scanné"

s min
set height 500
set width 500

puts stderr "s min"

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

set v [blas::vector create double $l]
# $v est la liste des amplitudes (double)

puts stderr "v créé"

set min [blas::mathop min $v]
set max [blas::mathop max $v]
blas::mathsvop v +scal [expr {-$max}]
blas::mathsvop v *scal [expr {-($height-1)/($max-$min)}]
# $v est normalisé de 0 à $height

puts stderr "v scalé"

# bug qui interdit blas::subvector getvector $v
set vv $v
# set vv [lindex $v 3] ; set rien 0

puts stderr "cvv créé"

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

proc plotPlot {delai} {
    global tStart
    set t [expr {1e-6*double([clock clicks] - $tStart)}]
    plotFrame $t
    after $delai [list plotPlot $delai]

}

proc plotFrame {t} {
    global tWin tSyncStart fSync tFirst tEch
    global vv tv av x y N xy xyTmp
    global fPixelFenetre

    
    # On est à l'instant $t relativement au début.
    # On veut afficher dans la fenêtre.
    # Il faut aller chercher l'instant de synchro précédent
    # $tSyncStart + $Ns * $tSync
    # égal à $t - $tWin + frac * $tSync
    set Ns [expr {floor (($t - $tWin - $tSyncStart)*$fSync)}]
 
   # index de l'instant $t dans le son
    set iBegin [expr {int(floor(($Ns/$fSync - $tFirst)/$tEch))}]
    
    # instants relatifs au début de fenêtre
    blas::mathsvop tv fill1 [expr {$tFirst + $iBegin * $tEch - $tSyncStart - $Ns/$fSync}] $tEch 
    
    # idem en coordonnées fenêtre
    blas::mathsvop tv *scal $fPixelFenetre
    blas::mathsvop x <-double $tv

    # puts stderr "$iBegin [lindex $x 0]"


    incr iBegin 1
    if {$iBegin < 1} {
	puts stderr wait
	return
    }

    blas::dcopy [blas::subvector create $iBegin 1 $N $vv] av

    blas::mathsvop y <-double $av

    blas::mathsvop x ddif
    blas::mathsvop y ddif

    set xy $xyTmp


}

proc essai {} {
    global fSync tStart fSyncMin fSyncMax

    raise .
    .fSync configure -from $fSyncMin -to $fSyncMax

    # $tSync est la période de synchro

    set tStart [clock clicks] ; plotPlot 50
}

canvas .c -width 500 -height 500
pack .c
.c create hsplot 0 0 500 500 -xyblas xy

# essai 441.45

button .b -text start -command {essai}
pack .b

set fSyncMin 432
set fSyncMax 444

entry .fSyncMin -textvariable fSyncMin
entry .fSyncMax -textvariable fSyncMax
scale .fSync -from $fSyncMin -to $fSyncMax -variable fSync -orient horizontal -resolution 0.01
pack .fSyncMin .fSync .fSyncMax

