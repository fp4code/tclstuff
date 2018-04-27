# RCS: @(#) $Id: iv_ui.2.3.tcl,v 1.3 2003/05/05 08:03:38 fab Exp $

package provide iv_ui 2.3
package require fidev
package require superWidgetsScroll 1.0

# 28 mars 2002 (FP)
# usage tout à fait partiel du namespace 
# 2 mai 2002 (FP)
# remise a vide de gloglo

namespace eval iv_ui {}

proc iv_ui::compareDate {date& f1 f2} {
    upvar ${date&} date
    return [expr {$date($f2) - $date($f1)}]
}

proc iv_ui::topAncetre {w} {
    while {$w != {} && [winfo class $w] != "Toplevel"} {
        set w [winfo parent $w]
    }
    return $w
}

proc iv_ui::get_selected_modele {varName l} {
    upvar #0 $varName index
    set t [iv_ui::topAncetre $l]
    set s [$l curselection]
    if {[llength $s] == 0} {
        bind $t <Visibility> {}
        tk_messageBox -message "Nothing selected"
        bind $t <Visibility> {raise %W}
    } elseif {[llength $s] > 1} {
        bind $t <Visibility> {}
        tk_messageBox -message "Please, select only one"
        bind $t <Visibility> {raise %W}
    } else {
        set index $s
    }
}

proc iv_ui::choisirModele {ndir fichiers} {
    global ASDEXDATA fidev_tclDir
    foreach f $fichiers {
        if {![regexp {[%~]$} $f]} {
            set date($f) [file mtime $f]
        }
    }
    set fichiers [lsort -command {iv_ui::compareDate date} [array names date]]
    set fwa 0
    set fwb 0
    foreach f $fichiers {
        set w [string length [file tail $f]]
        if {$w > $fwa} {set fwa $w}
        if {$ndir == 1} {
            set w [string length [file tail [file dirname $f]]]
        } elseif {$ndir == 2} {
            set w [string length [file join [file tail [file dirname [file dirname $f]]] [file tail [file dirname $f]]]]
        }
        if {$w > $fwb} {set fwb $w}
    }
    set t [toplevel .choisirModele]
    wm title $t "Choisir un modèle"
    set w [frame $t.f]
    set l [listbox $w.l -width 120]
    global index$l
    ::widgets::packWithScrollbar $w l
    set bok [button $t.bok -text "OK, copie" -command [list iv_ui::get_selected_modele index$l $l]]
    set bcan [button $t.bcan -text "Cancel" -command [list set index$l {}]]
    pack $w
    pack $bok -side left
    pack $bcan -side left
    foreach f $fichiers {
        set fa [file tail $f]
        set dir [file dirname $f]
        if {$ndir == 1} {
            set fb [file tail $dir]
            set dir [file dirname $dir]
        } elseif {$ndir == 2} {
            set fb [file join [file tail [file dirname $dir]] [file tail $dir]]
            set dir [file dirname [file dirname $dir]]
        }
        set FICH([$l index end]) $f
        $l insert end "[format %-${fwb}s $fb] [format %-${fwa}s $fa] [clock format $date($f) -format "%Y-%m-%d %H:%M:%S"] $dir"
    }
    bind $t <Visibility> {
        raise %W
    }
    bind $t <Destroy> "set index$l {}"
    vwait index$l
    if {[winfo exists $t]} {
        bind $t <Destroy> {}
        destroy $t
    }
    set index [set index$l]
    if {$index != {}} {
        return $FICH($index)
    } else {
        return {}
    }
}

proc iv_ui {root args} {
    # this treats "." as a special case
    global TC
    global AsdexTclDir
    global IVGLO
    global ASDEXDATA
    global gloglo
    if {$root == "."} {
        set B ""
    } else {
        set B $root
    }
    
    wm title $root IV
    
    frame $B.frame#1
############
# rootDataSansPlaque #
############
    set ASDEXDATA(rootDataSansPlaque) $ASDEXDATA(rootData)
    label $B.rootDataSansPlaque_l \
        -text répertoire
    entry $B.rootDataSansPlaque_e \
        -textvariable ASDEXDATA(rootDataSansPlaque)
    aide::ui_minihelp $B.message $B.rootDataSansPlaque_e {Répertoire de travail}
###############
# plaque #
###############
    label $B.plaque_l \
        -text plaque
    entry $B.plaque_e \
        -textvariable ASDEXDATA(plaque)
    aide::ui_minihelp $B.message $B.plaque_e {sous-répertoire du répertoire de travail}
    button $B.plaque_b -text "<- cliquez pour ce répertoire"
    $B.plaque_b configure -command {
        set of $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)
        if {![file exists $of]} {
            file mkdir $of
        }
        set ASDEXDATA(rootData) $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)
    }
###############
# echantillon #
###############
    label $B.echantillon_l \
        -text échantillon

    entry $B.echantillon_e \
        -textvariable ASDEXDATA(echantillon)
    aide::ui_minihelp $B.message $B.echantillon_e {sous-répertoire du répertoire plaque}

    button $B.echantillon_b -bitmap @$AsdexTclDir/bitmaps/down.xbm
    $B.echantillon_b configure -command {
        set of $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)
        while {![file isdirectory $of]} {
            set of [file dirname $of]
        }
puts "of = $of"
        set of [tk_getOpenFile -initialdir $of -filetypes {{{paramètres mécaniques} mparams*}}]
puts "of = $of"
        if {$of != {}} {
            set ASDEXDATA(mparams) [file tail $of]
            set of [file dirname $of]
            set ASDEXDATA(echantillon) [file tail $of]
            set of [file dirname $of]
            set ASDEXDATA(plaque) [file tail $of]
            set ASDEXDATA(rootDataSansPlaque) [file dirname $of]
            set ASDEXDATA(rootData) $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)
        } else {
            set ASDEXDATA(mparams) {?mparams?}
        }
    }
    aide::ui_minihelp $B.message $B.echantillon_b {choix d'un fichier de paramètres mécaniques}

    button $B.echantillon_mparams -textvariable ASDEXDATA(mparams)
    button $B.echantillon_mlit -text lit
    $B.echantillon_mparams configure -command {
            set r $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)
            set f $r/$ASDEXDATA(mparams)
            if {![file exists $r]} {
                file mkdir $r
            }
            if {![file exists $f]} {
                set of [iv_ui::choisirModele 1 [concat [glob -nocomplain $fidev_tclDir/masque/modeles/*] [glob -nocomplain $ASDEXDATA(rootDataSansPlaque)/*/*/mparams*]]]
                if {$of == {}} return
                file copy $of $r
                set ASDEXDATA(mparams) [file tail $of]
                set f $r/$ASDEXDATA(mparams)
            }
            exec emacs $f &
            # 2000/02/25 (FP) source $f
        }
    aide::ui_minihelp $B.message $B.echantillon_mparams {paramètres mécaniques : édition et chargement}
    $B.echantillon_mlit configure -command {
            set r $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)
            set f $r/$ASDEXDATA(mparams)
            source $f
        }
    aide::ui_minihelp $B.message $B.echantillon_mlit {paramètres mécaniques : chargement}
##########
# typCar #
##########
    label $B.typCar_l \
        -text {mesures}

    entry $B.typCar_e \
        -textvariable ASDEXDATA(typCar)
    aide::ui_minihelp $B.message $B.typCar_e {sous-répertoire du répertoire échantillon}

    button $B.typCar_b -bitmap @$AsdexTclDir/bitmaps/down.xbm
    $B.typCar_b configure -command {
        set of $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)
        while {![file isdirectory $of]} {
            set of [file dirname $of]
        }
        set of [tk_getOpenFile -initialdir $of -filetypes {{{paramètres électriques} eparams*}}]
        if {$of != {}} {
            set ASDEXDATA(eparams) [file tail $of]
            set of [file dirname $of]
            set ASDEXDATA(typCar) [file tail $of]
            set of [file dirname $of]

            set ASDEXDATA(echantillon) [file tail $of]
            set of [file dirname $of]
            set ASDEXDATA(plaque) [file tail $of]
            set ASDEXDATA(rootDataSansPlaque) [file dirname $of]
            set ASDEXDATA(rootData) $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)
        } else {
            set ASDEXDATA(eparams) {?eparams?}
        }
    }
    aide::ui_minihelp $B.message $B.typCar_b {choix d'un fichier de paramètres électriques}

    button $B.typCar_eparams -textvariable ASDEXDATA(eparams)
    aide::ui_minihelp $B.message $B.typCar_eparams {paramètres électriques : édition et chargement}
    button $B.typCar_elit -text lit
    aide::ui_minihelp $B.message $B.typCar_elit {paramètres électriques : chargement}
    $B.typCar_eparams configure -command {
            set r $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)
            set f $r/$ASDEXDATA(eparams)
            if {![file exists $r]} {
                file mkdir $r
            }
            if {![file exists $f]} {
                set of [iv_ui::choisirModele 2 [concat [glob -nocomplain $fidev_tclDir/mesures/modeles/*] [glob -nocomplain $ASDEXDATA(rootDataSansPlaque)/*/*/*/eparams*]]]
                if {$of == {}} return
                file copy $of $r
                set ASDEXDATA(eparams) [file tail $of]
                set f $r/$ASDEXDATA(eparams)
            }
            exec emacs $f &
            # 2000/02/25 (FP) source $f
        }
    $B.typCar_elit configure -command {
        set r $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)
        set f $r/$ASDEXDATA(eparams)
        catch {unset gloglo}
        set gloglo(splitGeoms) {}
        source $f
    }
##########
# typMes #
##########
    label $B.typMes_l \
        -text {type de Mesure}
    
    menubutton $B.m \
        -textvariable ASDEXDATA(typMes) \
        -menu $B.m.menu \
        -indicatoron 1 \
        -relief raised
    aide::ui_minihelp $B.message $B.m {Choisir}
    
    menu $B.m.menu
    proc creeBTM {menu} {
        global IVGLO
        set IVGLO(typMes) [readTypesMes]
        $menu delete 1 end ; # A VOIR
        foreach t $IVGLO(typMes) {
            $menu add command -label $t \
                 -command "set ASDEXDATA(typMes) $t ; iv:read.def"
         }
    }
# minihelp A FAIRE
    creeBTM $B.m.menu
    button $B.typMes_relitRepert \
        -text MAJ -command "creeBTM $B.m.menu"
    aide::ui_minihelp $B.message $B.typMes_relitRepert "Lecture de $AsdexTclDir/iv_valeursParDefaut => mise à jour du menu"
    button $B.typMes_relit \
        -text relit -command "iv:read.def"
    aide::ui_minihelp $B.message $B.typMes_relit {Relit le fichier associé au type de mesure}
#############
# connectés #
#############
    label $B.conn_l \
        -text connectées
    entry $B.conn_e \
        -textvariable GPIBAPP(conn)
    aide::ui_minihelp $B.message $B.conn_e {liste des appareils connectés}
    button $B.conn_scrute -text {scrute}
    $B.conn_scrute configure -command {
            set numBranches [GPIB::rescanBranches]
            supprimeDe numBranches 0
            set GPIB_Branches {}
            foreach n $numBranches {
                global gpibNames
                if {[info exists gpibNames(0,$n)]} {
                    lappend GPIB_Branches $gpibNames(0,$n)
                } else {
                    lappend GPIB_Branches $n
                }
            }
            
            foreach a $GPIBAPP(conn) {
                global gpibNames
                if {[array exists $a]} {
                    upvar #0 $a aa
                } else {
                    error "Le tableau associé à l'appareil $a n'est pas défini"
                }
                set err [catch {supprimeDe GPIB_Branches $a} i]
                if {$err} {
        error "L'appareil $a (adresse $aa(gpibAddr)) n'est pas branché"
                }
                set GPIB_Branches [linsert $GPIB_Branches $i $a]
            }
            set GPIBAPP(conn) $GPIB_Branches
        }
    aide::ui_minihelp $B.message $B.conn_scrute {scrute les appareils connectés sur le bus GPIB}
##################
# initialisables #
##################
    label $B.init_l \
        -text initialisables
    entry $B.init_e \
        -textvariable GPIBAPP(init)
    aide::ui_minihelp $B.message $B.init_e {liste des appareils initialisables}
    button $B.init_initoutiv \
        -text initoutiv -command "iv:initoutiv %W"
    aide::ui_minihelp $B.message $B.init_initoutiv {initialise les appareils initialisables}
##############
# appelables #
##############
    label $B.poll_l \
        -text {SRQ appelables}
    entry $B.poll_e \
        -textvariable GPIBAPP(poll)
    aide::ui_minihelp $B.message $B.poll_e {liste des appareils répondant au polling SRQ}
    button $B.poll_testpoll \
        -text {testpoll} -command "iv:testpoll %W"
    aide::ui_minihelp $B.message $B.poll_testpoll {effectue un polling SRQ}
###########
# sources #
###########
    label $B.sources_l \
        -text {sources}
    entry $B.sources_e \
        -textvariable GPIBAPP(sources)
    aide::ui_minihelp $B.message $B.sources_e {liste des sources}
    button $B.sources_repos \
        -text repos -command "iv:sourcesAuRepos %W"
    aide::ui_minihelp $B.message $B.sources_repos {met les sources au repos}
##########
# divers #
##########
    frame $B.divers
########
# gpib #
########
    button $B.divers.gpib \
        -text GPIB -command GPIB::ui
    aide::ui_minihelp $B.message $B.divers.gpib {commandes GPIB directes}
    label $B.srq -textvariable variable_SRQ -foreground red
########
# quit #
########
    button $B.divers.quit \
        -text quit -command "iv:quit %W"
    aide::ui_minihelp $B.message $B.divers.quit {quitte}
########
# divers #
########
    button $B.divers.sourceCode \
        -text sourceCode -command "sourceCode DIVERS.tcl"
    aide::ui_minihelp $B.message $B.divers.sourceCode {sourceCode}
############
# table xy #
############
    frame $B.pos
    set rien {
    button $B.pos.tc550 \
            -text {TC 550} -command {
        set TC(machine) tc550
        if {[winfo exists .tc550_ui]} {
            wm deiconify .tc550_ui
            raise .tc550_ui
        } else {
            package require tc550 
            package require tablexy 1.2
            createTC550IfNonExistent
            toplevel .tc550_ui
            wm geometry .tc550_ui +0+0
            aligned::tablexy_ui tc550 tc550:specialFrame
            aide::nondocumente .tc550_ui
        }
    }
    aide::ui_minihelp $B.message $B.pos.tc550 {démarre une séquence d'alignement}
    }

    button $B.pos.mm4005 \
            -text {MM 4005} -command {
        set TC(machine) mm4005
        if {[winfo exists .mm4005_ui]} {
            wm deiconify .mm4005_ui
            raise .mm4005_ui
        } else {
            package require tablexy 1.2
            package require mm4005 1.0
            mm4005::createIfNonExistent
            toplevel .mm4005_ui
            wm geometry .mm4005_ui +0+0
            aligned::tablexy_ui mm4005 mm4005::specialFrame
            aide::nondocumente .mm4005_ui
        }
    }
    aide::ui_minihelp $B.message $B.pos.mm4005 {démarre une séquence d'alignement}
    
    label $B.reste -textvariable TC(reste_a_mesurer)
    aide::ui_minihelp $B.message $B.reste {combien de mesures a faire}

    checkbutton $B.pos_sr \
        -relief raised \
        -text "start\nstop" \
        -variable TC(go) \
        -selectcolor green \
        -command {
            if {$TC(go)} {
                tc.cycle $AllSymDes
            }
        }
    aide::ui_minihelp $B.message $B.pos_sr {démarre un cycle complet ou arrête après la mesure en cours}

    button $B.pos_continue \
        -text continue \
        -command "getSymdesAndRestart"
    aide::ui_minihelp $B.message $B.pos_continue {relance à partir du dispositif donné}

    button $B.pos.calcule \
        -text "calcule" \
        -command {
            ::masque::calculeTout
        }
    aide::ui_minihelp $B.message $B.pos.calcule {calcule la liste des dispositifs (long...)}
    button $B.pos.print \
        -text "affiche" \
        -command {
            puts $AllSymDes
        }
    aide::ui_minihelp $B.message $B.pos.print {affiche la liste des dispositifs}

    frame $B.pos.lico
    label $B.pos.lico.ls \
        -text "symDes"
    entry $B.pos.lico.symDes \
        -textvariable TC(symDes) \
        -width 16

    button $B.pos.moveTo \
        -text "moveTo" \
        -command {tc.moveTo $TC(symDes)}
    aide::ui_minihelp $B.message $B.pos.moveTo {déplace les pointes sur le dispositif donné}
    button $B.pos.mesure \
        -text "mesure" \
        -command {set TC(go) 1; tc.mesure.xeq $TC(symDes)}
    aide::ui_minihelp $B.message $B.pos.mesure {mesure le dispositif donné (sans y aller)}

    proc getSymdesAndExec {entry commande} {
        $commande [$entry get]
    }

    proc getSymdesAndRestart {} {
        global AllSymDes TC
        if {$TC(go)} {
            return
        }
        set TC(go) 1
        set i [lsearch $AllSymDes $TC(symDes)]
        if {$i < 0} {
            error "$TC(symDes) pas dans la liste"
        }
        tc.cycle [lrange $AllSymDes $i end]
    }

###########
# message #
###########
    label $B.message -relief sunken -anchor w

#########
# Geometry management
#########

    grid configure $B.frame#1 -in $root    -row 0 -column 0 

        grid configure $B.rootDataSansPlaque_l - $B.rootDataSansPlaque_e -       -                   -        
        grid configure $B.plaque_l      - $B.plaque_e      $B.plaque_b           -                   -
        grid configure $B.echantillon_l - $B.echantillon_e $B.echantillon_b $B.echantillon_mparams $B.echantillon_mlit
        grid configure $B.typCar_l      - $B.typCar_e      $B.typCar_b      $B.typCar_eparams      $B.typCar_elit 
        grid configure $B.typMes_l      - $B.m               -              $B.typMes_relitRepert  $B.typMes_relit
        grid configure $B.conn_l        - $B.conn_e          -              $B.conn_scrute           -
        grid configure $B.init_l        - $B.init_e          -              $B.init_initoutiv        -
        grid configure $B.srq   $B.poll_l $B.poll_e          -              $B.poll_testpoll         -
        grid configure $B.sources_l     - $B.sources_e       -              $B.sources_repos         -
        grid configure $B.reste         - $B.pos             -              $B.pos_sr          $B.pos_continue
        grid configure $B.divers        -   -                -                -                      - -sticky we
        grid configure $B.message       -   -                -                -                      - -sticky we

        grid configure $B.pos                                     -sticky we
        grid configure $B.pos.mm4005  $B.pos.calcule $B.pos.print  -sticky news
        grid configure ^              $B.pos.lico      -           -sticky news
        grid configure ^              $B.pos.moveTo  $B.pos.mesure -sticky news
        grid configure $B.pos.lico.ls $B.pos.lico.symDes -sticky news
        pack $B.divers.gpib -side left
        pack $B.divers.quit -side right
        pack $B.divers.sourceCode -side right
        
        foreach w {rootDataSansPlaque plaque echantillon typCar typMes conn init poll sources} {
            grid configure $B.${w}_l -sticky e
        }
        foreach w {rootDataSansPlaque plaque echantillon typCar conn init poll sources} {
            grid configure $B.${w}_e -sticky we
        }
        grid configure $B.pos.lico.ls -sticky e
        foreach w {plaque_b echantillon_mlit typCar_elit echantillon_mparams typCar_eparams typMes_relitRepert typMes_relit conn_scrute init_initoutiv poll_testpoll sources_repos reste} {
            grid configure $B.$w -sticky we
        }
#        grid configure $B.pos.tc550 $B.pos_sr -sticky wns
#        grid configure $B.pos.tc550 -sticky ns
#        grid columnconfigure $B.pos 0 -weight 1
        grid configure $B.pos_sr $B.pos_continue -sticky ewns
}
