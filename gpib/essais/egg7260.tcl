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
	package require egg7260 1.0
	
	GPIB::main
	
	GPIB::newGPIB egg7260 egg $GPIB_board 12
    }
}

initialise

