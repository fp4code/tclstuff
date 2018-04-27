#
# structure :
# 
#

namespace eval ::tpg::Struct {
    variable CREES
}

proc ::tpg::Struct::new {sname} {
    puts $sname
    global enCours
    variable CREES
    set enCours(sname) $sname
    upvar S,$sname struct
    if [info exists struct] {
        if {$struct(rn,S) != {} || $struct(id,B) != {}} {
            error "La structure \"$sname\" existe et n'est pas vierge"
        } else {
            return
        }
    }
    set struct(lock) 1         ;# verrou d'accès. Pas utilisé
# sans interet    set struct(id) [list]      ;# liste de B,$id S,$rname,$id etc.
    set struct(rn,S) [list]    ;# liste de $rname
    set struct(id,B) [list]    ;# liste de $id
    set struct(srefs) [list]   ;# liste des référenceuses directes
    set struct(xmin)  {}   ;# encombrement
    set struct(xmax)  {}   ;# encombrement
    set struct(ymin)  {}   ;# encombrement
    set struct(ymax)  {}   ;# encombrement
    set struct(lock) 0
#    displayWinStruct $sname
    set CREES($sname) {}
}

proc ::tpg::Struct::existElem {n} {
    upvar globNames globNames
    if {![info exists globNames($n)]} {
        error "l'élément $n n'existe pas"
    }
    unset globNames($n)
}

proc ::tpg::Struct::verifCoherence {sname} {
    upvar #0 S,$sname struct
    if {![info exists struct]} {
        error "La structure $sname n'existe pas"
    }
        
  # A - cohérence des noms des éléments de la structure associée.
    
    foreach n [array names struct *] {set globNames($n) {}}

  # A1 - cohérence des noms globaux.

    foreach n {lock rn,S id,B srefs xmin xmax ymin ymax} {existElem $n}

  # A2 - cohérence des noms de boundaries.

    if [info exists vu] {unset vu}
    foreach id $struct(id,B) {
        if [info exists vu($id)] {
            error "doublon dans id,B"
        } else {
            set vu($id) {}
        }
        foreach n [list B,$id \
                   layer,B,$id datatype,B,$id \
                   xmin,B,$id ymin,B,$id xmax,B,$id ymax,B,$id \
                   ] {existElem $n}
    }

  # A2 - cohérence des noms de sref.

    if [info exists vu] {unset vu}
    foreach rname $struct(rn,S) {
        if [info exists vu($rname)] {
            error "doublon dans rn,S"
        } else {
            set vu($rname) {}
        }
        existElem id,S,$rname
        foreach id $struct(id,S,$rname) {existElem S,$rname,$id}
        foreach n {xmin ymin xmax ymax} {existElem $n,S,$rname}            
    }

  # A3 - reste des elements non vus?

    if {[array names globNames] != {}} {error "reste [array names globNames]"}

  # B - cohérences des valeurs
    set xminStruct {}
    set yminStruct {}
    set xmaxStruct {}
    set ymaxStruct {}
      
  # B1 - cohérences des boundaries

    foreach id $struct(id,B) {
        if {$struct(layer,B,$id) < 0 || $struct(layer,B,$id) > 63} {error layer,B,$id}
        if {$struct(datatype,B,$id) < 0 || $struct(datatype,B,$id) > 63} {error datatype,B,$id}
        if {![tpg::Chemin::isClos $struct(B,$id)]} {error "non clos : B,$id"} 
        if {[tpg::Chemin::tours $struct(B,$id)] != 1} {error "nombre de tours incorrect : B,$id"}
# TEST doubles et papillons a faire            
        foreach {xmin ymin xmax ymax} [tpg::Chemin::minimax $struct(B,$id)] {}
        if {$struct(xmin,B,$id) != $xmin} {error xmin,B,$id}
        if {$struct(ymin,B,$id) != $ymin} {error ymin,B,$id}
        if {$struct(xmax,B,$id) != $xmax} {error xmax,B,$id}
        if {$struct(ymax,B,$id) != $ymax} {error ymax,B,$id}
        if {$xminStruct == {} || $xminStruct > $xmin} {set xminStruct $xmin}
        if {$yminStruct == {} || $yminStruct > $ymin} {set yminStruct $ymin}
        if {$xmaxStruct == {} || $xmaxStruct < $xmax} {set xmaxStruct $xmax}
        if {$ymaxStruct == {} || $ymaxStruct < $ymax} {set ymaxStruct $ymax}
    }

  # C - cohérences des encombrements de sref
    foreach rname $struct(rn,S) {
        upvar #0 S,$rname sref
        if {![info exists sref]} {
            error "rname n'existe pas"
        }
        set xmin {}
        set ymin {}
        set xmax {}
        set ymax {}
            
#puts "xmin=$xmin ymin=$ymin xmax=$xmax ymax=$ymax"
        foreach id $struct(id,S,$rname) {
#puts "id=$id"
            foreach {x y} $struct(S,$rname,$id) {
                if {$xmin == {} || $xmin > $x} {set xmin $x}
                if {$ymin == {} || $ymin > $y} {set ymin $y}
                if {$xmax == {} || $xmax < $x} {set xmax $x}
                if {$ymax == {} || $ymax < $y} {set ymax $y}
#puts "x=$x y=$y"
#puts "xmin=$xmin ymin=$ymin xmax=$xmax ymax=$ymax"
            }
        }
        if {$struct(xmin,S,$rname) != $xmin} {error xmin,S,$rname}
        if {$struct(ymin,S,$rname) != $ymin} {error ymin,S,$rname}
        if {$struct(xmax,S,$rname) != $xmax} {error xmax,S,$rname}
        if {$struct(ymax,S,$rname) != $ymax} {error ymax,S,$rname}

        if {$sref(xmin) != {}} {
            set xmin [expr $xmin + $sref(xmin)]
            if {$xminStruct == {} || $xminStruct > $xmin} {set xminStruct $xmin}
        }
        if {$sref(ymin) != {}} {
            set ymin [expr $ymin + $sref(ymin)]
            if {$yminStruct == {} || $yminStruct > $ymin} {set yminStruct $ymin}
        }
        if {$sref(xmax) != {}} {
            set xmax [expr $xmax + $sref(xmax)]
            if {$xmaxStruct == {} || $xmaxStruct < $xmax} {set xmaxStruct $xmax}
        }
        if {$sref(ymax) != {}} {
            set ymax [expr $ymax + $sref(ymax)]
            if {$ymaxStruct == {} || $ymaxStruct < $ymax} {set ymaxStruct $ymax}
        }
    }
    if {$struct(xmin) != $xminStruct} {error "xmin"}
    if {$struct(ymin) != $yminStruct} {error "ymin"}
    if {$struct(xmax) != $xmaxStruct} {error "xmax"}
    if {$struct(ymax) != $ymaxStruct} {error "ymax"}


  # D - cohérence sref amont

    foreach sr $struct(srefs) {
        upvar #0 S,$sr referenceuse
        if {![info exists referenceuse(id,S,$sname)]} {
            error "srefs : $sr ne référence pas"
        }
    }


  # E - cohérence sref aval

    foreach sr $struct(rn,S) {
        upvar #0 S,$sr referencee
        if {[lsearch $referencee(srefs) $sname] < 0} {
            error "$sname n'est pas dans srefs de $sr"
            }
        }
    }
    
proc ::tpg::Struct::verifCoherenceTotale {} {
    variable CREES
    foreach struct [array names CREES] {
        if [catch {verifCoherence $struct} err] {
            puts stderr "incohérence sur $struct : $err"
        }
    }
}

proc ::tpg::Struct::copie {from to} {
    global enCours
    set enCours(sname) {}

    upvar #0 S,$to sTo
    upvar #0 S,$from sFrom
    if [info exists sTo] {
        error "La structure $to existe"
    }
    if {![info exists from]} {
        error "La structure $from n'existe pas"
    }
#    set struct(lock) 1
    foreach n [array names sFrom] {
        set sTo($n) $sFrom($n)
    }
    set sTo(srefs) {}
    foreach sr $sTo(rn,S) {
        upvar #0 S,$sr referencee
        lappend $referencee(srefs) $to
    }
}

proc ::tpg::Struct::copieAllWithPrefix {prefixe sname} {
    global enCours
    set enCours(sname) {}

    set afaire [referencees $sname]
    lappend afaire $sname
    if {![isCluster $afaire]} {
        error "n'est pas a la tête d'un cluster"
    }

    foreach from $afaire {
        upvar #0 S,$prefixe$from sTo
        if [info exists sTo] {
            error "S,$prefixe$from existe déjà"
        }
    }

    foreach from $afaire {
        upvar #0 S,$from sFrom
        upvar #0 S,$prefixe$from sTo
        foreach n {lock id,B srefs xmin xmax ymin ymax} {set sTo($n) $sFrom($n)}
        foreach id $sFrom(id,B) {
            foreach n [list B,$id \
                   layer,B,$id datatype,B,$id \
                   xmin,B,$id ymin,B,$id xmax,B,$id ymax,B,$id \
                   ] {
                set sTo($n) $sFrom($n)
            }
        }
        set sTo(rn,S) [list]
        foreach rnameFrom $sFrom(rn,S) {
            set rnameTo $prefixe$rnameFrom
            lappend sTo(rn,S) $rnameTo
            set sTo(id,S,$rnameTo) $sFrom(id,S,$rnameFrom)
            foreach id $sFrom(id,S,$rnameFrom) {
                set sTo(S,$rnameTo,$id) $sFrom(S,$rnameFrom,$id)
            }
            foreach n {xmin ymin xmax ymax} {
                set sTo($n,S,$rnameTo) $sFrom($n,S,$rnameFrom)
            }
        }
    }
}

proc ::tpg::Struct::copieWithPrefix {prefixe from} {
    copie $from $prefixe$from
}

proc ::tpg::Struct::referencees {sname {profondeur {}}} {
    upvar #0 S,$sname struct
    foreach rname [array names struct id,S,*] {
        set rname [string range $rname 5 end]
        set refs($rname) 1
        if {$profondeur != {}} {
            incr profondeur -1
        }
        if {$profondeur == {} || $profondeur >= 0} {
            foreach r [referencees $rname $profondeur] {
                set refs($r) 1
            }
        }
    }
    return [array names refs]
}

set HELP(::tpg::Struct::isCluster) {
    un Cluster est un ensemble de structures qui ne sont pas reférencées par
    une structure qui n'en fait pas partie
}

proc ::tpg::Struct::isCluster {structList} {
    foreach s $structList {
        upvar #0 S,$s struct
        foreach sr $struct(srefs) {
            if {[lsearch $structList $sr] < 0} {
                return 0
            }
        }
    }
    return 1
}


proc ::tpg::Struct::dilate {facteur sname prof} {
    if {$prof == {} || $prof > 0} {
        set afaire [referencees $sname $prof]
    }
    lappend afaire $sname
# il faudrait poser des verrous
    if {![isCluster $afaire]} {
        error "n'est pas a la tête d'un cluster"
    }

    foreach s $afaire {
        upvar #0 S,$s struct
        foreach obj [array names struct S,*] {
            foreach {x y} $struct($obj) {
# lreplace serait-il mieux ? non, pas meme lsubst
                set struct($obj) [list [expr $x*$facteur] [expr $y*$facteur]]
            }
        }
        set scalaires [concat [list xmin ymin xmax ymax] \
                             [array names struct xmin,S,*] \
                             [array names struct xmax,S,*] \
                             [array names struct ymin,S,*] \
                             [array names struct ymax,S,*] \
                             [array names struct xmin,B,*] \
                             [array names struct xmax,B,*] \
                             [array names struct ymin,B,*] \
                             [array names struct ymax,B,*]]
        foreach v $scalaires {
            set struct($v) [expr $struct($v)*$facteur]
        }
        foreach obj [array names struct B,*] {
            set struct($obj) [tpg::Chemin::dilated $facteur $struct($obj)]
        }
    }
}
    
proc ::tpg::Struct::transforme {oper sname prof} {
    if {$prof == {} || $prof > 0} {
        set afaire [referencees $sname $prof]
    }
    lappend afaire $sname
# puts "afaire = $afaire"
# il faudrait poser des verrous
    if {![isCluster $afaire]} {
        error "n'est pas a la tête d'un cluster"
    }

    foreach s $afaire {
        upvar #0 S,$s struct
        foreach id $struct(id,B) {
            set struct(B,$id) [tpg::Chemin::transformed $oper $struct(B,$id)]
            set xmin $struct(xmin,B,$id)
            set ymin $struct(ymin,B,$id)
            set xmax $struct(xmax,B,$id)
            set ymax $struct(ymax,B,$id)
            if {$oper == "rotation90"} {
                set struct(xmin,B,$id) [expr -$ymax]
                set struct(xmax,B,$id) [expr -$ymin]
                set struct(ymin,B,$id) $xmin
                set struct(ymax,B,$id) $xmax
            } elseif {$oper == "rotation180"} {
                set struct(xmin,B,$id) [expr -$xmax]
                set struct(xmax,B,$id) [expr -$xmin]
                set struct(ymin,B,$id) [expr -$ymax]
                set struct(ymax,B,$id) [expr -$ymin]
            } elseif {$oper == "rotation270"} {
                set struct(xmin,B,$id) $ymin
                set struct(xmax,B,$id) $ymax
                set struct(ymin,B,$id) [expr -$xmax]
                set struct(ymax,B,$id) [expr -$xmin]
            } else {
                error "operation \"$oper\" interdite"
            }
        }
        foreach rname $struct(rn,S) {
            foreach id $struct(id,S,$rname) {
                foreach {x y} $struct(S,$rname,$id) {
                    set struct(S,$rname,$id) [tpg::Point::$oper $x $y]
                }
                set xmin $struct(xmin,S,$rname)
                set ymin $struct(ymin,S,$rname)
                set xmax $struct(xmax,S,$rname)
                set ymax $struct(ymax,S,$rname)
                if {$oper == "rotation90"} {
                    set struct(xmin,S,$rname) [expr -$ymax]
                    set struct(xmax,S,$rname) [expr -$ymin]
                    set struct(ymin,S,$rname) $xmin
                    set struct(ymax,S,$rname) $xmax
                } elseif {$oper == "rotation180"} {
                    set struct(xmin,S,$rname) [expr -$xmax]
                    set struct(xmax,S,$rname) [expr -$xmin]
                    set struct(ymin,S,$rname) [expr -$ymax]
                    set struct(ymax,S,$rname) [expr -$ymin]
                } elseif {$oper == "rotation270"} {
                    set struct(xmin,S,$rname) $ymin
                    set struct(xmax,S,$rname) $ymax
                    set struct(ymin,S,$rname) [expr -$xmax]
                    set struct(ymax,S,$rname) [expr -$xmin]
                } else {
                    error "operation \"$oper\" interdite"
                }
            }
        }
#    puts -nonewline "$sname : $xmin"
        set xmin $struct(xmin)
        set ymin $struct(ymin)
        set xmax $struct(xmax)
        set ymax $struct(ymax)
        if {$oper == "rotation90"} {
            set struct(xmin) [expr -$ymax]
            set struct(xmax) [expr -$ymin]
            set struct(ymin) $xmin
            set struct(ymax) $xmax
        } elseif {$oper == "rotation180"} {
            set struct(xmin) [expr -$xmax]
            set struct(xmax) [expr -$xmin]
            set struct(ymin) [expr -$ymax]
            set struct(ymax) [expr -$ymin]
        } elseif {$oper == "rotation270"} {
            set struct(xmin) $ymin
            set struct(xmax) $ymax
            set struct(ymin) [expr -$xmax]
            set struct(ymax) [expr -$xmin]
        } else {
            error "operation \"$oper\" interdite"
        }
#    puts "-> $xmin"
    }
}        
    
proc ::tpg::Struct::empate {facteur sname} {
    upvar #0 S,$sname struct

    if {[array names struct *,S,*] != {}} {
        error "On ne peut empater une structure qui contient des Sref"
    }

    set xminA {}
    set xmaxA {}
    set yminA {}
    set ymaxA {}

    foreach obj [array names struct B,*] {
        set chemin [tpg::Chemin::empated $facteur $struct($obj)]
#        puts "AVANT $struct($obj)"
#        puts "APRES $chemin"
        set struct($obj) $chemin
        foreach {xmin ymin xmax ymax} [tpg::Chemin::minimax $chemin] {
            if {$xminA == {} || $xminA > $xmin} {
                set xminA $xmin
            }
            if {$yminA == {} || $yminA > $ymin} {
                set yminA $ymin
            }
            if {$xmaxA == {} || $xmaxA < $xmax} {
                set xmaxA $xmax
            }
            if {$ymaxA == {} || $ymaxA < $ymax} {
                set ymaxA $ymax
            }
            set struct(xmin,$obj) $xmin
            set struct(xmax,$obj) $xmax
            set struct(ymin,$obj) $ymin
            set struct(ymax,$obj) $ymax
        }
    }

    if {$xminA != {}} {
        modifBords $sname $xminA $yminA $xmaxA $ymaxA
    }
}
    
    
set HELP(::tpg::Struct::informeReferenceuse) {
    la structure $qui informe la structure $sname que le bord $quoi (xmin, ymin, xmax ou ymax)
    a bougé de $combienOld à $combien
    $combienOld peut être {} mais pas $combien
}

proc ::tpg::Struct::informeReferenceuse {sname qui quoi combien combienOld} {
    upvar #0 S,$sname struct

    if {![info exists struct]} {
        error "\"$sname\" n'existe pas"
    }

    if {$quoi == "xmin"} {
        set xmin [expr $struct(xmin,S,$qui) + $combien]
        set xminOld [expr $struct(xmin,S,$qui) + $combienOld]
        if {$xmin < $struct(xmin) || ($xminOld == $struct(xmin) && $combien != $combienOld)} {
            modifBord $sname xmin $xmin
        }
    } elseif {$quoi == "ymin"} {
        set ymin [expr $struct(ymin,S,$qui) + $combien]
        set yminOld [expr $struct(ymin,S,$qui) + $combienOld]
        if {$ymin < $struct(ymin) || ($yminOld == $struct(ymin) && $combien != $combienOld)} {
            modifBord $sname ymin $ymin
        }
    } elseif {$quoi == "xmax"} {
        set xmax [expr $struct(xmax,S,$qui) + $combien]
        set xmaxOld [expr $struct(xmax,S,$qui) + $combienOld]
        if {$xmax > $struct(xmax) || ($xmaxOld == $struct(xmax) && $combien != $combienOld)} {
            modifBord $sname xmax $xmax
        }
    } elseif {$quoi == "ymax"} {
        set ymax [expr $struct(ymax,S,$qui) + $combien]
        set ymaxOld [expr $struct(ymax,S,$qui) + $combienOld]
        if {$ymax > $struct(ymax) || ($ymaxOld == $struct(ymmax) && $combien != $combienOld)} {
            modifBord $sname ymax $ymax
        }
    }
}
    
set HELP(::tpg::Struct::informeReferenceuse4) {
    la structure $qui informe la structure $sname que les bord (xmin, ymin, xmax ou ymax)
    ont éventuellement bougé de $xmin à $xminOld, etc.
    $xmin et $xminOld, etc. peuvent être {}
}

proc ::tpg::Struct::informeReferenceuse4 {sname qui xmin ymin xmax ymax xminOld yminOld xmaxOld ymaxOld} {
    upvar #0 S,$sname struct

    if {![info exists struct]} {
        return
    }

    set xmin [expr $struct(xmin,S,$qui) + $xmin]
    set xminOld [expr $struct(xmin,S,$qui) + $xminOld]
    if {($xmin != {} && $xmin < $struct(xmin)) || ($xminOld == $struct(xmin) && $xmin != $xminOld)} {
        modifBord $sname xmin $xmin
    }
    set ymin [expr $struct(ymin,S,$qui) + $ymin]
    set yminOld [expr $struct(ymin,S,$qui) + $yminOld]
    if {($ymin != {} && $ymin < $struct(ymin)) || ($yminOld == $struct(ymin) && $ymin != $yminOld)} {
        modifBord $sname ymin $ymin
    }
    set xmax [expr $struct(xmax,S,$qui) + $xmax]
    set xmaxOld [expr $struct(xmax,S,$qui) + $xmaxOld]
    if {($xmax != {} && $xmax > $struct(xmax)) || ($xmaxOld == $struct(xmax) && $xmax != $xmaxOld)} {
        modifBord $sname xmax $xmax
    }
    set ymax [expr $struct(ymax,S,$qui) + $ymax]
    set ymaxOld [expr $struct(ymax,S,$qui) + $ymaxOld]
    if {($ymax != {} && $ymax > $struct(ymax)) || ($ymaxOld == $struct(ymax) && $ymax != $ymaxOld)} {
        modifBord $sname ymax $ymax
    }
}


set HELP(::tpg::Struct::modifBord) {
    un élément Sref, Boundary, etc. ayant bougé (ou ayant été créé),
    le bord $quoi de $sname vaut maintenant $combien
    On modifie la valeur struct($quoi) et on informe les référenceuses
}


proc ::tpg::Struct::modifBord {sname quoi combien} {
#puts "modifBord $sname $quoi $combien"
    upvar #0 S,$sname struct

    set combienOld $struct($quoi)
    set struct($quoi) $combien

    foreach ref $struct(srefs) {
        informeReferenceuse $ref $sname $quoi $combien $combienOld
    }
}
    
set HELP(::tpg::Struct::modifBords) {
    un élément Sref, Boundary, etc. ayant bougé (ou ayant été créé),
    les bords de $sname valent maintenant $xmin $ymin $xmax $ymax
    On modifie la valeur struct(xmin), etc. et on informe les référenceuses
}

proc ::tpg::Struct::modifBords {sname xmin ymin xmax ymax} {
    upvar #0 S,$sname struct
# puts "modifBords $sname $xmin $xmax $ymin $ymax"
    set xminOld $struct(xmin)
    set yminOld $struct(ymin)
    set xmaxOld $struct(xmax)
    set ymaxOld $struct(ymax)
    set struct(xmin) $xmin
    set struct(ymin) $ymin
    set struct(xmax) $xmax
    set struct(ymax) $ymax

    foreach ref $struct(srefs) {
        informeReferenceuse4 $ref $sname $xmin $ymin $xmax $ymax $xminOld $yminOld $xmaxOld $ymaxOld
    }
}

proc ::tpg::Struct::setLayer {sname layer} {
    upvar #0 S,$sname struct
    foreach obj [array names struct layer,*] {
        set struct(obj) $layer 
    }
}


proc ::tpg::Struct::newBoundary {sname chemin layer datatype} {
    upvar S,$sname struct
    set chemin [::tpg::Chemin::bonSens $chemin]
    if {$struct(id,B) == {}} {
        set id 0
    } else {
        set id [lindex $struct(id,B) end]
        incr id
    }
    lappend struct(id,B) $id
#    lappend struct(id) B,$id
    set struct(B,$id) $chemin
    foreach {xmin ymin xmax ymax} [tpg::Chemin::minimax $chemin] {
        set struct(layer,B,$id) $layer
        set struct(datatype,B,$id) $datatype
        set struct(xmin,B,$id) $xmin
        set struct(xmax,B,$id) $xmax
        set struct(ymin,B,$id) $ymin
        set struct(ymax,B,$id) $ymax

        if {$struct(xmin) == {} || $xmin < $struct(xmin)} {
            modifBord $sname xmin $xmin
        }
        if {$struct(ymin) == {} || $ymin < $struct(ymin)} {
            modifBord $sname ymin $ymin
        }
        if {$struct(xmax) == {} || $xmax > $struct(xmax)} {
            modifBord $sname xmax $xmax
        }
        if {$struct(ymax) == {} || $ymax > $struct(ymax)} {
            modifBord $sname ymax $ymax
        }
    }
#    afficheBoundary $sname $id
}

proc ::tpg::Struct::newSref {sname rname x y} {
    upvar #0 S,$sname struct
    upvar #0 S,$rname sref
    if [info exists struct(parents,$rname)] {
        error "sref impossible : $rname est deja un parent de $sname"
    }
    if {![info exists sref]} {
        new $rname
    }
    if {![info exists struct(id,S,$rname)]} {
        set id 0
        lappend struct(rn,S) $rname
        lappend sref(srefs) $sname
    } else {
        set id [lindex $struct(id,S,$rname) end]
        incr id
    }
    lappend struct(id,S,$rname) $id
#    lappend struct(id) S,$rname,$id
    set struct(S,$rname,$id) [list $x $y]
    if {$id == 0} {
        set struct(xmin,S,$rname) $x
        set struct(xmax,S,$rname) $x
        set struct(ymin,S,$rname) $y
        set struct(ymax,S,$rname) $y
        set xmin [expr $sref(xmin) + $x]
        set xmax [expr $sref(xmax) + $x]
        set ymin [expr $sref(ymin) + $y]
        set ymax [expr $sref(ymax) + $y]
        if {$struct(xmin) == {} || $xmin < $struct(xmin)} {
            modifBord $sname xmin $xmin
        }
        if {$struct(ymin) == {} || $ymin < $struct(ymin)} {
            modifBord $sname ymin $ymin
        }
        if {$struct(xmax) == {} || $xmax > $struct(xmax)} {
            modifBord $sname xmax $xmax
        }
        if {$struct(ymax) == {} || $ymax > $struct(ymax)} {
            modifBord $sname ymax $ymax
        }
    } else {
        if {$x < $struct(xmin,S,$rname)} {
            set struct(xmin,S,$rname) $x
            set xmin [expr $sref(xmin) + $x]
            if {$xmin < $struct(xmin)} {
                modifBord $sname xmin $xmin
            }
        }
        if {$x > $struct(xmax,S,$rname)} {
            set struct(xmax,S,$rname) $x
            set xmax [expr $sref(xmax) + $x]
            if {$xmax > $struct(xmax)} {
                modifBord $sname xmax $xmax
            }
        }
        if {$y < $struct(ymin,S,$rname)} {
            set struct(ymin,S,$rname) $y
            set ymin [expr $sref(ymin) + $y]
            if {$ymin < $struct(ymin)} {
                modifBord $sname ymin $ymin
            }
        }
        if {$y > $struct(ymax,S,$rname)} {
            set struct(ymax,S,$rname) $y
            set ymax [expr $sref(ymax) + $y]
            if {$ymax > $struct(ymax)} {
                modifBord $sname ymax $ymax
            }
        }
    }
    foreach p [array names struct parents,*] {
        if [info exists sref($p)] {
            incr sref($p) $struct($p)
        } else {
            set sref($p) $struct($p)
        }
    }
}


proc ::tpg::Struct::delete {sname} {
    upvar #0 S,$sname struct
    destroy .s:$sname
    variable CREES
    foreach rname $struct(rn,S) {
        upvar #0 S,$rname sref
        # ecrire une proc
        set ii [lsearch $sref(srefs) $sname]
        if {$ii < 0} {
            error "\"$sname\" référence \"rname\" mais \"$rname(srefs)\" ne contient pas \"$sname\""
        }
        set sref(srefs) [concat \
            [lrange $sref(srefs) 0 [expr $ii - 1]] \
            [lrange $sref(srefs) [expr $ii +1] end]]
        
    }
    if {$struct(srefs) == {}} {
        unset struct
        unset CREES($sname)
        return 0
    } else {
        set srefs $struct(srefs)
        set xminOld $struct(xmin)
        set yminOld $struct(ymin)
        set xmaxOld $struct(xmax)
        set ymaxOld $struct(ymax)
        unset struct
        new $sname
        set struct(srefs) $srefs
        foreach ref $struct(srefs) {
            informeReferenceuse4 $ref $sname {} {} {} {} $xminOld $yminOld $xmaxOld $ymaxOld
        }
        return 1
    }
}











