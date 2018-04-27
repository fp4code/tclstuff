package provide minihelp 1.0

set HELP(aide::ui_minihelp) {
    $vers est un widget (typiquement label) dont
    le contenu contiendra $help (typiquement une ligne)
    chaque fois que la souris passera sur de widget $de
}

namespace eval aide {
    variable MINIHELP
    namespace export ui_minihelp
    proc ui_minihelp {vers de help} {
        variable MINIHELP
        set MINIHELP($de) $help
        set MINIHELP(OUT$de) {}
        bind $de <Enter> "$vers configure -text \$aide::MINIHELP(%W)"
        bind $de <Leave> "$vers configure -text \$aide::MINIHELP(OUT%W)"
    }
}
