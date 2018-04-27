package require mes_bipolaire 1.0

GPIB::renameGPIB smuE {}
GPIB::renameGPIB smuB {}
GPIB::renameGPIB smuC {}
GPIB::renameGPIB smu1 smuE
GPIB::renameGPIB smu2 smuB
GPIB::renameGPIB smu3 smuC

proc valeurs.par.defaut {} {
    set temperature 0
    foreach s {smuE smuB smuC} {
	$s trigIn continuous
	$s trigOut none
	$s trigSweepEndOff
	$s write "F0,O0XF1,O0X" ; puts "ATTENTION : $s Local Sensing"
	foreach m {I(V) V(I)} {
	    $s $m
	    $s write "S3W1X"  ;# 50Hz_integ, enable_default_delay
	    $s dc
	}
    }

    smuE V(I)
    smuB I(V)
    smuC V(I)

    smuE write "D1,EMETTEUR 2 FILSX"
    smuB write "D1,BASE 2 FILSX"
    smuC write "D1,COLLECTEUR 2 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) bipolaire_pretri_2fils

set GPIBAPP(sources) {smuE smuB smuC}
set GPIBAPP(poll) {smuE smuB smuC synchro}
set GPIBAPP(init) {smuE smuB smuC synchro}
set GPIBAPP(conn) {smuE smuB smuC synchro}
set GPIBAPP(synchro) {1*2*3}

installIn mes.xeq ::mes::bipolaire::pretri
installIn tc.mesure.xeq tc.mesure

installIn valeurs.par.defaut.xeq valeurs.par.defaut

source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(mparams)]
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(typCar)\
                  $ASDEXDATA(eparams)]

installIn sauv.xeq sauvInSupertable


