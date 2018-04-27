# ----------------------------------------------------------------------
#  MAIN WINDOW
# ----------------------------------------------------------------------


proc choixMesure_ui {} {

    global ASDEX ASDEXTCL choixFils
    upvar #0 ASDEX(w) w
    upvar #0 ASDEX(pl) pl
    upvar #0 ASDEX(hlt) hlt
    upvar #0 ASDEX(hlm) hlm
    upvar #0 ASDEX(hld) hld
    upvar #0 ASDEX(txt) txt

# ----------------------------------------------------------------------
#  MENU BAR
# ----------------------------------------------------------------------
    frame .gauche
    pack .gauche -expand 1 -fill both


    frame .gauche.menu \
        -borderwidth 1 -relief raised
    menubutton .gauche.menu.help \
        -text "Help" -menu .gauche.menu.help.m
    menu .gauche.menu.help.m
    
    .gauche.menu.help.m add command -label "About HyperHelp..." \
    	-command "hyperhelp_file HyperHelp"
    .gauche.menu.help.m add separator
    .gauche.menu.help.m add command -label "About Asdex3.0a..." \
    	-command "hyperhelp_file Intro"
    
    tk_menuBar .gauche.menu .gauche.menu.help
    pack .gauche.menu -fill x ;# -in .gauche


    set w [frame .gauche.choix]
    pack $w -expand 1 -fill both
    
    label $w.msg \
        -font $ASDEX(font) \
        -wraplength 100m \
        -justify left \
        -relief sunken
    
    label $w.dirLabel -text "Répertoire : "

    set ASDEX(dirData) $ASDEX(dir)/data
    entry $w.dirData -width 30 -textvariable ASDEX(dirData)
    ::aide::WIN_DOCUMENT $w.dirData {Entrez ici le nom du répertoire racine}
    
    bind $w.dirData <Return> {loadDirData $ASDEX(hld)}
   
    frame $w.type -relief raised
    radiobutton $w.type.typeU -text "?" -value 0 -variable ASDEX(dataVersion) -relief raised
    radiobutton $w.type.type2 -text "2" -value 2 -variable ASDEX(dataVersion) -relief raised
    radiobutton $w.type.type3 -text "3" -value 3 -variable ASDEX(dataVersion) -relief raised
    label $w.type.tl -text "type :"
    
    set ASDEX(dataVersion) 0
        
    pack $w.type.tl $w.type.type3 $w.type.type2 $w.type.typeU -side left -expand 1 -fill x
    
    button $w.brd -text "rescan dispos" -command {loadDirData $ASDEX(hld)}
    button $w.brt -text "rescan type de mes."
    button $w.brm -text "rescan mesures"

    frame $w.stxt
    set txt [text $w.stxt.txt]
    ::widgets::packWithScrollbar $w.stxt txt
    ::aide::WIN_DOCUMENT $txt {Fichier de description des dispositifs}
    
    frame $w.hld
    set hld [widgets::listbox $w.hld]
    widgets::listboxSetType2 $hld choixTypMes
    
    frame $w.hlt
    set hlt [widgets::listbox $w.hlt]
    widgets::listboxSetType1 $hlt choixDirMesure

    frame $w.hlm
    set hlm [widgets::listbox $w.hlm]
    widgets::listboxSetType1 $hlm choixMesures
    
    frame $w.boutons

    grid configure $w.dirData $w.type x -sticky ew
    grid configure $w.hld $w.hlt $w.hlm -sticky ew
    grid configure $w.brd $w.brt $w.brm  -sticky ew
    grid configure $w.stxt -        -   -sticky ew
    grid configure $w.boutons -      -   -sticky ew
    grid configure $w.msg     -      -   -sticky ew
    
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    grid columnconfigure $w 2 -weight 1
    
    loadDirData $hld
        
    $txt configure -width 80
    
    # un peu rustique
    bind $txt <KeyPress> "set ASDEX(txt_modif) 1"
    
    
    button $w.boutons.quit -text "Exit" -command "exit"
    ::aide::WIN_DOCUMENT $w.boutons.quit {Sortie du programme}
    
    button $w.boutons.restart -text "Restart" -command {
            cd $ASDEX(udir)
            exec asdex3 &
            exit
        }
    ::aide::WIN_DOCUMENT $w.boutons.restart {Sortie du programme et relance}
    
    button $w.boutons.sauve -text "Sauve" -command "txt_sauve $txt \$txt_file"
    ::aide::WIN_DOCUMENT $w.boutons.sauve {Sauvegarde du fichier texte}

    button $w.boutons.source -text "developpe.tcl" \
        -command "source ${ASDEXTCL}/developpe.tcl"
    ::aide::WIN_DOCUMENT $w.boutons.source {Chargement d'un fragment de code ./developpe.tcl Cela sert surtout à l'étape de développement}

    button $w.boutons.debogue -text Débogue -command debogue
    ::aide::WIN_DOCUMENT $w.boutons.debogue {
        Lancement du dévermineur "debugger"
        Cela sert surtout à surveiller le fonctionnement de code C, C++ ou Fortran
        chargé par Tcl
    }

    pack $w.boutons.quit $w.boutons.restart  $w.boutons.source $w.boutons.debogue -side left
    pack $w.boutons.sauve -side right
    pack .gauche.menu.help -side right -padx 2

    set ASDEX(pl) [frame $w.pl]
#    pack $ASDEX(pl) -expand yes -fill both -side right
    label $ASDEX(pl).messages
#    pack $ASDEX(pl).messages -side bottom

#carteDispo::newCarte $ASDEX(pl)
    newCarte $ASDEX(pl)
}

proc debogue {} {
    global w ASDEXTCL
    set actu [pwd]
    cd $ASDEXTCL
    exec workshop -D [info nameofexecutable] [pid] &
    cd $actu
    signal ignore USR2
    $w.debogue configure -text "Débogue:Stop" -command "kill USR2 [pid]" 
}


