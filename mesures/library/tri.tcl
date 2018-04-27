proc mes.tri {nom} {
    global AsdexTclDir
    
    set mesures [list "@@ $nom"]
    lappend mesures {@qualité}
    if {![winfo exists .tri]} {
        toplevel .tri
        label .tri.l -text "Boutons de la souris : bon douteux mauvais" -height 50
        pack .tri.l
        bind .tri <Button-1> {
            exec cat $AsdexTclDir/mesures/sounds/bon.au > /dev/audio
            set reponse "bon"
        }
        bind .tri <Button-2> {
            exec cat $AsdexTclDir/mesures/sounds/douteux.au > /dev/audio
            set reponse "douteux"
        }
        bind .tri <Button-3> {
            exec cat $AsdexTclDir/mesures/sounds/mauvais.au > /dev/audio
            set reponse "mauvais"
        }
        aide::nondocumente .tri
    }
    
    global reponse
    set reponse 0
    tkwait variable reponse

    set mesure $reponse
    set mesures [concat $mesures $mesure]
    return $mesures
}
