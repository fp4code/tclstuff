#!/bin/sh
# \
exec /prog/Tcl/bin/expect "$0" ${1+"$@"}

set TELNET_LOGIN_SLEEP 0.1
set PERIOD [expr {4*1000}]
set FICHIER /home/fab/Z/aliases

if {$argc == 1} {
    set lp [split $argv /]
    set login [lindex $lp 0]
    set passwd [lindex $lp 1]
} else {
    exp_send_user "login: "
    expect_user -re "(.*)\n"
    set login $expect_out(1,string)
    exp_stty -echo
    exp_send_user "passwd: "
    expect_user -re "(.*)\n"
    exp_send_user "\n"
    set passwd $expect_out(1,string)
    exp_stty echo
}

proc get_aliases {} {
    global PERIOD TELNET_LOGIN_SLEEP login passwd FICHIER
    
    exp_spawn -noecho telnet berta
    
    expect {
	-re "login:.*" {
	    exp_sleep $TELNET_LOGIN_SLEEP ;# indispensable !?
	    exp_send $login\r
	}
	timeout {
	    puts stderr "NO LOGIN PROMPT !"
	}
    }
    
    expect {
	-gl "Password*" {
	    exp_sleep $TELNET_LOGIN_SLEEP ;# indispensable !?
	    exp_send $passwd\r
	}
	timeout {
	    puts stderr "NO PASSWORD PROMPT !"
	}
    }
    
    expect {
	-gl {$ } {
	    exp_send "md5sum /etc/aliases; cat /etc/aliases; echo END.END.END\r" 
	}
	timeout {
	    puts stderr "NO \$ PROMPT !"
	    puts stderr $expect_out(buffer)
	}
    }
    
    expect END.END.END\r\n {}

    set lignes [list]
    expect {
	-re {([^\r\n]*)\r\n} {
	    set ligne $expect_out(1,string)
	    if {$ligne != "END.END.END"} {
		lappend lignes $ligne
		exp_continue
	    }
	}
	eof {set tout $expect_out(buffer)}
	timeout {
	    puts stderr "FINIT MAL"
	    puts stderr $expect_out(buffer)
	}
    }
    
    
    exp_close
    exp_wait ;# indispensable pour ne pas avoir de <defunct>

    set f [open $FICHIER w]

    foreach l [lrange $lignes 1 end] {
	puts $f $l
    }
    close $f

    set rep [exec md5sum $FICHIER]

    if {[lindex $rep 0] == [lindex [lindex $lignes 0] 0]} {
	puts OK
    } else {
	puts "ERREUR DE TRANSFERT"
    }

    after $PERIOD get_aliases
}

get_aliases

set dummy {}
vwait dummy


