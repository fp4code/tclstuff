proc valeurs.par.defaut {} {
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) bidon

set GPIBAPP(sources) {}
set GPIBAPP(poll) {}
set GPIBAPP(init) {}
set GPIBAPP(conn) {}

installIn mes.xeq mes.choix
installIn tc.mesure.xeq tc.mesure.bidon

installIn valeurs.par.defaut.xeq valeurs.par.defaut

source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(mparams)]

set INUTILE {
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(typCar)\
                  $ASDEXDATA(eparams)]

installIn sauv.xeq sauvInSupertable
}
