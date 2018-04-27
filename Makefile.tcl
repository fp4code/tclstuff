PL := $(shell echo 'puts $$tcl_patchLevel' | /prog/Tcl/bin/tclsh)
VERS := $(shell echo 'puts $$tcl_version' | /prog/Tcl/bin/tclsh)
LTCL=-L/prog/Tcl/lib -R/prog/Tcl/lib -ltcl${VERS}
CPPFLAGS += -I/prog/Tcl/tcl${PL}/generic -I/prog/Tcl/tk${PL}/generic -I.
CPPFLAGS += -I${OPENWINHOME}/include
