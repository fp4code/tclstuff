# de http://dbforums.com/arch/136/2002/5/351957

package require tdom

dom createNodeCmd elementNode foo
dom createNodeCmd elementNode bar
dom createNodeCmd textNode t

set doc [dom createDocument racine]

set racVar [$doc documentElement]

set heure [clock format  [clock seconds] -format "%H:%M:%S"] 

$racVar appendFromScript {
    foo un_attribut sa_valeur {t "Blabla accentué"}
    foo {
	bar {t "un autre texte"}
	bar un_autre_attribut $heure {t "heure = $heure"}
    }
}

puts [$racine asXML]
