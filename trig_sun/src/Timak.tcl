set INCLUDES [list ../../../c/sunmath/src $TCLINCLUDEDIR]

set SOURCES(libtcl_trig_sun) [list trig_sun.c dummy.f]
set SOURCES(trig_sunsh) mainTcl.c
set LIBS(libtcl_trig_sun) [concat ../../../c/sunmath/src/libfidev_sunmath $TCLLIB libm]
set LIBS(trig_sunsh) [concat ../../../c/sunmath/src/libfidev_sunmath  ./libtcl_trig_sun $TCLLIB $TKLIB]

do -create lib libtcl_trig_sun
do -create program trig_sunsh

#	    main.o \
#	    -L/prog/Tcl/lib ${RP} /prog/Tcl/lib -ltcl${VERS} -ltk${VERS} \
#	    -L${PREFIX}/Tcl/trig_sun ${RP} ${PREFIX}/Tcl/trig_sun -l${LIB} \
#            -lm -L/usr/X11R6/lib -lX11 -ldl
#            -lsunmath -lm

#${LIBNAME}:${OBJSLIB} 
#	$(DO_SO) -o $@ ${OBJSLIB} -lm
#	$(DO_SO) -o $@ ${OBJSLIB} -lsunmath -lm
