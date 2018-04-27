set INFO(theoremes) {
    Soit une liste L0 de nombres premiers distincts p1 p2 ... pN
    Soit leur produit P0 = p1*p2*...*pN
    Soit la liste LP des nombres premiers inférieurs à P0 
    Soit LCi la liste LP dont on a exclu les élents de L0
    Soit LC la liste des produits des éléments de LCi, inférieurs à P0
    Pour tout nombre premier inférieur à P0^2, 

}

set INFO(erax) {
  incorpore dans l'ensemble aName
  les multiples de $x non superieurs a $max
} 
proc erax {aName max x} {
  upvar $aName a
  set i 2
  set np [expr {$x*2}]
  while {$np <= $max} {
    set a($np) {}
    incr i
    set np [expr {$x*$i}] 
  }
}

set INFO(era) {
  retourne la liste des nombres premiers nonsuperieurs a $max
  1 debute la liste
}
proc era {max} {
  set prems [list 1]
  for {set i 2} {$i <= $max} {incr i} {
    if {![info exists a($i)]} {
      lappend prems $i
      erax a $max $i
    }
  }
  return $prems
}

set INFO(complement) {
  retourne la liste obtenue en supprimant
  de $l les elements de $la
}
proc complement {la l} {
  foreach x $la {
    set a($x) {}
  }
  set nl [list]
  foreach x $l {
    if {![info exists a($x)]} {
      lappend nl $x
    }
  }
  return $nl
}

set INFO(prodlist) {
  retourne le produit des elements de $l
}
proc prodlist {l} {
  set p 1
  foreach x $l {
    set p [expr {$p*$x}]
  }
  return $p
}

proc LiCo {P0 LC candidat} {
  set m [expr {$candidat % $P0}]
  set li [expr {($candidat - $m) / $P0}]
  set co [lsearch $LC $m]
  if {$co < 0} {
    return -code error "Mauvais candidat : $candidat"
  }
  return [list $li $co]
}

proc candidatPremier {P0 LC li co} {
  return [expr {[lindex $LC $co] + $li * $P0}]
}

proc s {} "source [info script]"
set INFO(eraf) {
  retourne la liste des nombres premiers
  construits a partir des quelques elements de $L0
}
proc eraf {L0} {
  set P0 [prodlist $L0]
  puts "P0 = $P0"
  set LP [era $P0]
  set LC [complement $L0 $LP]
  puts "liste era = $LC"
  set LC [expandLC $P0 $LC]
  puts "liste LC = $LC"
  set lLC [llength $LC]
  set liMax [lindex $LC end]
  for {set li 0} {$li < $liMax} {incr li} {
    for {set co 0} {$co < $lLC} {incr co} {
      set nnpp($li,$co) {}
    }
  }
  puts "ini done"
  for {set i 1} {$i < $lLC} {incr i} {
    set pi [lindex $LC $i]
    puts $pi
    for {set j 0} {$j< $lLC} {incr j} {
      set pj [lindex $LC $j]
      set candidat [expr {$pi * $pj}]
      foreach {li co} [LiCo $P0 $LC $candidat] break
      while {$li < $liMax} {
        lappend nnpp($li,$co) $pi
        incr li $pi
      }
    }  
  }
  set LPn $LP
  for {set co 0} {$co < $lLC} {incr co} {
    set coGood($co) 0
  }
  for {set li 1} {$li < $liMax} {incr li} {
    puts $li
    for {set co 0} {$co < $lLC} {incr co} {
      if {$nnpp($li,$co) == {}} {
        lappend LPn [candidatPremier $P0 $LC $li $co]
        incr coGood($co)
      }
    }
  }
  puts "rendement = [llength $LPn]/[expr {$liMax*$lLC}] = [expr {double([llength $LPn])/double($liMax*$lLC)}]"
  puts "gain = [expr {$P0*$P0}]/[expr {$liMax*$lLC}] = [expr {pow($P0,2)/double($liMax*$lLC)}]"
  parray coGood
  return $LPn
}

set INFO(expandLC) {
  retourne la liste $LC elargie aux produits
  inferieurs ou egaux a $P0
}
proc expandLC {P0 LC} {
  set L [list 1]
  foreach x [lrange $LC 1 end] {
    foreach e $L {
      set ne [expr {$x * $e}]
      while {$ne < $P0} {
        lappend L $ne
        set ne [expr {$x * $ne}]
      }
    }
  }
  return [lsort -integer $L]
}

proc np {max} {
  puts [llength [era $max]]
}

np 1000
set L0 {2 3 5 7}
set p [eraf $L0] ; llength $p

