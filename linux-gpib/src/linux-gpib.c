#include <tcl.h>
#ifdef WINNT
#include <windows.h>
#include "Decl-32.h"
#else
#endif
#include <gpib/ib.h>

// #include <signal.h>

// 6 juillet 1999 (FP):
// le systeme de gestion du SRQ s'emballe trop souvent.
// Dorénavant, le rétablissement signale(1) doit être fait dans Tcl "::GPIBBoard::signale 1"
// 9 janvier 2001 (FP):
// lorsque Tcl est rapide parce qu'optimisé, le système s'embale encore
// On décide de ne plus utiliser les interruptions Unix, par ailleurs non
// portables sous Linux, mais un timer Tcl qui va scruter le SRQ et mettre à jour "SRQstatus"

// 2005-08-30 (FP) Portage pour la version libgpibapi.so.2.3.1

// NI488.c -> linux-gpib.c
// 2008-12-22 (FP) Tentative de portage pour libgpib.so.0.1.5 de Linux-GPIB

int TRACE_ON=0;
int TRACE_SRQ=0;
int SRQstatus;

int testErreur(Tcl_Interp *interp) {
    if (TRACE_ON) {
        fprintf (stderr, "ista = %08x\n", ibsta);
    }
    if (ibsta & 0x8000) {
        char iberrString[10];
        Tcl_Obj *resultPtr, *explic;
        Tcl_ResetResult(interp);
        resultPtr = Tcl_GetObjResult(interp);
        Tcl_AppendToObj(resultPtr, "NI488 ERROR : ", -1);
        sprintf(iberrString, "%d", iberr);
/* 8.1        explic = Tcl_GetObjVar2(interp,
            "NI488_ErrorExplication",
            iberrString,
            TCL_GLOBAL_ONLY);
*/
        explic = Tcl_ObjGetVar2(interp,
            Tcl_NewStringObj("NI488_ErrorExplication", -1),
            Tcl_NewStringObj(iberrString, -1),
            TCL_GLOBAL_ONLY);
        if (explic == 0) {
            Tcl_AppendToObj(resultPtr, "Pas d'explication", -1);
        } else {
            Tcl_AppendToObj(resultPtr, Tcl_GetStringFromObj(explic, NULL), -1);
        }
        Tcl_SetObjResult(interp, resultPtr);
        return TCL_ERROR;
    }
    return TCL_OK;
}

void updateSRQ(Tcl_Interp *interp, int GPIB_board) {
    unsigned short lines;
    if (TRACE_SRQ) {
	fprintf(stderr, "updateSRQ: SRQstatus = ");
    }
    iblines(GPIB_board, (short*)&lines);
    if (testErreur(interp) == TCL_OK) {
        SRQstatus = ((lines & 0x2000) != 0);
	if (TRACE_SRQ) {
	    fprintf(stderr, "%d\n", SRQstatus);
	}
    }
    Tcl_UpdateLinkedVar (interp, "SRQstatus"); /* indispensable parce qu'on la trace */
    // a faire dans Tcl    signale(1);
}

void displaySyntax(Tcl_Interp *interp,  Tcl_Obj * CONST objv[], char *argums) {
    Tcl_ResetResult(interp);
    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
        "wrong # args: should be \"",
        Tcl_GetStringFromObj(objv[0], (int *) NULL),
        " ", argums, "\"", (char *)NULL);
}

int NIBoard_scruteSRQ(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
        
    if (objc != 2) {
	displaySyntax(interp, objv, "GPIB_board");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }

    updateSRQ(interp, GPIB_board);
    
    return TCL_OK;
}

int NIBoard_ask(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int option;
    int value;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board option");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &option) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibask(%d, %d) = ", GPIB_board, option);
    }
    ibask(GPIB_board, option, &value);
    if (TRACE_ON) {
        fprintf(stderr, "%d\n", value);
    }
    Tcl_SetObjResult(interp, Tcl_NewIntObj(value));
    return testErreur(interp);
}

int NIBoard_cac(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int cac;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board true|false");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetBooleanFromObj(interp, objv[2], &cac) != TCL_OK)  {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACEibcac(%d, %d)\n", GPIB_board, cac);
    }
    ibcac(GPIB_board, cac);
    return testErreur(interp);
}

int NIBoard_cmd(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    char *cmd;
    int len;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board commandString");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    cmd = Tcl_GetStringFromObj(objv[2], &len);
        
    if (TRACE_ON) {
        int i;
        fprintf(stderr, "NI488-TRACE ibcmd(%d", GPIB_board);
        for (i=0; i<len; i++) {
            fprintf(stderr, ", 0x%04x", cmd[i]);
        }
        fprintf(stderr, ")\n");
    }
    ibcmd(GPIB_board, cmd, len);
    return testErreur(interp);
}

int NIBoard_1cmd(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int icmd;
    char cmd[1];
    int len=1;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board commandString");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }

    if (Tcl_GetIntFromObj(interp, objv[2], &icmd) != TCL_OK) {
        return TCL_ERROR;
    }
    cmd[0]=icmd;
    len=1;
    
    if (TRACE_ON) {
        int i;
        fprintf(stderr, "NI488-TRACE ibcmd(%d", GPIB_board);
        for (i=0; i<len; i++) {
            fprintf(stderr, ", 0x%04x", cmd[i]);
        }
        fprintf(stderr, ")\n");
    }
    ibcmd(GPIB_board, cmd, len);
    return testErreur(interp);
}

int NIBoard_config(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int option, value;
    
    if (objc != 4) {
	displaySyntax(interp, objv,"GPIB_board option value");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &option) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[3], &value) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibconfig(%d, %d, %d)\n", GPIB_board, option, value);
    }
    ibconfig(GPIB_board, option, value);
    return testErreur(interp);
}

int NIBoard_find(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    char *name;
    int unit;
    
    if (objc != 2) {
	displaySyntax(interp, objv,"name");
	return TCL_ERROR;
    }
    
    name = Tcl_GetStringFromObj(objv[1], 0);

    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibfind = ");
    }
    unit = ibfind(name);
    if (TRACE_ON) {
        fprintf(stderr, "%d\n", unit);
    }
    Tcl_SetObjResult(interp, Tcl_NewIntObj(unit));
    return testErreur(interp);
}

int NIBoard_eos(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board, v;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board mode_and_char_int");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
        
    if (Tcl_GetIntFromObj(interp, objv[2], &v) != TCL_OK) {
        return TCL_ERROR;
    }
        
    if (1) {
        fprintf(stderr, "NI488-TRACE ibeos(%d,%d)\n", GPIB_board, v);
    }
    ibeos(GPIB_board, v);
    return testErreur(interp);
}

int NIBoard_eot(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board, v;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board 0/1");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
        
    if (Tcl_GetIntFromObj(interp, objv[2], &v) != TCL_OK) {
        return TCL_ERROR;
    }
        
    if (1) {
        fprintf(stderr, "NI488-TRACE ibeot(%d,%d)\n", GPIB_board, v);
    }
    ibeot(GPIB_board, v);
    return testErreur(interp);
}

int NIBoard_lines(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    unsigned short lines;
    
    if (objc != 2) {
	displaySyntax(interp, objv,"GPIB_board");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE iblines(%d) = ", GPIB_board);
    }
    iblines(GPIB_board, (short*)&lines);
    if (TRACE_ON) {
        fprintf(stderr, "0x%08x\n", lines);
    }
    Tcl_SetObjResult(interp, Tcl_NewIntObj(lines));
    
    return testErreur(interp);
}

int NIBoard_ln(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int pad, sad;
    unsigned short value;
    
    if (objc != 4) {
	displaySyntax(interp, objv,"GPIB_board pad sad");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &pad) != TCL_OK) {
        return TCL_ERROR;
    }

    if (Tcl_GetIntFromObj(interp, objv[3], &sad) != TCL_OK) {
        return TCL_ERROR;
    }

    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibln(%d, %d, %d) = ", GPIB_board, pad, sad);
    }
    ibln(GPIB_board, pad, sad, (short*)&value);
    if (TRACE_ON) {
        fprintf(stderr, "%d\n", value);
    }
    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(value));
    return testErreur(interp);
}

int NIBoard_onl(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int v;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board value");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &v) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibonl(%d, %d)\n", GPIB_board, v);
    }
    ibonl(GPIB_board, v);
    return testErreur(interp);
}

int NIBoard_gts(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int v;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board true|false");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetBooleanFromObj(interp, objv[2], &v) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibgts(%d, %d)\n", GPIB_board, v);
    }
    ibgts(GPIB_board, v);
    return testErreur(interp);
}

/* int NIBoard_sgnl(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int mask;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board mask");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &mask) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibsgnl(%d, 0x%08x)\n", GPIB_board, mask);
    }
    ibsgnl(GPIB_board, mask);
    return testErreur(interp);
}
*/

int NIBoard_sic(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    
    if (objc != 2) {
	displaySyntax(interp, objv,"GPIB_board");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
        
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibsic(%d)\n", GPIB_board);
    }
    ibsic(GPIB_board);
    return testErreur(interp);
}


int NIBoard_sre(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    int set;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board true|false");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetBooleanFromObj(interp, objv[2], &set) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibsre(%d, %d)\n", GPIB_board, set);
    }
    ibsre(GPIB_board, set);
    return testErreur(interp);
}

int NIBoard_wrt(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    char *wrt;
    int len;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board string");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    wrt = Tcl_GetStringFromObj(objv[2], &len);

    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibwrt(%d, %s, %d)\n", GPIB_board, wrt, len);
    }
    ibwrt(GPIB_board, wrt, len);
    return testErreur(interp);
}

int NIBoard_rd(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    char *rd;
    int cnt;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board count");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &cnt) != TCL_OK) {
        return TCL_ERROR;
    }
    
    rd = Tcl_Alloc(cnt);
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibrd(%d, %d) = ", GPIB_board, cnt);
    }
    ibrd(GPIB_board, rd, cnt);
    cnt = ibcnt;
    if (TRACE_ON) {
        fprintf(stderr, "%s\n", rd);
        fprintf(stderr, "ibcnt = %d\n", cnt);
    }
    updateSRQ(interp, GPIB_board); /* IMPORTANT apres SPE */
    Tcl_SetObjResult(interp, Tcl_NewStringObj(rd, cnt));
    if (0) {
        int i;
        fprintf(stderr, "%d caractères :", cnt);
        for (i=0;i<cnt;i++) {
            fprintf(stderr, " %02x", (unsigned char)rd[i]);
        }
        fprintf(stderr, "\n");
    }
    Tcl_Free(rd);
    return testErreur(interp);
}

int NIBoard_rdBin(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    int GPIB_board;
    unsigned char *rd;
    int cnt;
    Tcl_Obj *ret;
    int i;
    
    if (objc != 3) {
	displaySyntax(interp, objv,"GPIB_board count");
	return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[1], &GPIB_board) != TCL_OK) {
        return TCL_ERROR;
    }
    
    if (Tcl_GetIntFromObj(interp, objv[2], &cnt) != TCL_OK) {
        return TCL_ERROR;
    }
    
    rd = (unsigned char*)Tcl_Alloc(cnt);
    if (TRACE_ON) {
        fprintf(stderr, "NI488-TRACE ibrd(%d, %d) = ", GPIB_board, cnt);
    }
    ibrd(GPIB_board, (char *)rd, cnt);
    cnt = ibcnt;
    if (TRACE_ON) {
        fprintf(stderr, "ibcnt = %d ->", cnt);
    }

    ret = Tcl_NewListObj(0, 0);
    for (i=0; i<cnt; i++) {
        if (TRACE_ON) {
            fprintf(stderr, " 0x%04x", rd[i]);
        }
       Tcl_ListObjAppendElement(interp, ret, Tcl_NewIntObj(rd[i]));
    }
    if (TRACE_ON) {
        fprintf(stderr, "\n");
    }
    
    updateSRQ(interp, GPIB_board); /* IMPORTANT apres SPE */
    Tcl_SetObjResult(interp, ret);
    Tcl_Free((char *)rd);
    return testErreur(interp);
}

int NIBoard_cnt(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {

    if (objc != 1) {
	displaySyntax(interp, objv,"");
	return TCL_ERROR;
    }
    
    Tcl_SetObjResult(interp, Tcl_NewIntObj(ibcnt));
    return testErreur(interp);
}

int NIBoard_TRACE_ON(ClientData dummy, Tcl_Interp *interp, int objc, Tcl_Obj * CONST objv[]) {
    
    if (objc != 2) {
	displaySyntax(interp, objv,"true|false");
	return TCL_ERROR;
    }

    if (Tcl_GetBooleanFromObj(interp, objv[1], &TRACE_ON) != TCL_OK)  {
        return TCL_ERROR;
    }
    
    return TCL_OK;
}

int Ni488_Init(Tcl_Interp *interp)	/* Interpreter in which the package is
				         * to be made available. */
{

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::ask", NIBoard_ask,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::cac", NIBoard_cac,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::1cmd", NIBoard_1cmd,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::config", NIBoard_config,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::eos", NIBoard_eos,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::eot", NIBoard_eot,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::find", NIBoard_find,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::lines", NIBoard_lines,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::ln", NIBoard_ln,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::onl", NIBoard_onl,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::gts", NIBoard_gts,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    /*    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::sgnl", NIBoard_sgnl,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
    */

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::sic", NIBoard_sic,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::sre", NIBoard_sre,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::wrt", NIBoard_wrt,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::rd", NIBoard_rd,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::rdBin", NIBoard_rdBin,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::cnt", NIBoard_cnt,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::scruteSRQ", NIBoard_scruteSRQ,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateObjCommand(interp,
      "::GPIBBoard::TRACE_ON", NIBoard_TRACE_ON,
      (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);

    SRQstatus=0;

    if (Tcl_LinkVar(interp, "SRQstatus", (char *)&SRQstatus, TCL_LINK_INT) != TCL_OK) {
	return TCL_ERROR;
    }

    return TCL_OK;
}

