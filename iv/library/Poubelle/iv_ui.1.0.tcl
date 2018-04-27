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
    button $B.plaque_b -text "crée répertoire"
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
                set of [tk_getOpenFile \
                    -title "choisir un modèle" \
                    -initialdir $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque) \
                    -filetypes {{{paramètres mécaniques} mparams*}}]
                file copy $of $r
                set ASDEXDATA(mparams) [file tail $of]
                set f $r/$ASDEXDATA(mparams)
            }
            exec textedit $f &
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
                set of [tk_getOpenFile \
                    -title "choisir un modèle" \
                    -initialdir $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon) \
                    -filetypes {{{paramètres électriques} eparams*}}]
                file copy $of $r
                set ASDEXDATA(eparams) [file tail $of]
                set f $r/$ASDEXDATA(eparams)
            }
            exec textedit $f &
            # 2000/02/25 (FP) source $f
        }
    $B.typCar_elit configure -command {
            set r $ASDEXDATA(rootDataSansPlaque)/$ASDEXDATA(plaque)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)
            set f $r/$ASDEXDATA(eparams)
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
            set numBranches [GPIB_rescanBranches]
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
        -text GPIB -command gpib_ui
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
#########
# tc550 #
#########
    frame $B.pos
    button $B.pos.tc550 \
        -text {TC 550} -command {
        if {[winfo exists .tc550_ui]} {
            wm deiconify .tc550_ui
            raise .tc550_ui
        } else {
            createTC550IfNonExistent
            toplevel .tc550_ui
            wm geometry .tc550_ui +0+0
            aligned::tablexy_ui tc550
            aide::nondocumente .tc550_ui
        }
        }
    aide::ui_minihelp $B.message $B.pos.tc550 {démarre une séquence d'alignement}

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

        grid configure $B.pos -sticky we
        grid configure $B.pos.tc550 $B.pos.calcule $B.pos.print -sticky wens
        grid configure ^            $B.pos.lico      - -sticky news
        grid configure ^            $B.pos.moveTo  $B.pos.mesure -sticky news
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
        grid configure $B.pos.tc550 -sticky ns
        grid columnconfigure $B.pos 0 -weight 1
        grid configure $B.pos_sr $B.pos_continue -sticky ewns
}



