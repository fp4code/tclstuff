
proc optim.old {fmax args} {
    global PMOD tid prefix MODELE

puts "REVOIR les \"'\""

    foreach varName [array names PMOD] {
	::scilab::exec $tid "P_$varName=$PMOD($varName)"
    }

    # attention: modifie la valeur des paramètres
    set vals ""
    set vars ""
    set pmin ""
    set pmax ""
    set ipara 0

    set first 1
    foreach {param norm min max} $args {
	puts [list $param $norm $min $max]
	incr ipara
	if {$first} {
	    set first 0
	} else {
	    append vars ","
	    append vals ";"
            append norms ";"
	    append pmin ";"
	    append pmax ";"
	}
	append vars "P_$param=p($ipara)*norm($ipara)"
	append vals "$PMOD($param)/norm($ipara)"
        append norms "$norm"
	append pmin "$min"
	append pmax "$max"
    }
    set deff "deff('e=G(p,z)','"
    append deff $vars
    append deff ",s11r=z(1),s11i=z(2),s12r=z(3),s12i=z(4),s21r=z(5),s21i=z(6),s22r=z(7),s22i=z(8),f=z(9)"
    append deff ",\[s11,s12,s21,s22\] = ${MODELE}(f)"
    append deff ",d11r=real(s11)-s11r,d11i=imag(s11)-s11i"
    append deff ",d12r=real(s12)-s12r,d12i=imag(s12)-s12i"
    append deff ",d21r=real(s21)-s21r,d21i=imag(s21)-s21i"
    append deff ",d22r=real(s22)-s22r,d22i=imag(s22)-s22i"
    append deff ",e=sqrt(d11r.*d11r + d11i.*d11i + d12r.*d12r + d12i.*d12i + d21r.*d21r + d21i.*d21i + d22r.*d22r + d22i.*d22i)"
    append deff {,disp([p;e;f]'')}
    append deff "')"

    puts $deff

    ::scilab::exec $tid $deff
    ::scilab::exec $tid "goods=find(${prefix}f<=$fmax)"
    ::scilab::exec $tid "Z=\[real(${prefix}s11(goods));imag(${prefix}s11(goods));real(${prefix}s12(goods));imag(${prefix}s12(goods));real(${prefix}s21(goods));imag(${prefix}s21(goods));real(${prefix}s22(goods));imag(${prefix}s22(goods));${prefix}f(goods)\];"

    # set fit "\[p,err\]=fit_dat(G,\[$vals\],Z,\[$pmin\],\[$pmax\])"
    set fit "\[p,err\]=datafit(2, G,Z,\[$vals\])"
    puts [list ::scilab::exec $tid $fit]
    ::scilab::exec $tid $fit
    # quand terminé, "g p" et "g err"
}

set HELP(optim) {
    12 mai 2000 (FP) rajout d'une norme
    Les s et les f sont des vecteurs ligne. Une "mesure" est un vecteur colonne
    

}

proc optim {fmax args} {
    global PMOD tid prefix MODELE

puts "REVOIR les \"'\""

    foreach varName [array names PMOD] {
	::scilab::exec $tid "P_$varName=$PMOD($varName)"
    }

    # attention: modifie la valeur des paramètres
    set vals ""
    set vars ""
    set pmin ""
    set pmax ""
    set ipara 0

    set first 1
    foreach {param norm} $args {
	puts [list $param $norm]
	incr ipara
	if {$first} {
	    set first 0
	} else {
	    append vars ","
	    append vals ";"
            append norms ";"
	}
	append vars "P_$param=p($ipara)*$norm"
	append vals [expr {$PMOD($param)/$norm}]
        append norms $norm
    }


    set deff "deff('e=G(p,z)','"
    append deff $vars
    append deff ",n=size(z),n=n(1,1)/9"
    append deff ",f=z(1:n).''"
    append deff ",s11r=z(n+1:2*n).''"
    append deff ",s11i=z(2*n+1:3*n).''"
    append deff ",s12r=z(3*n+1:4*n).''"
    append deff ",s12i=z(4*n+1:5*n).''"
    append deff ",s21r=z(5*n+1:6*n).''"
    append deff ",s21i=z(6*n+1:7*n).''"
    append deff ",s22r=z(7*n+1:8*n).''"
    append deff ",s22i=z(8*n+1:9*n).''"
    append deff ",\[s11,s12,s21,s22\] = ${MODELE}(f)"
    append deff ",d11r=real(s11)-s11r,d11i=imag(s11)-s11i"
    append deff ",d12r=real(s12)-s12r,d12i=imag(s12)-s12i"
    append deff ",d21r=real(s21)-s21r,d21i=imag(s21)-s21i"
    append deff ",d22r=real(s22)-s22r,d22i=imag(s22)-s22i"
    append deff ",e=sqrt(sum(d11r.*d11r + d11i.*d11i + d12r.*d12r + d12i.*d12i + d21r.*d21r + d21i.*d21i + d22r.*d22r + d22i.*d22i))"
    append deff {,disp([p;e]'')}
    append deff "')"

    puts $deff

    ::scilab::exec $tid $deff
    ::scilab::exec $tid "goods=find(${prefix}f<=$fmax)"
    ::scilab::exec $tid "Z=\[${prefix}f(goods).';real(${prefix}s11(goods)).';imag(${prefix}s11(goods)).';real(${prefix}s12(goods)).';imag(${prefix}s12(goods)).';real(${prefix}s21(goods)).';imag(${prefix}s21(goods)).';real(${prefix}s22(goods)).';imag(${prefix}s22(goods)).'\];"

    set fit "\[p,err\]=datafit(2,G,Z,\[$vals\])"
    puts [list ::scilab::exec $tid $fit]
    ::scilab::exec $tid $fit
    puts {quand terminé, "g p" et "g err"}
}
