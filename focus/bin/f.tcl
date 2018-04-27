#!/usr/bin/wish8.5

entry .e
pack .e
.e insert 0 12345

bind .e <KeyPress> {puts stderr Press}
bind .e <FocusIn> {puts stderr In}
bind .e <FocusOut> {puts stderr Out}




