package provide a4156 1.0

namespace eval a4156 {
    variable a4156SRQBitNames
    variable a4156ErrorStatus
    variable a4156ErrorMessages
    variable a4156

    # L'appareil semble émettre des SRQ transitoires

    set a4156SRQBitNames(0) EMER
    set a4156SRQBitNames(1) MEAS
    set a4156SRQBitNames(2) {bit 2 not used}
    set a4156SRQBitNames(3) QUES
    set a4156SRQBitNames(4) MAV
    set a4156SRQBitNames(5) Error
    set a4156SRQBitNames(6) SRQ
    set a4156SRQBitNames(7) OPER

    set a4156ErrorStatus(0) OPC
    set a4156ErrorStatus(1) {bit 1 not used}
    set a4156ErrorStatus(2) {bit 2 not used}
    set a4156ErrorStatus(3) Error
    set a4156ErrorStatus(4) {Parameter Error}
    set a4156ErrorStatus(5) {Syntax Error}
    set a4156ErrorStatus(6) {bit 6 not used}
    set a4156ErrorStatus(7) {bit 7 not used}
    
    # Cf. 04156-90050 p. 1-292
    set a4156ErrorMessages(500) {Improper parameter value. Check setup range}
    set a4156ErrorMessages(501) {Improper channel number or slot number}
    set a4156ErrorMessages(502) {A unit is not installed on specified channel}
    set a4156ErrorMessages(503) {Specified unit cannot execute this command}
    set a4156ErrorMessages(504) {Specified unit failed self-test/self-calib}
    set a4156ErrorMessages(505) {Filter can be set to SMUs only}
    set a4156ErrorMessages(506) {Unsupportde unit detected in some slot}
    set a4156ErrorMessages(507) {Program memory is fill. Reduce commands}
    set a4156ErrorMessages(508) {Program creation aborted}
    set a4156ErrorMessages(509) {ST must be executed before END command}
    set a4156ErrorMessages(510) {Unable to use this command between ST and END}
    set a4156ErrorMessages(511) {Comp/range cannot be omit to use prog memory}
    set a4156ErrorMessages(512) {Ouput data buffer full. To many points.}
    set a4156ErrorMessages(513) {Improper output range or output value}
    set a4156ErrorMessages(514) {Improper measurement range setup}
    set a4156ErrorMessages(515) {Specified output values are out of range}
    set a4156ErrorMessages(516) {Cannot ommit compliance setup}
    set a4156ErrorMessages(517) {The compliance setup is out of range}
    set a4156ErrorMessages(518) {Power compliance setting is out of range}
    set a4156ErrorMessages(519) {Current output range must be >= nA in PI}
    set a4156ErrorMessages(520) {Measurement range must be less than compliance}
    set a4156ErrorMessages(521) {Range setup is wrong for the specified VMU}
    set a4156ErrorMessages(522) {Unable to set compliance for VSU or PGU}
    set a4156ErrorMessages(523) {Cannot open the relay driving more than 40V}
    set a4156ErrorMessages(524) {Unable to output over 40V. Interlock open}
    set a4156ErrorMessages(525) {Unit sw must be ON before command execution}
    set a4156ErrorMessages(526) {Filter must be set to OFF for pulse SMU}
    set a4156ErrorMessages(527) {SMU/VSU hold time must be <= 655.35 s in the PT}
    set a4156ErrorMessages(528) {SMU/VSU pulse width must be 0.5 ms to 100 ms}
    set a4156ErrorMessages(529) {SMU/VSU pulse period must be 5 ms to 1 s}
    set a4156ErrorMessages(530) {SMU/VSU pulse trigger must ne 0ms to 32.7 ms}
    set a4156ErrorMessages(531) {Improper measurement mode in MM command}
    set a4156ErrorMessages(532) {Only one meas unit when priority is 0 in PT}
    set a4156ErrorMessages(533) {Only one meas channel when init int < 2 us}
    set a4156ErrorMessages(534) {Measurement mode must be set by MM command}
    set a4156ErrorMessages(535) {At least one meas. unit must be set in MM}
    set a4156ErrorMessages(536) {Command order must be MT, MM, then XE}
    set a4156ErrorMessages(537) {Chan no cannot be set for stress force in MM}
    set a4156ErrorMessages(538) {Set PV/PI for meas. uning pulse source}
    set a4156ErrorMessages(539) {At least one SYNC channel must be specified}
    set a4156ErrorMessages(540) {WV or WI must be set for sweep measurement}
    set a4156ErrorMessages(541) {PWV/PWI must be set for pulse sweep meas}
    set a4156ErrorMessages(542) {Cal/Diag may not be performed on some units}
    set a4156ErrorMessages(543) {Cal/Diag failed. Cannot use the units}
    set a4156ErrorMessages(544) {41501A/B is not turned on}
    set a4156ErrorMessages(545) {Unable to execute RZ before DZ}
    set a4156ErrorMessages(546) {Start and stop value must be same when step=1}
    set a4156ErrorMessages(547) {Set WV/WI/PWV/PWI before WSV/WSI}
    set a4156ErrorMessages(548) {CH num for pulse must differ from other sources}
    set a4156ErrorMessages(549) {Ranging mode must be 0 to 3 (0 to 2 for VMU) in RV/RI}
    set a4156ErrorMessages(550) {Ranging mode must be 0 or 1 in WI/WV/WSV/WSI/PWI/PWV}
    set a4156ErrorMessages(551) {Improper comp. polarity for manual polarity}
    set a4156ErrorMessages(552) {Sweep mode must be 1 to 4 in WI/WV/PWI/PWV}
    set a4156ErrorMessages(553) {Num of steps in WI/WV/PWI/PWV must be 1 to 1001}
    set a4156ErrorMessages(554) {Start/stop must be same pol and not 0 for log}
    set a4156ErrorMessages(555) {Base and pulse current must be same polarity}
    set a4156ErrorMessages(556) {Unable to assign primary/sync. sweep to same CH}
    set a4156ErrorMessages(557) {Improper WSI/WSV entry. Ignore returned value}
    set a4156ErrorMessages(558) {Pulse mode must be 0 or 1 in PT command}
    set a4156ErrorMessages(559) {Trigger output delay must be <= pulse width}
    set a4156ErrorMessages(560) {Mode must be set to 0 or 1 on FL command}
    set a4156ErrorMessages(561) {Mode nust be set to 1 or 2 in VM}
    set a4156ErrorMessages(562) {Incorrect triger mode. Check TM syntax}
    set a4156ErrorMessages(563) {PGU pulse delay time must be 0s to 10s}
    set a4156ErrorMessages(564) {PGU pulse width must be 1 us to 10s}
    set a4156ErrorMessages(565) {PGU pulse period must be 1 us to 10 s}
    set a4156ErrorMessages(566) {PGU leading time must be 100 ns to 10.0 ms}
    set a4156ErrorMessages(567) {PGU trailing time must be 100 ns to 10.0 ms}
    set a4156ErrorMessages(568) {PG pulse width/period/delay must be same range}
    set a4156ErrorMessages(569) {SMU pulse period must be >= pulse width + 4 ms}
    set a4156ErrorMessages(570) {Offset mode must be set 0 or 1 in SOC command}
    set a4156ErrorMessages(571) {Zero offser meas failed for the unit}
    set a4156ErrorMessages(572) {Too big offset for 10 pA range on the unit}
    set a4156ErrorMessages(573) {Range setup is wrong in GOC command}
    set a4156ErrorMessages(574) {Category must be 1 or 3 in SIT}
    set a4156ErrorMessages(575) {Integration time must be mode than 0 s}
    set a4156ErrorMessages(576) {System error. Unable to communicate with SMUC}
    set a4156ErrorMessages(577) {Mode must be set 0, 1, or 2 in SPG command}
    set a4156ErrorMessages(578) {PGU pulse and base value must be <= +/- 40 V}
    set a4156ErrorMessages(579) {Pulse count must be 0 to 65535 s in SPG}
    set a4156ErrorMessages(580) {Pulse unit must be set by SPG before SRP}
    set a4156ErrorMessages(581) {Set 0 or 1 to output impedance parameter in POR}
    set a4156ErrorMessages(582) {PGUs are not installed}
    set a4156ErrorMessages(583) {Port number must be set to 0, 1, 2, or 3 in SSP}
    set a4156ErrorMessages(584) {Status must be set to 0, 1, 2, 3 in SSP}
    set a4156ErrorMessages(585) {Channel number must be set to 1 or 2 in RBC}
    set a4156ErrorMessages(586) {Resistance must be set to 0, 1, 2, or 3 in RBC}
    set a4156ErrorMessages(587) {Reference number must be 0 to 3 in STI/STV/STP}
    set a4156ErrorMessages(588) {Output mode must be set to 0 or 1 in STP}
    set a4156ErrorMessages(589) {Stress mode must be set to 0, 1, or 2 in STT}
    set a4156ErrorMessages(590) {Set 500 us to 655 s for time, or 1 to 65536 for count}
    set a4156ErrorMessages(591) {Pulse period must be 1 us to 10 s in STT}
    set a4156ErrorMessages(592) {Output mode must be set to 0 or 1 in MP}
    set a4156ErrorMessages(593) {The specified programs are not stored}
    set a4156ErrorMessages(594) {Start prog num must be <= stop prog num in RU}
    set a4156ErrorMessages(595) {Program \# must be 1 to 255 in DO/RU/SCR/LST?}
    set a4156ErrorMessages(596) {DO or RU command execution was aborted}
    set a4156ErrorMessages(597) {Measurement aborted. Interlock open while > 40}
    set a4156ErrorMessages(598) {Network disabled. Improper network setup.}
    set a4156ErrorMessages(599) {Disk must be set to 0, 1, 2, 3, or 4 in SDSK}
    set a4156ErrorMessages(600) {Open mode must be set to 0, 10, or 2 in OPEN}
    set a4156ErrorMessages(601) {Printer must be 1, 2, 3, or 4 in SPR}
    set a4156ErrorMessages(602) {Data cannot be appended to a file on a diskette}
    set a4156ErrorMessages(603) {Incomplete network setup. Unable to mount disk}
    set a4156ErrorMessages(604) {Cannot open two files. Close the opened file}
    set a4156ErrorMessages(605) {Unable to open file}
    set a4156ErrorMessages(606) {Seek operation to the network disk failed}
    set a4156ErrorMessages(607) {Unable to create the file specified in OPEN}
    set a4156ErrorMessages(608) {Unable tpo close the file specified in CLOSE}
    set a4156ErrorMessages(609) {Unable to write or read. File is not opened}
    set a4156ErrorMessages(610) {Read error occured. Data or media corrupt}
    set a4156ErrorMessages(611) {Write error occured. Media corrupt or full}
    set a4156ErrorMessages(612) {PA command gets no return from SMUC}
    set a4156ErrorMessages(613) {Select printer registered in the MISC page}
    set a4156ErrorMessages(614) {Must select disk before executiond SPL or PRN}
    set a4156ErrorMessages(615) {Must select network printer before PRN}
    set a4156ErrorMessages(616) {Unable to connect server. Network problem}
    set a4156ErrorMessages(617) {Unable to print out. LPN went down}
    set a4156ErrorMessages(618) {Unable to print out. Data transfer failed}
    set a4156ErrorMessages(619) {Unable to delete spool file}
    set a4156ErrorMessages(620) {Measurement aborted by AB command}
    set a4156ErrorMessages(621) {Measurement abosrted. Timeout occured}
    set a4156ErrorMessages(622) {Meas./stress completed. Stop condition satisfied}
    set a4156ErrorMessages(623) {Measurement aborted. Data buffer full}
    set a4156ErrorMessages(624) {Measurement aborted. Reason unknown}
    set a4156ErrorMessages(625) {Measurement mode must be 0, 1, 2 or 3 in CMM}
    set a4156ErrorMessages(626) {Unsopported file, or file name is wrong}
    set a4156ErrorMessages(627) {PGU pulse period must be > pulse width}
    set a4156ErrorMessages(628) {PGU pulse period must be >= pulse delay}
    set a4156ErrorMessages(629) {PGU leading time must be <= 0.8 x pulse width}
    set a4156ErrorMessages(630) {PGU trailing time must be <- 0.8 x(Period - Width)}
    set a4156ErrorMessages(631) {Emergency. Reason unknown}
    set a4156ErrorMessages(632) {At least one PG must be set for pulse count mode}
    set a4156ErrorMessages(633) {Auto calib must be 0 or 1 in CM}
    set a4156ErrorMessages(634) {Level must be 1, 2, 4, 6, or 16 in US42}
    set a4156ErrorMessages(635) {Type parameter setup is wrong in *LRN? command}
    set a4156ErrorMessages(636) {format must be 1 to 5 in FMT}
    set a4156ErrorMessages(637) {Mode must be 0, 1, or 2 in FMT}
    set a4156ErrorMessages(638) {Wait time must be 0 to 99.9999 s in PA}
    set a4156ErrorMessages(639) {Mode must be 1 or 2 in WS}
    set a4156ErrorMessages(640) {Mode must be 0 or 1 in STG}
    set a4156ErrorMessages(641) {State must be 0 or 1 in STG}
    set a4156ErrorMessages(642) {Polarity must be 0 or 1 in STG}
    set a4156ErrorMessages(643) {Mode must be 0 or 1 in UNT?}
    set a4156ErrorMessages(644) {4142ch must be 1 to 28 in ACH}
    set a4156ErrorMessages(645) {chnum must be 1 to 6, or 21 to 28 in ACH}
    set a4156ErrorMessages(646) {Averaging num must be -1023 to 1023 (not 0) in AV}
    set a4156ErrorMessages(647) {Averaging mode must be 0 or 1 in AV}
    set a4156ErrorMessages(648) {Post sweep condition must be 1 or 2 in VM}
    set a4156ErrorMessages(649) {Abort condition setup is wrong in WM/MSC/STM}
    set a4156ErrorMessages(650) {Hold time must be 0 to 655.35 s in WT}
    set a4156ErrorMessages(651) {Delay time must be 0 to 65.535 s in WT}
    set a4156ErrorMessages(652) {Step delay time must be 0 to 1 s in WT}
    set a4156ErrorMessages(653) {Number of data must be 0 to 20002 in RMD?}
    set a4156ErrorMessages(654) {Category must be 1, 2, or 3 in SLI command}
    set a4156ErrorMessages(655) {Mode must be 0 (off) or 1 (on) in AZ}
    set a4156ErrorMessages(656) {For pulse mode, pulse para must be set in STP}
    set a4156ErrorMessages(657) {Time or num of pulse must be set in STT}
    set a4156ErrorMessages(658) {Base must be set when mode = 1 or 2 in SPG}
    set a4156ErrorMessages(659) {Pulse para must be set when mode = 2 in SPG}
    set a4156ErrorMessages(660) {Unable to use Free run to use program memory}
    set a4156ErrorMessages(661) {Inproper stresse time to use program memory}
    set a4156ErrorMessages(662) {Hold time must be -0.03 to 655.35 s in MT}
    set a4156ErrorMessages(663) {Interval must be 0.00006 to 65.534 s in MT}
    set a4156ErrorMessages(664) {Sampling points must be 1 to 100001 in MT}
    set a4156ErrorMessages(665) {Hold time must be >= 0 when init int >= 2 ms}
    set a4156ErrorMessages(666) {Pulse para must be set for pulse mode in MP}
    set a4156ErrorMessages(667) {Pulse count be 0 to 65535 in MP}
    set a4156ErrorMessages(668) {Unable to use TV/TI&TV?/TI? in same program}
    set a4156ErrorMessages(669) {V force must be set for the chan set in GOC}
    set a4156ErrorMessages(670) {10 (0.2 V range) must be set for VMU in GOC}
    set a4156ErrorMessages(671) {Offset data was out of range or GOC failed}
    set a4156ErrorMessages(672) {VMU must be diff. mode when SOC is executed}
    set a4156ErrorMessages(673) {Promary and secondary sweep must be same force mode}
    set a4156ErrorMessages(674) {Slot number must be 0 to 9 in *TST? command}
    set a4156ErrorMessages(675) {Slot number must be 0 to 8 in CA command}
    set a4156ErrorMessages(676) {This mode is only for the system sith PGU}
    set a4156ErrorMessages(677) {WV/WI/QSV: Sweep step value too small}
    set a4156ErrorMessages(678) {QSV: Use SMU for VAR1 channel}
    set a4156ErrorMessages(679) {QSV: Sweep mode must be 1(single) or 2 (double)}
    set a4156ErrorMessages(680) {QSV: Number or steps must be 1 to 1001}
    set a4156ErrorMessages(681) {QSL: Sata mode must be 0(off) or 1 (on)}
    set a4156ErrorMessages(682) {QSL: Compensation mode must be 0(off) or 1 (on)}
    set a4156ErrorMessages(683) {QSM: Improper stop copndition was specified}
    set a4156ErrorMessages(684) {QSM: Abort voltage must be 1(start) or 2 (stop)}
    set a4156ErrorMessages(685) {QST: Hold time must be 0 to 655.35s on 0.01s}
    set a4156ErrorMessages(686) {QST: Delay1 must be 0 to 65.535s in 0.0001s}
    set a4156ErrorMessages(687) {QST: Delay2 must be 0 to 65.535s in 0.0001s}
    set a4156ErrorMessages(688) {code inconnu au bataillon}
    set a4156ErrorMessages(689) {QSR: Range must be -9, -10, -11, or -12}
    set a4156ErrorMessages(690) {Enter MM 13 and QSV before XE command}
    set a4156ErrorMessages(691) {MM 13 allows only one measurement channel}
    set a4156ErrorMessages(692) {TSC: Time stamp mode must be 0(off) or 1(on)}
    set a4156ErrorMessages(693) {LSV/LSI: Step value must be + or - value, not 0}
    set a4156ErrorMessages(694) {LSV/LSI: Improper start, stop, or step value}
    set a4156ErrorMessages(695) {LSTM: Hold time must be 0 to 655.35s in 0.01s}
    set a4156ErrorMessages(696) {LSTM: Delay must be 0 to 65.535s in 0.0001s}
    set a4156ErrorMessages(697) {LSVM: Data mode must be 0(result) or 1(all)}
    set a4156ErrorMessages(698) {LGV/LGI: Serach mode must be 0(drop) or 1(rise)}
    set a4156ErrorMessages(699) {LGV/LGI: Improper range or target value}
    set a4156ErrorMessages(700) {LSSV/LSSI: Polarity must be 0(-) or 1(+)}
    set a4156ErrorMessages(701) {Enter MM 14 and LSV/LSI before XE command}
    set a4156ErrorMessages(702) {Enter MM 14 and LGV/LGI before XE command}
    set a4156ErrorMessages(703) {LSSV/LSSI: Offset value too large}
    set a4156ErrorMessages(704) {Search target must be =< compliance setting}
    set a4156ErrorMessages(705) {Set search source before synchronous source}
    set a4156ErrorMessages(706) {V (or I) search unit must be I (or V) source mode}
    set a4156ErrorMessages(707) {Sync source channel must be set to another unit}
    set a4156ErrorMessages(708) {Synchronous source output setting too large}
    set a4156ErrorMessages(709) {Do not specify channel number for MM 14 and 15}
    set a4156ErrorMessages(710) {BSV/BSI: Start ant stop must be different}
    set a4156ErrorMessages(711) {BST: Hold time must be 0 to 655.35 s in 0.01s}
    set a4156ErrorMessages(712) {BST: Delay must be 0 to 65.535s in 0.0001s}
    set a4156ErrorMessages(713) {BGV/BGI: Mode must be 0(limit) or 1 (repeat)}
    set a4156ErrorMessages(714) {BGV/BGI: Improper search stop condition}
    set a4156ErrorMessages(715) {BGV/BGI: Improper range, target, or limit value}
    set a4156ErrorMessages(716) {BSSV/BSSI: Polarity must be 0(-) or 1(+)}
    set a4156ErrorMessages(717) {BSSV/BSSI: Offset value too large}
    set a4156ErrorMessages(718) {BSM: Mode must be 0(normal) or 1(cautious)}
    set a4156ErrorMessages(719) {BSVM: Data mode must be 0(result) or 1 (all)}
    set a4156ErrorMessages(720) {Enter MM 15 and BSV/BSI before XE command}
    set a4156ErrorMessages(721) {Enter MM 15 and BGV/BGI before XE command}
    set a4156ErrorMessages(722) {Invalid command for the US42 control mode}
    set a4156ErrorMessages(723) {VMD: parameter value must be 0, 1, or 2}
    set a4156ErrorMessages(724) {ESC: Mode must be 0(off) or 1(on)}
    set a4156ErrorMessages(725) {ESC: condition1 must be 0,1,2,3, or 4}
    set a4156ErrorMessages(726) {ESC: Value1 must be -10000 to 10000}
    set a4156ErrorMessages(727) {ESC: Condition2 must be 0,1,2,3, or 4}
    set a4156ErrorMessages(728) {ESC: Value2 must be -200 to 200}
    set a4156ErrorMessages(729) {QSZ: Integration time too short for sero cancel}
    set a4156ErrorMessages(730) {QSZ: Offset value too large for zero cancel}
    set a4156ErrorMessages(731) {Enter MM 13 before QSZ}
    set a4156ErrorMessages(732) {Enter QSV before QSZ command}
    set a4156ErrorMessages(733) {code inconnu au bataillon}
    set a4156ErrorMessages(734) {QSZ: Mode must be 0(off), 1(on) or 2(execution)}
    set a4156ErrorMessages(735) {MM: Specify channel number of the V mode SMU}
}

proc ::a4156::iniGlobals {} {
}


#################################################################################################################################
# Il est très important pour "GPIB::newGPIB" que le premier argument soit "a4156Name" et que les procédures soient ::a4156::... #
#################################################################################################################################


proc ::a4156::write {a4156Name chaine} {
    upvar #0 $a4156Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) $chaine
}

proc ::a4156::read {a4156Name {len 512}} {
    upvar #0 $a4156Name deviceArray
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::a4156::readBin {a4156Name {len 512}} {
    upvar #0 $a4156Name deviceArray
    return [GPIB::rdBin $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
}

proc ::a4156::serialPoll {a4156Name} {
    upvar #0 $a4156Name deviceArray
    return [GPIB::serialPoll $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::a4156::poll {a4156Name} {
    upvar #0 $a4156Name deviceArray
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::spe
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    set spByte [::GPIBBoard::rdBin $deviceArray(gpibBoard) 1]
    puts stderr "spByte = $spByte"
    GPIB::unt
    GPIB::unl
    GPIB::spd
    return [::a4156::pollEnClair $a4156Name $spByte]
}


# qqchose à lire
proc ::a4156::waitMAV {a4156Name} {
    set again true
    while {$again} {
        GPIB::srqWait
        set poll [::a4156::serialPoll $a4156Name]
        if {$poll & 16} {       ;# qqchose à lire
            set again false 
        } else {
            if {$poll & 32} { ;# error
                error "::a4156::wait : $a4156Name : Error : [::a4156::getErrors $a4156Name]"
            }
        }
    }
}

proc ::a4156::DCL {a4156Name} {
    upvar #0 $a4156Name deviceArray
    global GPIB_boardAddress

    GPIB::unt
    GPIB::unl
    GPIB::mta $deviceArray(gpibAddr)
    GPIB::mla $GPIB_boardAddress($deviceArray(gpibBoard))
    GPIB::Command DCL
    GPIB::unt
    GPIB::unl
}

proc ::a4156::pollEnClair {_a4156Name spByte} {
    variable a4156SRQBitNames

    set rep [list]
    if {[isSet $spByte 6]} {
        if {[isSet $spByte 0]} {
            set w $a4156SRQBitNames(0)
#            lappend w [::a4156::warnings $_a4156Name]
            lappend rep $w
        }
        if {[isSet $spByte 1]} {
            lappend rep $a4156SRQBitNames(1)
        }
        if {[isSet $spByte 2]} {
            lappend rep $a4156SRQBitNames(2)
        }
        if {[isSet $spByte 3]} {
            lappend rep $a4156SRQBitNames(3)
        }
        if {[isSet $spByte 4]} {
            lappend rep $a4156SRQBitNames(4)
        }
        if {[isSet $spByte 5]} {
            set w $a4156SRQBitNames(5)
            lappend w [::a4156::getErrors $_a4156Name]
            lappend rep $w
        }
        if {[isSet $spByte 7]} {
            lappend rep $a4156SRQBitNames(7)
        }
    }
    return $rep
}

proc ::a4156::getErrors {a4156Name} {
    upvar #0 $a4156Name deviceArray
    global GPIB_boardAddress

    ::a4156::write $a4156Name "*ESR?"
    set rep [::a4156::readBin $a4156Name]
    if {[llength $rep] != 2} {
	return -code error "Attendu deux octets, reçu [llength $rep]"
    }
    if {[lindex $rep 1] != 10} {
	return -code error "Attendu octets \"xx 10\", reçu \"$rep\""
    }
    set r1 [::a4156::errorStatusEnClair [lindex $rep 0]]
    set r2 [::a4156::errorsEnClair [::a4156::getErrorRegister $a4156Name]]
    set rep [list $r1 $r2]
}

proc ::a4156::errorsEnClair {list} {
    variable a4156ErrorMessages

    set ret [list]
    foreach i $list {
	if {$i == 0} continue
	if {[info exists a4156ErrorMessages($i)]} {
	    lappend ret "$i - $a4156ErrorMessages($i)"
	} else {
	    lappend ret $i
	}
    }
    return $ret
}


proc ::a4156::errorStatusEnClair {spByte} {
    variable a4156ErrorStatus

    set rep [list]
    for {set i 0} {$i < 8} {incr i} {
        if {[isSet $spByte $i]} {
            lappend rep $a4156ErrorStatus($i)
        }
    }
    return $rep
}


#####################################################
# FLEX FLEX FLEX FLEX FLEX FLEX FLEX FLEX FLEX FLEX #
#####################################################

set a4156::flexUS {

    Reset
    *RST      reset, ini

    Self-Test
    *TST?

    Control Mode
    US        ini
    US42
    ACH
    :PAGE

    Unit Control
    CN
    CL
    FL
    IN
    DZ
    RZ
    RCV

    Measurement Mode
    MM
    CMM
    VM
    VMD

    dc Source Setup
    DI
    DV
    TDI
    TDV

    SMU Pulse Setup
    PT
    PI
    PV

    Stair Sweep Source Setup
    WT
    WI
    WV
    WM
    ESC

    Pulsed Sweep Source Setup
    PT
    PWI
    PWV
    WM
    ESC

    Synchronous Sweep Source Setup
    WSI
    WSV

    Source Setup for Sampling Measurements
    MI
    MV
    MP
    MCC
    MSC

    Time Stamp Function
    TSC
    TSR
    TSQ?

    Quasi-static CV Measurements Setup
    QSM
    QSL
    QSZ/QSZ?
    QST
    QSR
    QSV

    Binary Search Measurement Setup
    BSM
    BST
    BSVM
    BSI
    BSSI
    BGV
    BSV
    BSSV
    BGI

    Linear Search Measurement Setup
    LSTM
    LSVM
    LSI
    LSSI
    LGV
    LSV
    LSSV
    LGI
    WM

    PGU Control
    POR
    SPG
    SRP
    SPP

    Stress Source Setup
    POR
    STT
    STI
    STV
    STP
    STC
    STM
    
    Measurement Setup
    RI
    RV
    MT
    
    Integration Time
    SIT
    SLI
    AZ

    Averaging
    AV

    Measurement Execution
    TM
    XE
    TI/TI?
    TV/TV?
    TTI/TTI?
    TTV/TTV?

    Output Data
    FMT
    RMD
    BC

    ABORT/PAUSE/WAIT
    AB
    PA
    *WAI
    WS

    Zero Offset Cancel
    GOC
    SOC

    Self Calibration
    *CAL?
    CA
    CM

    Program Memory
    ST
    END
    SCR
    LST?
    DO
    RU
    PA

    SMU/PGU Selector
    SSP

    R-BOX
    RBC

    External Trigger
    STG
    OS

    Network Operation
    SDSK
    OPEN
    RD?
    WR
    CLOSE
    SPR
    SPL
    PRN
    
    Status Byte
    *CLS
    *ESE(?)
    *ESR?      getEventStatus
    *SRE
    *SRE?
    *STB?
    
    Query
    CMD?       1
    ERR?       getErrorRegister
    *IDN?      getModel
    LOP?       
    *LRN*
    NUB?
    *OPC(?)
    *OPT?
    :SYST:ERR?
    UNT?
    WNU?

}


proc ::a4156::enable_time_stamp {a4156Name} {
    ::a4156::write $a4156Name "TSC 1" 
}

proc ::a4156::reset_time_stamp {a4156Name} {
    ::a4156::write $a4156Name "TSR" 
}

proc ::a4156::read_time_stamp {a4156Name} {
    ::a4156::write $a4156Name "TSQ?"
    return [::a4156::read $a4156Name]
}

###############

set HELP(::a4156::abort) {Cf. p.1-48}
proc ::a4156::abort {a4156Name} {
    ::a4156::write $a4156Name "AB"
}

set HELP(::a4156::ini) {Cf. 1-3 1-4}
proc ::a4156::ini {a4156Name} {
    ::a4156::DCL   $a4156Name
    ::a4156::write $a4156Name "US"
#    ::a4156::abort $a4156Name
#    ::a4156::write $a4156Name "*RST"
#  attention,  a4 write "US" ; détruit *SRE, *ESE, etc.
    # a4 write "*SRE [expr {1+2+8+16+32}]"
    ::a4156::write $a4156Name "*SRE [expr {1+2+16+32}]"
    ::a4156::write $a4156Name "*ESE [expr {1+8+16+32}]"
    ::a4156::write $a4156Name "*OPC"
    ::a4156::write $a4156Name "FMT 3,1" ; puts stderr "Voir si \"FMT 3,2\" n'est pas mieux"
    ::a4156::setAverage $a4156Name 1
    ::a4156::setIntegrationTime $a4156Name period
    ::a4156::write $a4156Name "FL 0"
}

proc ::a4156::stripNL {s} {
    if {[string index $s end] != "\n"} {
	return -code error "La chaine de retour (longueur == [string length $s]) n'est pas terminée par \"\\n\""
    }
    return [string range $s 0 end-1]
}

set HELP(::a4156::modele) {Cf. p. 1-108}
proc ::a4156::getModel {a4156Name} {
    ::a4156::write $a4156Name "*IDN?"
    return [::a4156::stripNL [::a4156::read $a4156Name]]
}

proc ::a4156::getErrorRegister {a4156Name} {
    ::a4156::write $a4156Name "ERR?"
    return [split [::a4156::stripNL [::a4156::read $a4156Name]] ,]
}

proc ::a4156::getOperationStatus {a4156Name} {
    ::a4156::write $a4156Name "LOP?"
    set s [::a4156::stripNL [::a4156::read $a4156Name]]
    set stats [split $s ,]
    if {[llength $stats] != 9} {
	return -code error "LOP? a renvoyé \"$s\" au lieur d'une liste de 9 nombres"
    }
    set ret [list]
    lappend ret GNDU [::a4156::lop GNDU [lindex $stats 0]]
    lappend ret SMU1 [::a4156::lop SMU  [lindex $stats 1]]
    lappend ret SMU2 [::a4156::lop SMU  [lindex $stats 2]]
    lappend ret SMU3 [::a4156::lop SMU  [lindex $stats 3]]
    lappend ret SMU4 [::a4156::lop SMU  [lindex $stats 4]]
    lappend ret SMU5 [::a4156::lop SMU  [lindex $stats 5]]
    lappend ret SMU6 [::a4156::lop SMU  [lindex $stats 6]]
    lappend ret VSUs [::a4156::lop VSU  [lindex $stats 7]]
    lappend ret PGUs [::a4156::lop PGU  [lindex $stats 8]]
    return $ret
}

proc ::a4156::lop {type statVal} {
    if {$statVal >= 256} {
	return -code error "Retour de LOP? >= 256"
    }
    set statList [list]
    if {$statVal & 128} {
	lappend statList "ON"
    } else {
	lappend statList "OFF"
    }
    if {$type == "VSU" || $type == "PGU"} {
	if {$statVal & 64} {
	    lappend statList "${type}2=ON"
	} else {
	    lappend statList "${type}2=OFF"
	}
	if {$statVal & 4} {
	    lappend statList "${type}1=limit"
	}
	if {$statVal & 2} {
	    lappend statList "${type}2=limit"
	}
    } elseif {$type == "VMU"} {
	if {$statVal & 32} {
	    lappend statList "${type}1=ON"
	}	
	if {$statVal & 16} {
	    lappend statList "${type}2=ON"
	}	
    } elseif {$type == "SMU"} {
	if {$statVal & 8} {
	    lappend statList "Source_I"
	} else {
	    lappend statList "Source_V"
	}
	switch [expr {($statVal >> 1) & 3}] {
	    0 {lappend statList "Voltage_compliance"}
	    1 {lappend statList "-Current_compliance"}
	    2 {lappend statList "+Current_compliance"}
	    3 {return -code error "LOP? = \"$statVal\", bits 1 et 2 inattendus"}
	}
	if {$statVal & 1} {
	    lappend statList Oscillating
	}
    } elseif {$type == "GNDU"} {
    } else {
	return -code error "Type \"$type\" inconnu"
    }
    return $statList
}

proc ::a4156::getEventStatus {a4156Name} {
    ::a4156::write $a4156Name "*ESR?"
    set stat [expr {int([::a4156::stripNL [::a4156::read $a4156Name]])}]
    if {$stat >= 64} {
	return -code error "I don't understand, bit 6 or 7 of *ESR? is not null"
    }
    set statlist [list]
    if {$stat >= 32} {
	lappend statlist "Syntax error"
	incr stat -32
    }
    if {$stat >= 16} {
	lappend statlist "Parameter error"
	incr stat -16
    }
    if {$stat >= 8} {
	lappend statlist "Error"
	incr stat -8
    }
    if {$stat >= 4} {
	return -code error "I don't understand, bit 1 or 2 of *ESR? is not null"
    }
    if {$stat == 1} {
	lappend statlist "Operation complete"
    }
    return $statlist
}

proc ::a4156::repos {a4156Name} {
    ::a4156::write $a4156Name "CL"
}

proc ::a4156::operate {a4156Name smu} {
    ::a4156::write $a4156Name "CN $smu"
}

proc ::a4156::setAverage {a4156Name n} {
    if {$n < 1 || $n > 1023} {
	return -code error "average (a4156 AV argument) should be beetween 1 and 1023"
    }
    ::a4156::write $a4156Name "AV $n"
}

proc ::a4156::setIntegrationTime {a4156Name duration} {
    if {$duration == "period"} {
	::a4156::write $a4156Name "SLI 2"
    } elseif {$duration >= 80.e-6 && $duration <= 10.16e-3} {
	::a4156::write $a4156Name "SIT 1,$duration"
	::a4156::write $a4156Name "SLI 1"
    } elseif {$duration >= 0.04 && $duration <= 2.0} {
	::a4156::write $a4156Name "SIT 3,$duration"
	::a4156::write $a4156Name "SLI 3"	
    } else {
	return -code error "integration time (a4156 SIT argument) out of range (80.e-6...10.16e-3 period 0.04...2.0)"
    }
}

proc ::a4156::spot {a4156Name smu IV range} {
    if {$IV != "I" && $IV != "V"} {
	return -code error "IV should be \"I\" or \"V\", not \"$IV\""
    }
    if {$range == "compliance"} {
	::a4156::write $a4156Name "T${IV}? $smu"
    } else {
	::a4156::write $a4156Name "T${IV}? $smu,$range"
    }
    ::a4156::waitMAV $a4156Name
    set ret [::a4156::readBin $a4156Name]
    puts stderr $ret
    if {[llength $ret] != 7} {
	return -code error "Lu [llength $ret] octets au lieu de 7"
    }
    if {[lindex $ret 6] != 10} {
	return -code error "7ieme octet = [lindex $ret 6] au lieu de 10"	
    }
    return [::a4156::binlist [lrange $ret 0 5]]
} 

proc ::a4156::spotWithTimeStamp {a4156Name smu IV range} {
    if {$IV != "I" && $IV != "V"} {
	return -code error "IV should be \"I\" or \"V\", not \"$IV\""
    }
    if {$range == "compliance"} {
	::a4156::write $a4156Name "TT${IV}? $smu"
    } else {
	::a4156::write $a4156Name "TT${IV}? $smu,$range"
    }
    # ::a4156::waitMAV $a4156Name
    set ret [::a4156::readBin $a4156Name]
    if {[llength $ret] != 13} {
	return -code error "Lu [llength $ret] octets au lieu de 13"
    }
    if {[lindex $ret 12] != 10} {
	return -code error "13ieme octet = [lindex $ret 12] au lieu de 10"	
    }
    return [concat [::a4156::binlist [lrange $ret 0 5]] [::a4156::binlist [lrange $ret 6 11]]]
}

proc ::a4156::testSpot {a4156Name v irange} {
    ::a4156::write $a4156Name "MM 1,1,2"
    ::a4156::write $a4156Name "CN 1,2"
    ::a4156::write $a4156Name "RI 1,$irange"    
    ::a4156::write $a4156Name "RI 2,$irange"    
    ::a4156::write $a4156Name "DV 1,11,0.00,1e-7,0"
    ::a4156::write $a4156Name "DV 2,11,$v,1e-7,0"
}

proc ::a4156::nub? {a4156Name} {
    ::a4156::write $a4156Name "NUB?"
    set n [::a4156::stripNL [::a4156::read $a4156Name]]
    return $n
}

proc ::a4156::mesure {a4156Name n} {
    ::a4156::write $a4156Name "XE"
    # set n [::a4156::nub? $a4156Name]
    ::a4156::write $a4156Name "RMD? 0"
    set ret [::a4156::readBin $a4156Name]
    
    if {[llength $ret] != $n*6+1} {
	return -code error "Lu [llength $ret] octets au lieu de [expr {$n*6+1}]"
    }
    if {[lindex $ret [expr {$n*6}]] != 10} {
	return -code error "13ieme octet = [lindex $ret [expr {$n*6}]] au lieu de 10"	
    }
    set lret [list]
    set i0 0
    set i1 5
    for {set i 0} {$i < $n} {incr i} {
	set v [lrange $ret $i0 $i1]
	incr i0 6
	incr i1 6
	set v [::a4156::binlist $v]
	lappend lret $v
    }
    return $lret
}

proc ::a4156::binlist {list} {
    if {[llength $list] != 6} {
	return -code error "length == [llength $list] != 6"
    }
    set sm [expr {([lindex $list 0] >> 7) & 1}]
    switch $sm {
	0 {set s_sm source}
	1 {set s_sm measure}
    }
    set type [expr {([lindex $list 0] >> 4) & 7}]
    switch $type {
	0 {set s_type voltage}
	1 {set s_type current}
	2 {set s_type capacitance}
	3 {set s_type time}
	6 {set s_type index}
	7 {set s_type status}
	default {set s_type unknown}
    }
    set channel [expr {([lindex $list 5] >> 0) & 15}]
    if {$type == 0 || $type == 1} {
	set range [expr {(([lindex $list 1] >> 7) & 1) + (([lindex $list 0] & 15) << 1)}]
	set stat [list]
	if {[expr {([lindex $list 5] >> 5) & 1}]} {lappend stat Overflow}
	if {[expr {([lindex $list 5] >> 6) & 1}]} {lappend stat Oscillation}
	if {[expr {([lindex $list 5] >> 7) & 1}]} {lappend stat "Other compliance"}
	if {[expr {([lindex $list 4] >> 0) & 1}]} {lappend stat "Compliance"}
	if {[expr {([lindex $list 4] >> 1) & 1}]} {lappend stat "PGU compliance"}
	if {[expr {([lindex $list 4] >> 2) & 1}]} {puts stderr "Sweep stopped"}
	if {[expr {([lindex $list 4] >> 3) & 1}]} {lappend stat "Invalid"}
	if {[expr {([lindex $list 4] >> 4) & 1}]} {set eod 1} else {set eod 0}
	set val [expr {([lindex $list 4] >> 5) + ([lindex $list 3] << 3) + ([lindex $list 2] << 11) + (([lindex $list 1] & 63) << 19)}]
	set sign [expr {([lindex $list 1] >> 6) & 1}]
	if {$sign} {
	    set val [expr {$val - 33554432}]
	}
	if {$sm} {
	    set val [expr {$val*0.000001}]
	} else {
	    set val [expr {$val*0.00005}]
	}
	if {$range == 31} {
	    set val "Invalid"
	} else {
	    switch $type {
		0 {
		    if {$range < 10 || $range > 15} {
			return -code error "Range $range interdit pour \"Voltage data\""
		    }
		    switch $range {
			10 {set fact 0.2}
			11 {set fact 2.0}
			12 {set fact 20.0}
			13 {set fact 40.0}
			14 {set fact 100.0}
			15 {set fact 200.0}
		    }
		    set dataType V
		}
		1 {
		    if {$range < 9 || $range > 20} {
			return -code error "Range $range interdit pour \"Current data\""
		    }
		    set fact [expr {pow(10,$range-20)}]
		    set dataType A
		}
		default {
		    return -code error "Type $type inattendu ici"
		}
	    }
	}
	return [list $s_sm $s_type $eod $channel $val $fact $dataType $stat]
    } elseif {$type == 3} {
	set dataType t
	set val [expr {(([lindex $list 5] >> 5) + ([lindex $list 4] << 3) + ([lindex $list 3] << 11) +
		       double((([lindex $list 0] & 15) << 16) + ([lindex $list 1] >> 8) +  [lindex $list 2])*pow(2,19))*100e-6 }]
	return [list $s_sm $s_type $channel $val]
    } else {
	return -code error "Type $type pas encore prise en compte"
    }
}

proc ::a4156::vsuTTL {a4156Name vsu level} {
    upvar #0 $a4156Name deviceArray

    if {$vsu == 1} {
	set chnum 21 
    } elseif {$vsu == 2} {
	set chnum 22
    } else {
	return -code error "vsu should be 1 or 2"
    }

    if {$level} {
	::a4156::write $a4156Name "DV $chnum,0,5"
    } else {
	::a4156::write $a4156Name "DV $chnum,0,0"
    }
}

proc ::a4156::essai {a4156Name} {
    upvar #0 $a4156Name deviceArray

    set l [list]
    for {set i 0} {$i < 100} {incr i} {
	::a4156::write $a4156Name "TV? 2,-11"
	set r [::a4156::readBin $a4156Name]
	if {[llength $r] != 7} {
	    return -code error "Lu [llength $r] octets au lieu de 7"
	}
	if {[lindex $r 6] != 10} {
	    return -code error "13ieme octet = [lindex $r 6] au lieu de 10"	
	}
	set r [::a4156::binlist [lrange $r 0 5]]
	lappend l [expr {[lindex $r 2]*[lindex $r 3]}]
    }
    return $l
}

proc ::a4156::essai2 {a4156Name} {
    upvar #0 $a4156Name deviceArray

    set l [list]
    for {set i 0} {$i < 100} {incr i} {
	::a4156::write $a4156Name "TV? 2,-11"
	::a4156::waitMAV $a4156Name
	set r [::a4156::readBin $a4156Name]
	if {[llength $r] != 7} {
	    return -code error "Lu [llength $r] octets au lieu de 7"
	}
	if {[lindex $r 6] != 10} {
	    return -code error "13ieme octet = [lindex $r 6] au lieu de 10"	
	}
	set r [::a4156::binlist [lrange $r 0 5]]
	lappend l [expr {[lindex $r 2]*[lindex $r 3]}]
    }
    return $l
}






set rien {
    Self-Test
    *TST?

    Control Mode
    US42
    ACH
    :PAGE

    Unit Control
    CN
    CL
    FL
    IN
    DZ
    RZ
    RCV

    Measurement Mode
    MM
    CMM
    VM
    VMD

    dc Source Setup
    DI
    DV
    TDI
    TDV

    SMU Pulse Setup
    PT
    PI
    PV

    Stair Sweep Source Setup
    WT
    WI
    WV
    WM
    ESC

    Pulsed Sweep Source Setup
    PT
    PWI
    PWV
    WM
    ESC

    Synchronous Sweep Source Setup
    WSI
    WSV

    Source Setup for Sampling Measurements
    MI
    MV
    MP
    MCC
    MSC

    Time Stamp Function
    TSC
    TSR
    TSQ?

    Quasi-static CV Measurements Setup
    QSM
    QSL
    QSZ/QSZ?
    QST
    QSR
    QSV

    Binary Search Measurement Setup
    BSM
    BST
    BSVM
    BSI
    BSSI
    BGV
    BSV
    BSSV
    BGI

    Linear Search Measurement Setup
    LSTM
    LSVM
    LSI
    LSSI
    LGV
    LSV
    LSSV
    LGI
    WM

    PGU Control
    POR
    SPG
    SRP
    SPP

    Stress Source Setup
    POR
    STT
    STI
    STV
    STP
    STC
    STM
    
    Measurement Setup
    RI
    RV
    MT
    
    Integration Time
    SIT
    SLI
    AZ

    Averaging
    AV

    Measurement Execution
    TM
    XE
    TI/TI?
    TV/TV?
    TTI/TTI?
    TTV/TTV?

    Output Data
    FMT
    RMD
    BC

    ABORT/PAUSE/WAIT
    AB
    PA
    *WAI
    WS

    Zero Offset Cancel
    GOC
    SOC

    Self Calibration
    *CAL?
    CA
    CM

    Program Memory
    ST
    END
    SCR
    LST?
    DO
    RU
    PA

    SMU/PGU Selector
    SSP

    R-BOX
    RBC

    External Trigger
    STG
    OS

    Network Operation
    SDSK
    OPEN
    RD?
    WR
    CLOSE
    SPR
    SPL
    PRN

    Status Byte
    *CLS
    *ESE(?)
    *SRE
    *SRE?
    *STB?
    
    Query
    CMD?
    ERR?
    LOP?
    *LRN*
    NUB?
    *OPC(?)
    *OPT?
    :SYST:ERR?
    UNT?
    WNU?

}



#####################################################
# SCPI SCPI SCPI SCPI SCPI SCPI SCPI SCPI SCPI SCPI #
#####################################################



set a4156::scpi {
    # Common Commands
    *CAL? switch {
        +0 PASS
        +1 FAIL
    }
    *CLS {}
    *ESE NR1 {
        PON "Power on"
        NOT_USED "Not Used"
        CME "Command ERROR"
        EXE "Execution ERROR"
        DDE "Device-Dependent ERROR"
        QYE "Query ERROR"
        RQC "Request Control"
        OPC "Operation Complete"
    }
    *ESE? NR1 {
        PON "Power on"
        NOT_USED "Not Used"
        CME "Command ERROR"
        EXE "Execution ERROR"
        DDE "Device-Dependent ERROR"
        QYE "Query ERROR"
        RQC "Request Control"
        OPC "Operation Complete"
    }
    *ESR? register
    *IDN? regexp HEWLETT-PACKARD,([^,]+),0,([^,]+) model revision
    *OPC {}
    *OPC? 1
etc.

}

namespace eval ::a4156::scpi {}

proc ::a4156::scpi::reset {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) "*RST"
}

proc ::a4156::scpi::data_catalog? {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA:CAT?"
    set chaine {}
    while {[string index $chaine end] != "\n"} {
        append chaine [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512]
    }
    return [split [string range $chaine 0 end-1] ,]
} 
    
proc ::a4156::scpi::data {a4156Name varname valList} {
    upvar #0 $a4156Name deviceArray

    puts stderr ":DATA '$varname',[join $valList ,]"
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA '$varname',[join $valList ,]"
}

proc ::a4156::scpi::binary_data? {a4156Name varname} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA? '$varname'"
    set ret [GPIB::rdBin $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512]
    return $ret
}

proc ::a4156::scpi::data? {a4156Name varname} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA? '$varname'"
    set ret [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512]
    if {[string index $ret end] != "\n"} {
        return -code error " ::a4156::scpi::data? : Chaîne lue non terminée par unretour de chariot : \"$ret\""
    }
    return [string range $ret 0 end-1]
}

set HELP(::a4156::scpi::getAllDatas) {
    transfère toutes les variables de l'appareil dans le tableau de nom $arrayName
}

proc ::a4156::scpi::getAllDatas {a4156Name arrayName} {
    upvar #0 $a4156Name deviceArray
    upvar 2 $arrayName array

    array unset a *
    foreach var [::a4156::scpi::data_catalog? $a4156Name] {
        set array($var) [::a4156::scpi::data? $a4156Name $var]
    }
}

proc ::a4156::scpi::data_define {a4156Name varname length} {
    upvar #0 $a4156Name deviceArray

    set length [format %d $length]
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA:DEF '$varname',$length"
}

proc ::a4156::scpi::data_delete_all {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA:DEL:ALL"
}

proc ::a4156::scpi::double_dl_to_list {bs} {
    if {![regexp {^#(.)$} [string range $bs 0 1] tout n]} {
        return -code error "Not a Definite Length Arbitrary Block Response Data"
    }
    set len [string trimleft [string range $bs 2 [expr {$n+1}]] 0]
    if {[string length $bs] != $len + $n + 1} {
        return -code error "Bad String Length ([string length $bs]), should be [expr {$len + $n + 1}]"
    }
    set bs [string range $bs [expr {$n+1}] end]

}

set test {
    package require a4156
    GPIB::newGPIB a4156 spa $GPIB_board 19
    

    spa data_delete_all
    spa format_ascii
    spa data_define essai1 1
    spa data_define essai4 4
    spa data essai1 3.14
    spa data essai4 10,20,30,40
    set x1 [spa data? essai1]
    set x4 [spa data? essai4]
    spa format_double
    set x1b [spa binary_data? essai1]
    set x4b [spa binary_data? essai4]
    set qb [spa binary_data? q]
    set x1b [spa data? essai1]
    set x4b [spa data? essai4]
    set qb [spa data? q]
    string length $qb
}

proc ::a4156::scpi::data_free? {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":DATA:FREE?"
    return [split [string range [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512] 0 end-1] ,]
} 

proc ::a4156::scpi::format_byte_order? {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM:BORD?"
    return [string range [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512] 0 end-1]
}

proc ::a4156::scpi::format_byte_order_normal {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM:BORD NORM"
}

proc ::a4156::scpi::format_byte_order_swapped {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM:BORD SWAP"
}

proc ::a4156::scpi::format? {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM?"
    return [split [string range [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 512] 0 end-1] ,]
}

set HELP(::a4156::scpi::format_binary) {
    concerne seulement ::a4156::scpi::data_define et ::a4156::scpi::data_status
}

proc ::a4156::scpi::format_ascii {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM ASC"
}

proc ::a4156::scpi::format_float {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM REAL,32"
}

proc ::a4156::scpi::format_double {a4156Name} {
    upvar #0 $a4156Name deviceArray

    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ":FORM REAL"
}

