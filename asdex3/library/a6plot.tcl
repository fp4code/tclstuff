
set ASDEX(index3) 0
set plotTableau {}
set plotTableau 0

proc plotindex {tag index} {
    global plotTableau
puts "plotindex $tag $index : plotTableau=$plotTableau"
    if {$plotTableau == {}} {
        return
    }
    set t2d [a6deuxD $plotTableau $index]
    plotfit $tag $index $t2d
    a6forget $t2d
}

proc plotage {dims tag} {
puts "plotage $dims $tag"
    global ASDEX	;# index interne aux fichiers multicourbes
    			;# (ex : mesures tlm)
    global plotTableau
    
    if { [lindex $dims 0] == 2 } {
        
        # index3 n'a ici pas de sens
        $ASDEX(graph).index3.e configure -state disabled
#        $ASDEX(graph).index3 configure -command {}
        trace variable index3 
        set ASDEX(index3) 0
        
        set t2d [a6deuxD $plotTableau]
        plotfit $tag {} $t2d
        a6forget $t2d
        
    } elseif { [lindex $dims 0] == 3} {
        
        # initialisation du widget de choix d'index3
        $ASDEX(graph).index3.e configure -state normal
#        $ASDEX(graph).index3 configure -command "plotindex $tag"
        set maxindex [expr [lindex $dims 3]-1]
        if {$ASDEX(index3) > $maxindex} {
            set ASDEX(index3) 0
        }
        $ASDEX(graph).index3 configure -max $maxindex
        plotindex $tag $ASDEX(index3)
    }
}


proc affiche {tag} {
    global ASDEX	;# pour Typ type de mesure (extension du fichier)
    global plotTableau


    # liste des fichiers mesurés pour Typ, ligne et colonne donnés
    set desfich [glob \
        [format %02d [tag2li $tag]][format %02d [tag2co $tag]]_*.$ASDEX(Typ)]
    set nfich [llength $desfich]
    if {$nfich<1} {
        erreur "affiche : Pas de fichiers"
        return -1
    } elseif {$nfich>1} {
        erreur "affiche : trop ($nfich) de fichiers"
        set desfich [lindex $desfich 0]
    }
    
    # ouverture du fichier
    if {[catch {a6file_open $desfich} adrAffiche]} {
        erreur "$desfich :\n $adrAffiche"
        set adrAffiche {}
        return
    }

    # affichage du commentaire 1
    $ASDEX(graph).comment configure -text [a6comment_v $adrAffiche 1]

    # lecture du tableau 1
    a6subfile $adrAffiche 1
    if {$plotTableau != 0} {
        a6forget $plotTableau
    }
    set plotTableau [a6file_v_unnamed_array $adrAffiche]

    # lecture et affichage des dimensions du tableau
    set dims [a6dims $plotTableau]
    $ASDEX(graph).taille configure -text [lrange $dims 1 end]

    # plotage
    plotage $dims $tag

    # fermeture du fichier
    a6file_close $adrAffiche
}
