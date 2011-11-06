/*
 * This file is (mostly) automatically generated from itcl.decls.
 */


#if defined(USE_ITCL_STUBS)

ITCLAPI const char *Itcl_InitStubs(
	Tcl_Interp *, const char *version, int exact);
#define Itcl_InitStubs(interp, version, exact) Itcl_InitStubs( \
	interp, ITCL_PATCH_LEVEL, 1)
#else

#define Itcl_InitStubs(interp, version, exact) Tcl_PkgRequire(interp,"itcl",version,exact)

#endif


/* !BEGIN!: Do not edit below this line. */

#define ITCL_STUBS_EPOCH 0
#define ITCL_STUBS_REVISION 144

#if !defined(USE_ITCL_STUBS)

/*
 * Exported function declarations:
 */

/* Slot 0 is reserved */
/* Slot 1 is reserved */
/* 2 */
ITCLAPI int		Itcl_RegisterC (Tcl_Interp * interp, 
				const char * name, Tcl_CmdProc * proc, 
				ClientData clientData, 
				Tcl_CmdDeleteProc * deleteProc);
/* 3 */
ITCLAPI int		Itcl_RegisterObjC (Tcl_Interp * interp, 
				const char * name, Tcl_ObjCmdProc * proc, 
				ClientData clientData, 
				Tcl_CmdDeleteProc * deleteProc);
/* 4 */
ITCLAPI int		Itcl_FindC (Tcl_Interp * interp, const char * name, 
				Tcl_CmdProc ** argProcPtr, 
				Tcl_ObjCmdProc ** objProcPtr, 
				ClientData * cDataPtr);
/* 5 */
ITCLAPI void		Itcl_InitStack (Itcl_Stack * stack);
/* 6 */
ITCLAPI void		Itcl_DeleteStack (Itcl_Stack * stack);
/* 7 */
ITCLAPI void		Itcl_PushStack (ClientData cdata, Itcl_Stack * stack);
/* 8 */
ITCLAPI ClientData	Itcl_PopStack (Itcl_Stack * stack);
/* 9 */
ITCLAPI ClientData	Itcl_PeekStack (Itcl_Stack * stack);
/* 10 */
ITCLAPI ClientData	Itcl_GetStackValue (Itcl_Stack * stack, int pos);
/* 11 */
ITCLAPI void		Itcl_InitList (Itcl_List * listPtr);
/* 12 */
ITCLAPI void		Itcl_DeleteList (Itcl_List * listPtr);
/* 13 */
ITCLAPI Itcl_ListElem*	Itcl_CreateListElem (Itcl_List * listPtr);
/* 14 */
ITCLAPI Itcl_ListElem*	Itcl_DeleteListElem (Itcl_ListElem * elemPtr);
/* 15 */
ITCLAPI Itcl_ListElem*	Itcl_InsertList (Itcl_List * listPtr, ClientData val);
/* 16 */
ITCLAPI Itcl_ListElem*	Itcl_InsertListElem (Itcl_ListElem * pos, 
				ClientData val);
/* 17 */
ITCLAPI Itcl_ListElem*	Itcl_AppendList (Itcl_List * listPtr, ClientData val);
/* 18 */
ITCLAPI Itcl_ListElem*	Itcl_AppendListElem (Itcl_ListElem * pos, 
				ClientData val);
/* 19 */
ITCLAPI void		Itcl_SetListValue (Itcl_ListElem * elemPtr, 
				ClientData val);
/* 20 */
ITCLAPI void		Itcl_EventuallyFree (ClientData cdata, 
				Tcl_FreeProc * fproc);
/* 21 */
ITCLAPI void		Itcl_PreserveData (ClientData cdata);
/* 22 */
ITCLAPI void		Itcl_ReleaseData (ClientData cdata);
/* 23 */
ITCLAPI Itcl_InterpState Itcl_SaveInterpState (Tcl_Interp* interp, 
				int status);
/* 24 */
ITCLAPI int		Itcl_RestoreInterpState (Tcl_Interp* interp, 
				Itcl_InterpState state);
/* 25 */
ITCLAPI void		Itcl_DiscardInterpState (Itcl_InterpState state);

#endif /* !defined(USE_ITCL_STUBS) */

typedef struct ItclStubHooks {
    const struct ItclIntStubs *itclIntStubs;
} ItclStubHooks;

typedef struct ItclStubs {
    int magic;
    int epoch;
    int revision;
    const struct ItclStubHooks *hooks;

    void (*reserved0)(void);
    void (*reserved1)(void);
    int (*itcl_RegisterC) (Tcl_Interp * interp, const char * name, Tcl_CmdProc * proc, ClientData clientData, Tcl_CmdDeleteProc * deleteProc); /* 2 */
    int (*itcl_RegisterObjC) (Tcl_Interp * interp, const char * name, Tcl_ObjCmdProc * proc, ClientData clientData, Tcl_CmdDeleteProc * deleteProc); /* 3 */
    int (*itcl_FindC) (Tcl_Interp * interp, const char * name, Tcl_CmdProc ** argProcPtr, Tcl_ObjCmdProc ** objProcPtr, ClientData * cDataPtr); /* 4 */
    void (*itcl_InitStack) (Itcl_Stack * stack); /* 5 */
    void (*itcl_DeleteStack) (Itcl_Stack * stack); /* 6 */
    void (*itcl_PushStack) (ClientData cdata, Itcl_Stack * stack); /* 7 */
    ClientData (*itcl_PopStack) (Itcl_Stack * stack); /* 8 */
    ClientData (*itcl_PeekStack) (Itcl_Stack * stack); /* 9 */
    ClientData (*itcl_GetStackValue) (Itcl_Stack * stack, int pos); /* 10 */
    void (*itcl_InitList) (Itcl_List * listPtr); /* 11 */
    void (*itcl_DeleteList) (Itcl_List * listPtr); /* 12 */
    Itcl_ListElem* (*itcl_CreateListElem) (Itcl_List * listPtr); /* 13 */
    Itcl_ListElem* (*itcl_DeleteListElem) (Itcl_ListElem * elemPtr); /* 14 */
    Itcl_ListElem* (*itcl_InsertList) (Itcl_List * listPtr, ClientData val); /* 15 */
    Itcl_ListElem* (*itcl_InsertListElem) (Itcl_ListElem * pos, ClientData val); /* 16 */
    Itcl_ListElem* (*itcl_AppendList) (Itcl_List * listPtr, ClientData val); /* 17 */
    Itcl_ListElem* (*itcl_AppendListElem) (Itcl_ListElem * pos, ClientData val); /* 18 */
    void (*itcl_SetListValue) (Itcl_ListElem * elemPtr, ClientData val); /* 19 */
    void (*itcl_EventuallyFree) (ClientData cdata, Tcl_FreeProc * fproc); /* 20 */
    void (*itcl_PreserveData) (ClientData cdata); /* 21 */
    void (*itcl_ReleaseData) (ClientData cdata); /* 22 */
    Itcl_InterpState (*itcl_SaveInterpState) (Tcl_Interp* interp, int status); /* 23 */
    int (*itcl_RestoreInterpState) (Tcl_Interp* interp, Itcl_InterpState state); /* 24 */
    void (*itcl_DiscardInterpState) (Itcl_InterpState state); /* 25 */
} ItclStubs;

#ifdef __cplusplus
extern "C" {
#endif
ITCLAPI const ItclStubs *itclStubsPtr;
#ifdef __cplusplus
}
#endif

#if defined(USE_ITCL_STUBS)

/*
 * Inline function declarations:
 */

/* Slot 0 is reserved */
/* Slot 1 is reserved */
#ifndef Itcl_RegisterC
#define Itcl_RegisterC \
	(itclStubsPtr->itcl_RegisterC) /* 2 */
#endif
#ifndef Itcl_RegisterObjC
#define Itcl_RegisterObjC \
	(itclStubsPtr->itcl_RegisterObjC) /* 3 */
#endif
#ifndef Itcl_FindC
#define Itcl_FindC \
	(itclStubsPtr->itcl_FindC) /* 4 */
#endif
#ifndef Itcl_InitStack
#define Itcl_InitStack \
	(itclStubsPtr->itcl_InitStack) /* 5 */
#endif
#ifndef Itcl_DeleteStack
#define Itcl_DeleteStack \
	(itclStubsPtr->itcl_DeleteStack) /* 6 */
#endif
#ifndef Itcl_PushStack
#define Itcl_PushStack \
	(itclStubsPtr->itcl_PushStack) /* 7 */
#endif
#ifndef Itcl_PopStack
#define Itcl_PopStack \
	(itclStubsPtr->itcl_PopStack) /* 8 */
#endif
#ifndef Itcl_PeekStack
#define Itcl_PeekStack \
	(itclStubsPtr->itcl_PeekStack) /* 9 */
#endif
#ifndef Itcl_GetStackValue
#define Itcl_GetStackValue \
	(itclStubsPtr->itcl_GetStackValue) /* 10 */
#endif
#ifndef Itcl_InitList
#define Itcl_InitList \
	(itclStubsPtr->itcl_InitList) /* 11 */
#endif
#ifndef Itcl_DeleteList
#define Itcl_DeleteList \
	(itclStubsPtr->itcl_DeleteList) /* 12 */
#endif
#ifndef Itcl_CreateListElem
#define Itcl_CreateListElem \
	(itclStubsPtr->itcl_CreateListElem) /* 13 */
#endif
#ifndef Itcl_DeleteListElem
#define Itcl_DeleteListElem \
	(itclStubsPtr->itcl_DeleteListElem) /* 14 */
#endif
#ifndef Itcl_InsertList
#define Itcl_InsertList \
	(itclStubsPtr->itcl_InsertList) /* 15 */
#endif
#ifndef Itcl_InsertListElem
#define Itcl_InsertListElem \
	(itclStubsPtr->itcl_InsertListElem) /* 16 */
#endif
#ifndef Itcl_AppendList
#define Itcl_AppendList \
	(itclStubsPtr->itcl_AppendList) /* 17 */
#endif
#ifndef Itcl_AppendListElem
#define Itcl_AppendListElem \
	(itclStubsPtr->itcl_AppendListElem) /* 18 */
#endif
#ifndef Itcl_SetListValue
#define Itcl_SetListValue \
	(itclStubsPtr->itcl_SetListValue) /* 19 */
#endif
#ifndef Itcl_EventuallyFree
#define Itcl_EventuallyFree \
	(itclStubsPtr->itcl_EventuallyFree) /* 20 */
#endif
#ifndef Itcl_PreserveData
#define Itcl_PreserveData \
	(itclStubsPtr->itcl_PreserveData) /* 21 */
#endif
#ifndef Itcl_ReleaseData
#define Itcl_ReleaseData \
	(itclStubsPtr->itcl_ReleaseData) /* 22 */
#endif
#ifndef Itcl_SaveInterpState
#define Itcl_SaveInterpState \
	(itclStubsPtr->itcl_SaveInterpState) /* 23 */
#endif
#ifndef Itcl_RestoreInterpState
#define Itcl_RestoreInterpState \
	(itclStubsPtr->itcl_RestoreInterpState) /* 24 */
#endif
#ifndef Itcl_DiscardInterpState
#define Itcl_DiscardInterpState \
	(itclStubsPtr->itcl_DiscardInterpState) /* 25 */
#endif

#endif /* defined(USE_ITCL_STUBS) */

/* !END!: Do not edit above this line. */
