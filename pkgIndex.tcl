# RCS: @(#) $Id: pkgIndex.tcl,v 1.21 2003/05/05 14:22:40 fab Exp $

# à raffiner : construction de la variable globale "fidev_libDir"

# global parce que la lecture avec env(TCLLIBDIR) est faite au travers de tclPkgUnknown
global FIDEV_TCL_ROOT FIDEV_SRC_ROOT FIDEV_LIB_ROOT fidev_tclDir tcl_platform

set FIDEV_TCL_ROOT [file dirname [info script]]
set FIDEV_SRC_ROOT [file dirname $FIDEV_TCL_ROOT]

puts "FIDEV_SRC_ROOT ===================== $FIDEV_SRC_ROOT"


set fidev_tclDir $FIDEV_TCL_ROOT

proc fidev_load {lib init} {
    global FIDEV_SRC_ROOT
    global FIDEV_LIB_ROOT

    set scriptdir [file dirname [info script]]
    puts stderr "script = $scriptdir, remove $FIDEV_SRC_ROOT ..."

    set suite [string range $scriptdir [expr {[string length $FIDEV_SRC_ROOT] +1 }] end]
    set suite [concat [file split $suite] [file split $lib[info sharedlibextension]]]
    puts stderr $suite

    set fulllib $FIDEV_LIB_ROOT

    puts stderr "fulllib = $fulllib"

    while {$suite != {}} {
        set next [lindex $suite 0]
        set suite [lrange $suite 1 end]
        puts stderr "next = \"$next\""
        if {$next == ".."} {
            set fulllib [file dirname $fulllib]
        } elseif {$suite != "."} {
            set fulllib [file join $fulllib $next]
        }
    }

    puts stderr "fulllib = $fulllib"

    return [load $fulllib $init]
}

if {[info exists env(FIDEV_EXPERIMENTAL)]} {
    set FIDEV_LIB_ROOT $env(FIDEV_EXPERIMENTAL)
} else {
    puts "machine/os = $tcl_platform(machine)/$tcl_platform(os) [string match x86_64 $tcl_platform(machine)] [string match Linux $tcl_platform(os)] [expr {[string match x86_64 $tcl_platform(machine)] && [string match Linux $tcl_platform(os)]}]"
    if {[string match sun4* $tcl_platform(machine)] && [string match SunOS $tcl_platform(os)]} {
        # set FIDEV_LIB_ROOT /home/fab/C/fidev-sparc-SunOS-5.8-cc-stable
        set FIDEV_LIB_ROOT /bob/fab/C/fidev-SparcSolarisForte7-stable
    } elseif {[string match i* $tcl_platform(machine)] && [string match Linux $tcl_platform(os)]}  {
        set FIDEV_LIB_ROOT /bob/fab/C/fidev-gcc4-linux-i686-optim
    } elseif {[string match x86_64 $tcl_platform(machine)] && [string match Linux $tcl_platform(os)]}  {
        set FIDEV_LIB_ROOT /bob/fab/C/fidev-gcc4-linux-x86_64-optim
        puts "OK $FIDEV_LIB_ROOT"
    } elseif {[string match i* $tcl_platform(machine)] && [string match "Windows NT" $tcl_platform(os)]}  {
        set FIDEV_LIB_ROOT C:/bob/fab/C/fidev-gcc-mingw-optim
    } else {
        error "machine/os = $tcl_platform(machine)/$tcl_platform(os) ; reconnus actuellement : sun*/SunOs, x86_64/Linux, i*/Linux"
    }
}
puts "OK FF"

package provide fidev 1.2

package ifneeded 2400                   1.0 "source $fidev_tclDir/gpib/library/2400.1.0.tcl"
package ifneeded 2361                   1.0 "source $fidev_tclDir/gpib/library/2361.1.0.tcl"
package ifneeded a4156                  1.0 "source $fidev_tclDir/gpib/library/a4156.1.0.tcl"
package ifneeded 37xxx                  0.1 "source $fidev_tclDir/gpib/library/37xxx.0.1.tcl"
package ifneeded mm4006                 1.0 "source $fidev_tclDir/gpib/library/mm4006.1.0.tcl"
package ifneeded mm4005                 1.0 "source $fidev_tclDir/gpib/library/mm4005.1.0.tcl"
package ifneeded tc550                  1.1 "source $fidev_tclDir/gpib/library/tc550.1.1.tcl"
package ifneeded 3vectors               1.0 "source $fidev_tclDir/3vectors/library/3vectors.1.0.tcl"
package ifneeded 3vectors               1.1 "source $fidev_tclDir/3vectors/library/3vectors.1.1.tcl"
package ifneeded 5carres                0.1 "source $fidev_tclDir/masque/library/5carres.0.1.tcl"
package ifneeded 5carres_centres        0.1 "source $fidev_tclDir/masque/library/5carres_centres.0.1.tcl"
package ifneeded 5carres_photodetecteurs 0.1 "source $fidev_tclDir/masque/library/5carres_photodetecteurs.0.1.tcl"
package ifneeded aide                   1.2 "source $fidev_tclDir/aide/library/aide.tcl"
package ifneeded alladin_md5            1.0 "source $fidev_tclDir/alladin_md5/library/alladin_md5.tcl"
package ifneeded arrayUtils		1.0 "source $fidev_tclDir/arrayUtils/library/arrayUtils.tcl"
package ifneeded asdex			1.0 "source $fidev_tclDir/asdex/library/asdex.tcl"
package ifneeded asyst                  1.1 "source $fidev_tclDir/asyst/library/load_and_compile.tcl"
package ifneeded blas                   1.0 "source $fidev_tclDir/blas/library/blas.tcl"
package ifneeded blasObj                0.1 "source $fidev_tclDir/blasObj/library/blasObj.0.1.tcl"
package ifneeded blasObj                0.2 "source $fidev_tclDir/blasObj/library/blasObj.0.2.tcl"
package ifneeded blasmath               0.1 "source $fidev_tclDir/blasMath/library/blasMath.tcl"
package ifneeded blasmath               0.2 "source $fidev_tclDir/blasMath/library/blasMath.0.2.tcl"
package ifneeded bolo                   0.1 "source $fidev_tclDir/masque/library/bolo.0.1.tcl"
package ifneeded captex                 0.1 "source $fidev_tclDir/masque/library/captex.0.1.tcl"
package ifneeded dblas1                 0.1 "source $fidev_tclDir/dblas1/library/dblas1.0.1.tcl"
package ifneeded dblas1                 0.2 "source $fidev_tclDir/dblas1/library/dblas1.0.2.tcl"
package ifneeded dcdflib                0.1 "source $fidev_tclDir/dcdflib/library/dcdflib.tcl"
package ifneeded diodes_gardees         0.1 "source $fidev_tclDir/masque/library/diodes_gardees.0.1.tcl"
package ifneeded diodes_gardees         0.2 "source $fidev_tclDir/masque/library/diodes_gardees.0.2.tcl"
package ifneeded zblas1                 0.1 "source $fidev_tclDir/zblas1/library/zblas1.0.1.tcl"
package ifneeded zblas1                 0.1 "source $fidev_tclDir/zblas1/library/zblas1.0.2.tcl"
package ifneeded complexes              1.1 "source $fidev_tclDir/complexes/library/complexes.1.1.tcl"
package ifneeded egg7260                1.0 "source $fidev_tclDir/gpib/library/egg7260.1.0.tcl"
package ifneeded ei-bisynch             0.1 "source $fidev_tclDir/eurotherm/library/ei-bisynch.0.1.tcl"
package ifneeded email                  0.1 "source $fidev_tclDir/email/library/email.tcl"
package ifneeded eqvp                   0.1 "source $fidev_tclDir/zerosComplexes/library/eqvp.tcl"
package ifneeded eqvp                   0.2 "source $fidev_tclDir/zerosComplexes/library/eqvp.0.2.tcl"
package ifneeded eqvp                   0.3 "source $fidev_tclDir/zerosComplexes/library/eqvp.0.3.tcl"
package ifneeded eqvp                   0.4 "source $fidev_tclDir/zerosComplexes/library/eqvp.0.4.tcl"
package ifneeded eqvp                   0.5 "source $fidev_tclDir/zerosComplexes/library/eqvp.0.5.tcl"
package ifneeded essais_f77             1.0 "source $fidev_tclDir/essais_f77/library/essais_f77.tcl"
package ifneeded fctlm                  0.1 "source $fidev_tclDir/fctlm/OLD/library/fctlm.0.1.tcl"
package ifneeded fctlm                  0.2 "source $fidev_tclDir/fctlm/OLD/library/fctlm.0.2.tcl"
package ifneeded fctlm                  0.3 "source $fidev_tclDir/fctlm/library/fctlm.0.3.tcl"
package ifneeded fctlm                  0.4 "source $fidev_tclDir/fctlm/library/fctlm.0.4.tcl"
package ifneeded fctlm                  0.5 "source $fidev_tclDir/fctlm/library/fctlm.0.5.tcl"
package ifneeded fctlmPart1             0.6 "source $fidev_tclDir/fctlm/library/fctlmPart1.0.6.tcl"
package ifneeded fctlm_geom             0.1 "source $fidev_tclDir/fctlm/OLD/geom.0.1.tcl"
package ifneeded fctlm_geom             0.2 "source $fidev_tclDir/fctlm/library/geom.0.2.tcl"
package ifneeded fichUtils              0.1 "source $fidev_tclDir/fichUtils/library/all.0.1.tcl"
package ifneeded fichUtils              0.2 "source $fidev_tclDir/fichUtils/library/all.0.2.tcl"
package ifneeded fidev_asdexUtils       1.0 "source $fidev_tclDir/asdexUtils/library/utils.tcl"
package ifneeded fidev_stats            0.2 "source $fidev_tclDir/stats/library/stats.tcl"
package ifneeded fidev_zinzout          1.0 "source $fidev_tclDir/canvas/library/zinzout.tcl"
package ifneeded fidev_zinzout          1.1 "source $fidev_tclDir/canvas/library/zinzout.1.1.tcl"
package ifneeded fidev_zinzout          1.2 "source $fidev_tclDir/canvas/library/zinzout.1.2.tcl"
package ifneeded fidevFloating          0.2 "source $fidev_tclDir/floatingPoint/library/floating.tcl"
package ifneeded flex                   0.2 "source $fidev_tclDir/a4156/library/flex.0.2.tcl"
package ifneeded gds2                   0.1 "source $fidev_tclDir/gds2/library/gds2.0.1.tcl"
package ifneeded gds2                   0.2 "source $fidev_tclDir/gds2/library/gds2.0.2.tcl"
package ifneeded gds2                   0.3 "source $fidev_tclDir/gds2/library/gds2.0.3.tcl"
package ifneeded gds2                   0.4 "source $fidev_tclDir/gds2/library/gds2.0.4.tcl"
package ifneeded gds2                   0.5 "source $fidev_tclDir/gds2/library/gds2.0.5.tcl"
package ifneeded gpib                   1.0 "source $fidev_tclDir/gpib/library/all.tcl"
package ifneeded gpibLowLevel           1.1 "source $fidev_tclDir/gpibLowLevel/library/all.1.1.tcl"
package ifneeded gpibLowLevel           1.2 "source $fidev_tclDir/gpibLowLevel/library/all.1.2.tcl"
package ifneeded gpibLowLevel           1.3 "source $fidev_tclDir/gpibLowLevel/library/all.1.3.tcl"
package ifneeded gpibLowLevel           1.4 "source $fidev_tclDir/gpibLowLevel/library/all.1.4.tcl"
package ifneeded html_photoIndex        1.0 "source $fidev_tclDir/html/library/photoIndex.tcl"
package ifneeded hsplot                 0.1 "source $fidev_tclDir/hsplot/library/hsplot.0.1.tcl"
package ifneeded hsplot                 0.5 "source $fidev_tclDir/hsplot/library/hsplot.0.5.tcl"
package ifneeded histo                  0.1 "source $fidev_tclDir/histo/library/histo.tcl"
package ifneeded horreur                0.1 "source $fidev_tclDir/horreur/library/horreur.0.1.tcl"
package ifneeded hyperHBT               1.0 "source $fidev_tclDir/sparams/library/HBT.tcl"
package ifneeded hyperpiano             1.0 "source $fidev_tclDir/sparams/library/piano.tcl"
package ifneeded hyperpianoHBT          0.1 "source $fidev_tclDir/sparams/library/pianoHBT.tcl"
package ifneeded iv_ui                  2.2 "source $fidev_tclDir/iv/library/iv_ui.2.2.tcl"
package ifneeded iv_ui                  2.3 "source $fidev_tclDir/iv/library/iv_ui.2.3.tcl"
package ifneeded iv_ui                  2.4 "source $fidev_tclDir/iv/library/iv_ui.2.4.tcl"
package ifneeded iv_ui                  2.5 "source $fidev_tclDir/iv/library/iv_ui.2.5.tcl"
package ifneeded kdutil                 1.2 "source $fidev_tclDir/kdutil/library/kdutil.tcl"
package ifneeded l2mGraph               1.2 "source $fidev_tclDir/l2mGraph/library/commandes.1.2.tcl"
package ifneeded l2mGraph               1.3 "source $fidev_tclDir/l2mGraph/library/commandes.1.3.tcl"
package ifneeded l2mGraphTicks          1.2 "source $fidev_tclDir/l2mGraph/library/ticks.tcl"
package ifneeded lapsus2012             0.1 "source $fidev_tclDir/masque/library/lapsus2012.0.1.tcl"
package ifneeded linux-gpib             0.1 "source $fidev_tclDir/linux-gpib/library/linux-gpib.tcl"
package ifneeded listUtils              1.0 "source $fidev_tclDir/listUtils/library/listUtils.1.0.tcl"
package ifneeded listUtils              1.1 "source $fidev_tclDir/listUtils/library/listUtils.1.1.tcl"
package ifneeded m22c                   0.1 "source $fidev_tclDir/m22c/library/m22c.0.1.tcl"
package ifneeded make                   1.0 "source $fidev_tclDir/make/library/make.tcl"
package ifneeded masque                 1.0 "source $fidev_tclDir/masque/library/masque.tcl"
package ifneeded masque_diodes_Benjamin_8x13 0.1 "source $fidev_tclDir/masque/library/diodes_Benjamin_8x13.tcl"
package ifneeded minimat                0.1 "source $fidev_tclDir/masque/library/minimat.0.1.tcl"
package ifneeded MOHbt                  0.2 "source $fidev_tclDir/masque/library/MOHbt.0.2.tcl"
package ifneeded mes                    0.1 "source $fidev_tclDir/mesures/library/mes.0.1.tcl"
package ifneeded mes                    0.2 "source $fidev_tclDir/mesures/library/mes.0.2.tcl"
package ifneeded mes_bipolaire          1.0 "source $fidev_tclDir/mesures/OLD/bipolaire.1.0.tcl"
package ifneeded mes_bipolaire          1.1 "source $fidev_tclDir/mesures/OLD/bipolaire.1.1.tcl"
package ifneeded mes_bipolaire          1.2 "source $fidev_tclDir/mesures/library/bipolaire.1.2.tcl"
package ifneeded mes_bipolaire          1.3 "source $fidev_tclDir/mesures/library/bipolaire.1.3.tcl"
package ifneeded mes_bipolaire          1.4 "source $fidev_tclDir/mesures/library/bipolaire.1.4.tcl"
package ifneeded mes_bipolaire          1.5 "source $fidev_tclDir/mesures/library/bipolaire.1.5.tcl"
package ifneeded mes_bipolaire          1.6 "source $fidev_tclDir/mesures/library/bipolaire.1.6.tcl"
package ifneeded mes_bipolaire          1.7 "source $fidev_tclDir/mesures/library/bipolaire.1.7.tcl"
package ifneeded mes_bipolaire          1.8 "source $fidev_tclDir/mesures/library/bipolaire.1.8.tcl"
package ifneeded mes_diode              0.2 "source $fidev_tclDir/mesures/library/diode.0.2.tcl"
package ifneeded mes_diode              0.4 "source $fidev_tclDir/mesures/library/diode.0.4.tcl"
package ifneeded mes_diode_1smu         0.2 "source $fidev_tclDir/mesures/library/diode_1smu.0.2.tcl"
package ifneeded mes_hemt               1.8 "source $fidev_tclDir/mesures/library/hemt.1.8.tcl"
package ifneeded mes_hemt               1.9 "source $fidev_tclDir/mesures/library/hemt.1.9.tcl"
package ifneeded mes_hemt               1.10 "source $fidev_tclDir/mesures/library/hemt.1.10.tcl"
package ifneeded mes_univ_2smus         1.10 "source $fidev_tclDir/mesures/library/univ_2smus.1.10.tcl"
package ifneeded mes_univ_2smus         1.11 "source $fidev_tclDir/mesures/library/univ_2smus.1.11.tcl"
package ifneeded mes_univ_2smus         1.12 "source $fidev_tclDir/mesures/library/univ_2smus.1.12.tcl"
package ifneeded microCIS               0.1 "source $fidev_tclDir/masque/library/microCIS.0.1.tcl"
package ifneeded microCIS_plots         0.1 "source $fidev_tclDir/masque/library/microCIS_plots.0.1.tcl"
package ifneeded microRCAST             0.1 "source $fidev_tclDir/masque/library/microRCAST.0.1.tcl"
package ifneeded minihelp               1.0 "source $fidev_tclDir/aide/library/minihelp.tcl"
package ifneeded minpack                0.2 "source $fidev_tclDir/minpack/library/minpack.0.2.tcl"
package ifneeded minpack                0.3 "source $fidev_tclDir/minpack/library/minpack.0.3.tcl"
package ifneeded mysqltcl               2.0 "load $fidev_tclDir/libmysqltcl.2.0.so Mysqltcl"
package ifneeded narray                 0.81 [list tclPkgSetup $fidev_tclDir narray 0.81 {
       {libNArray.so load narray} {narray.tcl source {pnarray narray_destroy}}}]
package ifneeded ni488                  1.0 "source $fidev_tclDir/ni488/OLD/load_an_compile.tcl"
package ifneeded ni488                  1.1 "source $fidev_tclDir/ni488/library/ni488.tcl"
package ifneeded nr                     1.0 "source $fidev_tclDir/nr/library/load_and_compile.tcl"
package ifneeded optiquePlane           0.1 "source $fidev_tclDir/optiquePlane/library/optiquePlane.tcl"
package ifneeded oplan                  0.1 "source $fidev_tclDir/oplan/library/oplan.tcl"
package ifneeded pas-a-pas_rs           0.1 "source $fidev_tclDir/pas-a-pas/library/rs.0.1.tcl"
package ifneeded pda_emilie             0.1 "source $fidev_tclDir/masque/library/pda_emilie.0.1.tcl"
package ifneeded pG-Lpn                 1.0 "source $fidev_tclDir/masque/library/pG-Lpn.1.0.tcl"
package ifneeded pG-Lpn                 1.1 "source $fidev_tclDir/masque/library/pG-Lpn.1.1.tcl"
package ifneeded pG_bigfet              0.1 "source $fidev_tclDir/masque/library/pG_bigfet.0.1.tcl"
package ifneeded port3_fft              0.1 "source $fidev_tclDir/port3_fft/library/port3_fft.0.1.tcl"
package ifneeded port3_fft              0.2 "source $fidev_tclDir/port3_fft/library/port3_fft.0.2.tcl"
package ifneeded port3_nl2opt           0.1 "source $fidev_tclDir/port3_nl2opt/library/port3_nl2opt.tcl"
package ifneeded port3_root_np          0.1 "source $fidev_tclDir/port3_root/library/port3_root_np.tcl"
package ifneeded port3_root_np          0.2 "source $fidev_tclDir/port3_root/library/port3_root_np.0.2.tcl"
package ifneeded port3_lin_np           0.1 "source $fidev_tclDir/port3_lin/library/port3_lin_np.tcl"
package ifneeded parport                0.1 "source $fidev_tclDir/parport/library/parport.0.1.tcl"
package ifneeded pauli                  1.1 "source $fidev_tclDir/pauli/library/pauli.1.1.tcl"
package ifneeded pauli                  1.2 "source $fidev_tclDir/pauli/library/pauli.1.2.tcl"
package ifneeded phi10_csv              0.1 "source $fidev_tclDir/csv/library/csv.0.1.tcl"
package ifneeded polyexec               0.1 "source $fidev_tclDir/polyexec/library/polyexec.0.1.tcl"
package ifneeded pvm                    0.1 "source $fidev_tclDir/pvm/library/pvm.0.1.tcl"
package ifneeded res1smu                0.1 "source $fidev_tclDir/mesures/library/res1smu.0.1.tcl"
package ifneeded res1smu                0.2 "source $fidev_tclDir/mesures/library/res1smu.0.2.tcl"
package ifneeded scilab                 0.1 "source $fidev_tclDir/scilab/library/scilab.tcl"
package ifneeded scpack                 0.2 "source $fidev_tclDir/scpack/library/scpack.0.2.tcl"
package ifneeded scplxi                 0.1 "source $fidev_tclDir/sunInterval/library/scplxi.tcl"
#package ifneeded smu                    1.0 "source $fidev_tclDir/gpib/OLD/smu.1.0.tcl"
#package ifneeded smu                    1.1 "source $fidev_tclDir/gpib/OLD/smu.1.1.tcl"
#package ifneeded smu                    1.2 "source $fidev_tclDir/gpib/library/Poubelle/smu.1.2.tcl"
package ifneeded smu                    1.3 "source $fidev_tclDir/gpib/library/smu.1.3.tcl"
package ifneeded slatec                 0.1 "source $fidev_tclDir/slatec/library/slatec.tcl"
package ifneeded slatec                 0.2 "source $fidev_tclDir/slatec/library/slatec.0.2.tcl"
package ifneeded slatec_fnlib           1.0 "source $fidev_tclDir/slatec_fnlib/library/slatec_fnlib.tcl"
package ifneeded stringutils            1.0 "source $fidev_tclDir/stringutils/library/stringutils.tcl"
package ifneeded spalab                 1.1 "source $fidev_tclDir/sparams/library/scilab.tcl"
package ifneeded sparams                0.1 "source $fidev_tclDir/sparams/library/sparams.tcl"
package ifneeded sparams2               0.1 "source $fidev_tclDir/sparams/library/sparams.2.tcl"
package ifneeded sparams2               0.2 "source $fidev_tclDir/sparams/library/sparams.2.0.2.tcl"
package ifneeded suninterval            0.1 "source $fidev_tclDir/sunInterval/library/sunInterval.tcl"
package ifneeded supercomplex           0.1 "source $fidev_tclDir/supercomplex/library/supercomplex.0.1.tcl"
package ifneeded supercomplex           0.2 "source $fidev_tclDir/supercomplex/library/supercomplex.0.2.tcl"
package ifneeded superTable             1.4 "source $fidev_tclDir/superTable/library/OLDsuperTable.1.4.tcl"
package ifneeded superTable             1.5 "source $fidev_tclDir/superTable/library/superTable.1.5.tcl"
package ifneeded superWidgets           1.0 "source $fidev_tclDir/superWidgets/library/superWidgets.tcl"
package ifneeded superWidgetsIntControl 1.0 "source $fidev_tclDir/superWidgets/library/superWidgetsIntControl.tcl"
package ifneeded superWidgetsListbox    1.2 "source $fidev_tclDir/superWidgets/library/listbox.1.2.tcl"
package ifneeded superWidgetsListbox    1.3 "source $fidev_tclDir/superWidgets/library/listbox.1.3.tcl"
package ifneeded superWidgetsPlusMoins  1.0 "source $fidev_tclDir/superWidgets/library/plusmoins.tcl"
package ifneeded superWidgetsScroll     1.0 "source $fidev_tclDir/superWidgets/library/scroll.tcl"
package ifneeded tablexy                1.3 "source $fidev_tclDir/tablexy/library/tablexy_ui.1.3.tcl"
package ifneeded tablexy                1.4 "source $fidev_tclDir/tablexy/library/tablexy_ui.1.4.tcl"
package ifneeded tablexy                1.5 "source $fidev_tclDir/tablexy/library/tablexy_ui.1.5.tcl"
package ifneeded tablexy_manual         1.1 "source $fidev_tclDir/tablexy/library/tablexy_manual_ui.1.1.tcl"
package ifneeded twop                   0.1 "source $fidev_tclDir/masque/library/twop.0.1.tcl"
package ifneeded aligned                1.1 "source $fidev_tclDir/tablexy/library/aligned.1.1.tcl"
package ifneeded aligned                1.2 "source $fidev_tclDir/tablexy/library/aligned.1.2.tcl"
package ifneeded isometrie              1.1 "source $fidev_tclDir/tablexy/library/isometrie.1.1.tcl"
package ifneeded tbs2                   1.0 "source $fidev_tclDir/masque/library/tbs2.tcl"
package ifneeded jumbo_carre            0.1 "source $fidev_tclDir/masque/library/jumbo_carre.tcl"
package ifneeded jumbo_pG               0.1 "source $fidev_tclDir/masque/library/jumbo_pG.0.1.tcl"
package ifneeded jumbo_pG               0.2 "source $fidev_tclDir/masque/library/jumbo_pG.0.2.tcl"
package ifneeded TLM_CNET               0.1 "source $fidev_tclDir/masque/library/TLM_CNET.0.1.tcl"
package ifneeded TLM_CNET               0.2 "source $fidev_tclDir/masque/library/TLM_CNET.0.2.tcl"
package ifneeded TLM2007                0.2 "source $fidev_tclDir/masque/library/TLM2007.0.2.tcl"
package ifneeded TLM2007simon           0.2 "source $fidev_tclDir/masque/library/TLM2007simon.0.2.tcl"
package ifneeded tkSuperTable           1.1 "source $fidev_tclDir/superTable/OLD/tkSuperTable.1.1.tcl"
package ifneeded tkSuperTable           1.2 "source $fidev_tclDir/superTable/OLD/tkSuperTable.1.2.tcl"
package ifneeded tkSuperTable           1.3 "source $fidev_tclDir/superTable/OLD/tkSuperTable.1.3.tcl"
package ifneeded tkSuperTable           1.4 "source $fidev_tclDir/superTable/library/tkSuperTable.1.4.tcl"
package ifneeded tkSuperTable           1.5 "source $fidev_tclDir/superTable/library/tkSuperTable.1.5.tcl"
package ifneeded tkSuperTable           1.6 "source $fidev_tclDir/superTable/library/tkSuperTable.1.6.tcl"
package ifneeded tkSuperTable_alpha     1.7 "source $fidev_tclDir/superTable/library/tkSuperTable.1.7.tcl"
package ifneeded tkSuperTable           1.8 "source $fidev_tclDir/superTable/library/tkSuperTable.1.8.tcl"
package ifneeded tkstcb_Diodir          0.1 "source $fidev_tclDir/superTable/library/callback_diodir.0.1.tcl"
package ifneeded tkstcb_gnuplot         1.0 "source $fidev_tclDir/superTable/OLD/callback_gnuplot.1.0.tcl"
package ifneeded tkstcb_gnuplot         2.0 "source $fidev_tclDir/superTable/library/callback_gnuplot.2.0.tcl"
package ifneeded tkstcb_gnuplot         2.1 "source $fidev_tclDir/superTable/library/callback_gnuplot.2.1.tcl"
package ifneeded tkstcb_gnuplot         2.2 "source $fidev_tclDir/superTable/library/callback_gnuplot.2.2.tcl"
package ifneeded tkstcb_gnuplot         2.3 "source $fidev_tclDir/superTable/library/callback_gnuplot.2.3.tcl"
package ifneeded tkstcb_gnuplot         2.4 "source $fidev_tclDir/superTable/library/callback_gnuplot.2.4.tcl"
package ifneeded tkstcb_verifOptR       1.0 "source $fidev_tclDir/superTable/library/callback_verifOptR.1.0.tcl"
package ifneeded tpg                    0.2 "source $fidev_tclDir/tpg/library/tpg.0.2.tcl"
package ifneeded tpg                    0.3 "source $fidev_tclDir/tpg/library/tpg.0.3.tcl"
package ifneeded tpgFont                0.1 "source $fidev_tclDir/tpg/library/font.tcl"
package ifneeded tpgPixFont             0.1 "source $fidev_tclDir/tpg/library/pixFont.tcl"
package ifneeded tpgFontLucidaTypeWriter 0.1 "source $fidev_tclDir/tpg/library/fontLucidaTypeWriter.tcl"
package ifneeded trig_sun               1.0 "source $fidev_tclDir/trig_sun/library/trig_sun.tcl"
package ifneeded units                  1.0 "source $fidev_tclDir/units/library/units.tcl"
package ifneeded unix                   1.0 "source $fidev_tclDir/unix/library/unix.tcl"
package ifneeded fidev_xh               0.1 "source $fidev_tclDir/xh/library/xh.tcl"
package ifneeded xml_physiparams        0.2 "source $fidev_tclDir/xml_physiparams/library/xml_physiparams.tcl"
