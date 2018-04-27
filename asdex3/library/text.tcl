proc vrai {args} {
    return 1
}

# souligne --
# Cette procédure met en évidence 
#
#

proc souligne {txt tag nom args} {
    if {[winfo depth $txt] <= 1} {
        erreur "Il faut un écran couleur"
    }    
    
    set nargs [llength $args]
    foreach op $args {
        if {[eval [lindex $op 0] $nom]} {
            eval $txt tag configure $tag [lrange $op 1 end]
	    break
	}
    }
}

proc textSearch {type txt string} {
    $txt tag remove $type 0.0 end
    if {$string == ""} {
        return
    }
    set cur 1.0
    set vu {}
    while 1 {
        set cur [$txt search -regexp -count length $string $cur end]
        if {$cur == ""} {
            break
        }
        if {$vu=={}} {
            set vu $cur
        }
        set tata [$txt get $cur "$cur + $length char"]
        $txt tag add $type $cur "$cur + $length char"
	set cur [$txt index "$cur + $length char"]
        souligne $txt $type $tata \
            "vrai -background black -foreground white" \
            "isAdispoDir -background red -foreground white"
        $txt see $vu
    }
}

proc txt_sauve {txt file} {
   catch {file rename $file ${file}.BAK}
   if {![catch {set filId [open $file w]} NonOuvert]} {
       puts $filId [$txt get 1.0 end]
       close $filId
       global ASDEX
       set ASDEX(txt_modif) 0
   } else {
       kd_message_box error "ERREUR : $NonOuvert"
   }

}

proc test_sauve {txt file} {
    if {![catch {set filId [open $file]} NonOuvert]} {
# test brut
        if {[$txt get 1.0 end] == [read $filId]} {
            return
        }
    }
    after idle {.dialog.msg configure -wraplength 4i}
    set i [ \
        tk_dialog .dialog "Attention" "Sauvegarde du texte modifié?" \
            info 0 Oui Non\
    ]

    if {$i==0} {
        txt_sauve $txt $file
    }
    if {$i==1} {
        global ASDEX
        set ASDEX(txt_modif) 0
    }
}

