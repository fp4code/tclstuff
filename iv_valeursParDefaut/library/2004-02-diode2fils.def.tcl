package require mes_diode 0.2

# Utilise "::masque::configPointes"

GPIB::renameGPIB smu {}
GPIB::renameGPIB smu0 {}
GPIB::copyGPIB smu1 smu
GPIB::copyGPIB smu2 smu0

proc valeurs.par.defaut {} {
    puts stderr configPointes?
    if {[info proc ::masque::configPointes] != {}} {
        puts stderr "OUI"
        ::masque::configPointes
    }
    set temperature 0
    smu write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smu0 write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    smu write "F0,1XO1XF1,1XO0X"
    smu write "D1,ANODE (+) 2 FILSX"
    smu0 write "F0,1XO1XF1,1XO0X"
    smu0 write "D1,CATHODE (-) 2 FILSX"
    puts "ATTENTION : Local Sensing"
}


# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) 2004-02-diode2fils

set GPIBAPP(sources) {smu smu0}
set GPIBAPP(poll) {smu smu0 smu3}
set GPIBAPP(init) {smu smu0}
set GPIBAPP(conn) {smu smu0 smu3}

installIn mes.xeq ::mes::diode::mesure
installIn tc.mesure.xeq tc.mesure

installIn valeurs.par.defaut.xeq valeurs.par.defaut

set rien {
# N'a aucun sens puisque c'est sourcé dans une procédure FAIRE LE MENAGE DANS lES AUTRES .def.tcl
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(mparams)]
source [file join $ASDEXDATA(rootData)\
                  $ASDEXDATA(echantillon)\
                  $ASDEXDATA(typCar)\
                  $ASDEXDATA(eparams)]
}

installIn sauv.xeq sauvInSupertable
