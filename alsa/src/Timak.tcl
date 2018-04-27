set INCLUDES [list $TCLINCLUDEDIR]

set SOURCES(essai) {essai.c}
set LIBS(essai) {libasound}
set SOURCES(latency) {latency.c}
set LIBS(latency) {libasound}
set SOURCES(pcm) {pcm.c}
set LIBS(pcm) {libasound}

do -create program pcm
do -create program essai
# do -create program latency
