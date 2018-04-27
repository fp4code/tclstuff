package require mes_hemt 1.8

# 8 février 2002 (FP) introduction de "::masque::configPointes"

GPIB::renameGPIB smuS {}
GPIB::renameGPIB smuG {}
GPIB::renameGPIB smuD {}
GPIB::copyGPIB smu1 smuG
GPIB::copyGPIB smu2 smuS
GPIB::copyGPIB smu3 smuD

proc valeurs.par.defaut {} {
    if {[info proc ::masque::configPointes] != {}} {
        ::masque::configPointes
    }

    set temperature 0
    foreach s {smuS smuG smuD} {
	$s write "F0,O1XF1,O1X" ; puts "ATTENTION : $s Remote Sensing"
	foreach m {I(V) V(I)} {
	    $s $m
	    $s write "S3W1X"  ;# 50Hz_integ, enable_default_delay
	}
    }

    ::mes::hemt::3smu.ini
    smuS write "D1,SOURCE 4 FILSX"
    smuG write "D1,GRILLE 4 FILSX"
    smuD write "D1,DRAIN 4 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) hemt

set GPIBAPP(sources) {smuS smuG smuD}
set GPIBAPP(poll) {smuS smuG smuD synchro}
set GPIBAPP(init) {smuS smuG smuD synchro}
set GPIBAPP(conn) {smuS smuG smuD synchro}
set GPIBAPP(synchro) {1*2*3}

installIn mes.xeq ::mes::hemt::mesure
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
