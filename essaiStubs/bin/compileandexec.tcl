set ici [pwd]
set didi [file join /tmp/Z $tcl_platform(machine)-$tcl_platform(os)-$tcl_platform(osVersion)]
if {![file exists $didi]} {
    file mkdir $didi
}
cd $didi
switch $tcl_platform(os) {
    Linux {
	exec g77 -c [file join $ici power.f]
	exec gcc -I/home/p10admin/prog/Tcl/include -DBUILD_power -DUSE_TCL_STUBS -c [file join $ici tclpower.c]
	exec gcc -shared -o power.so tclpower.o power.o -L/home/p10admin/prog/Tcl/IntelLinux/lib -ltclstub8.4
    }
    SunOS {
	set err [catch {
	    exec f95 -KPIC -c [file join $ici power.f]
	    exec cc -KPIC -I/home/p10admin/prog/Tcl/include -DBUILD_power -DUSE_TCL_STUBS -c [file join $ici tclpower.c]
	    exec f95 -V -G -ztext -z defs  -o power.so tclpower.o power.o -L/home/p10admin/prog/Tcl/SparcSolaris/lib -ltclstub8.4 -lm
	} blabla]
	if {$err == 0} {
	    puts stderr "OK 0"
	    puts stderr $blabla
	} elseif {$errorCode == "NONE"} {
	    puts stderr "OK NONE"
	    puts stderr $blabla
	} else {
	    puts stderr $blabla
	    exit 1
	}
    }
}
    cd $ici
    load [file join $didi power.so] Power
puts "3^3 = [power 3]"
