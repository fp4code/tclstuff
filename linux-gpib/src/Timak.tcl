# 2005-08-30 (FP)
# 2006-09-05 (FP)
# 2007-11-23 (FP) cht NIDIR
# 2008-12-22 (FP) Passage à Linux-GPIB

set NIDIR /local/prog/linux-gpib

set INCLUDES [concat $TCLINCLUDEDIR [file join $NIDIR include]]

set SOURCES(libtcllinuxgpib.0.1.5) linux-gpib.c
set LIBS(libtcllinuxgpib.0.1.5) [list [file join $NIDIR lib libgpib] libc]


set SOURCES(linuxgpib) {MainTk.c}
set LIBS(linuxgpib) [list ./libtcllinuxgpib.0.1.5 [file join $NIDIR lib libgpib] $TKLIB $GLOBLIBS(X11) $TCLLIB libdl libm libc]

do -create lib libtcllinuxgpib.0.1.5
do -create program linuxgpib
