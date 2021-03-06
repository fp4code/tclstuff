proc valeurs.par.defaut {} {
    global smu1
    set temperature 0
    smu1 write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    smu1 write "F0,1XO1XF1,1XO1X"
    smu1 write "D1,SMU1 4 FILSX"
    puts "ATTENTION : Remote Sensing"
}

# indispensable parce que le fichier est sourc� dans une proc�dure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) log

set GPIBAPP(sources) smu1
set GPIBAPP(poll) smu1
set GPIBAPP(init) smu1
set GPIBAPP(conn) smu1

installIn mes.xeq mes.log
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
