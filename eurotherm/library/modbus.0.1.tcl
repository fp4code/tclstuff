package provide modbus 0.1

% 2007-10-05 (FP) commande de l'Eurotherm 2404 par liaison série

set SERIAL [open "/dev/ttyS0" r+]
fconfigure $SERIAL -blocking 0 -buffering none -encoding binary -translation binary -mode 9600,n,8,1

proc toASCII { char } {
  scan $char %c value
  return $value
}

proc toChar { value } {
  return [format %c $value]
}

proc append_crc message {
  set word 0xffff
  foreach char [split $message {}] {
    set byte [toASCII $char]
    set word [expr {$word ^ $byte}]
    for {set i 1} {$i <= 8} {incr i} {
      if {$word & 1} {
        set word [expr {($word >> 1) ^ 0xa001}]
      } else {
        set word [expr {$word >>1}]
      }
    }
  }
  return "$message[toChar [expr {$word & 0xff}]][toChar [expr {$word >> 8}]]"
}

# [modifier]
# Lecture d'un octet

proc r_simple_2404 {} {global SERIAL; return [read $SERIAL [lindex [fconfigure $SERIAL -queue] 0]]}



set message \x02\x03\x00\x01\x00\x02
set oo [append_crc $message]
string compare $oo ${message}\x95\xf8
set message \x01\x03\x00\x01\x00\x02
set oo [append_crc $message]
puts -nonewline $SERIAL $oo
set lu [r_simple_2404]
foreach c [split $lu {}] {puts [toASCII $c]}

puts -nonewline $SERIAL [append_crc \x01\x07]
set lu [r_simple_2404]
foreach c [split $lu {}] {puts [toASCII $c]}

puts -nonewline $SERIAL [append_crc \x01\x03\x00\x01\x00\x02]
set lu [r_simple_2404]
foreach c [split $lu {}] {puts [toASCII $c]}




array set Home_List {
    Process_Variable 1
    OP 3
    SP 2
    m-A 273
    AmPS 80
    Cid 629
    wSP 5
    OP 85
    VP_Manual_Output 60
    Valve Posn 53
}

array set AL_List {


























OLDOLD


foreach m {AT AA TR DT} {set ATUN($m) [r2404 $m]}
# GS G0 G1
array set PID1_INFO {
    XP {Bande proportionnelle}
    TI {Temps d'integrale}
    TD {Temps de d'dérivée}
    MR {Intégrale manuelle}
    HB {Cutback haut (0: Auto)}
    LB {Cutback bas (0: Auto)}
    RG {Gain relatif de refroidissement}
}
array set PID2_INFO {
    P2 {Bande proportionnelle}
    I2 {Temps d'integrale}
    D2 {Temps de dérivée}
    M2 {Intégrale manuelle}
    hb {Cutback haut (0: Auto)}
    lb {Cutback bas (0: Auto)}
    G2 {Gain relatif de refroidissement}
}
foreach m [array names PID1_INFO] {set PID1($m) [r2404 $m]}
foreach m [array names PID2_INFO] {set PID2($m) [r2404 $m]}
# CP CD
array set PID_INFO {
    FP {Bande proprotionnelle de tendance}
    FO {Correction de la tendance}
    FD {Limite de correction de la tendance}
}
foreach m [array names PID_INFO] {set PID($m) [r2404 $m]}
#     HH {Hystérésis de chauffage}
#     BO {Puissance de sortie en cas de rupture capteur}
#     hc {Hystérésis de refroidissement}
array set ONOFF_INFO {
    HC {Bande morte de chauffage/refroidissement}
}
foreach m [array names ONOFF_INFO] {set ONOFF($m) [r2404 $m]}

array set UNUSED {
    RC {Limite de puissance basse déportée}
    RH {Limite de puissance haute déportée}
    FM {Niveau de sortie forcée}
    HH {Hystérésis de chauffage (sortie on/off)}
    hc {Hystérésis de refroidissement (sortie on/off)}
}
unset OP_INFO
array set OP_INFO {
    LO {Limite de puissance basse}
    HO {Limite de puissance haute}
    OR {Limite de vitesse de sortie (0: Off)}
    CH {Temps de cycle de chauffage}
    C2 {Temps de cycle de refroidissement}
    MC {Durée minimale dd'activation de la sortie refroidisement (0: Auto)}
    HC {Bande morte de chauffage/refroidissement (sortie On/Off)}
    BP {Puissance de sortie en cas de rupture capteur}
}
foreach m [array names OP_INFO] {set OP($m) [r2404 $m]}
array set CMS_INFO {
    Ad {Adresse de communication}
}
foreach m [array names CMS_INFO] {set CMS($m) [r2404 $m]}
array set UNUSED {
    Pa {Code d'accès}
    GO {Niveau d'accès (1: Oper, 2: Full, 4: Edit, 8: Conf)}
    PC {Code d'accès à la configuration}
}
unset ACCS_INFO
array set ACCS_INFO {
}
foreach m [array names ACCS_INFO] {set ACCS($m) [r2404 $m]}


proc configuration {} {
    w2404 IM2

}


proc read_temp {} {
    global START_TEMP
    if {$START_TEMP == 0} return
    puts "[expr {[clock seconds]-$START_TEMP}] [r2404 PV]"
    after 1000 read_temp
}

proc start_cycle_temp {} {
    global START_TEMP
    set START_TEMP [clock seconds]
    read_temp
}

proc stop_cycle_temp {} {
    global START_TEMP
    set START_TEMP 0
}

