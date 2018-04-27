proc valeurs.par.defaut {} {
    global gloglo
    set temperature 0
    $gloglo(smu) write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    $gloglo(smu) write "F0,1XO1XF1,1XO1X"
    $gloglo(smu) write "D1,SMU1 4 FILSX"
    $gloglo(smu0) write "F0,1XO1XF1,1XO1X"
    $gloglo(smu0) write "D1,SMU1 4 FILSX"
    puts "ATTENTION : Remote Sensing"
}


# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP
global ghost_tlm_nmotifs ghost_tlm_array ghost_tlm_typesOfMotifs
global GPIBAPP

set ASDEXDATA(typMes) sgt


set GPIBAPP(sources) {smu1 smu2 smu3}
set GPIBAPP(poll) {smu1 smu2 smu3}
set GPIBAPP(init) {smu1 smu2 smu3}
set GPIBAPP(conn) {smu1 smu2 smu3}

set ghost_tlm_nmotifs 12
set ghost_tlm_array(0) { 500    0} ; set ghost_tlm_typesOfMotifs(0) Vide
set ghost_tlm_array(1) {   0    0} ; set ghost_tlm_typesOfMotifs(1) 1.5x4
set ghost_tlm_array(2) {1250 -250} ; set ghost_tlm_typesOfMotifs(2) 2x4
set ghost_tlm_array(3) { 500 -250} ; set ghost_tlm_typesOfMotifs(3) 3x4
set ghost_tlm_array(4) { 250 -250} ; set ghost_tlm_typesOfMotifs(4) 4x4
set ghost_tlm_array(5) { 250    0} ; set ghost_tlm_typesOfMotifs(5) 6x4
set ghost_tlm_array(6) {1250    0} ; set ghost_tlm_typesOfMotifs(6) 8x4
set ghost_tlm_array(7) {1000    0} ; set ghost_tlm_typesOfMotifs(7) 15x4
set ghost_tlm_array(8) { 750    0} ; set ghost_tlm_typesOfMotifs(8) 28x4
set ghost_tlm_array(9) {1000 -250} ; set ghost_tlm_typesOfMotifs(9) 60x4
set ghost_tlm_array(10) {750 -250} ; set ghost_tlm_typesOfMotifs(10) 192x4
set ghost_tlm_array(11) {  0 -250} ; set ghost_tlm_typesOfMotifs(11) badCC

installIn gtlm.mes.xeq mes.ser
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
