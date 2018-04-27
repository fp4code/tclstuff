package provide flex 0.2

set commandes {
AB ACH AV AZ BC BGI BGV BSI BSM BSSI BSSV BST BSV BSVM CA *CAL? CL CLOSE *CLS CM CMD? CMM CN
DI DO DV DZ END ERR? ESC *ESE *ESE? *ESR? FL FMT GOC *IDN? IN
LGI LGV LOP? *LRN? LSI LSSI LSSV LST? LSTM LSV LSVM
MCC MI MM MP MSC MT MV NUB? *OPC *OPC? OPEN *OPT? OS
PA PI POR PRN PT PV PWI PWV QSL QSM QSR QST QSV QSZ QSZ?
RBC RCV RD? RI RMD? *RST RU RV RZ
SCR SDSK SIT SLI SOC SPG SPL SPP SPR *SRE *SRE? SRP SSP ST *STB? STC STG STI STM STP STT STV :SYST:ERR?
TDI TDV TI TI? TM TSC TSQ? TSR *TST? TTI TTI? TTV TTV? TV TV? UNT?
US US42
VM VMD *WAI WI WM WNU? WR WS WSI WSV WT WV XE
}

set tcl_traceExec 0
set tcl_traceCompile 0

puts stderr "Voir si \"FMT 3,2\" n'est pas mieux"

package require fidev
package require a4156
package require gpib
package require gpibLowLevel 1.3

GPIB::main
set variable_SRQ {}
global GPIB_board GPIB_boardAddress
GPIB::newGPIB a4156 a4156  $GPIB_board 9


namespace eval ::a4156::flex {}
namespace eval ::a4156::private_flex {}

proc ::a4156::private_flex::error_message {code} {
    if {$code == 0} {
	return None
    }
    switch -- [string index $code 0] {
	"-" {switch -- [string index $code 1] {
	    1 {switch -- [string index $code 2] {
		0 {switch -- [string index $code 3] {
		    0 {return "Command error"}
		    1 {return "Invalid character"}
		    2 {return "Syntax error"}
		    3 {return "Invalid separator"}
		    4 {return "Data type error"}
		    5 {return "GET not allowed"}
		    8 {return "Parameter not allowed"}
		    9 {return "Missing parameter"}
		    default {error "Bad -10x error code \"$code\""}
		}}
		1 {switch -- [string index $code 3] {
		    0 {return "Command header error"}
		    1 {return "Header separator error"}
		    2 {return "Program mnemonic too long"}
		    3 {return "Undefined header"}
		    4 {return "Header suffix out of range"}
		    default {error "Bad -11x error code \"$code\""}
		}}
		2 {switch -- [string index $code 3] {
		    0 {return "Numeric data error"}
		    1 {return "Invalid character in number"}
		    3 {return "Exponent too large"}
		    4 {return "Too many digits"}
		    8 {return "Numeric data not allowed"}
		    default {error "Bad -12x error code \"$code\""}
		}}
		3 {switch -- [string index $code 3] {
		    0 {return "Suffix error"}
		    1 {return "Invalid suffix"}
		    4 {return "Suffix too long"}
		    8 {return "Suffix not allowed"}
		    default {error "Bad -13x error code \"$code\""}
		}}
		4 {switch -- [string index $code 3] {
		    0 {return "Character data error"}
		    1 {return "Invalid character data"}
		    4 {return "Character data too long"}
		    8 {return "Character data not allowed"}
		    default {error "Bad -14x error code \"$code\""}
		}}
		5 {switch -- [string index $code 3] {
		    0 {return "String data error"}
		    1 {return "Invalid string data"}
		    8 {return "String data not allowed"}
		    default {error "Bad -15x error code \"$code\""}
		}}
		6 {switch -- [string index $code 3] {
		    0 {return "Block data error"}
		    1 {return "Invalid block data"}
		    8 {return "Block data not allowed"}
		    default {error "Bad -16x error code \"$code\""}
		}}
		7 {switch -- [string index $code 3] {
		    0 {return "Expression error"}
		    1 {return "Invalid expression"}
		    8 {return "Expression data not allowed"}
		    default {error "Bad -17x error code \"$code\""}
		}}
		default {error "Bad -1xx error code \"$code\""}
	    }}
	    2 {switch -- [string index $code 2] {
		0 {switch -- [string index $code 3] {
		    0 {return "Execution error"}
		    1 {return "Invalid while in local"}
		    2 {return "Settings lost due to rtl"}
		    default {error "Bad -20x error code \"$code\""}
		}}
		1 {switch -- [string index $code 3] {
		    0 {return "Trigger error"}
		    1 {return "Trigger deadlock"}
		    default {error "Bad -21x error code \"$code\""}
		}}
		2 {switch -- [string index $code 3] {
		    0 {return "Parameter error"}
		    1 {return "Settings conflict"}
		    2 {return "Data out of range"}
		    3 {return "Too much data"}
		    4 {return "Illegal parameter value"}
		    default {error "Bad -22x error code \"$code\""}
		}}
		3 {switch -- [string index $code 3] {
		    0 {return "Data corrupt or stale"}
		    1 {return "Data questionable"}
		    default {error "Bad -23x error code \"$code\""}
		}}
		4 {switch -- [string index $code 3] {
		    0 {return "Hardware error"}
		    1 {return "Hardware missing"}
		    default {error "Bad -24x error code \"$code\""}
		}}
		5 {switch -- [string index $code 3] {
		    0 {return "Mass storage error"}
		    1 {return "Missing mass storage"}
		    2 {return "Missing media"}
		    3 {return "Corrupt media"}
		    4 {return "Media full"}
		    6 {return "File name not found"}
		    7 {return "File name error"}
		    8 {return "Media protected"}
		    9 {return ""}
		    default {error "Bad -25x error code \"$code\""}
		}}
		6 {switch -- [string index $code 3] {
		    0 {return "Expression error"}
		    1 {return "Math error in expression"}
		    default {error "Bad -26x error code \"$code\""}
		}}
		default {error "Bad -2x error code \"$code\""}
	    }}
	    3 {switch -- [string index $code 2] {
		0 {switch -- [string index $code 3] {
		    0 {return "Device-specific error"}
		    default {error "Bad -30x error code \"$code\""}
		}}
		1 {switch -- [string index $code 3] {
		    0 {return "System error"}
		    1 {return "Memory error"}
		    3 {return "Calibration memory lost"}
		    5 {return "Configuration memory lost"}
		    default {error "Bad -31x error code \"$code\""}
		}}
		3 {switch -- [string index $code 3] {
		    0 {return "Self-test failed"}
		    default {error "Bad -33x error code \"$code\""}
		}}
		5 {switch -- [string index $code 3] {
		    0 {return "Queue overflow"}
		    default {error "Bad -35x error code \"$code\""}
		}}
		default {error "Bad -3xx error code \"$code\""}
	    }}
	    4 {switch -- [string index $code 2] {
		0 {switch -- [string index $code 3] {
		    0 {return "Query error"}
		    default {error "Bad -40x error code \"$code\""}
		}}
		1 {switch -- [string index $code 3] {
		    0 {return "Query INTERRUPTED"}
		    default {error "Bad -41x error code \"$code\""}
		}}
		2 {switch -- [string index $code 3] {
		    0 {return "Query UNTERMINATED"}
		    default {error "Bad -42x error code \"$code\""}
		}}
		3 {switch -- [string index $code 3] {
		    0 {return "Query DEADLOCKED"}
		    default {error "Bad -43x error code \"$code\""}
		}}
		4 {switch -- [string index $code 3] {
		    0 {return "Query UNTERMINATED"}
		    default {error "Bad -44x error code \"$code\""}
		}}
		default {error "Bad error -4xx code \"$code\""}
	    }}
	    default {error "Bad error -xxx code \"$code\""}   
	}}
	5 {switch -- [string index $code 1] {
	    0 {switch -- [string index $code 2] {
		0 {return "Improper parameter value, check setup range"}
		1 {return "Improper channel number or slot number"}
		2 {return "A unit is not installed on specified channel"}
		3 {return "Specified unit cannot execute this command"}
		4 {return "Specified unit failed self-test/self-calib"}
		5 {return "Filter can be set to SMUs only"}
		6 {return "Unsupported unit detected in some slot"}
		7 {return "Program memory is full, reduce commands (program number [string range $code 3 5], overflow at [string range $code 6 end]"}
		8 {return "Program creation aborted"}
		9 {return "ST must be executed before END command"}
		default {error "Bad 50x error code \"$code\""}
	    }}
	    1 {switch -- [string index $code 2] {
		0 {return "Unable to use this command between ST and END"}
		1 {return "Comp/range cannot be omit to use prog memory"}
		2 {return "Output data buffer full"}
		3 {return "Improper output range or output value"}
		4 {return "Improper measurement range setup"}
		5 {return "Specified output values are out of range"}
		6 {return "Cannot omit compliance setup"}
		7 {return "The compliance setup is out of range"}
		8 {return "Power compliance setting is out of range"}
		9 {return "Current output range must be >= 100 nA in PI"}
		default {error "Bad 51x error code \"$code\""}
	    }}
	    2 {switch -- [string index $code 2] {
		0 {return "Measurement range must be less than compliance (en fait, la range doit être juste adaptée)"}
		1 {return "Range setup is wrong for the specified VMU"}
		2 {return "Unable to set compliance for VSU or PGU"}
		3 {return "Cannot open the relay driving more than 40 V"}
		4 {return "Unable to output over 40 V, interlock open"}
		5 {return "Unit sw must be ON before command execution"}
		6 {return "Filter must be set to OFF for pulse SMU"}
		7 {return "SMU/VSU hold time must be <= 655.35 s in the PT"}
		8 {return "SMU/VSU pulse width must be 0.5 ms to 100 ms"}
		9 {return "SMU/VSU pulse period must be 5 ms to 1 s"}
		default {error "Bad 52x error code \"$code\""}
	    }}
	    3 {switch -- [string index $code 2] {
		0 {return "SMU/VSU pulse trigger must be 0 ms to 32.7 ms"}
		1 {return "Improper measurement mode in MM command"}
		2 {return "Only one meas unit when priority is 0 in PT"}
		3 {return "Only one meas channel when init int < 2 µs"}
		4 {return "Measurement mode must be set by MM command"}
		5 {return "At least one meas. unit must be set in MM"}
		6 {return "Command order must be MT, MM, then XE"}
		7 {return "Chan no cannot be set for stress force in MM"}
		8 {return "Set PV/PI for meas. using pulse source"}
		9 {return "At least one SYNC channel must be specified"}
		default {error "Bad 53x error code \"$code\""}
	    }}
	    4 {switch -- [string index $code 2] {
		0 {return "WV or WI must be set for sweep measurement"}
		1 {return "PWV/PWI must be set for pulse sweep meas"}
		2 {return "Cal/Diag may not be performed on some units"}
		3 {return "Cal/Diag failed. Cannot use the units"}
		4 {return "41501A/B is not turned on"}
		5 {return "Unable to execute RZ before DZ"}
		6 {return "Start and stop value must be same when step=1"}
		7 {return "Set WV/WI/PWV/PWI before WSV/WSI"}
		8 {return "CH num for pulse must differ from other sources"}
		9 {return "Ranging mode must be 0 to 3 (0 to 2 for VMU) in RV/RI"}
		default {error "Bad 54x error code \"$code\""}
	    }}
	    5 {switch -- [string index $code 2] {
		0 {return "Ranging mode must be 0 or 1 in WI/WV/WSV/WSI/PWI/PWV"}
		1 {return "Improper comp. polarity for manual polarity"}
		2 {return "Sweep mode must be 1 to 4 in WI/WV/PWI/PWV"}
		3 {return "Num of steps in WI/WV/PWI/PWV must be 1 to 1001"}
		4 {return "Start/stop must be same pol and not 0 for log"}
		5 {return "Base and pulse current must be same polarity"}
		6 {return "Unable to assign primary/sync. sweep to same CH"}
		7 {return "Improper WSI/WSV entry, ignore returned value"}
		8 {return "Pulse mode must be 0 or 1 in PT command"}
		9 {return "Trigger output delay must be <= pulse width"}
		default {error "Bad 55x error code \"$code\""}
	    }}
	    6 {switch -- [string index $code 2] {
		0 {return "Mode must be set to 0 or 1 in FL command"}
		1 {return "Mode must be set to 1 or 2 in VM"}
		2 {return "Incorrect trigger mode, check TM syntax"}
		3 {return "PGU pulse delay time must be 0 s to 10 s"}
		4 {return "PGU pulse width must be 1 us to 10 s"}
		5 {return "PGU pulse period must be 1 us to 10 s"}
		6 {return "PGU leading time must be 100 ns to 10.0 ms"}
		7 {return "PGU trailing time must be 100 ns to 10.0 ms"}
		8 {return "PG pulse width/period/delay must be same range"}
		9 {return "SMU pulse period must be >= pulse width + 4 ms"}
		default {error "Bad 56x error code \"$code\""}
	    }}
	    7 {switch -- [string index $code 2] {
		0 {return "Offset mode must be set 0 or 1 in SOC command"}
		1 {return "Zero offset meas failed for the unit"}
		2 {return "Too big offset for 10 pA range of the unit"}
		3 {return "Range setup is wrong in GOC command"}
		4 {return "Category must be 1 or 3 in SIT"}
		5 {return "Integration time must be more than 0 s"}
		6 {return "System error"}
		7 {return "577 Mode must be set 0, 1, or 2 in SPG command"}
		8 {return "PGU pulse and base value must be <= +/- 40 V"}
		9 {return "Pulse count must be 0 to 65535 s in SPG"}
		default {error "Bad 57x error code \"$code\""}
	    }}
	    8 {switch -- [string index $code 2] {
		0 {return "Pulse unit must be set by SPG before SRP"}
		1 {return "Set 0 or 1 to output impedance parameter in POR"}
		2 {return "PGUs are not installed"}
		3 {return "Port number must be set to 0, 1, 2, or 3 in SSP"}
		4 {return "Status must be set to 0, 1, 2, or 3 in SSP"}
		5 {return "Channel number must be set to 1 or 2 in RBC"}
		6 {return "Resistance must be set to 0, 1, 2, or 3 in RBC"}
		7 {return "Reference number must be 0 to 3 in STI/STV/STP"}
		8 {return "Output mode must be set to 0 or 1 in STP"}
		9 {return "Stress mode must be set to 0, 1, or 2 in STT"}
		default {error "Bad 58x error code \"$code\""}
	    }}
	    9 {switch -- [string index $code 2] {
		0 {return "Set 500 µs to 655 s for time, or 1 to 65535 for count"}
		1 {return "Pulse period must be 1 us to 10 s in STT"}
		2 {return "Output mode must be set to 0 or 1 in MP"}
		3 {return "The specified programs are not stored"}
		4 {return "Start prog num must be <= stop prog num in RU"}
		5 {return "Program \# must be 1 to 255 in DO/RU/SCR/LST?"}
		6 {return "DO or RU command execution was aborted"}
		7 {return "Measurement aborted, interlock open while > 40 V"}
		8 {return "Network disabled"}
		9 {return "Disk must be set to 0, 1, 2, 3, or 4 in SDSK"}
		default {error "Bad 59x error code \"$code\""}
	    }}
	    default {
		error "Bad 5xx error code \"$code\""
	    }
	}}
	6 {switch -- [string index $code 1] {
	    0 {switch -- [string index $code 2] {
		0 {return "Open mode must be set to 0, 1, or 2 in OPEN"}
		1 {return "Printer must be 1, 2, 3, or 4 in SPR"}
		2 {return "Data cannot be appended to a file on a diskette"}
		3 {return "Incomplete network setup, unable to mount disk"}
		4 {return "Cannot open two files, close the opened file"}
		5 {return "Unable to open file"}
		6 {return "Seek operation to the network disk failed"}
		7 {return "Unable to create the file specified in OPEN"}
		8 {return "Unable to close the file specified in CLOSE"}
		9 {return "Unable to write or read, file is not opened"}
		default {error "Bad 60x error code \"$code\""}
	    }}
	    1 {switch -- [string index $code 2] {
		0 {return "Read error occurred, data or media corrupt"}
		1 {return "Write error occurred, media corrupt or full"}
		2 {return "PA command gets no return from SMUCWrite error occurred, media corrupt or full"}
		3 {return "Select printer registered in the MISC page"}
		4 {return "Must select disk before executing SPL or PRN"}
		5 {return "Must select network printer before PRN"}
		6 {return "Unable to connect server, network problem"}
		7 {return "Unable to print out, LPD went down"}
		8 {return "Unable to print out, data transfer failed"}
		9 {return "Unable to delete spool file"}
		default {error "Bad 61x error code \"$code\""}
	    }}
	    2 {switch -- [string index $code 2] {
		0 {return "Measurement aborted by AB command"}
		1 {return "Measurement aborted, timeout occurred"}
		2 {return "Meas./stress completed, stop condition satisfied"}
		3 {return "Measurement aborted, data buffer full"}
		4 {return "Measurement aborted, reason unknown"}
		5 {return "Measurement mode must be 0, 1, 2 or 3 in CMM"}
		6 {return "Unsupported file, or file name is wrong"}
		7 {return "PGU pulse period must be > pulse width"}
		8 {return "PGU pulse period must be >= pulse delay"}
		9 {return "PGU leading time must be <= 0.8 x pulse width"}
		default {error "Bad 62x error code \"$code\""}
	    }}
	    3 {switch -- [string index $code 2] {
		0 {return "PGU trailing time must be <= 0.8 x(Period Width)"}
		1 {return "Emergency, reason unknown"}
		2 {return "At least one PG must be set for pulse count mode"}
		3 {return "Auto calib must be 0 or 1 in CM"}
		4 {return "Level must be 1, 2, 4, 8, or 16 in US42"}
		5 {return "Type parameter setup is wrong in *LRN? command"}
		6 {return "Format must be 1 to 5 in FMT"}
		7 {return "Mode must be 0, 1, or 2 in FMT"}
		8 {return "Wait time must be 0 to 99.9999 s in PA"}
		9 {return "Mode must be 1 or 2 in WS"}
		default {error "Bad 63x error code \"$code\""}
	    }}
	    4 {switch -- [string index $code 2] {
		0 {return "Mode must be 0 or 1 in STG"}
		1 {return "State must be 0 or 1 in STG"}
		2 {return "Polarity must be 0 or 1 in STG"}
		3 {return "Mode must be 0 or 1 in UNT?"}
		4 {return "4142ch must be 1 to 28 in ACH"}
		5 {return "chnum must be 1 to 6, or 21 to 28 in ACH"}
		6 {return "Averaging num must be -1023 to 1023 (not 0) in AV"}
		7 {return "Averaging mode must be 0 or 1 in AV"}
		8 {return "Post sweep condition must be 1 or 2 in WM"}
		9 {return "Abort condition setup is wrong in WM/MSC/STM"}
		default {error "Bad 64x error code \"$code\""}
	    }}
	    5 {switch -- [string index $code 2] {
		0 {return "Hold time must be 0 to 655.35 s in WT"}
		1 {return "Delay time must be 0 to 65.535 s in WT"}
		2 {return "Step delay time must be 0 to 1 s in WT"}
		3 {return "Number of data must be 0 to 20002 in RMD?"}
		4 {return "Category must be 1, 2, or 3 in SLI command"}
		5 {return "Mode must be 0 (off) or 1 (on) in AZ"}
		6 {return "For pulse mode, pulse para must be set in STP"}
		7 {return "Time or num of pulse must be set in STT"}
		8 {return "Base must be set when mode = 1 or 2 in SPG"}
		9 {return "Pulse para must be set when mode = 2 in SPG"}
		default {error "Bad 65x error code \"$code\""}
	    }}
	    6 {switch -- [string index $code 2] {
		0 {return "Unable to use Free run to use program memory"}
		1 {return "Improper stress time to use program memory"}
		2 {return "Hold time must be -0.03 to 655.35 s in MT"}
		3 {return "Interval must be 0.00006 to 65.534 s in MT"}
		4 {return "Sampling points must be 1 to 10001 in MT"}
		5 {return "Hold time must be >= 0 when init int >= 2 ms"}
		6 {return "Pulse para must be set for pulse mode in MP"}
		7 {return "Pulse count must be 0 to 65535 in MP"}
		8 {return "Unable to use TV/TI&TV?/TI? in same program"}
		9 {return "V force must be set for the chan set in GOC"}
		default {error "Bad 66x error code \"$code\""}
	    }}
	    7 {switch -- [string index $code 2] {
		0 {return "10 (0.2 V range) must be set for VMU in GOC"}
		1 {return "Offset data was out of range or GOC failed"}
		2 {return "VMU must be diff. mode when SOC is executed"}
		3 {return "Primary and secondary sweep must be same force mode"}
		4 {return "Slot number must be 0 to 9 in *TST? command"}
		5 {return "Slot number must be 0 to 8 in CA command"}
		6 {return "This mode is only for the system with PGU"}
		7 {return "WV/WI/QSV: Sweep step value too small"}
		8 {return "QSV: Use SMU for VAR1 channel"}
		9 {return "QSV: Sweep mode must be 1(single) or 2(double)"}
		default {error "Bad 67x error code \"$code\""}
	    }}
	    8 {switch -- [string index $code 2] {
		0 {return "QSV: Number of steps must be 1 to 1001"}
		1 {return "QSL: Data mode must be 0(off) or 1(on)"}
		2 {return "QSL: Compensation mode must be 0(off) or 1(on)"}
		3 {return "QSM: Improper stop condition was specified"}
		4 {return "Abort voltage must be 1(start) or 2(stop)"}
		5 {return "QST: Hold time must be 0 to 655.35s in 0.01s"}
		6 {return "QST: Delay1 must be 0 to 65.535s in 0.0001s"}
		7 {return "QST: Delay2 must be 0 to 65.535s in 0.0001s"}
		9 {return "QSR: Range must be -9,-10,-11, or -12"}
		default {error "Bad 68x error code \"$code\""}
	    }}
	    9 {switch -- [string index $code 2] {
		0 {return "Enter MM 13 and QSV before XE command"}
		1 {return "MM 13 allows only one measurement channel"}
		2 {return "TSC: Time stamp mode must be 0(off) or 1(on)"}
		3 {return "LSV/LSI: Improper start, stop, or step value"}
		4 {return "LSV/LSI: Step value must be + or - value, not 0"}
		5 {return "LSTM: Hold time must be 0 to 655.35s in 0.01s"}
		6 {return "LSTM: Delay must be 0 to 65.535s in 0.0001s"}
		7 {return "LSVM: Data mode must be 0(result) or 1(all)"}
		8 {return "LGV/LGI: Search mode must be 0(drop) or 1(rise)"}
		default {error "Bad 69x error code \"$code\""}
		9 {return "LGV/LGI: Improper range or target value"}
	    }}
	    default {
		error "Bad 6xx error code \"$code\""
	    }
	}}
	7 {switch -- [string index $code 1] {
	    0 {switch -- [string index $code 2] {
		0 {return "LSSV/LSSI: Polarity must be 0(-) or 1(+)"}
		1 {return "Enter MM 14 and LSV/LSI before XE command"}
		2 {return "Enter MM 14 and LGV/LGI before XE command"}
		3 {return "LSSV/LSSI: Offset value too large"}
		4 {return "Search target must be =< compliance setting"}
		5 {return "Set search source before synchronous source"}
		6 {return "V(or I)search unit must be I(or V)source mode"}
		7 {return "Sync source channel must be set to another unit"}
		8 {return "Synchronous source output setting too large"}
		9 {return "Do not specify channel number for MM 14 and 15"}
		default {error "Bad 70x error code \"$code\""}
	    }}
	    1 {switch -- [string index $code 2] {
		0 {return "BSV/BSI: Start and stop must be different"}
		1 {return "BST: Hold time must be 0 to 655.35s in 0.01s"}
		2 {return "BST: Delay must be 0 to 65.535s in 0.0001s"}
		3 {return "BGV/BGI: Mode must be 0(limit) or 1(repeat)"}
		4 {return "BGV/BGI: Improper search stop condition"}
		5 {return "BGV/BGI: Improper range, target, or limit value"}
		6 {return "BSSV/BSSI: Polarity must be 0(-) or 1(+)"}
		7 {return "BSSV/BSSI: Offset value too large"}
		8 {return "BSM: Mode must be 0(normal) or 1(cautious)"}
		9 {return "BSVM: Data mode must be 0(result) or 1(all)"}
		default {error "Bad 71x error code \"$code\""}
	    }}
	    2 {switch -- [string index $code 2] {
		0 {return "Enter MM 15 and BSV/BSI before XE command"}
		1 {return "Enter MM 15 and BGV/BGI before XE command"}
		2 {return "Invalid command for the US42 control mode"}
		3 {return "VMD: Parameter value must be 0, 1, or 2"}
		4 {return "ESC: Mode must be 0(off) or 1(on)"}
		5 {return "ESC: Condition1 must be 0,1,2,3, or 4"}
		6 {return "ESC: Value1 must be -10000 to 10000"}
		7 {return "ESC: Condition2 must be 0,1,2,3, or 4"}
		8 {return "ESC: Value2 must be -200 to 200"}
		9 {return "QSZ: Integration time too short for zero cancel"}
		default {error "Bad 72x error code \"$code\""}
	    }}
	    3 {switch -- [string index $code 2] {
		0 {return "QSZ: Offset value too large for zero cancel"}
		1 {return "Enter MM 13 before QSZ"}
		2 {return "Enter QSV before QSZ command"}
		4 {return "QSZ: Mode must be 0(off), 1(on) or 2(execution)"}
		5 {return "MM: Specify channel number of the V mode SMU"}
		default {error "Bad 73x error code \"$code\""}
	    }}
	    default {
		error "Bad 7xx error code \"$code\""
	    }
	}}
	default {
	    error "Bad xxx error code \"$code\" , should be -|5|6|7..."
	}
    }
}












#== High speed spot measurement ==

#TI TI?

proc ::a4156::flex::high_speed_spot {a ch} {
    
}





#TTI TTI? TTV TTV? TV TV?


set ALERTS(test_if_all_are_units) 0
proc ::a4156::private_flex::test_if_all_are_units {a list} {
    if {!$::ALERTS(test_if_all_are_units)} {
	puts stderr "TO BE CODED: ::a4156::private_flex::test_if_all_are_units"
    }
    set ::ALERTS(test_if_all_are_units) 1
}

set ALERTS(test_if_all_are_smus) 0
proc ::a4156::private_flex::test_if_all_are_smus {a list} {
    if {!$::ALERTS(test_if_all_are_units)} {
	puts stderr "TO BE CODED: ::a4156::private_flex::test_if_all_are_smus"
    }
    set ::ALERTS(test_if_all_are_smus) 1
}

set ALERTS(test_if_not_in_high_voltage) 0
proc ::a4156::private_flex::test_if_not_in_high_voltage {a list} {
    if {!$::ALERTS(test_if_not_in_high_voltage)} {
	puts stderr "TO BE CODED: ::a4156::private_flex::test_if_not_in_high_voltage"
    }
    set ::ALERTS(test_if_not_in_high_voltage) 1
}

set measurement_modes {

}



#== MM ==


proc ::a4156::flex::enable_time_stamp {a} {
    puts stderr "Warning, no time stamp if dt < 2ms"
    $a write "TSC 1"
}

proc ::a4156::flex::disable_time_stamp {a} {
    $a write "TSC 0"
}


proc ::a4156::flex::reset_time_stamp {a} {
    $a write "TSR"
}

proc ::a4156::flex::get_formatted_time_stamp {a} {
    $a write "TSQ?"
    set rep [$a read_phrase]
    return $rep
}


#=== Spot measurement "MM 1" "LRN? 1..6" ===

proc ::a4156::flex::choose_spot_measurement {a units} {
    $a write "MM 1,[join $units ,]"
}



#DI
#DV



# SMU1 SMU2 SMU3 SMU4
# range resolution max_compliance
# 2V    0.1mV      100mA
# 20V   1mV        100mA
# 40V   2mV        50mA
# 100V  5mV        20mA

# VSU1 VSU2
# range resolution
# 20V   1mV

# comp_polarity never used here

proc ::a4156::flex::smu_force_output_voltage {a unit range voltage compliance} {
    set chnum [::a4156::private_flex::chnum $unit]
    switch -- $range {
	"Auto" {set r 0}
	"2V"   {set r 11}
	"20V"  {set r 12}
	"40V"  {set r 13}
	"100V" {set r 14}
	"200V" {set r 15}
	default {error "Bad range \"$range\""}
    }
    set argums "$chnum,$r,$voltage"
    if {$compliance != {}} {
	append argums ",$compliance"
    }
    $a write "DV $argums"
}

proc ::a4156::flex::vsu_force_output_voltage {a unit voltage} {
    set chnum [::a4156::private_flex::chnum $unit]
    $a write "DV $chnum,12,$voltage"
}

proc ::a4156::flex::smu_force_output_current {a unit range current compliance} {
    set chnum [::a4156::private_flex::chnum $unit]
    switch -- $range {
	"Auto"  {set r 0}
	"10pA"  {set r 9}
	"100pA" {set r 10}
	"1nA"   {set r 11}
	"10nA"  {set r 12}
	"100nA" {set r 13}
	"1µA"   {set r 14}
	"10µA"  {set r 15}
	"100µA" {set r 16}
	"1mA"   {set r 17}
	"10mA"  {set r 18}
	"100mA" {set r 19}
	"1A"    {set r 20}
	default {error "Bad range \"$range\""}
    }
    set argums "$chnum,$r,$current"
    if {$compliance != {}} {
	append argums ",$compliance"
    }
    $a write "DI $argums"
}



#TDI
#TDV

#TSC

proc ::a4156::private_flex::chnum {unit} {
    switch -- $unit {
	"SMU1" {set chnum 1}
	"SMU2" {set chnum 2}
	"SMU3" {set chnum 3}
	"SMU4" {set chnum 4}
	"SMU5" {set chnum 5}
	"SMU6" {set chnum 6}
	"VMU1" {set chnum 23}
	"VMU2" {set chnum 24}
	"VSU1" {set chnum 23}
	"VSU2" {set chnum 24}
	"PGU1" {set chnum 27}
	"PGU2" {set chnum 28}
	default {error "Bad unit name \"$unit\""}
    }
    return $chnum
}

proc ::a4156::private_flex::unit_name {chnum} {
    switch -- $chnum {
	"1" {set chnum SMU1}
	"2" {set chnum SMU2}
	"3" {set chnum SMU3}
	"4" {set chnum SMU4}
	"5" {set chnum SMU5}
	"6" {set chnum SMU6}
	"23" {set chnum SMU23}
	"24" {set chnum SMU24}
	"27" {set chnum SMU27}
	"28" {set chnum SMU28}
	default {error "Bad unit name \"$unit\""}
    }
    return $chnum
}

#=== Staircase sweep measurement "MM 2" ===

#"LRN? 33"

#WM
#WT
#WI
#WV
#WSI
#WSV

#TSC


proc ::a4156::flex::get_number_of_sweep_steps {a} {
    $a write "WNU?"
    return [$a read_phrase]
}


#=== 1 ch pulsed spot measurement MM 3 ===

#"LRN? 34"

#PT
#PI
#PV
#PWI

#TSC

#=== Pulsed sweep measurement "MM 4" ===

#TSC

#"LRN? 34"

#PT
#PI
#PV
#PWI
#PWV

#"LRN? 33"

#WM
#WT
#WI
#WV
#WSI
#WSV


#=== Staircase sweep with pulsed bias measurement MM 5 ===

#TSC

#"LRN? 34"

#PT
#PI
#PV
#PWI
#3PWV

#"LRN? 33"

#WM
#WT
#WI
#WV
#WSI
#WSV


#=== Sampling measurement "MM 10" "LRN? 47" ===

proc ::a4156::flex::choose_sampling_measurement {a units} {
    $a write "MM 10,[join $units ,]"
}


#TSC

#MSC
#MT
#MV
#MI
#MP

#MCC ;# clears MV, MI or MP

#=== Stress force "MM 11" "LRN? 48" ===

#STM
#STT
#STI
#STV
#STP

#POR ;# sets the PGU output impedance
#STC ;# clears settings

#=== Quasi-static CV mesurement "MM 13" "LRN? 49" ===

#QSM
#QSL
#QST
#QSR
#QSV

# ??? QSI
#QSZ ;# execute

#QSZ?

#=== Linear search measurement "MM 14" "LRN? 50" ===

#LSTM
#LSVM
#WM
#LGV
#LGI
#LSV
#LSI
#LSSV
#LSSI

#=== Binary search mesurement "MM 15" "LRN? 51" ===

#BSM
#BST
#BSVM
#BGV
#BGI
#BSV
#BSI
#BSSV
#BSSI


#== Programmation ==

set COMMANDES(Programmation) {

    ST $p1   ;#   p1 == 1..255
    END
    
    
    DO $p1
    DO $p1,$p2,$p3,$p4,$p5,$p6,$p7,$p8   ;#   max 8 programmes
    RU $p1,$pend   ;#   $p1,...,$pend en séquence
    
    SCR $p1
    SCR   ;#   scratch all programs
    
    LST?
}

proc a4156::flex::get_programs_catalog {a} {
    $a write "LST?"
    set rep [$a read_phrase]
    set l [split $rep ,]
    set n [lindex $l 0]
    set ret [lrange $l 1 end]
    if {[llength $ret] != $n} {
	error "Bad \"LST?\" response: \"$rep\""
    } else {
	return $ret
    }
}

proc a4156::flex::get_program_list {a p} {
    if {$p < 1 || $p > 255} {
	error "Bad argument, program number out of range"
    }
    $a write "LST? $p"
    set again true
    set ret [list]
    while {$again} {
	set rep [$a read_phrase]
	if {[string compare $rep "END"] == 0} {
	    set again false
	} else {
	    lappend ret $rep
	}
    }
    if {[string compare [lindex $ret 0] "ST $p"] != 0} {
	error "Program list is beginning by \"[lindex $ret 0]\" instead of \"ST $p\""
    }
    return $ret
} 

proc a4156::flex::pause_program {a microsec} {
    if {$microsec == ""} {
	$a write "PA"
    } else {
        $a write "PA [format %.4f [expr {$microsec*1e-6}]]"
    }
}



#== Non programmables ==


set not_programmable {
AB ACH
CA CLOSE CM *CAL? *CLS?
DO END ERR? *ESE?  *IDN?
LOP? LST? *LRN? NUB? *OPC *OPC? OPEN 
*OPT? PRN RCV RD? RMD? *RST RU 
SCR SDSK SPL SPR ST *SRE? *STB? :SYST:ERR?
*TST? UNT? US US42
WNU? WR *WAI
}

#=== Langage  ===

#US    ;#   mode FLEX
#US42

proc ::a4156::flex::get_language {a} {
    $a write "CMD?"
    set rep [$a read_phrase]
    switch -- $rep {
	"+0" {return "SCPI"}
	"+1" {return "FLEX"}
	"+2" {return "4145"}
	default {error "Bad response to \"CMD?\": \"$rep\""}
    }
}



#=== fichiers ===

#SDSK 0   ;# ou 1 2 3 4

#==== lecture ====

#OPEN $fichier,0   ;#   mode read
#RD?
#CLOSE

#==== écriture ====

#OPEN $fichier,1   ;#   mode write, ou 2 = mode write/append (not for SDSK 0)
#WR $data
#CLOSE

#==== impression ====

#SPR 1   ;#   ou  2,3,4
#SPL $blabla
#PRN


#=== self-test ===

#RCV *TST?


#=== imprévus  ===

# clears status byte register, standard event register, error register, but does not clear the enable registers 
proc a4156::flex::clear_registers {a} {
    $a write "*CLS"
}


#==== Status Byte Register *CLS *STB? *SRE ====

proc ::a4156::flex::set_status_byte_register_mask {a mask} {
    $a write "*SRE $mask"
}

proc ::a4156::flex::get_status_byte_register_mask {a} {
    $a write "*SRE?"
    return [$a read_phrase]
}

# idem spoll, but doesn't clear SRQ
proc ::a4156::flex::get_status_byte_register {a} {
    $a write "*STB?"
    return [$a read_phrase]
}



#==== Standard Event Status Register ====

proc ::a4156::flex::set_event_status_register_mask {a mask} {
    $a write "*ESE $mask"
}

proc ::a4156::flex::get_event_status_register_mask {a} {
    $a write "*ESE?"
    return [$a read_phrase]
}

proc ::a4156::flex::get_event_status_register {a} {
    $a write "*ESR?"
    return [$a read_phrase]
# 1:OPC, 8:Error, 16:Parameter_Error, 32:Syntax_Error
}



#*OPC *WAI
# Pour certains appareils, une seconde commande peut être mise en route alors
# que la première commande (appelée overlapping command) n'est pas complètement achevée.
# Pour bloquer la seconde commande et les suivantes tant que la première commande n'est pas
# achevée, appeler *WAI avant la seconde commande.

proc a4156::flex::wait_opc_before_continuing {a} {
    $a write "*WAI"
}

# depends on read timeout
proc a4156::flex::wait_operation_complete {a} {
    $a write "*OPC?"
    set r [$a read_phrase]
    if {$r != 1} {
	error "*OPC? returns \"$r\" instead of \"1\""  
    }
}

proc a4156::flex::abort {a} {
    $a write "AB"
}





# clears error register queue
proc ::a4156::flex::get_errors {a} {
    $a write "ERR?"
    set rep [$a read_phrase]
    set r [split $rep ,]
    if {[llength $r] != 7} {
	error "Bad \"ERR?\" response \"$rep\""
    }
    set errlist [list]
    set i 0
    set inone -1
    foreach code $r {
	set err [::a4156::private_flex::error_message $code]
	lappend errlist $err
	if {$err != "None"} {
	    set inone $i 
	}
	incr i
    }
    return [lrange $errlist 0 $inone] 
}

# drops one error register stack element
proc a4156::flex::get_error_register_and_message {a} {
    $a write ":SYST:ERR?"
    return [split [$a read_phrase] ,]    
}

proc a4156::flex::clear_output_data_buffer {a} {
    $a write "BC"
}








#=== calibrage ===

#CA
#CA $slot
#*CAL?
#CM

#*CLS?
#*IDN?
#LOP? LST? *LRN? NUB? *OPC *OPC? 
#*OPT? RCV RMD? *RST 
#*TST? UNT?
#WNU? *WAI


#=== Général ===

proc ::a4156::read_phrase {a} {
    set rep [$a read]
    if {[string index $rep end] != "\n"} {
	error "Unterminated string \"$rep\""
    } else {
	return [string range $rep 0 end-1]
    }
}


proc ::a4156::private_flex::interpret_multiple_status {cmd rep} {
    set r [split $rep \;]
    if {[llength $r] == 1} {
	if {[string compare $rep "$cmd 0"] == 0} {
	    return "All Off"
	} elseif {[string compare $rep "$cmd 1"] == 0} {
	    return "All On"
	} else {
	    error "Bad response \"$rep\" (should be \"$cmd 0|1\")"
	}
    } elseif {[llength $r] != 2} {
	error "Bad response \"$rep\" (more than 2 \";\""
    } else {
	set r1 [lindex $r 0]
	set r2 [lindex $r 1]
	if {![string match "$cmd 0,*" $r1] || ![string match "$cmd 1,*" $r2]} {
	    error "Bad response \"$rep\" (should be \"$cmd 0,...;$cmd 1,...\")"
	} else {
	    return [list Off [split [string range $r1 5 end] ,] On [split [string range $r2 5 end] ,]]
	}
    }
}



#=== Informations ===

proc ::a4156::flex::get_instrument_revision {a} {
    $a write "*IDN?"
    set rep [$a read_phrase]
    set r [split $rep ,]
    set rr [split [lindex $r 3] :]
    if {[llength $r] != 4 || [llength $rr] != 3} {
	error "Bad get_instrument_revision response: \"$rep\""
    }
    return [list Maker [lindex $r 0] Model [lindex $r 1] _zero_ [lindex $r 2] Host_rev [lindex $rr 0] Smuc_rev [lindex $rr 1] Ad_rev [lindex $rr 2]] 
}

proc ::a4156::private_flex::lop_signification {slot byte} {
    switch -- $slot {
	0 {set type GNDU; set number {}}
	1 {set type SMU; set number 1}
	2 {set type SMU; set number 2}
	3 {set type SMU; set number 3}
	4 {set type SMU; set number 4}
	5 {set type SMU; set number 5}
	6 {set type SMU; set number 6}
	7 {set type VSU; set number {}}
	8 {set type PGU; set number {}}
	default {error "Bad slot \"$slot\""}
    }
    set rep0 "$type$number"
    set rep [list]
    if {$byte & 128} {
	lappend rep "Installed and On"
    } else {
	lappend rep "Off or not installed"
    }
    set bic [expr {($byte & 6)>>1}]
    switch -- $type {
	SMU {
	    if {$byte & 8} {
		lappend rep "Current source mode"
	    } else {
		lappend rep "Voltage source mode"
	    }
	    if {$bic == 0} {
		lappend rep "Voltage compliance"
	    } elseif {$bic == 1} {
		lappend rep "Negative current compliance"
	    } elseif {$bic == 2} {
		lappend rep "Positive current compliance"
	    } else {
		lappend rep "No compliance"
	    }
	    if {$byte & 1} {
		lappend rep "Oscillating"
	    } else {
		lappend rep "Not oscillating"
	    }
	}
	VSU {
	    if {$byte & 64} {
		lappend rep "VSU2 is installed and On"
	    } else {
		lappend rep "VSU2 is Off or not installed"
	    }
	    if {$bic == 0} {
		lappend rep "Current limit not reached"
	    } elseif {$bic == 1} {
		lappend rep "VSU2 reaches current limit"
	    } elseif {$bic == 2} {
		lappend rep "VSU1 reaches current limit"
	    } else {
		lappend rep "Both VSU1 and VSU2 reach current limit"
	    }
	}
	PGU {
	    if {$byte & 64} {
		lappend rep "PGU2 is installed and On"
	    } else {
		lappend rep "PGU2 is Off or not installed"
	    }
	    if {$bic == 0} {
		lappend rep "Current limit not reached"
	    } elseif {$bic == 1} {
		lappend rep "PGU2 reaches current limit"
	    } elseif {$bic == 2} {
		lappend rep "PGU1 reaches current limit"
	    } else {
		lappend rep "Both PGU1 and PGU2 reach current limit"
	    }
	}
	VMU {
	    if {$byte & 32} {
		lappend rep "VMU1 is installed and On"
	    } else {
		lappend rep "VMU1 is Off or not installed"
	    }
	    if {$byte & 16} {
		lappend rep "VMU2 is installed and On"
	    } else {
		lappend rep "VMU2 is Off or not installed"
	    }
	}
    }
    return [list $rep0 $rep]
}

proc ::a4156::flex::get_sources_operation_status {a} {
    $a write "LOP?"
    set rep [$a read_phrase]
    set bytes [split $rep ,]
    if {[llength $bytes] != 9} {
	error "Bad \"LOP?\" response: \"$rep\""
    }
    set ret [list]
    for {set slot 0} {$slot <= 8} {incr slot} {
	set byte [lindex $bytes $slot]
	set rep [::a4156::private_flex::lop_signification $slot $byte]
	lappend ret [lindex $rep 0] [lindex $rep 1]
    }
    return $ret
}
    

proc ::a4156::flex::get_device_options {a} {
    $a write "*OPT?"
    set rep [$a read_phrase]
    set o [split $rep ,]
    if {[llength $o] != 5} {
	error "Bad return for \"*OPT?\": \"$rep\""
    }
    return $o
}

proc ::a4156::flex::get_model_and_revisions_of_units {a} {
    $a write "UNT?"
    set rep [$a read_phrase]
    set r [split $rep \;]
    return $r
}


set programmable_not_mm {
AZ BC BGI BGV BSI BSM BSSI BSSV BST BSV BSVM CL CMD? CMM CN
DZ ESC *ESE *ESR? FL FMT GOC IN
MM OS
PA QST QSZ?
RBC RCV RD? RI RV RZ
SIT SLI SOC SPG SPP *SRE SRP SSP STG  
TI TI? TM TSC TSQ? TSR TTI TTI? TTV TTV? TV TV?
VMD WS XE
}


#== PGU ==

#SPG
#SPP
#SRP
#DV


#== VMU ==

#VMD

#== Output On-Off "LRN? 0" ==


# SMU off state : source_mode = V, output_voltage = 0, V range = 20V, I compliance = 100µA, I range = 100 µA, Filter = On

proc ::a4156::flex::list_active_outputs {a} {
    $a write "LRN? 0"
    set response [$a read_phrase]
    switch -- [string range $response 0 1] {
	CL {return {}}
	CN {return [split [string range $response 3 end] ,]}
	error "Bad response \"$response\""
    }
}

proc ::a4156::flex::set_all_outputs_off {a} {
    $a write "CL"
}

proc ::a4156::flex::set_output_off {a list} {
    if {$list == {}} {
	error "Void list not permitted. Please call flex::set_all_outputs_off instead." 
    }
    ::a4156::private_flex::test_if_all_are_units $a $list
    ::a4156::private_flex::test_if_not_in_high_voltage $a $list
    $a write "CL [join $list ,]"
}

proc ::a4156::flex::set_all_outputs_on {a} {
    $a write "CN"
}

proc ::a4156::flex::set_output_on {a list} {
    if {$list == {}} {
	error "Void list not permitted. Please call flex::set_all_outputs_on instead." 
    }
    ::a4156::private_flex::test_if_all_are_units $a $list
    ::a4156::private_flex::test_if_not_in_high_voltage $a $list
    $a write "CN [join $list ,]"
}

proc ::a4156::flex::set_output_temporary_to_zero {a list} {
    $a write "DZ [join $list ,]"
}

proc ::a4156::flex::set_output_to_saved_state {a list} {
    # The "DZ" saved state is cleared by US, CL, CA, *TST? *RST or Device_Clear
    $a write "RZ [join $list ,]"
}

proc ::a4156::flex::set_output_to_zero {a list} {
    # difference avec DZ ?
    $a write "IN [join $list ,]"
}


#== "LRN? 1..6 21..28" ==

proc ::a4156::flex::read_lrn {a argum} {
    set rep [$a read_phrase]
    if {![string match "$argum *" $rep]} {
	error "Bad response \"$rep\", should be \"$argum ...\""
    }
    return [string range [string length $argum] end $rep]
    UNVERIFIED
}


#== Filter On/Off "LRN? 30" ==

proc ::a4156::flex::get_smu_filter_status {a} {
    $a write "LRN? 30"
    set rep [$a read_phrase]
    return [::a4156::private_flex::interpret_multiple_status FL $rep]
}

proc ::a4156::flex::set_smu_filter_off {a smulist} {
    if {$smulist == {}} {
	error "Void list not permitted. Please call flex::set_all_smu_filters_off instead." 
    }
    ::a4156::private_flex::test_if_all_are_smus $a $smulist
    $a write "FL 0,[join $smulist ,]"
}

proc ::a4156::flex::set_smu_filter_on {a smulist} {
    if {$smulist == {}} {
	error "Void list not permitted. Please call flex::set_all_smu_filters_on instead." 
    }
    ::a4156::private_flex::test_if_all_are_smus $a $smulist
    $a write "FL 1,[join $smulist ,]"
}

proc ::a4156::flex::set_all_smu_filters_off {a} {
    $a write "FL 0"
}

proc ::a4156::flex::set_all_smu_filters_on {a} {
    $a write "FL 1"
}

puts "LOUCHE, il faut appeler deux fois ::a4156::flex::get_smu_filter_status
avant d'avoir la bonne réponse !
Normal, on lit la réponse à deux questions auparavant
"


#== Trigger-mode, Averaging, Auto-calibration, Data output format, Measurement mode "LRN? 31" ==

proc ::a4156::flex::get_trigger_mode {a} {
    $a write "LRN? 31"
    set repg [$a read_phrase]
    set rep [lindex [split $repg \;] 0]
    if {![string match "TM *" $rep]} {
	error "Bad LRN? 31 response: \"$rep\""
    }
    return [string index $rep 3]
}

proc ::a4156::flex::set_trigger_mode {a mode} {
    $a write "TM $mode" 
}

proc ::a4156::flex::get_averaging_number {a} {
    $a write "LRN? 31"
    set repg [$a read_phrase]
    set rep [lindex [split $repg \;] 1]
    if {![string match "AV *" $rep]} {
	error "Bad LRN? 31 response: \"$rep\""
    }
    return [lindex [split [string range $rep 3 end] ,] 0]
}

proc ::a4156::flex::set_averaging_number {a number} {
    if {$number < 1 || $number > 1023} {
	error "Bad averaging number \"$number\", should be 1..1023"
    }
    $a write "AV $number" 
}


#CM
#FMT
#MM


#== Measurement ranging "LRN? 32" ==

proc ::a4156::flex::get_measurement_ranges {a} {
    $a write "LRN? 32"
    set rep [$a read_phrase]
    set r [split $rep \;]
    return $r
}

proc ::a4156::private_flex::range_of_index {i} {
    switch -- $i {
	 0 {return Auto}
	 9 {return Auto_10pA}
	10 {return Auto_100pA}
	11 {return Auto_1nA}
	12 {return Auto_10nA}
	13 {return Auto_100nA}
	14 {return Auto_1µA}
	15 {return Auto_10µA}
	16 {return Auto_100µA}
	17 {return Auto_1mA}
	18 {return Auto_10mA}
	19 {return Auto_100mA}
	20 {return Auto_1A}
	 -9 {return Fixed_10pA}
	-10 {return Fixed_100pA}
	-11 {return Fixed_1nA}
	-12 {return Fixed_10nA}
	-13 {return Fixed_100nA}
	-14 {return Fixed_1µA}
	-15 {return Fixed_10µA}
	-16 {return Fixed_100µA}
	-17 {return Fixed_1mA}
	-18 {return Fixed_10mA}
	-19 {return Fixed_100mA}
	-20 {return Fixed_1A}
    }

}


#RI
#RV




#== Trigger mode status "LRN? 39" ==

proc ::a4156::flex::set_trig_function {a mode state polarity} {
    switch -- $mode {
	"input" {set m 0}
	"output" {set m 1}
	default {error "Bad mode \"$mode\""}
    }
    switch -- $state {
	"disable" {set s 0}
	"enable" {set s 1}
	default {error "Bad state \"$state\""}
    }
    switch -- $polarity {
	"+" {set p 0}
	"-" {set p 1}
	default {error "Bad polarity \"$polarity\""}
    }
    $a write "STG $m,$s,$p"
}


proc ::a4156::flex::send_a_trigger_output_signal {a} {
    $a write "OS"
}

proc ::a4156::flex::start_measurement {a} {
    $a write "XE"
}

proc ::a4156::flex::goto_wait_state {a} {
       $a write "WS 1"
} 

proc ::a4156::flex::goto_wait_state_immediatly {a} {
    $a write "WS 2"
} 

#== Zero offset cancel "LRN? 42" ==


# Warning, SMU should be in current measurement mode
#          VMU should be in differential voltage measurement mode

proc ::a4156::flex::get_zero_offset_status {a} {
    $a write "LRN? 42"
    set rep [$a read_phrase]
    set r [split $rep \;]
    set rlist [list]
    foreach rr $r {
	if {![string match "SOC *" $rr]} {
	    error "Bad \"LRN? 42\" response: \"$rep\" (\"$rr\" doesn't match \"SOC *\" )"
	} else {
	    set rrr [split [string range $rr 4 end] ,]
	    if {[llength $rrr] == 1} {
		if {$rrr == 0} {
		    return "All Off"
		} elseif {$rrr == 1} {
		    return "All On"
		} else {
		    error "Bad \"LRN? 42\" response: \"$rep\ (rrr == \"$rrr\")"
		}
	    } elseif {[llength $rrr] != 2} {
		error "Bad \"LRN? 42\" response: \"$rep\ (rrr == \"$rrr\")"
	    }
	    switch -- [lindex $rrr 0] {
		1 {set unit SMU1}
		2 {set unit SMU2}
		3 {set unit SMU3}
		4 {set unit SMU4}
		5 {set unit SMU5}
		6 {set unit SMU6}
		23 {set unit VMU1-VMU2}
		default {error "Bad \"LRN? 42\" response: \"$rep\" (bad chnum \"[lindex $rrr 0]\")"}
	    }
	    switch -- [lindex $rrr 1] {
		0 {set status OFF}
		1 {set status ON}
		default {error "Bad \"LRN? 42\" response: \"$rep\" (bad status \"[lindex $rrr 1]\")"}
	    }
	}
	lappend rlist $unit $status
    }
    return $rlist
}

# Smu should be in voltage force (DV)

proc ::a4156::flex::measure_and_cancel_current_zero_offset {a smu range} {
    switch -- $range {
	"10pA" {set range 9}
	"100pA" {set range 10}
	"1nA" {set range 11}
	default {error "Bad range \"$range\""}
    }
    $a write "GOC [::a4156::private_flex::chnum $smu],$range"
}

proc ::a4156::flex::measure_and_cancel_voltage_zero_offset {a vmu range} {
    switch -- $range {
	"200mV" {set range 10}
	default {error "Bad range \"$range\""}
    }
    $a write "GOC [::a4156::private_flex::chnum $vmu],$range"
}

proc ::a4156::flex::enable_current_zero_offset {a smu} {
    $a write "SOC [::a4156::private_flex::chnum $smu],1"
}

proc ::a4156::flex::disable_current_zero_offset {a smu} {
    $a write "SOC [::a4156::private_flex::chnum $smu],0"
}

proc ::a4156::flex::enable_voltage_zero_offset {a vmu} {
    $a write "SOC [::a4156::private_flex::chnum $vmu],1"
}

proc ::a4156::flex::disable_voltage_zero_offset {a vmu} {
    $a write "SOC [::a4156::private_flex::chnum $vmu],0"
}






#== Integration time settings "LRN? 43" ==

proc ::a4156::flex::get_integration_time {a} {
    $a write "LRN? 43"
    set rep [$a read_phrase]
    set r [split $rep \;]
    if {[llength $r] != 4 \
	    || [string range [lindex $r 0] 0 3] != "SLI " \
	    || [string range [lindex $r 1] 0 5] != "SIT 1," \
	    || [string range [lindex $r 2] 0 5] != "SIT 3," \
	    || [string range [lindex $r 3] 0 2] != "AZ "} {
	error "Bad \"LRN? 43\" response \"$rep\""
    }
    set sli [string range [lindex $r 0] 4 end]
    set short [string range [lindex $r 1] 6 end]
    set long [string range [lindex $r 2] 6 end]
    set az [string range [lindex $r 3] 3 end]
    switch -- $sli {
	1 {set slic Short}
	2 {set slic Period}
	3 {set slic Long}
	default {error "Bad SLI \"$sli\""}
    }
    switch -- $az {
	0 {set azc Off}
	1 {set azc On}
	default {error "Bad AZ \"$az\""}	
    }
    return [list Integration_Time $slic Short_Time $short Long_Time $long Auto_Zero $azc]
}

# 80 µs ... 10.16 ms
proc ::a4156::flex::set_short_integration_time_value {a v} {
    if {$v < 80e-6 || $v > 10.16e-3} {
	error "Out of range short integration time value \"$v\", should be 80e-6..10.16e-3"
    }
    $a write "SIT 1,$v"
}
# 16.7 ms ... 2 s
proc ::a4156::flex::set_long_integration_time_value {a v} {
    if {$v < 20e-3 || $v > 2} {
	error "Out of range long integration time value \"$v\", should be 20e-3(with 50Hz mains)..2"
    }
    $a write "SIT 3,$v"
}

proc ::a4156::flex::set_integration_time_type {a type} {
    switch -- $type {
	Short {set t 1}
	Period {set t 2}
	Long {set t 3}
	default {error "Bad type \"$type\", should be Short, Period or Long"}
    }
    $a write "SLI $t"
}

proc ::a4156::flex::auto_zero_enable {a} {
    $a write "AZ 1"
}

proc ::a4156::flex::auto_zero_disable {a} {
    $a write "AZ 0"
}

#== Resistor box settings "LRN? 44" ==

#RBC

#== Smu/Pgu selector settings "LRN? 45" ==

#SSP

#== Smu measurement mode "LRN? 46" ==

array set ::a4156::flex::CMM {0 Compliance_side 1 Current 2 Voltage 3 Source_side}

proc ::a4156::flex::get_smu_measurement_mode {a} {
    $a write "LRN? 46"
    set rep [$a read_phrase]
    if {![regexp {^CMM 1,([0-3]);CMM 2,([0-3]);CMM 3,([0-3]);CMM 4,([0-3])$} $rep tout s1 s2 s3 s4]} {
	return "Bad response for \"LRN? 46\": \"$rep\""
    }
    return [list \
		SMU1 $::a4156::flex::CMM($s1) \
		SMU2 $::a4156::flex::CMM($s2) \
		SMU3 $::a4156::flex::CMM($s3) \
		SMU4 $::a4156::flex::CMM($s4)]   
}

proc ::a4156::flex::set_smu_measurement_mode {a smu mode} {
    set chnum [::a4156::private_flex::chnum $smu]
    switch -- $mode {
	Compliance_side {$a write "CMM $chnum,0"} 
	Current {$a write "CMM $chnum,1"} 
	Voltage {$a write "CMM $chnum,2"} 
	Source_side {$a write "CMM $chnum,0"}
	default {error "Mode should be Compliance_side|Current|Voltage|Source_side"}
    }
}




#== Sweep stop condition settings "LRN? 52" ==

#ESC

#== Measurements NUB? RMD?  ==

proc ::a4156::flex::get_number_of_measurements_in_buffer {a} {
    $a write "NUB?"
    return [$a read_phrase]
}

proc ::a4156::flex::read_measurements {a count} {
    if {$count == "All"} {
	$a write "RMD?"

    } else {
	$a write "RMD? $count"
    }
    return [$a read]
}

#== Reset *RST ==

proc ::a4156::flex::reset {a} {
    $a write "*RST"
}

set reset_result {

    flex::set_all_outputs_on                          flex::list_active_outputs

    flex::set_smu_filter_on                           flex::get_smu_filter_status

    flex::set_smu_measurement_mode 1 Compliance_side  flex::get_smu_measurement_mode
    flex::set_smu_measurement_mode 2 Compliance_side  flex::get_smu_measurement_mode
    flex::set_smu_measurement_mode 3 Compliance_side  flex::get_smu_measurement_mode
    flex::set_smu_measurement_mode 4 Compliance_side  flex::get_smu_measurement_mode
    
    SMU range

    VMU mode

    VMU range

    Source parameters

    Hold time, Delay time

    Pulse width, Period

    Auto calibration On

    Auto Abort OFF

    Program memory not cleared

    Trigger XE TV TI GET

    Ouput Data Format ASCII with Header

    Terminator LF^EOI

    Output data buffer cleared

    Error Register cleared

    Status Byte bit 6 enabled

}


#Martyrs programmables

    #1 .. 6  
    # 21..28
#        99 get_language
proc ditou {} {
    foreach {n c} {
	99 get_language
	0  list_active_outputs
	30 get_smu_filter_status
        31 get_trigger_mode
        31 get_averaging_number
	32 get_measurement_ranges
	42 get_zero_offset_status
	43 get_integration_time
	46 get_smu_measurement_mode
    } {
	puts -nonewline stderr [format "%2d %-30s " $n $c]
	puts stderr [a4156 flex::$c]
    }
}


# Cf. Programming Manual ch.3 #

# High-Speed Spot Measurements p. 3-6#

proc example_high_speed_spot_measurement {} {

    # a4156 DCL
    
    # a4156 flex::list_active_outputs
    # a4156 flex::set_all_outputs_on
    # a4156 flex::set_all_outputs_off
    # a4156 flex::set_output_on  [list_of 1 2 3 4]
    # a4156 flex::set_output_off [list_of 1 2 3 4]
    
    # a4156 flex::get_smu_filter_status
    # a4156 flex::set_smu_filter_off [list_of 1 2 3 4]
    # a4156 flex::set_smu_filter_on  [list_of 1 2 3 4]
    # a4156 flex::set_all_smu_filters_off
    # a4156 flex::set_all_smu_filters_on
    
    # a4156 flex::set_averaging_number [integer_interval 1 1023]
    # a4156 flex::get_averaging_number
    
    # a4156 flex::get_integration_time
    # a4156 flex::set_short_integration_time_value [float_interval 80e-6 10.16e-3]
    # a4156 flex::set_long_integration_time_value  [float_interval 50e-3 2]
    # a4156 flex::set_integration_time_type [one_of Short Period Long]
    
    # flex::smu_force_output_voltage [one_of SMU1 SMU2 SMU3 SMU4] [one_of Auto 2V 20V 40V 100V 200V] $voltage [one_of {} $compliance]
    # flex::smu_force_output_current [one_of SMU1 SMU2 SMU3 SMU4] [one_of Auto 10pA ...100mA] $current [one_of {} $compliance]
    
    
    
    
    
    # a4156 flex::auto_zero_enable
    # a4156 flex::auto_zero_disable
    
    # a4156 flex::set_trigger_mode [one_of SMU1 SMU2 SMU3 SMU4]
    # a4156 flex::get_trigger_mode
    
    
    a4156 DCL
    a4156 write US
    a4156 write "FMT 1"
    a4156 flex::set_averaging_number 1
    a4156 flex::set_short_integration_time_value .0005
    a4156 flex::set_long_integration_time_value .04
    a4156 flex::set_integration_time_type Short
    a4156 flex::set_all_smu_filters_off
    a4156 flex::set_output_on {1 2 3 4}
    a4156 flex::smu_force_output_voltage 1 2V 0 0.01
    a4156 flex::smu_force_output_voltage 2 2V 0 0.01
    a4156 flex::smu_force_output_voltage 3 2V 0 0.01
    a4156 flex::smu_force_output_voltage 4 2V 0 0.01
    a4156 flex::wait_operation_complete
    set err [a4156 flex::get_error_register_and_message]
    puts $err
    if {[lindex $err 0] == 0} {
	set l [list]
	for {set i 0} {$i < 100} {incr i} {a4156 write "TI? 2,15"; lappend l [a4156 read_phrase]}
    } else {
	puts "ERROR : [lindex $err 1]"
    }
    a4156 flex::set_all_outputs_off
    set l [list]
    for {set i 0} {$i < 100} {incr i} {a4156 write "TI 2,15"}
    
}

# Cf. 3-9
proc example_spot_measurement {} {
    a4156 DCL
    a4156 write US ;#  attention,  a4 write "US" ; détruit *SRE, *ESE, etc.
    a4156 write "FMT 1"
    a4156 flex::set_averaging_number 1
    a4156 flex::set_short_integration_time_value .0005
    a4156 flex::set_long_integration_time_value .04
    a4156 flex::set_integration_time_type Period
    a4156 flex::set_all_smu_filters_off
    a4156 flex::set_output_on {1 2 3 4}
    a4156 flex::smu_force_output_voltage SMU1 2V 0 0.01
    a4156 flex::smu_force_output_voltage SMU2 2V 0 0.01
    a4156 flex::smu_force_output_voltage SMU3 2V 0 0.01
    a4156 flex::smu_force_output_voltage SMU4 2V 0 0.01
    a4156 flex::choose_spot_measurement {1 2}
    a4156 flex::set_smu_measurement_mode SMU1 Current
    a4156 flex::set_smu_measurement_mode SMU2 Current
    a4156 flex::enable_time_stamp
    a4156 flex::get_error_register_and_message
    a4156 flex::start_measurement
    a4156 flex::get_error_register_and_message
    a4156 flex::set_all_outputs_off
    a4156 flex::get_number_of_measurements_in_buffer
    a4156 flex::read_measurements All
}



proc shift_index {l i s} {
    return [lindex $l [expr {$i + $s}]]
}

proc extract_current {s index smu} {
    set type [expr {[lindex $s $index] >> 7}]
    set datatype [expr {([shift_index $s $index 0] >> 4) & 7}]
    set range [expr {([shift_index $s $index 0] & 7)*2 + ([shift_index $s $index 1]] >> 7)}]
    set data [expr {(((
		       [lindex $s [expr {$index+1}]] & 127
		       )*256. + [lindex $s [expr {$index + 2}]]
		      )*256. + [lindex $s [expr {$index + 3}]]
		     )*8. + ([lindex $s [expr {$index + 4}]] >> 5)
		}]
    set status 
}

proc extract_time {s index smu} {
    if {(([lindex $s $index] >> 4) & 7) != 3} {
	error "Bad s $index, to time"
    }
    if {([lindex $s [expr {$index + 5}]] & 15) != $smu} {
	error "Bad s $index, no smu$smu"
    }
    return [expr {((((((
			[lindex $s $index] & 15
			)*256. + [lindex $s [expr {$index + 1}]]
		       )*256. + [lindex $s [expr {$index + 2}]]
		      )*256. + [lindex $s [expr {$index + 3}]]
		     )*256. + [lindex $s [expr {$index + 4}]]
		    )*8. + ([lindex $s [expr {$index + 5}]] >> 5))*1e-4}]
}


proc extract_bin s {
    if {[lindex $s 24] != 10} {
	error "Bad s, no 10 at the end"
    }
    return [format "%10.4f %10.4f" [extract_time $s 0 1] [extract_time $s 12 2]]
}



