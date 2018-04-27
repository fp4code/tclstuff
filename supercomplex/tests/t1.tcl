#!/bin/sh

#\
exec tclsh "$0" ${1+"$@"}

if {[lsearch [namespace children] ::tcltest] == -1} {
    package require tcltest
    namespace import -force ::tcltest::*
}

package require fidev
package require supercomplex

test supercomplex-1.1 {supercomplex create} {
    supercomplex create xy 1 2
} {xy 1.0 2.0}

test supercomplex-1.2 {supercomplex create} {
    supercomplex create maspi 1 0.1
} {maspi 1.0 0.1}

test supercomplex-1.3 {supercomplex create} {
    supercomplex create maspi 1 3.1
} {maspi 1.0 -0.9}

test supercomplex-1.4 {supercomplex create} {
    supercomplex create maspi 19.2 1.0
} {maspi 19.2 1.0}

test supercomplex-1.5 {supercomplex create} {
    supercomplex create maspi 19.2 -1.0
} {maspi 19.2 1.0}

test supercomplex-1.6 {supercomplex create} {
    supercomplex create 3 4
} {xy 3.0 4.0}

test supercomplex-1.7 {supercomplex create} {
    supercomplex create maspi -3.1 0.1
} {maspi 3.1 -0.9}

test supercomplex-2.1 {supercomplex type} {
    supercomplex type {3 4}
} {xy}

test supercomplex-2.2 {supercomplex type} {
    supercomplex type {xy 3 4}
} {xy}

test supercomplex-2.3 {supercomplex type} {
    supercomplex type {maspi 3 0.1}
} {maspi}

test supercomplex-2.4 {supercomplex type} {
    list [catch {supercomplex type {foo 3 0.1}} msg] $msg
} {1 {bad Bad type "foo": must be xy or maspi}}

test supercomplex-3.1 {supercomplex tomaspi} {
    supercomplex tomaspi {xy 10 0}
} {maspi 10.0 0.0}

test supercomplex-3.2 {supercomplex tomaspi} {
    supercomplex tomaspi {xy 0 10}
} {maspi 10.0 0.5}

test supercomplex-3.3 {supercomplex tomaspi} {
    supercomplex tomaspi {xy -10 0}
} {maspi 10.0 1.0}

test supercomplex-3.4 {supercomplex tomaspi} {
    supercomplex tomaspi {xy 0 -10}
} {maspi 10.0 -0.5}

test supercomplex-3.5 {supercomplex tomaspi} {
    supercomplex tomaspi {maspi 3.0 5.1}
} {maspi 3.0 -0.9}

test supercomplex-3.6 {supercomplex tomaspi} {
    supercomplex tomaspi {maspi -3.1 0.1}
} {maspi 3.1 -0.9}

test supercomplex-4.1 {supercomplex toxy} {
    supercomplex toxy {maspi 10 0}
} {xy 10.0 0.0}

test supercomplex-4.2 {supercomplex toxy} {
    supercomplex toxy {maspi 10 0.5}
} {xy 0.0 10.0}

test supercomplex-4.3 {supercomplex toxy} {
    supercomplex toxy {maspi 10 1.0}
} {xy -10.0 0.0}

test supercomplex-4.4 {supercomplex toxy} {
    supercomplex toxy {maspi 10 -0.5}
} {xy 0.0 -10.0}


test supercomplex-5.1 {supercomplex re} {
    supercomplex re {4 5}
} {4.0}

test supercomplex-5.2 {supercomplex re} {
    supercomplex re {xy -4 5}
} {-4.0}

test supercomplex-5.3 {supercomplex re} {
    supercomplex re {maspi 2 0}
} {2.0}

test supercomplex-5.4 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 [expr {1./3.}]]
} {1.0}

test supercomplex-5.6 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 0.5]
} {0.0}

test supercomplex-5.7 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 [expr {2./3.}]]
} {-1.0}

test supercomplex-5.8 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 1]
} {-2.0}

test supercomplex-5.9 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 [expr {-2./3.}]]
} {-1.0}

test supercomplex-5.10 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 -0.5]
} {0.0}

test supercomplex-5.11 {supercomplex re} {
    supercomplex re [supercomplex create maspi 2 [expr {-1./3.}]]
} {1.0}

test supercomplex-6.1 {supercomplex im} {
    supercomplex im {4 5}
} {5.0}

test supercomplex-6.2 {supercomplex im} {
    supercomplex im {xy -4 5}
} {5.0}

test supercomplex-6.3 {supercomplex im} {
    supercomplex im {maspi 2 0}
} {0.0}

test supercomplex-6.4 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 [expr {1./6.}]]
} {1.0}

test supercomplex-6.6 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 0.5]
} {2.0}

test supercomplex-6.7 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 [expr {5./6.}]]
} {1.0}

test supercomplex-6.8 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 1]
} {0.0}

test supercomplex-6.9 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 [expr {-5./6.}]]
} {-1.0}

test supercomplex-6.10 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 -0.5]
} {-2.0}

test supercomplex-6.11 {supercomplex im} {
    supercomplex im [supercomplex create maspi 2 [expr {-1/6.}]]
} {-1.0}

test supercomplex-7.1 {supercomplex module} {
    supercomplex module -3
} {3.0}

test supercomplex-7.2 {supercomplex module} {
    supercomplex module {3 4}
} {5.0}

test supercomplex-7.3 {supercomplex module} {
    supercomplex module {0 0}
} {0.0}

test supercomplex-7.4 {supercomplex module} {
    supercomplex module {maspi 0 0}
} {0.0}

test supercomplex-7.5 {supercomplex module} {
    supercomplex module {maspi 3.1 0.1}
} {3.1}

test supercomplex-7.6 {supercomplex module} {
    supercomplex module {maspi -3.1 0.1}
} {3.1}

test supercomplex-8.1 {supercomplex aspi} {
    supercomplex aspi 10.0
} {0.0}

test supercomplex-8.2 {supercomplex aspi} {
    supercomplex aspi -10.0
} {1.0}

test supercomplex-8.3 {supercomplex aspi} {
    supercomplex aspi 0.0
} {0.0} ; # arbitrary

test supercomplex-8.4 {supercomplex aspi} {
    expr {6.0*[supercomplex aspi [supercomplex create xy [expr {sqrt(300.)}] 10.]]}
} {1.0}

test supercomplex-8.5 {supercomplex aspi} {
    expr {6.0*[supercomplex aspi [supercomplex create xy 10. [expr {sqrt(300.)}]]]}
} {2.0}

test supercomplex-8.6 {supercomplex aspi} {
    expr {6.0*[supercomplex aspi [supercomplex create xy 0.0 20.0]]}
} {3.0}

test supercomplex-9.1 {supercomplex arad} {
    expr {[supercomplex arad -1.0] - acos(-1.0)}
} {0.0}

test supercomplex-10.1 {supercomplex neg} {
    supercomplex neg 2
} {xy -2.0 0.0}

test supercomplex-10.2 {supercomplex neg} {
    supercomplex neg {3 1}
} {xy -3.0 -1.0}

test supercomplex-10.3 {supercomplex neg} {
    supercomplex neg {2 2}
} {xy -2.0 -2.0}

test supercomplex-10.4 {supercomplex neg} {
    supercomplex neg {1 3}
} {xy -1.0 -3.0}

test supercomplex-10.4 {supercomplex neg} {
    supercomplex neg {-1 3}
} {xy 1.0 -3.0}

test supercomplex-10.6 {supercomplex neg} {
    supercomplex neg {-2 2}
} {xy 2.0 -2.0}

test supercomplex-10.7 {supercomplex neg} {
    supercomplex neg {-3 1}
} {xy 3.0 -1.0}

test supercomplex-10.8 {supercomplex neg} {
    supercomplex neg {-3 -1}
} {xy 3.0 1.0}

test supercomplex-10.9 {supercomplex neg} {
    supercomplex neg {-2 -2}
} {xy 2.0 2.0}

test supercomplex-10.10 {supercomplex neg} {
    supercomplex neg {-1 -3}
} {xy 1.0 3.0}

test supercomplex-10.11 {supercomplex neg} {
    supercomplex neg {1 -3}
} {xy -1.0 3.0}

test supercomplex-10.12 {supercomplex neg} {
    supercomplex neg {2 -2}
} {xy -2.0 2.0}

test supercomplex-10.13 {supercomplex neg} {
    supercomplex neg {3 -1}
} {xy -3.0 1.0}

test supercomplex-10.21 {supercomplex neg} {
    supercomplex neg {maspi 3 0}
} {maspi 3.0 1.0}

test supercomplex-10.22 {supercomplex neg} {
    supercomplex neg {maspi 3 0.5}
} {maspi 3.0 -0.5}

test supercomplex-10.23 {supercomplex neg} {
    supercomplex neg {maspi 3 1}
} {maspi 3.0 0.0}

test supercomplex-10.24 {supercomplex neg} {
    supercomplex neg {maspi 3 -0.5}
} {maspi 3.0 0.5}

test supercomplex-11.1 {supercomplex inv} {
    supercomplex re [supercomplex inv 0.5]
} {2.0}

test supercomplex-11.2 {supercomplex inv} {
    supercomplex inv {3 4}
} {xy 0.12 -0.16}

test supercomplex-11.3 {supercomplex inv} {
    supercomplex inv {4 3}
} {xy 0.16 -0.12}

test supercomplex-11.4 {supercomplex inv} {
    supercomplex inv {0 2}
} {xy 0.0 -0.5}

test supercomplex-11.5 {supercomplex inv} {
    supercomplex inv {-3 4}
} {xy -0.12 -0.16}

test supercomplex-11.6 {supercomplex inv} {
    supercomplex inv {-4 3}
} {xy -0.16 -0.12}

test supercomplex-11.7 {supercomplex inv} {
    supercomplex re [supercomplex inv {-2}]
} {-0.5}

test supercomplex-11.8 {supercomplex inv} {
    supercomplex inv {-4 -3}
} {xy -0.16 0.12}

test supercomplex-11.9 {supercomplex inv} {
    supercomplex inv {-3 -4}
} {xy -0.12 0.16}

test supercomplex-11.10 {supercomplex inv} {
    supercomplex im [supercomplex inv {0 -2}]
} {0.5}

test supercomplex-11.11 {supercomplex inv} {
    supercomplex inv {3 -4}
} {xy 0.12 0.16}

test supercomplex-11.12 {supercomplex inv} {
    supercomplex inv {4 -3}
} {xy 0.16 0.12}

test supercomplex-11.21 {supercomplex inv} {
    supercomplex inv {maspi 2 0}
} {maspi 0.5 0.0}

test supercomplex-11.22 {supercomplex inv} {
    supercomplex inv {maspi 2 0.5}
} {maspi 0.5 -0.5}

test supercomplex-11.23 {supercomplex inv} {
    supercomplex inv {maspi 2 1}
} {maspi 0.5 1.0}

test supercomplex-11.24 {supercomplex inv} {
    supercomplex inv {maspi 2 -0.5}
} {maspi 0.5 0.5}

proc tconj {z} {
    set re [supercomplex re [supercomplex sub [supercomplex conj $z] $z]]
    set im [supercomplex im [supercomplex add $z [supercomplex conj $z]]]
    return [expr {$re*$re + $im*$im}]
}

test supercomplex-13.1 {supercomplex conj} {
    tconj {maspi 2 -0.5} 
} {0.0}

test supercomplex-14.1 {supercomplex add} {
    supercomplex add 1 2
} {xy 3.0 0.0}

# add, sub, mul, or div
