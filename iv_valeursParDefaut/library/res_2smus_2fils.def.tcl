GPIB::renameGPIB smuI {}
GPIB::renameGPIB smuV {}
GPIB::renameGPIB smu2 smuI
GPIB::renameGPIB smu3 smuV

proc valeurs.par.defaut {} {
    set temperature 0
    smuI write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smuV write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smu1 write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smuI write "F0,1XO0XF1,1XO0X"
    smuV write "F0,1XO0XF1,1XO0X"
    smu1 write "F0,1XO0XF1,1XO0X"
    puts "ATTENTION : Local Sensing"
    
    ::mes::2smu::ini
    smuI write "D1,I 2 FILSX"
    smuV write "D1,V 2 FILSX"
    smu1 write "D1,INUTILE 2 FILSX"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) res_2smus_2fils

set GPIBAPP(sources) {smuI smuV}
set GPIBAPP(poll) {smuI smuV smu1 synchro}
set GPIBAPP(init) {smuI smuV smu1 synchro}
set GPIBAPP(conn) {smuI smuV smu1 synchro}
set GPIBAPP(synchro) {2*3}

installIn mes.xeq ::mes::2smu::V(I)
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
