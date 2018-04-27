#!/bin/sh
# the next line restarts using expect \
exec expect "$0" "$@"

# set LOG [open "/tmp/$env(USER).log" a]
# puts $LOG [concat $argv0 $argv]
# puts $LOG "LD_LIBRARY_PATH=$env(LD_LIBRARY_PATH)"
# close $LOG

if {$argc < 1} {
    send_user "ERREUR : la syntaxe est \"$argv0 nom_ip \[fichiers...\]\"\n"
    exit 1
}

if {$argc == 1} {

    set tmp /tmp/papif.$env(USER)
    # cree les parents
    if {[catch {file mkdir $tmp} err]} {
	puts stdout $err
    }
    set tmpf $tmp/[clock format [clock seconds] -format %Y.%m.%d.%H.%M.%S].stdin
    if {[file exists $tmpf]} {
        set iv 1
        while {[file exists ${tmpf}#$iv]} {
            incr iv
        }
        set tmpf ${tmpf}#$iv
    }
    fconfigure stdin -translation binary
    set standardIn [read -nonewline stdin]
    
    set magic [string range $standardIn 0 1]
    if {$magic == "%!"} {
        set tmpChannel [open $tmpf w+]
        puts $tmpChannel $standardIn
        close $tmpChannel
        lappend tmpfic $tmpf
    } else {
        puts stderr "stdin non PostScript"
	exit 1
    }
    set fichiers [list $tmpfic]
} else {
    set  fichiers [lrange $argv 1 end]
}

set machine [lindex $argv 0]

log_user 0
set timeout 20

set RC "\r\n"
set PROMPT "ftp> "

proc abort {args} {
    if {$args == "timeout"} {
	send_user -- "Timeout !\n"
	exit 22
    }
    global expect_out
    send_user "ERREUR"
    catch {parray expect_out}
    exit 22
}

proc expectStrict {glob} {
    expect {
	$glob {}
	timeout {
	    abort timeout
	}
	default abort
    }
}

proc expectStrictRE {exp args} {
    global expect_out
    expect {
	-re $exp {}
	default {
	    puts stderr [list ATTENDU $exp]
	    puts [list -> [info exists expect_out]]
	    abort
	}
    }
    set i 0
    foreach aName $args {
	incr i
	upvar $aName a
	set a $expect_out($i,string)
    }
# parray expect_out
}

proc sendEchoed {commande} {
    global RC
    send -- "$commande\r"
    expectStrict "$commande$RC"
}

proc aCommand {commande} {
    global PROMPT
    expectStrictRE ".*$PROMPT"
    sendEchoed $commande
}

proc transfert {commande fichier} {
    global RC expect_out
    set lus 0
    aCommand "$commande $fichier"
    expectStrictRE "200 .*${RC}"
    # send_user -- "200 "
    expectStrictRE "150 .*${RC}"
    # send_user -- "150 "
    set encore 1
    while {$encore} {
	expect {
            -re "(#+)" {
                send_user -- "#"
            }
	    -re "226 .*${RC}(.*)${RC}" {
		set encore 0
                set vitesse $expect_out(1,string)
		send_user -- "\n$vitesse"
	    }
	    timeout {
		abort timeout
	    }
	}
    }
    send_user --  " OK\n"
}

proc getMagic {file} {
    set f [open $file r]
    set magic [read $f 2]
    close $f
    return $magic
}

send_user "    Connection à \"$machine\" : "
spawn /home/p10admin/bin_gnu/ftp $machine

expect {
    -re "^Connected.*$RC" {}
    "Unknown host" {
	puts stderr "L'imprimante n'existe pas"
	exit
    }
    timeout {
	puts stderr ERREUR!!!
	abort
    }
}
expectStrictRE "^220 .*$RC"
expectStrictRE "^Name .*: "
sendEchoed {}
expectStrictRE "230 .*\$"
send_user "OK\n"
aCommand hash

foreach f $fichiers {
    send_user "    Transfert de \"$f\" :\n"
    if {[catch {getMagic $f} magic]} {
        send_user "        ERREUR : $magic\n"
        continue
    }
    if {$magic != "%!"} {
        send_user "        ERREUR : Fichier non PostScript\n"
        continue
    }
    transfert put $f
}

send_user -- "    Fin de la Session : "
aCommand quit
expectStrictRE "221 .*$RC"
send_user -- "OK\n"
exit 0

set rien {

    

    spawn ftp $argv
    foreach g [info globals] {
	puts stderr "--- $g"
	if {[array exists $g]} {
	    parray $g
	} else {
	    puts stderr [set $g]
	}
    }
}