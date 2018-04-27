set ASDEX(Plaque) {}
set ASDEX(Dispo) {}
set ASDEX(Mesure) {}
set ASDEX(txt_modif) 0
set ASDEX(txt_file) {}
set ASDEX(lDMid) 0

proc choixTypMes {plaque dispo} {
    global ASDEX
    set ASDEX(Dispo) $dispo
    set ASDEX(Plaque) $plaque
    if {$ASDEX(txt_modif)} {
        test_sauve $ASDEX(txt) $ASDEX(txt_file)
    }
    $ASDEX(txt) delete 1.0 end
    set file $ASDEX(dirData)/$ASDEX(Plaque)/info.txt
    set ASDEX(txt_file) $file
    if {![catch {set filId [open $file]}]} {
        $ASDEX(txt) insert current [read $filId]
        close $filId
        set ASDEX(txt_modif) 0
    }
    textSearch dispo $ASDEX(txt) $dispo
    set typFile $ASDEX(dirData)/$ASDEX(Plaque)/$ASDEX(Dispo)/typeDeStructure.dat
    if {![file exists $typFile]} {
puts "$typFile : 0"
        set ASDEX(dataVersion) 0
    } elseif {![file readable $typFile]} {
        kd_message_box error "le fichier\n$typFile\nn'est pas lisible\n(il doit contenir asdex2 ou asdex3)"
        set ASDEX(dataVersion) 0
    } else {
        set tf [open $typFile r]
        set titi [gets $tf]
        close $tf
        if {![string match "asdex*" $titi]} {
            kd_message_box error "le fichier\n$typFile\nne contient pas asdex2 ou asdex3"
            set ASDEX(dataVersion) 0
        } else {
            set ver [string index $titi 5]
            if {![string match \[23\] $ver]} {
                kd_message_box error "la version $ver n'est pas acceptable"
                set ASDEX(dataVersion) 0
            } else {
                set ASDEX(dataVersion) $ver
            }
        }
    }
    loadDirDispo $ASDEX(hlt)
} 

proc choixDirMesure {args} {
    global ASDEX
    set ASDEX(Mesure) $args
    if {$ASDEX(dataVersion) == 3} {
        set mesure [lindex $args 0]
    } elseif {$ASDEX(dataVersion) == 2} {
        set mesure $args
    }
    after cancel $ASDEX(lDMid)
#    set cursor [$ASDEX(hlt) cget -cursor]
    $ASDEX(hlt) configure -cursor watch
    update
    set ASDEX(lDMid) [after idle {
        loadDirMesure $ASDEX(hlm) $ASDEX(Mesure)
        puts lu
        $ASDEX(hlt) configure -cursor {}
    }]
    textSearch mesure $ASDEX(txt) $mesure
}

