#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

# Revu le 31 décembre 2002 (FP)
# 16 février 2003 (FP) nom récupéré de FROM

# Doit être lancé depuis le répertoire contenant ce fichier

set sendmail(smtphost) zenobe.lpn.cnrs.fr
set sendmail(from) fabrice.pardo@free.fr
set sendmail(to) fabrice.pardo@lpn.cnrs.fr

proc echange {message} {
    global sockid
    puts $sockid $message
    flush $sockid
    set result [gets $sockid]
    puts stderr "> \"$message\""
    puts stderr "< \"$result\""
    return $result
}

set sockid [socket $sendmail(smtphost) 25]
echange "HELO $sendmail(smtphost)"
set result [echange "MAIL From:<$sendmail(from)>"]
set R {^250 zenobe.lpn.cnrs.fr Hello rameau-1-81-57-198-61.fbx.proxad.net}
if {![regexp $R $result tout moi]} {
    puts stderr "\"$result\" is not \"$R\""
    exit 1
}
set moi rameau-1-81-57-198-61.fbx.proxad.net
echange "RCPT To:<$sendmail(to)>"
echange "DATA "
echange "From: <$sendmail(from)>"
echange "Subject: [list maison-lpn $moi muzo 30]\n."
echange "QUIT"
close $sockid
exit 0
