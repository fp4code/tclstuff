set INCLUDES [list {C:/Program Files/National Instruments/NI-488.2/Languages/Microsoft C}]

set SOURCES(FindInstruments) FindInstruments.c
set    LIBS(FindInstruments) [concat {C:/WINNT/system32/libgpib-32} $GLOBLIBS(c)]

do -create program FindInstruments

set OK {
gcc FindInstruments.c -I"/c/Program Files/National Instruments/NI-488.2/Languages/Microsoft C" "/c/Program Files/National Instruments/NI-488.2/Languages/Microsoft C/Gpib-32.obj"
# rale un peu
gcc Dll4882query.c -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry"
gcc DllFindInstruments.c -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry"



gcc -g -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry" -shared -Wall -o foo.dll -Wl,--out-implib,libfoo.a DllFindInstrumentsLib.c
gcc -g  -o bar DllFindInstrumentsMain.c libfoo.a

gcc -g -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry" -shared -Wall -o foo.dll -Wl,--out-implib,libfoo.a DllMiniLib.c
gcc -g  -o bar DllMiniMain.c libfoo.a

gcc -DWINNT -g -Wall -Wconversion -Wno-implicit-int -c -IC:/prog/msys/prog/Tcl/include -I"C:/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry" -o bar tcl.c -LC:/C/fidev-gcc-mingw-optim/Tcl/ni488/src -lni488.2.0 -LC:/prog/msys/prog/Tcl/lib -ltcl84
}






# pas fait :

# gcc DllFindInstruments2.c -I"/c/Program Files/National Instruments/NI-488.2/Languages/DLL Direct Entry" -L"/c/WINNT/system32" -lgpib-32
