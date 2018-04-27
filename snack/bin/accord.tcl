# 1 janvier 2003 (FP)

# A LANCER INTERACTIVEMENT AVEC WISH
# penser à ouvrir le mixer.

package require snack
snack::sound sc -rate 44100
snack::sound s2

proc f2 {s lignes} {
    # lignes issues de ellf

    set lignes [split $lignes \n]
    if {[lindex $lignes 0] != {z plane Denominator      Numerator}} {
	return -code error "Attendu \"z plane Denominator      Numerator\""
    }
    if {[lindex $lignes end] != {}} {
	return -code error "Attendu ligne vide, reçu \"[lindex $lignes end]\""
    }

    set num [list]
    set denom [list]
    set i 0

    foreach l [lrange $lignes 1 end-1] {
	if {[lindex $l 0] != $i} {
	    return -code error "attendu \"$i\""
	}
	lappend denom [lindex $l 1]
	lappend num [lindex $l 2]
	incr i
    }

    puts stderr "snack::filter iir  -numerator $num -denominator $denom"

    s2 copy $s
    s2 filter  [snack::filter iir  -numerator $num -denominator $denom] -continuedrain 0
    # s2 play
}


demos/tcl/xs.tcl
-> ~/Z/si.wav (53.58 Hz)

sc read ~/Z/si.wav
sc play

# Butterworth Low 3 70

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   1.227742805E-07
 1  -2.980053463E+00   3.683228416E-07
 2   2.960305361E+00   3.683228416E-07
 3  -9.802509166E-01   1.227742805E-07
}

s2 write ~/Z/sipur.wav

# Butterworth Low 4 70

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   6.103690123E-10
 1  -3.973938537E+00   2.441476049E-09
 2   5.922154675E+00   3.662214074E-09
 3  -3.922491160E+00   2.441476049E-09
 4   9.742750319E-01   6.103690123E-10
}

s2 write ~/Z/sipur4.wav

# Butterworth Low 5 70

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   3.034260343E-12
 1  -4.967725730E+00   1.517130171E-11
 2   9.871423121E+00   3.034260343E-11
 3  -9.807909808E+00   3.034260343E-11
 4   4.872453206E+00   1.517130171E-11
 5  -9.682407882E-01   3.034260343E-12
}

s2 write ~/Z/sipur5.wav

# INSTABLE !!!!

# Butterworth Low 3 70

f2 sc {z plane Denominator      Numerator
 0   1.000000000E+00   1.227742805E-07
 1  -2.980053463E+00   3.683228416E-07
 2   2.960305361E+00   3.683228416E-07
 3  -9.802509166E-01   1.227742805E-07
}
s2 write ~/Z/sipur3.wav
f2 s2 {z plane Denominator      Numerator
 0   1.000000000E+00   1.227742805E-07
 1  -2.980053463E+00   3.683228416E-07
 2   2.960305361E+00   3.683228416E-07
 3  -9.802509166E-01   1.227742805E-07
}
s2 write ~/Z/sipur3+3.wav

# Butterworth Low 7 70
f2 sc {z plane Denominator      Numerator
 0   1.00000000000000000E+00   1.08420217248550443E-16
 1  -6.95518037790590427E+00   7.58941520739853104E-16
 2   2.07320858711716056E+01   2.27682456221955931E-15
 3  -3.43327092476404445E+01   3.79470760369926552E-15
 4   3.41135859805877004E+01   3.79470760369926552E-15
 5  -2.03376554980605349E+01   2.27682456221955931E-15
 6   6.73604295650152007E+00   7.58941520739853104E-16
 7  -9.56169684653928598E-01   1.08420217248550443E-16
}
s2 write ~/Z/sipur7.wav

# Butterworth Low 7 110
f2 sc {z plane Denominator      Numerator
 0   1.00000000000000000E+00   1.75900960464048239E-15
 1  -6.92956922591284830E+00   1.23130672324833768E-14
 2   2.05798925154771162E+01   3.69392016974501303E-14
 3  -3.39558682351688645E+01   6.15653361624168838E-14
 4   3.36159331773845835E+01   6.15653361624168838E-14
 5  -1.99679768778066986E+01   3.69392016974501303E-14
 6   6.58957994229168875E+00   1.23130672324833768E-14
 7  -9.31991296264753633E-01   1.75900960464048239E-15
}
s2 write ~/Z/sipur7b.wav
f2 s2 {z plane Denominator      Numerator
 0   1.00000000000000000E+00   1.75900960464048239E-15
 1  -6.92956922591284830E+00   1.23130672324833768E-14
 2   2.05798925154771162E+01   3.69392016974501303E-14
 3  -3.39558682351688645E+01   6.15653361624168838E-14
 4   3.36159331773845835E+01   6.15653361624168838E-14
 5  -1.99679768778066986E+01   3.69392016974501303E-14
 6   6.58957994229168875E+00   1.23130672324833768E-14
 7  -9.31991296264753633E-01   1.75900960464048239E-15
}
s2 write ~/Z/sipur7b+7b.wav
