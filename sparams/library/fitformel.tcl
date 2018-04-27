# (C) CNRS/LPN (FP) 2001.06.12

package require fidev
package require superTable
package require blasObj
package require dblas1
package require zblas1
package require blasmath
package require slatec
package require port3_nl2opt

#package require sparams2
#package require hsplot

proc readFichiers {frequence fichiers} {

    set fl [list]
    set s11r [list]
    set s11i [list]
    set s12r [list]
    set s12i [list]
    set s21r [list]
    set s21i [list]
    set s22r [list]
    set s22i [list]
    foreach fichier $fichiers {
        puts stderr "$fichier"
        set nomDeTable "*Sparams"
        catch {unset array}
        set indexes [::superTable::fileToTable array $fichier nomDeTable freq]

        set frequences [lindex $indexes 0]
        set colonnes [lindex $indexes 1]

        set lindex {}
        foreach f $frequences {
            if {($f - $frequence) < 0.001*$frequence} {
                set lindex $f
                break
            }
        }
        if {$lindex == {}} {
            puts stderr "Warning, pas de fréquence $frequence dans $fichier"
            break
        }


        lappend fl $fichier
        lappend s11r [::superTable::getCell array $lindex s11_r]
        lappend s11i [::superTable::getCell array $lindex s11_i]
        lappend s12r [::superTable::getCell array $lindex s12_r]
        lappend s12i [::superTable::getCell array $lindex s12_i]
        lappend s21r [::superTable::getCell array $lindex s21_r]
        lappend s21i [::superTable::getCell array $lindex s21_i]
        lappend s22r [::superTable::getCell array $lindex s22_r]
        lappend s22i [::superTable::getCell array $lindex s22_i]
    }
    return [list \
            $fl \
            [blas::vector create double $s11r]\
            [blas::vector create double $s11i]\
            [blas::vector create double $s12r]\
            [blas::vector create double $s12i]\
            [blas::vector create double $s21r]\
            [blas::vector create double $s21i]\
            [blas::vector create double $s22r]\
            [blas::vector create double $s22i]\
            ]
}

proc toPauli {m11r m11i m12r m12i m21r m21i m22r m22i} {
    set mIr [blas::vector create -copy $m11r]
    blas::mathsvop mIr + $m22r
    blas::mathsvop mIr *scal 0.5
    set mIi [blas::vector create -copy $m11i]
    blas::mathsvop mIi + $m22i
    blas::mathsvop mIi *scal 0.5

    set mXr [blas::vector create -copy $m12r]
    blas::mathsvop mXr + $m21r
    blas::mathsvop mXr *scal 0.5
    set mXi [blas::vector create -copy $m12i]
    blas::mathsvop mXi + $m21i
    blas::mathsvop mXi *scal 0.5

    set mYr [blas::vector create -copy $m21i]
    blas::mathsvop mYr - $m12i
    blas::mathsvop mYr *scal 0.5
    set mYi [blas::vector create -copy $m12r]
    blas::mathsvop mYi - $m21r
    blas::mathsvop mYi *scal 0.5

    set mZr [blas::vector create -copy $m11r]
    blas::mathsvop mZr - $m22r
    blas::mathsvop mZr *scal 0.5
    set mZi [blas::vector create -copy $m11i]
    blas::mathsvop mZi - $m22i
    blas::mathsvop mZi *scal 0.5

    return [list $mIr $mIi $mXr $mXi $mYr $mYi $mZr $mZi]
}

proc fromPauli {mIr mIi mXr mXi mYr mYi mZr mZi} {
    set m11r [blas::vector create -copy $mIr]
    blas::mathsvop m11r + $mZr
    set m11i [blas::vector create -copy $mIi]
    blas::mathsvop m11i + $mZi

    set m12r [blas::vector create -copy $mXr]
    blas::mathsvop m12r + $mYi
    set m12i [blas::vector create -copy $mXi]
    blas::mathsvop m12i - $mYr

    set m21r [blas::vector create -copy $mXr]
    blas::mathsvop m21r - $mYi
    set m21i [blas::vector create -copy $mXi]
    blas::mathsvop m21i + $mYr

    set m22r [blas::vector create -copy $mIr]
    blas::mathsvop m22r - $mZr
    set m22i [blas::vector create -copy $mIi]
    blas::mathsvop m22i - $mZi

    return [list $m11r $m11i $m12r $m12i $m21r $m21i $m22r $m22i]
}

proc toPauli_VS {v} {
    set m11r [blas::mathop get@ $v 1]
    set m11i [blas::mathop get@ $v 2]
    set m12r [blas::mathop get@ $v 3]
    set m12i [blas::mathop get@ $v 4]
    set m21r [blas::mathop get@ $v 5]
    set m21i [blas::mathop get@ $v 6]
    set m22r [blas::mathop get@ $v 7]
    set m22i [blas::mathop get@ $v 8]

    set mIr [expr {0.5*($m11r + $m22r)}]
    set mIi [expr {0.5*($m11i + $m22i)}]
    set mXr [expr {0.5*($m12r + $m21r)}]
    set mXi [expr {0.5*($m12i + $m21i)}]
    set mYr [expr {0.5*($m21i - $m12i)}]
    set mYi [expr {0.5*($m12r - $m21r)}]
    set mZr [expr {0.5*($m11r - $m22r)}]
    set mZi [expr {0.5*($m11i - $m22i)}]

    return [blas::vector create double [list $mIr $mIi $mXr $mXi $mYr $mYi $mZr $mZi]]
} 

proc fromPauli_VS {v} {
    set mIr [blas::mathop get@ $v 1]
    set mIi [blas::mathop get@ $v 2]
    set mXr [blas::mathop get@ $v 3]
    set mXi [blas::mathop get@ $v 4]
    set mYr [blas::mathop get@ $v 5]
    set mYi [blas::mathop get@ $v 6]
    set mZr [blas::mathop get@ $v 7]
    set mZi [blas::mathop get@ $v 8]

    set m11r [expr {$mIr + $mZr}]
    set m11i [expr {$mIi + $mZi}]
    set m12r [expr {$mXr + $mYi}]
    set m12i [expr {$mXi - $mYr}]
    set m21r [expr {$mXr - $mYi}]
    set m21i [expr {$mXi + $mYr}]
    set m22r [expr {$mIr - $mZr}]
    set m22i [expr {$mIi - $mZi}]

    return [blas::vector create double [list $m11r $m11i $m12r $m12i $m21r $m21i $m22r $m22i]]
} 


proc sumsqP {sIr sIi sXr sXi sYr sYi sZr sZi alphaIr alphaIi alphaXr alphaXi alphaYr alphaYi alphaZr alphaZi} {
    blas::mathsvop sIr +scal [expr {-$alphaIr}]
    blas::mathsvop sIi +scal [expr {-$alphaIi}]
    blas::mathsvop sXr +scal [expr {-$alphaXr}]
    blas::mathsvop sXi +scal [expr {-$alphaXi}]
    blas::mathsvop sYr +scal [expr {-$alphaYr}]
    blas::mathsvop sYi +scal [expr {-$alphaYi}]
    blas::mathsvop sZr +scal [expr {-$alphaZr}]
    blas::mathsvop sZi +scal [expr {-$alphaZi}]

    # puts [list $sIr $sIi $sXr $sXi $sYr $sYi $sZr $sZi]

    set tmp [blas::vector create -copy $sIr]
    blas::mathsvop tmp * $tmp
    set r [blas::vector create -copy $tmp]

    blas::dcopy $sIi tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r - $tmp

    blas::dcopy $sXr tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r - $tmp
    
    blas::dcopy $sXi tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r + $tmp

    blas::dcopy $sYr tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r - $tmp
    
    blas::dcopy $sYi tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r + $tmp

    blas::dcopy $sZr tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r - $tmp
    
    blas::dcopy $sZi tmp
    blas::mathsvop tmp * $tmp
    blas::mathsvop r + $tmp

    blas::dcopy $sIr tmp
    blas::mathsvop tmp * $sIi

    set i [blas::vector create -copy $tmp]
    
    blas::dcopy $sXr tmp
    blas::mathsvop tmp * $sXi
    blas::mathsvop i - $tmp
    
    blas::dcopy $sYr tmp
    blas::mathsvop tmp * $sYi
    blas::mathsvop i - $tmp
    
    blas::dcopy $sZr tmp
    blas::mathsvop tmp * $sZi
    blas::mathsvop i - $tmp
    
    blas::mathsvop i *scal 2.0

    blas::mathsvop r * $r
    blas::mathsvop i * $i
    blas::mathsvop r + $i
    
    set sumcar [blas::mathop sum $r]
    return [list $sumcar $r]
}

proc sumsqM {s11r s11i s12r s12i s21r s21i s22r s22i alpha11r alpha11i alpha12r alpha12i alpha21r alpha21i alpha22r alpha22i} {
    blas::mathsvop s11r +scal [expr {-$alpha11r}]
    blas::mathsvop s11i +scal [expr {-$alpha11i}]
    blas::mathsvop s12r +scal [expr {-$alpha12r}]
    blas::mathsvop s12i +scal [expr {-$alpha12i}]
    blas::mathsvop s21r +scal [expr {-$alpha21r}]
    blas::mathsvop s21i +scal [expr {-$alpha21i}]
    blas::mathsvop s22r +scal [expr {-$alpha22r}]
    blas::mathsvop s22i +scal [expr {-$alpha22i}]
    
    # puts [toPauli $s11r $s11i $s12r $s12i $s21r $s21i $s22r $s22i]

    set tmp [blas::vector create -copy $s11r]
    blas::mathsvop tmp * $s22r
    set r [blas::vector create -copy $tmp]

    blas::dcopy $s11i tmp
    blas::mathsvop tmp * $s22i
    blas::mathsvop r - $tmp

    blas::dcopy $s12r tmp
    blas::mathsvop tmp * $s21r
    blas::mathsvop r - $tmp

    blas::dcopy $s12i tmp
    blas::mathsvop tmp * $s21i
    blas::mathsvop r + $tmp

    blas::dcopy $s11r tmp
    blas::mathsvop tmp * $s22i
    set i [blas::vector create -copy $tmp]
    
    blas::dcopy $s11i tmp
    blas::mathsvop tmp * $s22r
    blas::mathsvop i + $tmp
    
    blas::dcopy $s12r tmp
    blas::mathsvop tmp * $s21i
    blas::mathsvop i - $tmp

    blas::dcopy $s12i tmp
    blas::mathsvop tmp * $s21r
    blas::mathsvop i - $tmp

    blas::mathsvop r * $r
    blas::mathsvop i * $i
    blas::mathsvop r + $i
    
    set sumcar [blas::mathop sum $r]
    return [list $sumcar $r]
}


set FACD 1000.

proc fitIni {alphaV} {
    global Fit
    global FACD

    set Fit(x) $alphaV
    set Fit(b) [blas::vector create double {-100 100 -100 100 -100 100 -100 100 -100 100 -100 100 -100 100 -100 100}]
    set d [expr {1.0/100./double($FACD)}]
    set Fit(d) [blas::vector create double [list $d $d $d $d $d $d $d $d]]
    set p [blas::vector length $Fit(x)]
    set liv [expr {59 + $p}]
    set lv [expr {77 + ($p*($p+23))/2}]
    set Fit(alg) 2
    set Fit(iv) [blas::vector create long -length $liv]
    set Fit(v) [blas::vector create double -length $lv]

    port3::divset $Fit(alg) Fit(iv) Fit(v)

    puts stderr "[lindex $Fit(iv) 1], x = $Fit(x)"
}

proc compareHead {e1 e2} {
    set e1 [lindex $e1 0]
    set e2 [lindex $e2 0]
    if {$e1 > $e2} {return 1}
    if {$e1 < $e2} {return -1}
    return 0
}

proc fitStep {pt} {
    global Fit

    set fx [$Fit(FUNC) \
            [lindex $Fit(S) 0] \
            [lindex $Fit(S) 1] \
            [lindex $Fit(S) 2] \
            [lindex $Fit(S) 3] \
            [lindex $Fit(S) 4] \
            [lindex $Fit(S) 5] \
            [lindex $Fit(S) 6] \
            [lindex $Fit(S) 7] \
            [blas::mathop get@ $Fit(x) 1] \
            [blas::mathop get@ $Fit(x) 2] \
            [blas::mathop get@ $Fit(x) 3] \
            [blas::mathop get@ $Fit(x) 4] \
            [blas::mathop get@ $Fit(x) 5] \
            [blas::mathop get@ $Fit(x) 6] \
            [blas::mathop get@ $Fit(x) 7] \
            [blas::mathop get@ $Fit(x) 8] \
    ]
    
    set fxl [lindex $fx 1]
    set fx [lindex $fx 0]

    if {0} {

        set pl [list]
        foreach fxel $fxl ffel $Fit(FL) {
            lappend pl [list $fxel $ffel]
        }
        
        set pl [lsort -command compareHead $pl]
        puts stderr {}
        foreach pel $pl {
            puts stderr "[lindex $pel 1] [lindex $pel 0]"
        }
    }

    puts -nonewline stderr "FX = $fx"

    port3::drmnfb $Fit(b) $Fit(d) $fx Fit(iv) Fit(v) Fit(x)

    puts stderr ", iv(1) = [lindex $Fit(iv) 1]"
    # x = $Fit(x)"

    return [lindex $Fit(iv) 1]
}

proc fitAll {} {
    set ff 1
    while {$ff == 1 || $ff == 2} {
        set ff [fitStep 0]
    }
    # bell ; bell
}

cd /home/asdex/data/G010204/G010204.3/hyper/45A5x17_20dB

set rf [readFichiers 20e9 [glob *]]
set FL [lindex $rf 0]
set sMatrix [lrange $rf 1 end]
foreach {s11r s11i s12r s12i s21r s21i s22r s22i} $sMatrix {break}

if 0 {
set s11r {double 1}
set s11i {double 1}
set s12r {double 0}
set s12i {double 0}
set s21r {double 0}
set s21i {double 0}
set s22r {double 1}
set s22i {double 1}
}

set sPauli [toPauli $s11r $s11i $s12r $s12i $s21r $s21i $s22r $s22i]
foreach {sIr sIi sXr sXi sYr sYi sZr sZi} $sPauli {break}

foreach {s11rb s11ib s12rb s12ib s21rb s21ib s22rb s22ib} [fromPauli $sIr $sIi $sXr $sXi $sYr $sYi $sZr $sZi] {break}

foreach s {s11r s11i s12r s12i s21r s21i s22r s22i} {
    set tmp [blas::vector create -copy [set ${s}b]]
    blas::mathsvop tmp - [set $s]
    blas::mathsvop tmp fabs
    puts "$s [blas::mathop max $tmp]"
}


set alphaIr 0
set alphaIi 0
set alphaXr 0
set alphaXi 0
set alphaYr 0
set alphaYi 0
set alphaZr 0
set alphaZi 0
sumsqP $sIr $sIi $sXr $sXi $sYr $sYi $sZr $sZi $alphaIr $alphaIi $alphaXr $alphaXi $alphaYr $alphaYi $alphaZr $alphaZi

set alpha11r [expr {$alphaIr + $alphaZr}]
set alpha11i [expr {$alphaIi + $alphaZi}]
set alpha12r [expr {$alphaXr + $alphaYi}]
set alpha12i [expr {$alphaXi - $alphaYr}]
set alpha21r [expr {$alphaXr - $alphaYi}]
set alpha21i [expr {$alphaXi + $alphaYr}]
set alpha22r [expr {$alphaIr - $alphaZr}]
set alpha22i [expr {$alphaIi - $alphaZi}]

sumsqM $s11r $s11i $s12r $s12i $s21r $s21i $s22r $s22i $alpha11r $alpha11i $alpha12r $alpha12i $alpha21r $alpha21i $alpha22r $alpha22i

set Fit(FUNC) sumsqP
set Fit(S) $sPauli
set Fit(FL) $FL
set alphaVP [blas::vector create double [list $alphaIr $alphaIi $alphaXr $alphaXi $alphaYr $alphaYi $alphaZr $alphaZi]]
fitIni $alphaVP
fitAll
set alphaVP $Fit(x)
set resul {
double 0.597084341249 -0.0572505541391 -0.948259677147 0.308155871204 0.309893064336 0.931188208504 0.367428328365 0.0675588819834
0.00176328331607
}

set alphaVP {double 2 0 -1 0.5 0.5 1 0.5 0}
fitIni $alphaVP
fitAll
set alphaVP $Fit(x)
set resul {
double 0.887127404366 -0.00127379291959 -1.15726244542 0.0973407971606 0.0971070643302 1.15159257105 -0.0542984899903 -0.00468416520628
0.000272374904923
}

set Fit(FUNC) sumsqM
set Fit(S) $sMatrix
set Fit(FL) $FL
set alphaVM [fromPauli_VS $alphaVP]
fitIni $alphaVM
fitAll
set alphaVM $Fit(x)
set resul {
double 0.832828404933 -0.00595839617024 -0.00567428896255 0.000229288925016 -2.30885501956 0.194447861281 0.941425815231 0.00341029738167
0.000272374165816
}

set alphaVM {double 1 0 0 0 -3 1 1 0}
fitIni $alphaVM
fitAll
set alphaVM $Fit(x)

set FACD 0.1
fitIni $alphaVM
fitAll
set alphaVM $Fit(x)
set resul {double 0.835661111713 -0.00353287484998 -0.00579302292026 8.73779846775e-05 -2.38970651391 0.127164401639 0.935181448608 -0.00149201876601
0.000271390191398
}

foreach {s11r s11i s12r s12i s21r s21i s22r s22i} $sMatrix {break}

set s11 [blas::math complex $s11r $s11i]
set s12 [blas::math complex $s12r $s12i]
set s21 [blas::math complex $s21r $s21i]
set s22 [blas::math complex $s22r $s22i]

set alpha11r [blas::mathop get@ $Fit(x) 1]
set alpha11i [blas::mathop get@ $Fit(x) 2]
set alpha12r [blas::mathop get@ $Fit(x) 3]
set alpha12i [blas::mathop get@ $Fit(x) 4]
set alpha21r [blas::mathop get@ $Fit(x) 5]
set alpha21i [blas::mathop get@ $Fit(x) 6]
set alpha22r [blas::mathop get@ $Fit(x) 7]
set alpha22i [blas::mathop get@ $Fit(x) 8]


set sm11 [blas::vector create -copy $s11]
blas::mathsvop sm11 +rscal [expr {-$alpha11r}]
blas::mathsvop sm11 +iscal [expr {-$alpha11i}]
set sm12 [blas::vector create -copy $s12]
blas::mathsvop sm12 +rscal [expr {-$alpha12r}]
blas::mathsvop sm12 +iscal [expr {-$alpha12i}]
set sm21 [blas::vector create -copy $s21]
blas::mathsvop sm21 +rscal [expr {-$alpha21r}]
blas::mathsvop sm21 +iscal [expr {-$alpha21i}]
set sm22 [blas::vector create -copy $s22]
blas::mathsvop sm22 +rscal [expr {-$alpha22r}]
blas::mathsvop sm22 +iscal [expr {-$alpha22i}]

set sigA [blas::vector create -copy $sm21]
blas::mathsvop sigA / $sm11
blas::mathsvop sigA *rscal -1.0
set sigB [blas::vector create -copy $sm22]
blas::mathsvop sigB / $sm12
blas::mathsvop sigB *rscal -1.0

set rien {

set tmp [blas::vector create -copy $sm11]
blas::mathsvop tmp * $sm22
set tmptmp [blas::vector create -copy $sm12]
blas::mathsvop tmptmp * $sm21
blas::mathsvop tmp - $tmptmp
set tmp

set tmpA [blas::vector create -copy $sigA]
blas::mathsvop tmpA * $sm11
blas::mathsvop tmpA * $sm12
set tmpB [blas::vector create -copy $sigB]
blas::mathsvop tmpB * $sm11
blas::mathsvop tmpB * $sm12

set tmp [blas::vector create -copy $tmpA]
blas::mathsvop tmp - $tmpB

set tmp [blas::vector create -copy $tmpA]
blas::mathsvop tmp / $tmpB


}
