package provide ei-bisynch 0.1

% 2007-09-21 (FP) commande de l'Eurotherm 2404 par liaison série

set SERIAL [open "/dev/ttyS0" r+]
fconfigure $SERIAL -blocking 0 -buffering none -encoding binary -translation binary -mode 9600,e,7,1
set STX \x02
set ETX \x03
set EOT \x04
set ENQ \x05
set ACK \x06
set NAK \x15
set GID \x30
set UID \x31
set BEGIN $EOT$GID$GID$UID$UID$STX

# obsolète ? proc p s {global SERIAL EOT ENQ; puts $SERIAL ${EOT}${s}${ENQ}}

# [modifier]
# Encodages

proc toASCII { char } {
  scan $char %c value
  return $value
}

proc toChar { value } {
  return [format %c $value]
}

% Returns the string with header and block checksum
proc compute_write_string s {
  global BEGIN ETX
  set bcc [toASCII $ETX]
  foreach b [split $s {}] {
    set bcc [expr {$bcc ^ [toASCII $b]}]
  }
  return $BEGIN$s$ETX[toChar $bcc]
}

# [modifier]
# Lecture d'un octet

proc r_simple_2404 {} {global SERIAL; return [read $SERIAL [lindex [fconfigure $SERIAL -queue] 0]]}

# Cf. 4.4
proc w2404 s {
  global SERIAL ACK NAK
  puts -nonewline $SERIAL [compute_write_string $s]
  for {set ii 0} {$ii < 300000} {incr ii} {
    set r [r_simple_2404]
    if {[string length $r] > 0} break
  }
  puts "response after $ii loops"
  if {[string compare $r $ACK] == 0} return
  if {[string compare $r $NAK] == 0} {return -code error "NAK : failed to write"} else {
      return -code error "Bad error detection, read \"$r\""
  }
}

toASCII [r_simple_2404]
w2404 SL21.0     
w2404 SL22.0     


proc r2404 mnemonic {
    global SERIAL EOT GID UID ENQ ETX
    puts -nonewline $SERIAL $EOT$GID$GID$UID$UID$mnemonic$ENQ
    set lu ""
    for {set ii 0} {$ii < 10000} {incr ii} {
	set lu $lu[r_simple_2404]
	if {[string length $lu] > 0 && [string compare [string index $lu end-1] $ETX] == 0} {
	    break
	} 
    }
    # puts "response after $ii loops"
    if {[string compare [string range $lu 1 2] $mnemonic] != 0} {
	if {[string compare $lu "$EOT"] == 0} {
	    return -code error "No such mnemonic or command \"${mnemonic}...\""
	}
	return -code error "Lu \"$lu\" au lieu de \"${mnemonic}\""
    }
    return [string range $lu 3 end-2]
}

% Cf. Ch 5 pour les mnémoniques

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

