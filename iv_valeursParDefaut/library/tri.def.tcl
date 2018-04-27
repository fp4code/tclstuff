proc valeurs.par.defaut {} {
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP
global ghost_tlm_nmotifs ghost_tlm_array ghost_tlm_typesOfMotifs

set ASDEXDATA(typMes) tri

set GPIBAPP(sources) smu1
set GPIBAPP(poll) smu1
set GPIBAPP(init) smu1
set GPIBAPP(conn) smu1


set ghost_tlm_nmotifs 12
set ghost_tlm_array(0) { 500    0} ;# vide
set ghost_tlm_array(1) {   0    0} ;# 1.5
set ghost_tlm_array(2) {1250 -250} ;# 2
set ghost_tlm_array(3) { 500 -250} ;# 3
set ghost_tlm_array(4) { 250 -250} ;# 4
set ghost_tlm_array(5) { 250    0} ;# 6
set ghost_tlm_array(6) {1250    0} ;# 8
set ghost_tlm_array(7) {1000    0} ;# 15
set ghost_tlm_array(8) { 750    0} ;# 28
set ghost_tlm_array(9) {1000 -250} ;# 60
set ghost_tlm_array(10) {750 -250} ;# qcc
set ghost_tlm_array(11) {  0 -250} ;# cc

installIn gtlm.mes.xeq mes.tri
installIn mes.xeq mes.gtlm
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
