#! /usr/local/bin/tclsh

# gestion des erreurs

set tutorial {
    Génération d'une erreur:

    error $message
    error $message $error_info
    error $message {} $error_code
    error $message $error_info $error_code
    
    Problement similaire à

    return -code error $message
    return -code error -errorinfo $error_info $message
    return -code error                        -errorcode $error_code $message
    return -code error -errorinfo $error_info -errorcode $error_code $message

    Les données transmises, $message $error_info et $error_code
    sont récupérées par

    catch {la_commande ...} message
    set error_code $errorCode
    set error_info $errorInfo


    La commande "exec" renvoit une erreur dès que stderr est écrite, ou que
    le code de retour n'est pas 0

    Si l'on souhaite que l'écriture sur stderr ne génère pas une erreur, on peut
    rediriger la commande par "exec ... 2>@ stdout"

    Dans tous les cas, errorCode contiendra "CHILDSTATUS numero_du_PID numero_Exit"
}

proc err1 {} {
    # error message {} errorCode
    return -code error -errorcode errorCode "C'est une erreur"
}

proc err2 {} {
    err1
    puts post1
}

proc err3 {} {
    err2
    puts post2
}

set err [catch err3 blabla]
puts "err       = $err"
puts "blabla    = $blabla"
puts "errorCode = $errorCode"
puts "errorInfo = $errorInfo"
 
set err [catch {exec printOnStderr.tcl} bubu]
puts $bubu

set err [catch {exec printOnStderr.tcl > out 2> err} bubu]
