# à exécuter avec le programme "ni488"


proc initialise {} {
    global GPIB_board
    global OnEstPasseParLa

    if {[info exists OnEstPasseParLa]} {
	puts stderr "Déjà initialisé !"
    } else {
	set OnEstPasseParLa "donc on n'y repasse pas"
   
	package require fidev
	package require gpibLowLevel 1.2
	package require gpib 1.0
	package require aide 1.2
	package require minihelp 1.0
	package require 37xxx 0.1
	
	GPIB::main
	
	GPIB::newGPIB 37xxx hyper $GPIB_board 6
    }
}


initialise 



proc filter {} {   #initialise le filtre de mesure#           
                                                               
hyper write if2    \#selection bande de frequence 100 Hz 

hyper write {avg 100 } \# moyenne des mesures
                     
}

proc lit_arbitrary_block {} {
    set x [hyper read 1]
    if {$x != "#"} {
	return -code error "diese attendu"
    }
    set nc [hyper read 1]
    set n [hyper read $nc]
    set res [hyper read [expr {$n + 10}]]
    return [string range $res 0 [expr {$n-1}]]
}

proc lit_s {ij r_ou_c} {
    if {$ij != "11" && $ij != "12" && $ij != "21" && $ij != "22"} {
	return -code error "ij incorrect (doit être 11, 12, 21 ou 22)"
    }
    if {$r_ou_c != "r" && $r_ou_c != "c"} {
	return -code error "r_ou_c incorrect (doit être r ou c)"
    }
    hyper write os$ij$r_ou_c
    set s [lit_arbitrary_block]
    set s [split $s ,]
    set ret [list]
    foreach {r i} $s {
	set r [expr {$r}]
	set i [expr {$i}]
	lappend ret [list $r $i]
    }
     return $ret
}

proc lit_freq {} {

hyper write ofv
set fr [lit_arbitrary_block]
set fr [split $fr ,]

  
return $fr

}
 


proc lit_tout {fichier info} {

    # hyper write np51
              
    set fr [lit_freq] 
    set s11 [lit_s 11 c]
    set s12 [lit_s 12 c]
    set s21 [lit_s 21 c]
    set s22 [lit_s 22 c]
    
    set f [open $fichier.spt w]
    puts $f "@@mesure hyper $fichier $info\n@f s11c_r s11c_i s12c_r s12c_i s21c_r s21c_i s22c_r s22c_i"
    foreach  x11 $s11 x12 $s12 x21 $s21 x22 $s22  y $fr {

	puts $f "$y $x11 $x12 $x21 $x22 " 
   }

    close $f

}



