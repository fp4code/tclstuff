set INCLUDES $TCLINCLUDEDIR

set SOURCES(libtcl_unix) unix.c
set LIBS(libtcl_unix) [list $TCLLIB libc libnsl]

do -create lib libtcl_unix