# RCS: @(#) $Id: Timak.tcl,v 1.6 2002/06/26 12:38:03 fab Exp $

set INCLUDES [list $TCLINCLUDEDIR]

# bin_PROGRAMS = bibi
# bibi_SOURCES = unix.c

switch $tcl_platform(os) {
    "Windows NT" {
        set libname libni488.2.0
    }
    default {
        set libname libni488
    }
}

set SOURCES(libni488) NI488.c
set SOURCES(libni488.2.0) {NI488.2.0.c}
set SOURCES(ni488) {MainTk.c}

puts [info globals]

set LIBS(libni488) [list $TCLLIB]

set LIBS(libni488.2.0) [list $TCLLIB]
switch $tcl_platform(os) {
    "Windows NT" {
	lappend INCLUDES {C:/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry}
#	lappend LIBS(libni488.2.0)  C:/WINNT/system32/libgpib-32
	lappend CFLAGS -DWINNT
    }
    default {
	lappend LIBS(libni488.2.0)  /opt/NICgpib/lib/libgpib
	lappend LIBS(libni488)  /opt/NICgpib/lib/libgpib
	lappend INCLUDES /opt/NICgpib/include
    }
}
eval lappend LIBS(libni488.2.0) $GLOBLIBS(c)
eval lappend LIBS(libni488) $GLOBLIBS(c)

set LIBS(ni488) [concat ./$libname $LIBS($libname) $TKLIB]

do -create program ni488
do -create lib $libname


set manuel {
cd /c/C/fidev-gcc-mingw-optim/Tcl/ni488/src
gcc -DWINNT -O -Wall -Wconversion -Wno-implicit-int -c -DBUILD_tcl -I/c/prog/msys/prog/Tcl/include -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry" /w/A/fidev/Tcl/ni488/src/NI488.2.0.c -o NI488.2.0.o
gcc -shared -o libni488.2.0.dll -Wl,--out-implib,libni488.2.0.dll.a NI488.2.0.o /prog/Tcl/bin/tcl84.dll /c/WINNT/system32/gpib-32.dll
# Il faut dans le PATH /c/WINNT/system32 pour gpib-32.dll et /prog/Tcl/bin pour tcl84.dll
# Il faut aussi que tclsh soit celui qui utilise  tcl84.dll
tclsh84
load libni488.2.0.dll Ni488
::GPIBBoard::cac ...
}