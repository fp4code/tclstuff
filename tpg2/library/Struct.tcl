snit::type ::tpg::Struct {
    typevariable enCours
    typevariable CREES

    option -rn_s [list]
    option -id_b [list]

    constructor {args} {
	puts stderr "self=$self"
	set enCours $self
	if {[$self cget -rn_s] != {} || [$self cget -id_b] != {}} {
            error "La structure \"$sname\" existe et n'est pas vierge"
        } else {
            puts stderr "vide"
        }
	$self configurelist $args
    }

    destructor {
	if {[$self cget -rn_s] != {} || [$self cget -id_b] != {}} {
            error "La structure \"$self\" existe et n'est pas vierge"
        } else {
            puts stderr "OK, vide"
        }
    }
}
