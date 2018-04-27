# Un ensemble de commandes qui doivent être interprétées
# au préalable par chaque interpréteur


set c1 {
SHELL = /bin/sh

CC=cc
FC=f77 -v
CFLAGS = -g -Kpic -xCC
FFLAGS = -g -Kpic -U -u -C

LIBNAME = lib${LIB}.so

PREFIX = /home/fidev/lib-sparc-solaris

CPPFLAGS+= -DSPECIAL_COMPLEX_RETURN

# M77 pour complexes ?

FLIBS = -lF77 -lsunmath -lM77

X11LIBS = -L/usr/openwin/lib -R/usr/openwin/lib -lX11

}

# création de fichiers objet
# $fsrc = fichier source
# $fdst = fichier objet à créer
# moreRecentVar = nom d'une variable à mettre à jour
# variable INCLUDES = liste d'arguments

proc ::timak::filejoin {args} {
    set clean [list]
    foreach e $args {
	if {$e == "."} {
	    continue
	} elseif {$e == ".."} {
	    if {$clean == {} || [lindex $clean end] == ".."} {
		lappend clean $e
	    } else {
		set clean [lrange $clean 0 end-1]
	    }
	} else {
	    lappend clean $e
	}
    }
    return [eval file join $clean]
}

proc timak::createSharedObjFromFortran {fsrc fdst moreRecentVar} {
    variable EXEC
    set command [concat $EXEC(SharedObjFromFortran) [list $fsrc -o $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createObjFromFortran {fsrc fdst moreRecentVar} {
    variable EXEC
    set command [concat $EXEC(ObjFromFortran) [list $fsrc -o $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createSharedObjFromC {fsrc fdst moreRecentVar} {
    variable DEBUG
    variable INCLUDES
    variable EXEC
    if {$DEBUG(call)} {
	puts stderr "timak::createSharedObjFromC $fsrc $fdst $moreRecentVar"
    }
    set src [file dirname $fsrc]
    set command [concat $EXEC(SharedObjFromC) [timak::includes $src $INCLUDES] [list $fsrc] -o [list $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createObjFromC {fsrc fdst moreRecentVar} {
    variable INCLUDES
    variable EXEC
    set src [file dirname $fsrc]
    set command [concat $EXEC(ObjFromC) [timak::includes $src $INCLUDES] [list $fsrc] -o [list $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

set HELP(timak::createSomething) {
    28 avril 2000
    La compilation des objets pour les bibliothèques les programmes
    est actuellement faite "sur place".
    On peut imaginer étendre le système de dépendances
    pour permettre une compilation en parallèle sur plusieurs machines
}

proc timak::createSomething {fsrc fdst moreRecentVar command} {
    variable INCLUDES
    variable DEBUG
    global errorCode errorInfo

    upvar $moreRecentVar moreRecent
    if {$DEBUG(call)} {
	puts stderr [list timak::createSomething $fsrc $fdst &$moreRecent $command]
    }

    if {![file exists $fsrc]} {
	return -code error "inexistent source file: \"$fsrc\"" 
    }
    if {$DEBUG(call)} {
        puts stderr "[file exists $fdst] = file exists $fdst"
        if {[file exists $fdst]} {
            puts stderr "[file mtime $fsrc] = file mtime $fsrc"
            puts stderr "[file mtime $fdst] = file mtime $fdst"
            puts stderr "$moreRecent = moreRecent"
        }
    }

    if {[file exists $fdst] && [file mtime $fsrc] <= [file mtime $fdst]} {
	if {$moreRecent < [file mtime $fdst]} {
	    set moreRecent [file mtime $fdst]
	    if {$DEBUG(depend)} {
		puts stderr "createSomething [file mtime $fdst] [pwd]/$fdst"
	    }
	}
	return 0
    } 
    puts stderr [list command = $command]
    set err [catch {eval exec $command} blabla]
    if {$err == 0} {
        puts stderr "OK 0"
	if {$moreRecent < [file mtime $fdst]} {
	    set moreRecent [file mtime $fdst]
	}
        return 0
    }
    set savedErrorCode $errorCode ;# est-ce utile ?

    if {$savedErrorCode == "NONE"} {
        puts stderr "OK NONE"
	if {$moreRecent < [file mtime $fdst]} {
	    set moreRecent [file mtime $fdst]
	}
	return 0
    }
    if {[file exists $fdst]} {
	file delete $fdst
    }
    if {[lindex $savedErrorCode 0] == "CHILDSTATUS"} {
	puts stderr $blabla
	return -code error "*** compilation error(s)"
    } else {
	puts stderr $blabla
	return -code error "*** errorCode -> $savedErrorCode"
    }
}

set HELP(::timak::create) {
    création d'un programme ou d'une bibliothèque
}

proc ::timak::create {progOrLib name} {
    # tableaux des sources et des bibliothèques
    variable SOURCES
    variable LIBS
    variable STOP
    variable DEBUG
    variable EXEC
    
    global errorCode
    
    set static [expr {[info exists EXEC(staticLib)] && $EXEC(staticLib)}]

    set fortranFiles 0
    set CFiles 0
    set errors 0
    set pwd [pwd]
    if {$DEBUG(call)} {
        puts stderr $pwd 
    }
    set objs [list]
    set moreRecent 0
    set objDest [timak::destFromSource obj $pwd]
    if {$DEBUG(call)} {
	puts stderr [list timak::create $progOrLib $name]
    }    

    switch $progOrLib {
	"program" {
	    set fromFortran timak::createObjFromFortran
	    set fromC timak::createObjFromC
	    set finalName $name
	    set finalDest [timak::destFromSource bin $pwd]
	    set specialLinkOptions $EXEC(programSpecialOptions)
	}
	"lib" {
            if {$static} {
                set fromFortran timak::createObjFromFortran
                set fromC timak::createObjFromC
                set finalName ${name}.a
                set finalDest [timak::destFromSource lib $pwd]                
            } else {
                set fromFortran timak::createSharedObjFromFortran
                set fromC timak::createSharedObjFromC
                set finalName ${name}.so
                set finalDest [timak::destFromSource lib $pwd]
                set specialLinkOptions $EXEC(sharedLibSpecialOptions)
            }
        }
	default {
	    return -code error "*** timak::createProgramOrLib: \"$progOrLib\" should be \"program\" or \"lib\""
	}
    }
    
    cd $objDest
    set realDest [pwd]
    
    foreach f [set SOURCES($name)] {
	set type [timak::getTypeOfFile $f]
	set obj [file rootname [file tail $f]].o
	lappend objs $obj
	switch $type {
	    "fortran" {
		set err [catch {$fromFortran $pwd/$f $obj moreRecent} message]
		if {!$err} {
		    incr fortranFiles
		} else {
                    puts stderr "ERREUR MAKING fortran \"$obj\": $message" 
                }
	    }
	    "C" {
		set err [catch {$fromC $pwd/$f $obj moreRecent} message]
		if {!$err} {
		    incr CFiles
		} else {
                    puts stderr "ERREUR MAKING C \"$obj\": $message"
                }
	    }
	    default {
		set message  "*** timak::createProgramOrLib unknown type \"$type\""
	    }
	}
	if {$err} {
	    if {$STOP(createObj)} {
                global errorInfo
		return -code error "\nerrorInfo=\n$errorInfo\n$message=\n$message"
	    } 
	    puts stderr "ERROR: $message"
	    incr errors
	}
    }


    # on retourne au plus aux sources, mais on se rappelle le lieu de compilation
    cd $pwd
    
    if {$errors != 0} {
	return -code "*** incomplete compilation"
    }


    if {$static && $progOrLib == "lib"} {
        set linker "ar cr"
    } else {    
        if {$fortranFiles != 0} {
            set linker [concat $EXEC(linkerFortran) $specialLinkOptions -o]
        } else {
            set linker [concat $EXEC(linkerC) $specialLinkOptions -o]
        }
    }

    if {[info exists LIBS($name)]} {
	set libs [timak::libs $LIBS($name) $finalDest]
    } else {
	set libs {}
    }
    
    if {$static && $progOrLib == "lib"} {
        set command [concat $linker [list $finalName] $objs]
    } else {
        set command [concat $linker [list $finalName] $objs $libs]
    }

    puts stderr "*** [list cd $realDest] ***"
    cd $realDest

    if {[file exists $finalName]} {
	set fnmt [file mtime $finalName]
	if {$DEBUG(depend)} {
	    puts stderr "create          $fnmt [file join $realDest $finalName]"
            puts stderr "moreRecent =    $moreRecent"
	}	    
	if {$moreRecent <= $fnmt} {
	    cd $pwd
	    return
	}
    } else {
	if {$DEBUG(depend)} {
	    puts stderr "inexistent [file join $realDest $finalName]"
	}
    }
    
    puts stderr $command
    set err [catch {eval exec $command} blabla]
    puts stderr $blabla
    set savedErrorCode $errorCode ;# est-ce utile ?

    if {!$err && $static && $progOrLib == "lib"} {
        set command [list ranlib $finalName]
        puts stderr $command
        set err [catch {eval exec $command} blabla2]
        puts stderr $blabla2
        lappend savedErrorCode $errorCode ;# est-ce utile ?        
    }

    cd $pwd

    if {$err == 0 || $savedErrorCode == "NONE"} {
	puts stderr "OK, $finalName is made in $realDest"
	return
    }
    
    if {[file exists [file join $realDest $finalName]]} {
	file delete [file join $realDest $finalName]
    }
    if {[lindex $savedErrorCode 0] == "CHILDSTATUS"} {
	puts stderr $blabla
	return -code error "*** link error(s)"
    } else {
	puts stderr $blabla
	return -code error "*** errorCode -> \"$savedErrorCode\""
    }
}

proc timak::includes {src list} {
    set elems [list]
    foreach elem $list {
	lappend elems [timak::include $src $elem]
    }
    return $elems
}

proc timak::include {src elem} {
    variable DEBUG
    if {$DEBUG(call)} {
	puts stderr "timak::include $src $elem"
    }
    set path [file split $elem]
    set pathtype [file pathtype [lindex $path 0]]
    switch $pathtype {
	"absolute" {
	    set path [eval file join $path]
	}
	"relative" {
	    if {$path == "."} {
		set path $src
	    } else {
		set path [eval ::timak::filejoin [file split $src] $path]
	    }
	}
	default {
	    return -code error "*** ERROR: Unknown path type \"$pathtype\""
	}
    }
    return "-I$path"
}

proc timak::libs {liblist dest} {
# puts stderr "timak::libs $liblist $dest"
    set libs [list]
    foreach lib $liblist {
	eval lappend libs [timak::lib $lib $dest]
    }
    return $libs
}

proc timak::lib {lib dest} {
    variable EXEC
    global errorCode
    set libpath [file split $lib]
    if {[llength $libpath] > 1} {
	set libname [lindex $libpath end]
	set libpath [lrange $libpath 0 end-1]
    } else {
	set libname $libpath
	set libpath {}
    }
    if {![string match lib* $libname]} {
	return -code error "*** ERROR: \"$libname\" has not \"lib...\" form"
    }
    set liblib -l[string range $libname 3 end]
    if {$libpath == {}} {
	return $liblib
    } else {
	set pathtype [file pathtype [lindex $libpath 0]]
	switch $pathtype {
	    "absolute" {
		set path [eval file join $libpath]
	    }
	    "relative" {
		if {$libpath == "."} {
		    set path $dest
		} else {
		    set path [eval ::timak::filejoin [file split $dest] $libpath]
		}
	    }
	    default {
		return -code error "*** ERROR: Unknown path type \"$pathtype\""
	    }
	}
# puts stderr "return : path = $path, liblib = $liblib"
	return [concat [timak::libPaths $path] [list $liblib]]
    }
}


proc timak::getTypeOfFile {f} {
    set extension [file extension $f]
    switch $extension {
	".f" {return fortran}
	".c" {return C}
	default {return -code error "*** timak::getTypeOfFile unknown extension: \"$extension\""}
    }
}

namespace eval ::timak {
    variable PWD [pwd]
    variable INCLUDES ""
    variable LIBS
    ###### pour diagnostiquer les dépendances circulaires

    variable MARKIN
    variable MARKOUT

    variable STOP
    set STOP(compile) 1
    set STOP(createObj) 1
    variable DEBUG
    set DEBUG(depend) 1
    set DEBUG(call) 0  
    set DEBUG(general) 0  
}
