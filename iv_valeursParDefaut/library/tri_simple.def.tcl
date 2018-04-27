proc valeurs.par.defaut {} {
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) tri_simple

set GPIBAPP(sources) smu1
set GPIBAPP(poll) smu1
set GPIBAPP(init) smu1
set GPIBAPP(conn) smu1


installIn mes.xeq mes.tri
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

set gloglo(splitGeoms) {}