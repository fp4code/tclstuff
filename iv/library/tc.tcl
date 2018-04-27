
proc bip {} {
    global alert_ok
    if {$alert_ok} {
        destroy .alert
        return
    }
    wm deiconify .alert
    raise .alert
    bell
    set coco [.alert.ok cget -activebackground]
    .alert.ok configure -activebackground red
    .alert.ok flash
    .alert.ok configure -activebackground $coco
    after 1000 bip
    bell
}

proc alert {} {
    global alert_ok
    set alert_ok 0
    toplevel .alert
    bind .alert <Destroy> {set alert_ok 1}
    button .alert.ok -text OK -command {set alert_ok 1 ; destroy .alert}
    pack .alert.ok
    bip
}


#\ ***************************\
#\ Enregistrement des mesures \
#\ ***************************\

proc sauv.xeq {nom tableau} {}

proc sauv.choix {nom tableau} {
    error {installIn sauv.xeq sauv|sauvn}
}

installIn sauv.xeq sauv.choix

proc tc.enregistre {symDes mesure} {
    global ASDEXDATA
    set name $ASDEXDATA(rootData)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)/
    global gloglo
    if {$gloglo(splitGeoms) != {}} {
        append name [$gloglo(splitGeoms) $symDes]/
        if {![file exists $name]} {
            file mkdir $name
        }
    }
    append name $symDes
#    append name .spt ;# .$ASDEXDATA(typMes)
    sauv.xeq $name $mesure
}

#\ ********************\
#\ Mesures electriques \
#\ ********************\

proc mes.xeq {nom} {}

proc mes.choix {nom} {
  error {installIn mes.xeq TOUTE_FONCTION_RENVOYANT_UN_TABLEAU_liste}
}

installIn mes.xeq mes.choix


#\ *******************\
#\ Mesure en un point \
#\ *******************\

proc tc.mesure.xeq {symDes} {}

proc tc.mesure.bidon {symDes} {
    puts "Mesure bidon de $symDes"
}

proc tc.mesure {symDes} {
    global ASDEXDATA TC
    set nom [list $ASDEXDATA(echantillon) $ASDEXDATA(typCar) $ASDEXDATA(typMes) $symDes]
puts "symDes=\"$symDes\", nom=\"$nom\""
    set mesure [mes.xeq $nom]
    if {$TC(go)} {
        tc.enregistre $symDes $mesure
    }
}

installIn tc.mesure.xeq tc.mesure.bidon

#\ *********************** \
#\  positionnement-mesure  \
#\ *********************** \

proc tc.moveTo {symDes} {
    global TC
    foreach {x y} [::masque::symDesToPos $symDes] {}
    aligned::moveTo $TC(machine) $x $y
}


proc tc.posmes {symDes} {
    global TC
    update
    if {!$TC(go)} {
        set TC(go) 0
        error "ARRÊT demandé avant $symDes"
    }
    set TC(symDes) $symDes
    tc.moveTo $symDes
    puts "$symDes"
    tc.mesure.xeq $symDes
}

#\ ******************* \
#\ cycles automatiques \
#\ ******************* \

proc tc.cycle {liste} {
    global TC
    set TC(go) 1
    set itot [llength $liste]
    set i $itot
    set TC(reste_a_mesurer) "$i/$itot"
    foreach symDes $liste {
        tc.posmes $symDes
        incr i -1
        set TC(reste_a_mesurer) "$i/$itot"
    }
}

#\ ******************************** \
#\ cycle de mesure standard complet \
#\ ******************************** \

proc mes.plaque {} {
    global ASDEXDATA
#    tc.en.gpib    \ tc en gpib
#    tc.ini.xeq    \ parametres initialises
#    tc.posini     \ machine positionnee
#    0 0 tc.pointe \ position definie
    tc.cycle \ mesures faites
}


proc ori {} {
    global TC
    aligned::moveTo $TC(machine) 0 0
}


