/*
 * ------------------------------------------------------------------------
 *      PACKAGE:  [incr Tcl]
 *  DESCRIPTION:  Object-Oriented Extensions to Tcl
 *
 *  These procedures handle command and variable resolution
 *
 * ========================================================================
 *  AUTHOR:  Arnulf Wiedemann
 *
 *     RCS:  $Id: itclVarsAndCmds.c,v 1.1.2.1 2008/10/16 20:05:45 wiede Exp $
 * ========================================================================
 *           Copyright (c) Arnulf Wiedemann
 * ------------------------------------------------------------------------
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tclInt.h"
#include "itclInt.h"
#include "itclVCInt.h"

static void
ItclDeleteResolveInfo(
    ClientData clientData,
    Tcl_Interp *interp)
{
// FIXME need to free stuff here
}

int
ItclVarsAndCommandResolveInit(
    Tcl_Interp *interp)
{
    ItclResolvingInfo *iriPtr;

    /*
     *  Create the top-level data structure for tracking objects.
     *  Store this as "associated data" for easy access, but link
     *  it to the itcl namespace for ownership.
     */
    iriPtr = (ItclResolvingInfo*)ckalloc(sizeof(ItclResolvingInfo));
    memset(iriPtr, 0, sizeof(ItclResolvingInfo));
    iriPtr->interp = interp;
    Tcl_InitHashTable(&iriPtr->resolveVars, TCL_ONE_WORD_KEYS);
    Tcl_InitHashTable(&iriPtr->resolveCmds, TCL_ONE_WORD_KEYS);
    Tcl_InitHashTable(&iriPtr->objectVarsTables, TCL_ONE_WORD_KEYS);
    Tcl_InitHashTable(&iriPtr->objectCmdsTables, TCL_ONE_WORD_KEYS);

    Tcl_SetAssocData(interp, ITCL_RESOLVE_DATA,
        (Tcl_InterpDeleteProc*)ItclDeleteResolveInfo, (ClientData)iriPtr);
    Tcl_Preserve((ClientData)iriPtr);

    Itcl_SetClassCommandProtectionCallback(interp, NULL,
            Itcl_CheckClassCommandProtection);
    Itcl_SetClassVariableProtectionCallback(interp, NULL,
            Itcl_CheckClassVariableProtection);
    return TCL_OK;
}

//int Itcl_CheckClassVariableProtection(Tcl_Interp *interp, Tcl_Namespace *nsPtr,
//    const char *varName, int protection, int type);
//int Itcl_CheckClassCommandProtection(Tcl_Interp *interp, Tcl_Namespace *nsPtr,
//    const char *commandName, int protection, int type);

ClientData
Itcl_RegisterClassVariable(
    Tcl_Interp *interp,
    Tcl_Namespace *nsPtr,
    const char *varName,
    ClientData clientData)
{
    Tcl_HashTable *tablePtr;
    Tcl_HashEntry *hPtr;
    ItclResolvingInfo *iriPtr;
    int isNew;

//if (strcmp(varName, "this") == 0) {
//fprintf(stderr, "Itcl_RegisterClassVariable!%s!%s!%p!\n", nsPtr->fullName, varName, clientData);
//}
    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    hPtr = Tcl_CreateHashEntry(&iriPtr->resolveVars, nsPtr->fullName, &isNew);
    if (isNew) {
	tablePtr = (Tcl_HashTable *)ckalloc(sizeof(Tcl_HashTable));
	Tcl_InitHashTable(tablePtr, TCL_STRING_KEYS);
        Tcl_SetHashValue(hPtr, tablePtr);
        
    } else {
        tablePtr = Tcl_GetHashValue(hPtr);
    }
    hPtr = Tcl_CreateHashEntry(tablePtr, varName, &isNew);
    if (isNew) {
//fprintf(stderr, "Itcl_RegisterClassVariable!%s!%s!%p!\n", nsPtr->fullName, varName, clientData);
        Tcl_SetHashValue(hPtr, clientData);
    }
    return Tcl_GetHashValue(hPtr);
}

ClientData
Itcl_RegisterClassCommand(
    Tcl_Interp *interp,
    Tcl_Namespace *nsPtr,
    const char *cmdName,
    ClientData clientData)
{
    Tcl_HashEntry *hPtr;
    Tcl_HashTable *tablePtr;
    ItclResolvingInfo *iriPtr;
    int isNew;

    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    hPtr = Tcl_CreateHashEntry(&iriPtr->resolveCmds, nsPtr->fullName, &isNew);
    if (isNew) {
	tablePtr = (Tcl_HashTable *)ckalloc(sizeof(Tcl_HashTable));
	Tcl_InitHashTable(tablePtr, TCL_STRING_KEYS);
        Tcl_SetHashValue(hPtr, tablePtr);
        
    } else {
        tablePtr = Tcl_GetHashValue(hPtr);
    }
    hPtr = Tcl_CreateHashEntry(tablePtr, cmdName, &isNew);
//fprintf(stderr, "Itcl_RegisterClassCommand!%s!%s!tablePtr!%p!clientData!%p!\n", nsPtr->fullName, cmdName, tablePtr, clientData);
    if (isNew) {
        Tcl_SetHashValue(hPtr, clientData);
    }
    return Tcl_GetHashValue(hPtr);
}

Tcl_Var
Itcl_RegisterObjectVariable(
    Tcl_Interp *interp,
    ItclObject *ioPtr,
    const char *varName,
    ClientData clientData,
    Tcl_Var varPtr,
    Tcl_Namespace *nsPtr)
{
    Tcl_HashEntry *hPtr;
    ItclResolvingInfo *iriPtr;
    ObjectVarTableInfo *ovtiPtr;
    ObjectVarInfo *oviPtr;
    int isNew;

//fprintf(stderr, "Itcl_RegisterObjectVariable!%s!%s!%p!%p!\n", nsPtr->fullName, varName, ioPtr, clientData);
    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    hPtr = Tcl_CreateHashEntry(&iriPtr->objectVarsTables,
            (char *)ioPtr, &isNew);
    if (isNew) {
	ovtiPtr = (ObjectVarTableInfo *)ckalloc(sizeof(ObjectVarTableInfo));
	Tcl_InitHashTable(&ovtiPtr->varInfos, TCL_ONE_WORD_KEYS);
	ovtiPtr->tablePtr = &((Namespace *)nsPtr)->varTable;
        Tcl_SetHashValue(hPtr, ovtiPtr);
    } else {
        ovtiPtr = Tcl_GetHashValue(hPtr);
    }
//fprintf(stderr, "Itcl_RegisterObjectVariable!%s!%s!ovtiPtr!%p!clientData!%p!\n", nsPtr->fullName, varName, ovtiPtr, clientData);
    hPtr = Tcl_CreateHashEntry(&ovtiPtr->varInfos, (char *)clientData, &isNew);
    if (isNew) {
	oviPtr = (ObjectVarInfo *)ckalloc(sizeof(ObjectVarInfo));
	memset(oviPtr, 0, sizeof(ObjectVarInfo));
        Tcl_SetHashValue(hPtr, oviPtr);
    } else {
        oviPtr = Tcl_GetHashValue(hPtr);
    }
    oviPtr->clientData = clientData;
    oviPtr->ioPtr = ioPtr;
    if (varPtr == NULL) {
        varPtr = Tcl_NewNamespaceVar(interp, nsPtr, varName);
    }
    oviPtr->varPtr = varPtr;
//fprintf(stderr, "Itcl_RegisterObjectVariable!%p!\n", varPtr);
    return varPtr;
}

Tcl_Command
Itcl_RegisterObjectCommand(
    Tcl_Interp *interp,
    ItclObject *ioPtr,
    const char *cmdName,
    ClientData clientData,
    Tcl_Command cmdPtr,
    Tcl_Namespace *nsPtr)
{
    Tcl_HashEntry *hPtr;
    ItclResolvingInfo *iriPtr;
    ObjectCmdTableInfo *octiPtr;
    ObjectCmdInfo *ociPtr;
    int isNew;

//fprintf(stderr, "Itcl_RegisterObjectCommand!%s!%s!ioPtr!%p!clientData!%p!\n", nsPtr->fullName, cmdName, ioPtr, clientData);
    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    hPtr = Tcl_CreateHashEntry(&iriPtr->objectCmdsTables,
            (char *)ioPtr, &isNew);
    if (isNew) {
	octiPtr = (ObjectCmdTableInfo *)ckalloc(sizeof(ObjectCmdTableInfo));
	Tcl_InitHashTable(&octiPtr->cmdInfos, TCL_ONE_WORD_KEYS);
	octiPtr->tablePtr = &((Namespace *)nsPtr)->cmdTable;
        Tcl_SetHashValue(hPtr, octiPtr);
    } else {
        octiPtr = Tcl_GetHashValue(hPtr);
    }
//fprintf(stderr, "Itcl_RegisterObjectCommand!%s!%s!octiPtr!%p!clientData!%p!\n", nsPtr->fullName, varName, octiPtr, clientData);
    hPtr = Tcl_CreateHashEntry(&octiPtr->cmdInfos, (char *)clientData, &isNew);
    if (isNew) {
	ociPtr = (ObjectCmdInfo *)ckalloc(sizeof(ObjectCmdInfo));
	memset(ociPtr, 0, sizeof(ObjectCmdInfo));
        Tcl_SetHashValue(hPtr, ociPtr);
    } else {
        ociPtr = Tcl_GetHashValue(hPtr);
    }
    ociPtr->clientData = clientData;
    ociPtr->ioPtr = ioPtr;
    if (cmdPtr == NULL) {
//        cmdPtr = Tcl_NewNamespaceVar(interp, nsPtr, varName);
    }
    ociPtr->cmdPtr = cmdPtr;
//fprintf(stderr, "Itcl_RegisterObjectCommand!%p!\n", cmdPtr);
    return cmdPtr;
}

int
Itcl_SetClassVariableProtectionCallback(
    Tcl_Interp *interp,
    Tcl_Namespace *nsPtr,
    ItclCheckClassProtection *fcnPtr)
{
    ItclResolvingInfo *iriPtr;

    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    iriPtr->varProtFcn = fcnPtr;
    return TCL_OK;
}

int
Itcl_SetClassCommandProtectionCallback(
    Tcl_Interp *interp,
    Tcl_Namespace *nsPtr,
    ItclCheckClassProtection *fcnPtr)
{
    ItclResolvingInfo *iriPtr;

    iriPtr = Tcl_GetAssocData(interp, ITCL_RESOLVE_DATA, NULL);
    iriPtr->cmdProtFcn = fcnPtr;
    return TCL_OK;
}