#!/bin/sh
# \
exec tclsh "$0" ${1+"$@@"}

#

# 2007-10-11 (FP)
# 2008-04-18 (FP) uid tolower, gecos -> displayname, continue on duplicate

package require ldap 1.2
#set SERVEUR ldap2.lpn.prive
set SERVEUR chiwana.lpn.prive
set h [ldap::connect $SERVEUR]
ldap::bind $h
set p {ou=People,dc=lpn,dc=prive}
catch {unset PASSWD}
foreach initial {a b c d e f g h i j k l m n o p q r s t u v w x y z} {
  set r [ldap::search $h $p "uid=${initial}*" {}]
  foreach e $r {
    catch {unset E}
    array set E [lindex $e 1]
    set uid [string tolower $E(uid)]
    if {[string match {{*$}} $uid]} continue
    foreach v {uidNumber gidNumber displayName homeDirectory loginShell} {
      if {[info exists E($v)]} {set $v $E($v)} else {set $v __NONE__}
    }
    if {[string index $displayName 0] == "\{"} {set displayName [string range $displayName 1 end]}
    if {[string index $displayName end] == "\}"} {set displayName [string range $displayName 0 end-1]}
    if {[info exists  PASSWD($uidNumber)]} {
      puts stderr "Duplicate uid $uidNumber for $uid, already as $PASSWD($uidNumber)"
      continue
    }
    set PASSWD($uidNumber) "$uid:*:$uidNumber:$gidNumber:$displayName:$homeDirectory:$loginShell"
  }
}
foreach u [lsort -integer [array names PASSWD]] {
  puts $PASSWD($u)
}
