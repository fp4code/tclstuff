proc valeurs.par.defaut {} {
    global gloglo
    set temperature 0
    $gloglo(smu) write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    $gloglo(smu) write "F0,1XO1XF1,1XO1X"
    $gloglo(smu) write "D1,SMU 4 FILSX"
    $gloglo(smu0) write "F0,1XO1XF1,1XO1X"
    $gloglo(smu0) write "D1,SMU0 4 FILSX"
    puts "ATTENTION : Remote Sensing"
}


# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA

set ASDEXDATA(typMes) v(t)

global GPIBAPP

set GPIBAPP(sources) {smu1 smu2 smu3}
set GPIBAPP(poll) {smu1 smu2 smu3}
set GPIBAPP(init) {smu1 smu2 smu3}
set GPIBAPP(conn) {smu1 smu2 smu3}

installIn mes.xeq mes.V(t)
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
