package require res1smu 0.2

GPIB::renameGPIB smu {}

proc valeurs.par.defaut {} {
    if {[info proc ::masque::configPointes] != {}} {
        ::masque::configPointes
    }
    set temperature 0
    smu write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
#  " M34,0X" "sss.standard ":=
#  " M50,0X" "sss.+rft ":=
    smu write "F0,1XO1XF1,1XO1X"
    smu write "D1,4 FILSX"
    puts "ATTENTION : Remote Sensing"
}


# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

set ASDEXDATA(typMes) res1smu

set GPIBAPP(sources) {smu}
set GPIBAPP(poll) {smu}
set GPIBAPP(init) {smu}
set GPIBAPP(conn) {smu}

installIn mes.xeq ::mes::res1smu::mesure
installIn tc.mesure.xeq tc.mesure

installIn valeurs.par.defaut.xeq valeurs.par.defaut

installIn sauv.xeq sauvInSupertable
