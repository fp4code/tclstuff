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

set ASDEXDATA(typMes) sg2


set GPIBAPP(sources) {smu1 smu2 smu3}
set GPIBAPP(poll) {smu1 smu2 smu3}
set GPIBAPP(init) {smu1 smu2 smu3}
set GPIBAPP(conn) {smu1 smu2 smu3}

set ghost_tlm_nmotifs 13
set ghost_tlm_array(0)  { 850    0} ; set ghost_tlm_typesOfMotifs(0) Vide
set ghost_tlm_array(1)  { 350    0} ; set ghost_tlm_typesOfMotifs(1) 1.5x4
set ghost_tlm_array(2)  {1600 -250} ; set ghost_tlm_typesOfMotifs(2) 2x4
set ghost_tlm_array(3)  { 850 -250} ; set ghost_tlm_typesOfMotifs(3) 3x4
set ghost_tlm_array(4)  { 350 -250} ; set ghost_tlm_typesOfMotifs(4) 3x3
set ghost_tlm_array(5)  { 600 -250} ; set ghost_tlm_typesOfMotifs(5) 4x4
set ghost_tlm_array(6)  { 600    0} ; set ghost_tlm_typesOfMotifs(6) 6x4
set ghost_tlm_array(7)  {1600    0} ; set ghost_tlm_typesOfMotifs(7) 8x4
set ghost_tlm_array(8)  {1350    0} ; set ghost_tlm_typesOfMotifs(8) 15x4
set ghost_tlm_array(9)  {1100    0} ; set ghost_tlm_typesOfMotifs(9) 28x4
set ghost_tlm_array(10) {1350 -250} ; set ghost_tlm_typesOfMotifs(10) 60x4
set ghost_tlm_array(11) {1100 -250} ; set ghost_tlm_typesOfMotifs(11) 192x4
set ghost_tlm_array(12) {   0    0} ; set ghost_tlm_typesOfMotifs(12) CC

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
