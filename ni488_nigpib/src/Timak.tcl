# RCS: @(#) $Id: Timak.tcl,v 1.6 2002/06/26 12:38:03 fab Exp $

set INCLUDES [list ../../../c/ni488_nigpib/src/]

# set LDFLAGS -DHAVE_ERRNO_AS_DEFINE=1
#puts stderr "Contournement BUG gcc version 3.2.2 (Mandrake Linux 9.1 3.2.2-3mdk)"

set SOURCES(libtclnigpib.0.8.3) NI488.c
set LIBS(libtclnigpib.0.8.3) [list ../../../c/ni488_nigpib/src/libnigpib.0.8.3 libc]


set SOURCES(ni488) {MainTk.c}
set LIBS(ni488) [list ./libtclnigpib.0.8.3 ../../../c/ni488_nigpib/src/libnigpib.0.8.3 $TKLIB $GLOBLIBS(X11) $TCLLIB libdl libm libc]

#eval lappend LIBS(libni488.2.0) $GLOBLIBS(c)
#eval lappend LIBS(libni488) $GLOBLIBS(c)

do -create lib libtclnigpib.0.8.3
do -create program ni488
