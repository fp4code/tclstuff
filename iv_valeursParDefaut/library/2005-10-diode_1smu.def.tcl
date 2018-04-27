# 17 février 2010 (FP) introduction de "::masque::configPointes"

package require mes_diode_1smu 0.2

GPIB::renameGPIB smu {}
GPIB::copyGPIB smu_1A smu

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

set ASDEXDATA(typMes) 2005-10-diode_1smu

set GPIBAPP(sources) {smu}
set GPIBAPP(poll) {smu smu1 smu2 smu3}
set GPIBAPP(init) {smu}
set GPIBAPP(conn) {smu smu1 smu2 smu3}

installIn mes.xeq ::mes::diode_1smu::mesure
installIn tc.mesure.xeq tc.mesure

installIn valeurs.par.defaut.xeq valeurs.par.defaut

installIn sauv.xeq sauvInSupertable


set bug_2013 {
OK:
fico2+asdex_data@boule:~$ symDes="C0001", nom="microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001"
commandes = {{::mes::diode_1smu::inv {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}}}
#1 ------- ::mes::diode_1smu::inv {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}
args = {{microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}} nom = {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}
******* no gloglo(IInvMax,C), IInvMax from surface -> 0.0020106
sweepDelay = 0
list = {}
list = {-range {1.1 V}}
pb. premier point si partie entiere vaut 2,4,6 (Ha) Q1,-0.2,0.3,0.1,1,0X 
list = {-range {1.1 V}}
Q7,0.3,-0.2,-0.1,1,0X
::smu::waitRft
private.smu.rft smu {{Ready for Trigger}}
::smu::waitRft is Done -> get in declenche
pre ::smu::waitRdRft in declenche

while de ::smu::waitRdRft smu -> {Sweep Done} {Reading Done} {Ready for Trigger}
post ::smu::waitRdRft in declenche
before repos in ::mes::diode_1smu::inv
debug : smu attendu DSSnnnn, lu "DSS0012"
end ::mes::diode_1smu::inv
------- TERMINE
on sauve dans /bob/asdex/A/data/microCIS/k123D/microCISplots-su8/dark-inv-2/C0001#8.spt


BAD:

fico2+asdex_data@boule:~$ symDes="C0001", nom="microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001"
commandes = {{::mes::diode_1smu::inv {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}}}
#1 ------- ::mes::diode_1smu::inv {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}
args = {{microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}} nom = {microCISplots-su8 dark-inv-2 2005-10-diode_1smu C0001}
******* no gloglo(IInvMax,C), IInvMax from surface -> 0.0020106
sweepDelay = 0
list = {}
list = {-range {1.1 V}}
pb. premier point si partie entiere vaut 2,4,6 (Ha) Q1,-0.2,0.3,0.1,1,0X 
list = {-range {1.1 V}}
Q7,0.3,-0.2,-0.1,1,0X
::smu::waitRft
private.smu.rft smu {{Ready for Trigger}}
::smu::waitRft is Done -> get in declenche
pre ::smu::waitRdRft in declenche

while de ::smu::waitRdRft smu -> {Sweep Done} {Reading Done}
waiting for Ready For Trigger after Reading Done
post ::smu::waitRdRft in declenche
before repos in ::mes::diode_1smu::inv
debug : smu attendu DSSnnnn, lu "DSS0012"
end ::mes::diode_1smu::inv
------- TERMINE
on sauve dans /bob/asdex/A/data/microCIS/k123D/microCISplots-su8/dark-inv-2/C0001#7.spt



}
