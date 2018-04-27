package require mes_univ_2smus 1.12

# 18 février 2014 (FP) nouveau

GPIB::renameGPIB smuX {}
GPIB::renameGPIB smuY {}
GPIB::copyGPIB smu1 smuX
GPIB::copyGPIB smu3 smuY

proc valeurs.par.defaut {} {
    if {[info proc ::masque::configPointes] != {}} {
        ::masque::configPointes
    }

    set temperature 0
    foreach s {smuX smuY} {
	$s write "F0,O1XF1,O1X" ; puts "ATTENTION : $s Remote Sensing"
	foreach m {I(V) V(I)} {
	    $s $m
	    $s write "S3W1X"  ;# 50Hz_integ, enable_default_delay
	}
    }

    ::mes::univ_2smus::2smu.ini
    smuX write "D1,POINTE G 4 FILSX"
    smuY write "D1,POINTE D 4 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) univ_2smus

set GPIBAPP(sources) {smuX smuY}
set GPIBAPP(poll) {smuX smuY synchro}
set GPIBAPP(init) {smuX smuY synchro}
set GPIBAPP(conn) {smuX smuY synchro}
set GPIBAPP(synchro) {1*2}
puts "DANGER GPIBAPP(synchro) == $GPIBAPP(synchro)"

installIn mes.xeq ::mes::univ_2smus::mesure
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
