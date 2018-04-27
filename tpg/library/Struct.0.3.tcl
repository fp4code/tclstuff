# 22 avril 2002 (FP) Struct.0.3.tcl




namespace eval tpg::Struct {
    variable CREES
}

set Aide(tpg::Struct) {
    Une structure de dessin de nom "toto"
    correspond à un tableau associatif global de nom "S,name"
    Les différentes clés sont les suivantes :

    struct(lock)  verrou d'accès. Pas utilisé pour l'instant

    struct(xmin)  encombrement
    struct(xmax)  encombrement
    struct(ymin)  encombrement
    struct(ymax)  encombrement


Boundary :

    struct(id,B)            liste de $id de boundary (à supprimer)

    struct(B,$id)           chemin dans le bon sens
    struct(layer,B,$id)     layer
    struct(datatype,B,$id)    
    struct(xmin,B,$id)
    struct(xmax,B,$id)
    struct(ymin,B,$id)
    struct(ymax,B,$id)

Sref :

    struct(id,S,$rname)   liste de id sref de $rname (à supprimer)
 
    struct(xmin,S,$rname) encombrement de toutes les références de $rname
    struct(xmax,S,$rname)
    struct(ymin,S,$rname)
    struct(ymax,S,$rname)

    struct(S,$rname,$id)  x y

    struct(parents) liste des structures référenceuses directes

}


#################################
proc ::tpg::Struct::new {structName} {
#################################
    global enCours
    variable CREES
    set enCours(structName) $structName
    upvar #0 S,$structName struct
    if {[info exists struct]} {
        if {[::tpg::Struct::srefNames $structName] != {} || $struct(id,B) != {}} {
            error "La structure \"$structName\" existe et n'est pas vierge"
        } else {
            return
        }
    }
    set struct(lock)  1
    set struct(id,B)  [list]
    set struct(parents) [list]
    set struct(xmin)  {}
    set struct(xmax)  {}
    set struct(ymin)  {}
    set struct(ymax)  {}
    set CREES($structName) {}
    set struct(lock)  0
    # displayWinStruct $structName
}

###################################
proc ::tpg::Struct::existElem {n} {
###################################
    upvar globNames globNames
    if {![info exists globNames($n)]} {
        error "l'élément $n n'existe pas"
    }
    unset globNames($n)
}

#################################################
proc ::tpg::Struct::verifCoherence {structName} {
#################################################
    upvar #0 S,$structName struct
    if {![info exists struct]} {
        return -code error "La structure $structName n'existe pas"
    }
        
  # A - cohérence des noms des éléments de la structure associée.
    
    foreach n [array names struct *] {set globNames($n) {}}

  # A1 - cohérence des noms globaux.

    foreach n {lock id,B parents xmin xmax ymin ymax} {existElem $n}

  # A2 - cohérence des noms de boundaries.

    if {[info exists vu]} {unset vu}
    foreach id $struct(id,B) {
        if {[info exists vu($id)]} {
            error "doublon dans id,B"
        } else {
            set vu($id) {}
        }
        foreach n [list B layer,B datatype,B xmin,B ymin,B xmax,B ymax,B] {existElem ${n},$id}
    }

  # A2 - cohérence des noms de sref.

    foreach rname [ ::tpg::Struct::srefNames $structName] {
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
    foreach rname [::tpg::Struct::srefNames $structName] {
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
        if {$struct(xmin,S,$rname) != $xmin} {error "(xmin,S,$rname = $struct(xmin,S,$rname)) != $xmin"}
        if {$struct(ymin,S,$rname) != $ymin} {error "(ymin,S,$rname = $struct(ymin,S,$rname)) != $ymin"}
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

    foreach parentName $struct(parents) {
        upvar #0 S,$parentName parent
        if {![info exists parent(id,S,$structName)]} {
            error "parents : \"$parentName\" ne référence pas \"$structName\""
        }
    }


  # E - cohérence sref aval

    foreach childrenName [::tpg::Struct::srefNames $structName] {
        upvar #0 S,$childrenName children
        if {[lsearch $children(parents) $structName] < 0} {
            error "\"$structName\" n'est pas dans parents de \"$childrenName\""
        }
    }
}

#############################################
proc ::tpg::Struct::verifCoherenceTotale {} {
#############################################
    variable CREES
    foreach struct [array names CREES] {
        if {[catch {verifCoherence $struct} err]} {
            puts stderr "incohérence sur $struct : $err"
        }
    }
}

###############################################
proc ::tpg::Struct::copie {sFromName sToName} {
###############################################
    global enCours
    set enCours(structName) {}

    upvar #0 S,$sToName sTo
    upvar #0 S,$sFromName sFrom
    if {[info exists sTo]} {
        return -code error "La structure \"$sToName\" existe"
    }
    if {![info exists sFrom]} {
        return -code error "La structure \"$sFromName\" n'existe pas"
    }
#    set struct(lock) 1
    foreach n [array names sFrom] {
        set sTo($n) $sFrom($n)
    }
    set sTo(parents) {}
    foreach childrenName [::tpg::Struct::srefNames $sToName] {
        upvar #0 S,$childrenName children
        lappend $children(parents) $sToName
    }
}

#############################################################
proc ::tpg::Struct::copieAllWithPrefix {prefixe structName} {
#############################################################
    global enCours
    set enCours(structName) {}

    # set afaire [::tpg::Struct::children $structName]
    set afaire [::tpg::Struct::allSrefNames $structName]
    lappend afaire $structName

    foreach from $afaire {
        set sToName $prefixe$from
        upvar #0 S,$sToName sTo
        if {[info exists sTo]} {
            return -code error "\"$sToName\" existe déjà"
        }
    }
    catch {unset from}

    foreach sFromName $afaire {
        set sToName $prefixe$sFromName
        upvar #0 S,$sFromName sFrom
        upvar #0 S,$sToName sTo
        foreach n {lock id,B xmin xmax ymin ymax} {
            set sTo($n) $sFrom($n)
        }
        set sTo(parents) {}
        if {$sFromName != $structName} {
            foreach parent $sFrom(parents) {
                lappend sTo(parents) $prefixe$parent
            }
        }

        foreach id $sFrom(id,B) {
            foreach n [list B,$id \
                   layer,B,$id datatype,B,$id \
                   xmin,B,$id ymin,B,$id xmax,B,$id ymax,B,$id \
                   ] {
                set sTo($n) $sFrom($n)
            }
        }
        foreach rnameFrom [::tpg::Struct::srefNames $sFromName] {
            set rnameTo $prefixe$rnameFrom
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


#################################################################################
proc ::tpg::Struct::copieAllWithPrefix+transform {transform prefixe structName} {
#################################################################################
    global enCours
    set enCours(structName) {}

    # set afaire [::tpg::Struct::children $structName]
    set afaire [::tpg::Struct::allSrefNames $structName]

    lappend afaire $structName

    puts stderr "afaire = $afaire"
    foreach from $afaire {
        set sToName $prefixe$from
        upvar #0 S,$sToName sTo
        if {[info exists sTo]} {
            return -code error "\"$sToName\" existe déjà"
        }
    }
    catch {unset from}

    foreach sFromName $afaire {
        set sToName $prefixe$sFromName
        upvar #0 S,$sFromName sFrom
        upvar #0 S,$sToName sTo
        foreach n {lock id,B} {
            set sTo($n) $sFrom($n)
        }
        set sTo(parents) {}
        if {$sFromName != $structName} {
            foreach parent $sFrom(parents) {
                lappend sTo(parents) $prefixe$parent
            }
        }
        set xymin [tpg::Point::$transform $sFrom(xmin) $sFrom(ymin)]
        set xymax [tpg::Point::$transform $sFrom(xmax) $sFrom(ymax)]
        
        set xmin [lindex $xymin 0]
        set xmax [lindex $xymax 0]
        set ymin [lindex $xymin 1]
        set ymax [lindex $xymax 1]
        if {$xmin <= $xmax} {
            set sTo(xmin) $xmin
            set sTo(xmax) $xmax
        } else {
            set sTo(xmin) $xmax
            set sTo(xmax) $xmin
        }
        if {$ymin <= $ymax} {
            set sTo(ymin) $ymin
            set sTo(ymax) $ymax
        } else {
            set sTo(ymin) $ymax
            set sTo(ymax) $ymin
        }

        foreach id $sFrom(id,B) {
            set sTo(B,$id) [::tpg::Chemin::transformed $transform $sFrom(B,$id)]
            foreach n [list layer,B,$id datatype,B,$id] {
                set sTo($n) $sFrom($n)
            }
            set xymin [tpg::Point::$transform $sFrom(xmin,B,$id) $sFrom(ymin,B,$id)]
            set xymax [tpg::Point::$transform $sFrom(xmax,B,$id) $sFrom(ymax,B,$id)]
            set xmin [lindex $xymin 0]
            set xmax [lindex $xymax 0]
            set ymin [lindex $xymin 1]
            set ymax [lindex $xymax 1]
            if {$xmin <= $xmax} {
                set sTo(xmin,B,$id) $xmin
                set sTo(xmax,B,$id) $xmax
            } else {
                set sTo(xmin,B,$id) $xmax
                set sTo(xmax,B,$id) $xmin
            }
            if {$ymin <= $ymax} {
                set sTo(ymin,B,$id) $ymin
                set sTo(ymax,B,$id) $ymax
            } else {
                set sTo(ymin,B,$id) $ymax
                set sTo(ymax,B,$id) $ymin
            }
        }
        foreach rnameFrom [::tpg::Struct::srefNames $sFromName] {
            set rnameTo $prefixe$rnameFrom
            set sTo(id,S,$rnameTo) $sFrom(id,S,$rnameFrom)
            foreach id $sFrom(id,S,$rnameFrom) {
                set xy $sFrom(S,$rnameFrom,$id)
                set sTo(S,$rnameTo,$id) [tpg::Point::$transform [lindex $xy 0] [lindex $xy 1]]
            }
            set xymin [tpg::Point::$transform $sFrom(xmin,S,$rnameFrom) $sFrom(ymin,S,$rnameFrom)]
            set xymax [tpg::Point::$transform $sFrom(xmax,S,$rnameFrom) $sFrom(ymax,S,$rnameFrom)]
            set xmin [lindex $xymin 0]
            set xmax [lindex $xymax 0]
            set ymin [lindex $xymin 1]
            set ymax [lindex $xymax 1]
            if {$xmin <= $xmax} {
                set sTo(xmin,S,$rnameTo) $xmin
                set sTo(xmax,S,$rnameTo) $xmax
            } else {
                set sTo(xmin,S,$rnameTo) $xmax
                set sTo(xmax,S,$rnameTo) $xmin
            }
            if {$ymin <= $ymax} {
                set sTo(ymin,S,$rnameTo) $ymin
                set sTo(ymax,S,$rnameTo) $ymax
            } else {
                set sTo(ymin,S,$rnameTo) $ymax
                set sTo(ymax,S,$rnameTo) $ymin
            }
        }
    }
}


####################################################
proc ::tpg::Struct::copieWithPrefix {prefixe from} {
####################################################
    ::tpg::Struct::copie $from $prefixe$from
}

#######################################
set HELP(::tpg::Struct::allSrefNames) {
    Renvoit toutes les structures référencées jusqu'à une descendance $profondeur
}
##############################################################
proc ::tpg::Struct::allSrefNames {structName {profondeur {}}} {
##############################################################
    upvar #0 S,$structName struct
    foreach rname [::tpg::Struct::srefNames $structName] {
        set refs($rname) 1
        if {$profondeur != {}} {
            incr profondeur -1
        }
        if {$profondeur == {} || $profondeur >= 0} {
            foreach r [::tpg::Struct::allSrefNames $rname $profondeur] {
                set refs($r) 1
            }
        }
    }
    return [array names refs]
}

####################################
set HELP(::tpg::Struct::srefNames) {
    Renvoit les structures immédiatement référencées
}
############################################
proc ::tpg::Struct::srefNames {structName} {
############################################
    upvar #0 S,$structName struct
    foreach name+id [::tpg::Struct::srefNamesAndIds $structName] {
        set name [lindex ${name+id} 0]
        if {![info exists vu($name)]} {
            set vu($name) {}
        }
    }
    return [array names vu]
}


#########################################
set HELP(::tpg::Struct::srefNamesAndIds) {
    Renvoit les structures immédiatement référencées
}
#################################################
proc ::tpg::Struct::srefNamesAndIds {structName} {
#################################################
    upvar #0 S,$structName struct
    set ret [list]
    foreach name+id [array names struct S,*] {
        set l [split [string range ${name+id} 2 end] ,]
        if {[llength $l] != 2} {
            return -code error "S,name+id = \"${name+id}\""
        }
        lappend ret $l
    }
    return $ret
}


######################################
set HELP(::tpg::Struct::boundaryIds) {
    Renvoit les "id" de boundaries
}
##############################################
proc ::tpg::Struct::boundaryIds {structName} {
##############################################
    upvar #0 S,$structName struct
    set ids [list]
    foreach rname [array names struct B,*] {
        set l [split $rname ,]
        lappend ids [lindex $l end]
    }
    return $ids
}

####################################
set HELP(::tpg::Struct::isCluster) {
####################################
    Un Cluster est un ensemble de structures
    qui ne sont reférencées que par des structures
    qui font partie de cet ensemble.
}
############################################
proc ::tpg::Struct::isCluster {structList} {
############################################
    foreach s $structList {
        upvar #0 S,$s struct
        foreach referenceuse $struct(parents) {
            if {[lsearch $structList $referenceuse] < 0} {
                return 0
            }
        }
    }
    return 1
}


######################################################
proc ::tpg::Struct::dilate {facteur structName prof} {
######################################################
    if {$prof == {} || $prof > 0} {
        set afaire [::tpg::Struct::allSrefNames $structName $prof]
    }
    lappend afaire $structName
# il faudrait poser des verrous
    if {![isCluster $afaire]} {
        return -code error "n'est pas a la tête d'un cluster"
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
    
#######################################################
proc ::tpg::Struct::transforme {oper structName prof} {
#######################################################
    if {$prof == {} || $prof > 0} {
        set afaire [::tpg::Struct::allSrefNames $structName $prof]
    }
    lappend afaire $structName
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
        foreach rname [::tpg::Struct::srefNames $structName] {
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
#    puts -nonewline "$structName : $xmin"
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
    
############################################
proc ::tpg::Struct::empate {facteur structName} {
############################################
    upvar #0 S,$structName struct

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
        ::tpg::Struct::modifBords $structName $xminA $yminA $xmaxA $ymaxA
    }
}
    
    
##############################################
set HELP(::tpg::Struct::informeReferenceuse) {
    la structure $qui informe la structure $structName que le bord $quoi (xmin, ymin, xmax ou ymax)
    a bougé de $combienOld à $combien
    $combienOld peut être {} mais pas $combien
}
#############################################################################
proc ::tpg::Struct::informeReferenceuse {structName qui quoi combien combienOld} {
#############################################################################
    upvar #0 S,$structName struct

    if {![info exists struct]} {
        error "\"$structName\" n'existe pas"
    }

    if {$quoi == "xmin"} {
        set xmin [expr {$struct(xmin,S,$qui) + $combien}]
        set xminOld [expr {$struct(xmin,S,$qui) + $combienOld}]
        if {$xmin < $struct(xmin) || ($xminOld == $struct(xmin) && $combien != $combienOld)} {
            ::tpg::Struct::modifBord $structName xmin $xmin
        }
    } elseif {$quoi == "ymin"} {
        set ymin [expr $struct(ymin,S,$qui) + $combien]
        set yminOld [expr $struct(ymin,S,$qui) + $combienOld]
        if {$ymin < $struct(ymin) || ($yminOld == $struct(ymin) && $combien != $combienOld)} {
            ::tpg::Struct::modifBord $structName ymin $ymin
        }
    } elseif {$quoi == "xmax"} {
        set xmax [expr $struct(xmax,S,$qui) + $combien]
        set xmaxOld [expr $struct(xmax,S,$qui) + $combienOld]
        if {$xmax > $struct(xmax) || ($xmaxOld == $struct(xmax) && $combien != $combienOld)} {
            ::tpg::Struct::modifBord $structName xmax $xmax
        }
    } elseif {$quoi == "ymax"} {
        set ymax [expr $struct(ymax,S,$qui) + $combien]
        set ymaxOld [expr $struct(ymax,S,$qui) + $combienOld]
        if {$ymax > $struct(ymax) || ($ymaxOld == $struct(ymmax) && $combien != $combienOld)} {
            ::tpg::Struct::modifBord $structName ymax $ymax
        }
    }
}
    

###############################################
set HELP(::tpg::Struct::informeReferenceuse4) {
    la structure $qui informe la structure $structName que les bord (xmin, ymin, xmax ou ymax)
    ont éventuellement bougé de $xmin à $xminOld, etc.
    $xmin et $xminOld, etc. peuvent être {}
}
##########################################################################################################
proc ::tpg::Struct::informeReferenceuse4 {structName qui xmin ymin xmax ymax xminOld yminOld xmaxOld ymaxOld} {
##########################################################################################################
    upvar #0 S,$structName struct

    if {![info exists struct]} {
        return
    }

    set xmin [expr $struct(xmin,S,$qui) + $xmin]
    set xminOld [expr $struct(xmin,S,$qui) + $xminOld]
    if {($xmin != {} && $xmin < $struct(xmin)) || ($xminOld == $struct(xmin) && $xmin != $xminOld)} {
        ::tpg::Struct::modifBord $structName xmin $xmin
    }
    set ymin [expr $struct(ymin,S,$qui) + $ymin]
    set yminOld [expr $struct(ymin,S,$qui) + $yminOld]
    if {($ymin != {} && $ymin < $struct(ymin)) || ($yminOld == $struct(ymin) && $ymin != $yminOld)} {
        ::tpg::Struct::modifBord $structName ymin $ymin
    }
    set xmax [expr $struct(xmax,S,$qui) + $xmax]
    set xmaxOld [expr $struct(xmax,S,$qui) + $xmaxOld]
    if {($xmax != {} && $xmax > $struct(xmax)) || ($xmaxOld == $struct(xmax) && $xmax != $xmaxOld)} {
        ::tpg::Struct::modifBord $structName xmax $xmax
    }
    set ymax [expr $struct(ymax,S,$qui) + $ymax]
    set ymaxOld [expr $struct(ymax,S,$qui) + $ymaxOld]
    if {($ymax != {} && $ymax > $struct(ymax)) || ($ymaxOld == $struct(ymax) && $ymax != $ymaxOld)} {
        ::tpg::Struct::modifBord $structName ymax $ymax
    }
}

####################################
set HELP(::tpg::Struct::modifBord) {
    un élément Sref, Boundary, etc. ayant bougé (ou ayant été créé),
    le bord $quoi de $structName vaut maintenant $combien
    On modifie la valeur struct($quoi) et on informe les référenceuses
}
####################################################
proc ::tpg::Struct::modifBord {structName quoi combien} {
####################################################
#puts "modifBord $structName $quoi $combien"
    upvar #0 S,$structName struct

    set combienOld $struct($quoi)
    set struct($quoi) $combien

    foreach ref $struct(parents) {
        ::tpg::Struct::informeReferenceuse $ref $structName $quoi $combien $combienOld
    }
}
    
#####################################
set HELP(::tpg::Struct::modifBords) {
    un élément Sref, Boundary, etc. ayant bougé (ou ayant été créé),
    les bords de $structName valent maintenant $xmin $ymin $xmax $ymax
    On modifie la valeur struct(xmin), etc. et on informe les référenceuses
}
############################################################
proc ::tpg::Struct::modifBords {structName xmin ymin xmax ymax} {
############################################################
    upvar #0 S,$structName struct
# puts "modifBords $structName $xmin $xmax $ymin $ymax"
    set xminOld $struct(xmin)
    set yminOld $struct(ymin)
    set xmaxOld $struct(xmax)
    set ymaxOld $struct(ymax)
    set struct(xmin) $xmin
    set struct(ymin) $ymin
    set struct(xmax) $xmax
    set struct(ymax) $ymax

    foreach ref $struct(parents) {
        ::tpg::Struct::informeReferenceuse4 $ref $structName $xmin $ymin $xmax $ymax $xminOld $yminOld $xmaxOld $ymaxOld
    }
}

############################################
proc ::tpg::Struct::setLayer {structName layer} {
############################################
    upvar #0 S,$structName struct
    foreach obj [array names struct layer,*] {
        set struct(obj) $layer 
    }
}

####################################################################
proc ::tpg::Struct::newBoundary {structName chemin layer datatype} {
####################################################################
    upvar #0 S,$structName struct
    set chemin [::tpg::Chemin::bonSens $chemin]
    if {$struct(id,B) == {}} {
        set id 0
    } else {
        set id [lindex $struct(id,B) end]
        incr id
        if {$id <= 0} {
            return -code error "Trop d'appels à ::tpg::Struct::newBoundary"
        }
    }
    lappend struct(id,B) $id
    set struct(B,$id) $chemin
    foreach {xmin ymin xmax ymax} [::tpg::Chemin::minimax $chemin] {
        set struct(layer,B,$id) $layer
        set struct(datatype,B,$id) $datatype
        set struct(xmin,B,$id) $xmin
        set struct(xmax,B,$id) $xmax
        set struct(ymin,B,$id) $ymin
        set struct(ymax,B,$id) $ymax

        if {$struct(xmin) == {} || $xmin < $struct(xmin)} {
            ::tpg::Struct::modifBord $structName xmin $xmin
        }
        if {$struct(ymin) == {} || $ymin < $struct(ymin)} {
            ::tpg::Struct::modifBord $structName ymin $ymin
        }
        if {$struct(xmax) == {} || $xmax > $struct(xmax)} {
            ::tpg::Struct::modifBord $structName xmax $xmax
        }
        if {$struct(ymax) == {} || $ymax > $struct(ymax)} {
            ::tpg::Struct::modifBord $structName ymax $ymax
        }
    }
    return [list $structName $id]
#    afficheBoundary $structName $id
}


##################################
set HELP(::tpg::Struct::newSref) {
    Ajoute à la structure de nom $structName
    une SREF de nom $rname en "$x $y"
}
####################################################
proc ::tpg::Struct::newSref {structName rname x y} {
####################################################
    upvar #0 S,$structName struct
    upvar #0 S,$rname sref

    # contrôle pour éviter les références croisées
    ::tpg::Struct::parents parents $structName
    if {[info exists parents($rname)]} {
        return -code error "sref impossible : \"$rname\" est deja un parent plus ou moins lointain de \"$structName\""
    }
    
    # construit éventuellement une structure vide $rname
    if {![info exists sref]} {
        ::tpg::Struct::new $rname
    }

    # 
    if {![info exists struct(id,S,$rname)]} {
        set id 0
        lappend sref(parents) $structName
    } else {
        set id [lindex $struct(id,S,$rname) end]
        incr id
    }
    lappend struct(id,S,$rname) $id
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
            ::tpg::Struct::modifBord $structName xmin $xmin
        }
        if {$struct(ymin) == {} || $ymin < $struct(ymin)} {
            ::tpg::Struct::modifBord $structName ymin $ymin
        }
        if {$struct(xmax) == {} || $xmax > $struct(xmax)} {
            ::tpg::Struct::modifBord $structName xmax $xmax
        }
        if {$struct(ymax) == {} || $ymax > $struct(ymax)} {
            ::tpg::Struct::modifBord $structName ymax $ymax
        }
    } else {
        if {$x < $struct(xmin,S,$rname)} {
            set struct(xmin,S,$rname) $x
            set xmin [expr {$sref(xmin) + $x}]
            if {$xmin < $struct(xmin)} {
                ::tpg::Struct::modifBord $structName xmin $xmin
            }
        }
        if {$x > $struct(xmax,S,$rname)} {
            set struct(xmax,S,$rname) $x
            set xmax [expr {$sref(xmax) + $x}]
            if {$xmax > $struct(xmax)} {
                ::tpg::Struct::modifBord $structName xmax $xmax
            }
        }
        if {$y < $struct(ymin,S,$rname)} {
            set struct(ymin,S,$rname) $y
            set ymin [expr {$sref(ymin) + $y}]
            if {$ymin < $struct(ymin)} {
                ::tpg::Struct::modifBord $structName ymin $ymin
            }
        }
        if {$y > $struct(ymax,S,$rname)} {
            set struct(ymax,S,$rname) $y
            set ymax [expr {$sref(ymax) + $y}]
            if {$ymax > $struct(ymax)} {
                ::tpg::Struct::modifBord $structName ymax $ymax
            }
        }
    }
    foreach p [array names struct parents,*] {
        if {[info exists sref($p)]} {
            incr sref($p) $struct($p)
        } else {
            set sref($p) $struct($p)
        }
    }
}


set HELP(parents) {
    ajoute à l'ensemble "parentArrayName"
    les éléments qui référencent la structure "structName"
}

#####################################################
proc ::tpg::Struct::parents {parentArrayName structName} {
#####################################################
    upvar #0 S,$structName struct
    upvar $parentArrayName parentArray
    
    foreach referenceuse $struct(parents) {
        if {![info exists parentArray($referenceuse)]} {
            ::tpg::Struct::parents parentArray $referenceuse
        }
    }
}


####################################
proc ::tpg::Struct::delete {structName} {
####################################
    upvar #0 S,$structName struct
    destroy .s:$structName
    variable CREES
    foreach rname [::tpg::Struct::srefNames $structName] {
        upvar #0 S,$rname sref
        # ecrire une proc
        set ii [lsearch $sref(parents) $structName]
        if {$ii < 0} {
            error "\"$structName\" référence \"rname\" mais \"$rname(parents)\" ne contient pas \"$structName\""
        }
        set sref(parents) [concat \
            [lrange $sref(parents) 0 [expr $ii - 1]] \
            [lrange $sref(parents) [expr $ii +1] end]]
        
    }
    if {$struct(parents) == {}} {
        unset struct
        unset CREES($structName)
        return 0
    } else {
        set parents $struct(parents)
        set xminOld $struct(xmin)
        set yminOld $struct(ymin)
        set xmaxOld $struct(xmax)
        set ymaxOld $struct(ymax)
        unset struct
        new $structName
        set struct(parents) $parents
        foreach ref $struct(parents) {
            ::tpg::Struct::informeReferenceuse4 $ref $structName {} {} {} {} $xminOld $yminOld $xmaxOld $ymaxOld
        }
        return 1
    }
}


################################################################
proc ::tpg::Struct::eclateIn {structDstName structSrcName x y} {
################################################################
    upvar #0 S,$structSrcName structSrc
    upvar #0 S,$structDstName structDst
    
    # affichage des boundaries
    foreach Bid [array names structSrc B,*] {
        ::tpg::Struct::newBoundary $structDstName [::tpg::Chemin::translated $x $y $structSrc($Bid)] $structSrc(layer,$Bid) $structSrc(datatype,$Bid) 
    }
    
    foreach Srid [array names structSrc S,*] {
        set rname [lindex [split $Srid ,] 1]
        set xy $structSrc($Srid)
        ::tpg::Struct::eclateIn $structDstName $rname [expr {$x+[lindex $xy 0]}] [expr {$y+[lindex $xy 1]}]
    }
}

####################################################################################
proc ::tpg::Struct::eclateIn+transform {structDstName structSrcName x y transform} {
####################################################################################
    upvar #0 S,$structSrcName structSrc
    upvar #0 S,$structDstName structDst
    
    # affichage des boundaries
    foreach Bid [array names structSrc B,*] {
        set chemin [::tpg::Chemin::transformed $transform [::tpg::Chemin::translated $x $y $structSrc($Bid)]]
        ::tpg::Struct::newBoundary $structDstName $chemin $structSrc(layer,$Bid) $structSrc(datatype,$Bid) 
    }
    
    foreach Srid [array names structSrc S,*] {
        set rname [lindex [split $Srid ,] 1]
        set xy $structSrc($Srid)
        ::tpg::Struct::eclateIn+transform $structDstName $rname [expr {$x+[lindex $xy 0]}] [expr {$y+[lindex $xy 1]}] $transform
    }
}

