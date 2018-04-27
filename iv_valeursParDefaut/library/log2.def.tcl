proc valeurs.par.defaut {} {
    set temperature 0
    smu1 write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    smu1 write "F0,1XO0XF1,1XO0X"
    smu1 write "D1,SMU1 2 FILSX"
    puts "ATTENTION : Local Sensing"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) log2

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
