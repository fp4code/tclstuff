# DSP lock-in amplifier EGG 7260
# (C) CNRS-LPN FP 2002.06.27

# RCS: @(#) $Id: egg7260.1.0.tcl,v 1.7 2003/05/05 08:02:51 fab Exp $

package provide egg7260 1.0

namespace eval egg7260 {
    variable STARMODE
    array set STARMODE {0 X 1 Y 2 MAG 3 PHA 4 ADC1 5 XY 6 MP 7 ADC1,ADC2}
    array set STARMODEINDEX {X 0 Y 1 MAG 2 PHA 3 ADC1 4 XY 5 MP 6 ADC1,ADC2 7}
}

set HELP(egg7260) {
    set Signal_Channel_Setup {
	ACGAIN[n]
	AUTOMATIC[c]
	CP[n]
	FET[n]
	FLOAT[n]
	IMODE[n]
	LF[n]
	VMODE[n]
    }
    set Reference {
	AQN
	FRQ[.]
	IE[n]
	LOCK
	RANGE[n]
	REFMODE[n]
	REFN[n]
	REFP[.][n]
	VRLOCK[n]
    }
    set Output_Channel {
	AQN
	AXO
	EX[n]
	SAMPLE[n]
	SEN[n]
	SEN[.]
	SLOPE[n]
	SYNC[n]
	TC[n]
	TC[.]
	XOF[n1 [n2]]
	YOF[n1 [n2]]
    }
    set Rear_Panel_Connectors {
	CH n1 [n2]
	DAC[.][n]
	ADC[.]n
	BYTE[n]
    }
    set Outputs {
	ADC[.][n]
	ENBW[.]
	EQUn
	FRQ[.]
	LR[.]
	MAG[.]
	MP[.]
	NHZ.
	NN[.] getNoise
	PHA[.]
	RT[.]
	X[.] getX
	XY[.]
	Y[.]
    }
    set Oscillator {
	OA[.]
	OF[.]
	ASTART[n]
	ASTEP[.][n]
	ASTOP[.][n]
	FSTART[.][n]
	FSTEP[.][n1 n2]
	FSTOP[.][n]
	SWEEP[n]
	SRATE[.][n]
	SYNCOSC[n]
    }
    set AUTO_Functions {
	AQN
	AS
	ASM
	AUTOMATIC
	AXO
    }
    set Curve_Bufer {
	CBD[n]
	DCI[.]n
	EVENT[n]
	HC
	LEN[n]
	M
	NC
	STR[n]
	TD
	TDC
    }
    set ADCs {
	ADC[.]n
	ADC3TIME[n]
	BURSTRATE[n]
	TADC[n]
	DC[.]5
	DC[.]6
	LEN[n]
    }
    set Bus_Setup {
	\Nn
	DD[n] {getDelimiter {setDelimiter char}}
	GP[n1[n2]] x
	RS[n1[n2]] x
	STAR[n]    {getStarMode {setStarMode varName}}
    }
    set Bus/7260_Status {
	M
	N
	ST
    }
    set Front_Panel {
	DISPn1[n2]
	DISPMODE[n]
	KP
	LTS[n]
    }
    set Others {
	ID
	VER
    }
}

proc ::egg7260::iniGlobals {} {

}

proc ::egg7260::ini {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
#    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) ""
}

proc ::egg7260::write {egg7260Name string} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) $string
}

proc ::egg7260::read {egg7260Name {len 512}} {
    upvar #0 $egg7260Name deviceArray
    set ret [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) $len]
#    if {[string index $ret end] == "\n"} {
#        set ret [string range $ret 0 end-1]
#    }
    return $ret
}

proc ::egg7260::getFirmwareVersion {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) VER
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr) 20]
}

proc ::egg7260::getDelimiter {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) DD
    set ascii [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
    return [binary format c $ascii]
}

proc ::egg7260::setDelimiter {egg7260Name char} {
    upvar #0 $egg7260Name deviceArray
    if {[binary scan $char c ascii] != 1} {
	return -code error "bad char '$char'"
    }
    if {$ascii < 0 || $ascii > 127} {
	return -code error "char out of range = $ascii"
    }
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) DD$ascii
    return
}


proc ::egg7260::getStarMode {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    variable STARMODE
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) STAR
    return $STARMODE([string trimright [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)]])
}

proc ::egg7260::setStarMode {egg7260Name varName} {
    upvar #0 $egg7260Name deviceArray
    variable STARMODEINDEX
    if {![info exists STARMODEINDEX($varName)]} {
	return -code error "bad varName \"$varName\", should be one of \{[array names STARMODEINDEX]\}"
    }
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) DD$STARMODEINDEX($varName)
    return
}

proc ::egg7260::getNoise {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) NN.
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::egg7260::getX {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) X.
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::egg7260::getY {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) Y.
    return [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)]
}

proc ::egg7260::getXY {egg7260Name} {
    upvar #0 $egg7260Name deviceArray
    GPIB::wrt $deviceArray(gpibBoard) $deviceArray(gpibAddr) XY.
    return [string trimright [GPIB::rd $deviceArray(gpibBoard) $deviceArray(gpibAddr)] "\0"]
}

proc scannestep {from to step delay stream} {
    global STOP
    set xy [egg getXY]
    set noise [egg getNoise]
    puts $stream "$from $xy $noise"
    flush $stream
    set next [expr {$from + $step}]
    if {$next <= $to && $STOP == false} {
	rs::move_nm $next
	after $delay [list scannestep $next $to $step $delay $stream]
    }
}

proc scanne {from to step delay stream} {
    global STOP
    set STOP false

    rs::move_nm $from
    set delay [expr {int($delay*1000.)}]
    puts $stream @@photocourant
    puts $stream {@ lambda_nm X Y Noise}
    after $delay [list scannestep $from $to $step $delay $stream]
}




# scanne 750 850 1 1000
