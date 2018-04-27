# de http://dbforums.com/arch/136/2002/5/351957

package require tdom

dom createNodeCmd elementNode head
dom createNodeCmd elementNode meta
dom createNodeCmd elementNode title
dom createNodeCmd elementNode body
dom createNodeCmd elementNode a
dom createNodeCmd elementNode br
dom createNodeCmd textNode t

set doc [dom createDocument html]

set racine [$doc documentElement]
set entete [$doc documentElement]

$entete appendFromScript {
    meta http-equiv "content-type" content "text/html; charset=ISO-8859-1"
    title {t yoko}
}

$racine appendChild $entete

$racine appendFromScript {
    body {
	a href http://www.teoma.com {t Teoma}
	t " | "
	a href http://www.google.com {t Google}
	br ; br
	a href cgi-bin/fom {t Faq-O-Matic}
	t " rassemble l'ancien contenu de http://yoko.lpn.prive."
	t "Et les pages sont maintenant éditables en ligne !"
    }
}

fconfigure stdout -encoding iso8859-1
puts [$racine asHTML]
