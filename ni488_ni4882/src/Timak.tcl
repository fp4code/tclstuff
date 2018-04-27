# 2005-08-30 (FP)
# 2006-09-05 (FP)
# 2007-11-23 (FP) cht NIDIR

#set NIDIR /home/p10admin/prog/ni488/ni488225L
set NIDIR /usr/local

#set INCLUDES [concat $TCLINCLUDEDIR /usr/local/natinst/ni4882/include/]
set INCLUDES [concat $TCLINCLUDEDIR [file join $NIDIR include]]

# set LDFLAGS -DHAVE_ERRNO_AS_DEFINE=1
#puts stderr "Contournement BUG gcc version 3.2.2 (Mandrake Linux 9.1 3.2.2-3mdk)"

set SOURCES(libtclni488.2.3.1) NI488.c
set LIBS(libtclni488.2.3.1) [list [file join $NIDIR lib libgpibapi] [file join $NIDIR lib libnipalu] libc]


set SOURCES(ni488) {MainTk.c}
set LIBS(ni488) [list ./libtclni488.2.3.1 [file join $NIDIR lib libgpibapi] [file join $NIDIR lib libnipalu] $TKLIB $GLOBLIBS(X11) $TCLLIB libdl libm libc]

#eval lappend LIBS(libni488.2.0) $GLOBLIBS(c)
#eval lappend LIBS(libni488) $GLOBLIBS(c)

do -create lib libtclni488.2.3.1
do -create program ni488
