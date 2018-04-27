namespace eval ::gpib::37xxxc {}


proc calibration_std_ini {f_start f_incr npts} {
    # menu C11A
    hyper write SCM  ;# standard calibration method
    hyper write LTC  ;# coax line calibration
    # menu C5
    hyper write C12  ;# calibrage 12 termes
    # menu C5D
    hyper write ISN  ;# incluse isolation
    # menu C1
    hyper write "FRP $npts XX1"
    hyper write "FRS $f_start GHZ"
    hyper write "FRI $f_incr GHZ"
    hyper write FIL  ;# fill freq
    hyper write DFD  ;# done speci. discrete freq

    foreach port {P1C P2C} {
	# menu C3
	hyper write $port  ;# select port 1 
	# menu C4	
	hyper write CND  ;# Select user specified connector for current port
	# 
	hyper write "COO 0.098 MM" ;# Enter offset for open for user specified connector
	hyper write "cc0 0 xx1" ;# Enter capacitance coefficient 0 for open
	hyper write "cc1 0 xx1" ;# Enter capacitance coefficient 1 for open
	hyper write "cc2 0 xx1" ;# Enter capacitance coefficient 2 for open
	hyper write "cc3 0 xx1" ;# Enter capacitance coefficient 3 for open
	hyper write "cos 0 m" ;# Enter offset for short for user specified connector
    }
    # menu C13
    hyper write MAT ;# Select matched reflective devices during cal
    # menu C6
    hyper write BBL ;# Select broadband load for calibration
    # menu C6A
    hyper write "BBZ 50 OHM" ;# Enter broadband load impedance for calibration
    # menu C20
    hyper write "BBZL 0 xx1" ;# Enter broadband load inductance for calibration
    hyper write "tlz 50 ohm" ;# Enter Through line impedance for calibration
    hyper write "tol 0.340 mm" ;# Enter Through offset length for calibration


    
}

proc calibration_std {f_start f_incr npts} {
    calibration_std_ini $f_start $f_incr $npts
    hyper write beg  ;# begin
}

proc cal_step {} {
    hyper write tcd  ;# 
    hyper write ncs
}
