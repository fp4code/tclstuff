# -----------------------------------------------------------------------------#
# Recompilation automatique du code C++ associé et chargement
# -----------------------------------------------------------------------------#

package provide asyst 1.1

set Asyst_peredir [pwd]
set Asyst_heredir [file dirname [info script]]
cd $Asyst_heredir

if {![file exists asyst.so] || [file mtime asyst.cc] > [file mtime asyst.so]} {
  puts "Compilation de asyst.cc"
  exec CC \
      -I/usr/openwin/include \
      -I/prog/Tcl/tk${tk_patchLevel}/generic \
      -I/prog/Tcl/tcl${tcl_patchLevel}/generic \
      -I/prog/Tcl/blt8.0a2-unoff/generic \
      -I/prog/asyst \
      -g -Kpic -c asyst.cc
  puts "Création asyst.so"
  exec cc -G -ztext asyst.o -o asyst.so -L/usr/local/lib -llifi -lC
}

cd $Asyst_peredir
puts "Chargement de asyst.so"
load $Asyst_heredir/asyst.so Asyst
