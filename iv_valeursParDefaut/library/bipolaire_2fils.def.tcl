package require mes_bipolaire 1.0

# 8 f�vrier 2002 (FP) introduction de "::masque::configPointes"

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
	$s write "F0,1XO0XF1,1XO0X" ; puts "ATTENTION : $s Local Sensing"
	foreach m {I(V) V(I)} {
	    $s $m
	    $s write "S3W1X"  ;# 50Hz_integ, enable_default_delay
	}
    }

#    smuE write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#    smuB write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#    smuC write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#    smuE write "F0,1XO0XF1,1XO0X"
#    smuB write "F0,1XO0XF1,1XO0X"
#    smuC write "F0,1XO0XF1,1XO0X"
    ::mes::bipolaire::3smu.ini
    smuE write "D1,EMETTEUR 2 FILSX"
    smuB write "D1,BASE 2 FILSX"
    smuC write "D1,COLLECTEUR 2 FILSX"
}

# indispensable parce que le fichier est sourc� dans une proc�dure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) bipolaire_2fils

set GPIBAPP(sources) {smuE smuB smuC}
set GPIBAPP(poll) {smuE smuB smuC synchro}
set GPIBAPP(init) {smuE smuB smuC synchro}
set GPIBAPP(conn) {smuE smuB smuC synchro}
set GPIBAPP(synchro) {1*2*3}

installIn mes.xeq ::mes::bipolaire::mesure
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
