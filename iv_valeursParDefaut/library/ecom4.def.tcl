GPIB::renameGPIB smuB {}
GPIB::renameGPIB smuC {}
GPIB::renameGPIB smu1 smuB
GPIB::renameGPIB smu2 smuC

proc valeurs.par.defaut {} {
    set temperature 0
    smuB write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smuC write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smuB write "F0,1XO1XF1,1XO1X"
    smuC write "F0,1XO1XF1,1XO1X"
    puts "ATTENTION : Remote Sensing"
    smuB write "D1,BASE 4 FILSX"
    smuC write "D1,COLLECTEUR 4 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) ecom4

set GPIBAPP(sources) {smuB smuC}
set GPIBAPP(poll) {smuB smuC}
set GPIBAPP(init) {smuB smuC}
set GPIBAPP(conn) {smuB smuC}

installIn mes.xeq mes.ecom
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
