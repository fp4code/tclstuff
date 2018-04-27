package provide lakeshore 0.1

namespace eval lakeshore {}

set lakeshore::dt470_t [list]
set lakeshore::dt470_v [list]

foreach {t v} {
1.40	1.69812
1.60	1.69521
1.80	1.69177
2.00	1.68786
2.20	1.68352
2.40	1.67880
2.60	1.67376
2.80	1.66845
3.00	1.66292
3.20	1.65721
3.40	1.65134
3.60	1.64529
3.80	1.63905
4.00	1.63263
4.20	1.62602
4.40	1.61920
4.60	1.61220
4.80	1.60506
5.00	1.59782
5.50	1.57928
6.00	1.56027
6.50	1.54097
7.00	1.52166
7.50	1.50272
8.00	1.48443
8.50	1.46700
9.00	1.45048
9.50	1.43488
10.0	1.42013
10.5	1.40615
11.0	1.39287
11.5	1.38021
12.0	1.36809
12.5	1.35647
13.0	1.34530
13.5	1.33453
14.0	1.32412
14.5	1.31403
15.0	1.30422
15.5	1.29464
16.0	1.28527
16.5	1.27607
17.0	1.26702
17.5	1.25810
18.0	1.24928
18.5	1.24053
19.0	1.23184
19.5	1.22314
20.0	1.21440
21.0	1.19645
22.0	1.17705
23.0	1.15558
24.0	1.13598
25.0	1.12463
26.0	1.11896
27.0	1.11517
28.0	1.11212
29.0	1.10945
30.0	1.10702
32.0	1.10263
34.0	1.09864
36.0	1.09490
38.0	1.09131
40.0	1.08781
42.0	1.08436
44.0	1.08093
46.0	1.07748
48.0	1.07402
50.0	1.07053
52.0	1.06700
54.0	1.06346
56.0	1.05988
58.0	1.05629
60.0	1.05267
65.0	1.04353
70.0	1.03425
75.0	1.02482
77.35	1.02032
80.0	1.01525
85.0	1.00552
90.0	0.99565
95.0	0.98564
100.0	0.97550
110.0	0.95487
120.0	0.93383
130.0	0.91243
140.0	0.89072
150.0	0.86873
160.0	0.84650
170.0	0.82404
180.0	0.80138
190.0	0.77855
200.0	0.75554
210.0	0.73238
220.0	0.70908
230.0	0.68564
240.0	0.66208
250.0	0.63841
260.0	0.61465
270.0	0.59080
273.15	0.58327
280.0	0.56690
290.0	0.54294
300.0	0.51892
305.0	0.50688
310.0	0.49484
320.0	0.47069
330.0	0.44647
340.0	0.42221
350.0	0.39783
360.0	0.37337
370.0	0.34881
380.0	0.32416
390.0	0.29941
400.0	0.27456
410.0	0.24963
420.0	0.22463
430.0	0.19961
440.0	0.17464
450.0	0.14985
460.0	0.12547
470.0	0.10191
475.0	0.09062
} {
    lappend lakeshore::dt470_t [expr {$t}]
    lappend lakeshore::dt470_v [expr {$v}]
}

unset t v
set lakeshore::dt470_tmin [lindex $lakeshore::dt470_t 0]
set lakeshore::dt470_tmax [lindex $lakeshore::dt470_t end]
set lakeshore::dt470_vmin [lindex $lakeshore::dt470_v 0]
set lakeshore::dt470_vmax [lindex $lakeshore::dt470_v end]
set lakeshore::dt470_imax [expr {[llength $lakeshore::dt470_v] - 1}]

proc lakeshore::interpole {x1 x2 y1 y2 x} {
    if {abs ($x - $x1) < abs ($x - $x2)} {
	return [expr {$y1 + ($x - $x1)*(($y2 - $y1)/($x2 - $x1))}]
    } else {
	return [expr {$y2 + ($x - $x2)*(($y1 - $y2)/($x1 - $x2))}]
    }
}

set lakeshore::dt470_last_i_of_t [expr {$lakeshore::dt470_imax / 2}]
set lakeshore::dt470_last_i_of_v [expr {$lakeshore::dt470_imax / 2}]

proc lakeshore::dt470_v_of_t {t} {
    if {$t < [lindex $lakeshore::dt470_t $lakeshore::dt470_last_i_of_t]} {
	if {$t < $lakeshore::dt470_tmin} {
	    error "t too low (min = $lakeshore::dt470_tmin)"
	}
	set i [expr {$lakeshore::dt470_last_i_of_t - 1}]
	while {$t < [lindex $lakeshore::dt470_t $i]} {incr i -1}
	set lakeshore::dt470_last_i_of_t $i
	return [lakeshore::interpole \
		[lindex $lakeshore::dt470_t $i] [lindex $lakeshore::dt470_t [expr {$i + 1}]] \
		[lindex $lakeshore::dt470_v $i] [lindex $lakeshore::dt470_v [expr {$i + 1}]] \
		$t]
    } elseif {$t > [lindex $lakeshore::dt470_t $lakeshore::dt470_last_i_of_t]} {
	if {$t > $lakeshore::dt470_tmax} {
	    error "t too  high (max = $lakeshore::dt470_tmax)"
	}
	set i [expr {$lakeshore::dt470_last_i_of_t + 1}]
	while {$t > [lindex $lakeshore::dt470_t $i]} {incr i}
	set lakeshore::dt470_last_i_of_t $i
	return [lakeshore::interpole \
		[lindex $lakeshore::dt470_t $i] [lindex $lakeshore::dt470_t [expr {$i + 1}]] \
		[lindex $lakeshore::dt470_v $i] [lindex $lakeshore::dt470_v [expr {$i + 1}]] \
		$t]
    } else {
	return [lindex $lakeshore::dt470_v $lakeshore::dt470_last_i_of_t]
    }
}

lakeshore::dt470_v_of_t 300