package provide superWidgetsPlusMoins 1.0

namespace eval l2mIntControl {

    

    proc create {w var args} {
        frame $w -class l2mIntControl
    
        entry $w.e -textvariable $var
     
        button $w.bu -image [image create bitmap -data {
            #define up_width 10
            #define up_height 6
            static char up_bits[] = {
               0x30, 0x00, 0x48, 0x00,
               0x84, 0x00, 0x02, 0x01,
               0x01, 0x02, 0xff, 0x03};
            }]

        button $w.bd -image [image create bitmap -data {
            #define down_width 10
            #define down_height 6
            static char down_bits[] = {
               0xff, 0x03, 0x01, 0x02,
               0x02, 0x01, 0x84, 0x00,
               0x48, 0x00, 0x30, 0x00};
            }]
        grid $w.e $w.bu
        grid   ^  $w.bd
        grid $w.e -sticky ns

    }
}

l2mIntControl::create .c titi
pack .c

