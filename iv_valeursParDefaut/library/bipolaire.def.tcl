package require mes_bipolaire 1.8

# 8 février 2002 (FP) introduction de "::masque::configPointes"

GPIB::renameGPIB smuE {}
GPIB::renameGPIB smuB {}
GPIB::renameGPIB smuC {}
GPIB::copyGPIB smu1 smuB
GPIB::copyGPIB smu2 smuE
GPIB::copyGPIB smu3 smuC

proc valeurs.par.defaut {} {
    if {[info proc ::masque::configPointes] != {}} {
        ::masque::configPointes
    }

    set temperature 0
    foreach s {smuE smuB smuC} {
	$s write "F0,O1XF1,O1X" ; puts "ATTENTION : $s Remote Sensing"
	foreach m {I(V) V(I)} {
	    $s $m
	    $s write "S3W1X"  ;# 50Hz_integ, enable_default_delay
	}
    }

    ::mes::bipolaire::3smu.ini
    smuE write "D1,EMETTEUR 4 FILSX"
    smuB write "D1,BASE 4 FILSX"
    smuC write "D1,COLLECTEUR 4 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) bipolaire

set GPIBAPP(sources) {smuE smuB smuC}
set GPIBAPP(poll) {smuE smuB smuC synchro}
set GPIBAPP(init) {smuE smuB smuC synchro}
set GPIBAPP(conn) {smuE smuB smuC synchro}
set GPIBAPP(synchro) {1*2*3}

installIn mes.xeq ::mes::bipolaire::mesure
installIn tc.mesure.xeq tc.mesure

installIn valeurs.par.defaut.xeq valeurs.par.defaut


set rien {
# N'a aucun sens puisque c'est sourcé dans une procédure FAIRE LE MENAGE DANS lES AUTRES .def.tcl
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(mparams)]
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(typCar)\
                  $ASDEXDATA(eparams)]
}

installIn sauv.xeq sauvInSupertable
