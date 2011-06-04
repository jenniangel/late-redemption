//==============================================================================
// This SeqAction deletes all variables of the type that is plugged in as
// True boolean into the SeqAct.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_DeleteAllVariables extends SequenceAction;


var UltimateSaveSystem SaveSystem;

event Activated()
{
    local SeqVar_Bool BoolVar;
    local string CurrentSaveName;
    local array<SequenceObject> SaveNames;
    local bool bAllSuccess, bDeleteInt, bDeleteFloat, bDeleteBool, bDeleteVect, bDeleteString;

    if (SaveSystem == None)
    {
        SaveSystem = class'UltimateSaveSystem'.static.GetSaveSystem();
    }


    ParentSequence.FindSeqObjectsByClass(class'SeqAct_SetCurrentSaveName', true, SaveNames);
    if (SaveNames.Length == 0)
    {
        `log("Tried to clear variables, but could not find any SeqAct_SetCurrentSaveName");
        return;
    }
    else
        CurrentSaveName = SeqAct_SetCurrentSaveName(SaveNames[0]).GlobalKismetSaveFileName;


    // Should we delete all? If yes, skip the other calculations.
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "All")
    {
        if (BoolVar.bValue != 0)
        {
            if (SaveSystem.UDeleteCompleteSave(CurrentSaveName))
                ActivateOutputLink(0); // This will always be the case, unless there is not a _single_ file with that name.
                                       // In compare: using the other links will fail immediately if one of them doesn't exist.
            else
                ActivateOutputLink(1);

            return;
        }
    }



    // Whichs lists should be cleared.
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "Int")
    {
        if (BoolVar.bValue != 0)
        {
            bDeleteInt = True;
        }
    }
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "Float")
    {
        if (BoolVar.bValue != 0)
        {
            bDeleteFloat = True;
        }
    }
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "Bool")
    {
        if (BoolVar.bValue != 0)
        {
            bDeleteBool = True;
        }
    }
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "Vector")
    {
        if (BoolVar.bValue != 0)
        {
            bDeleteVect = True;
        }
    }
    foreach LinkedVariables(class'SeqVar_Bool', BoolVar, "String")
    {
        if (BoolVar.bValue != 0)
        {
            bDeleteString = True;
        }
    }


    bAllSuccess = True;

    // INT
    if (bDeleteInt)
    {
        bAllSuccess = SaveSystem.UDeleteAllInt(CurrentSaveName) && bAllSuccess;
    }



    // FLOAT
    if (bDeleteFloat)
    {
        bAllSuccess = SaveSystem.UDeleteAllFloat(CurrentSaveName) && bAllSuccess;
    }



    // BOOL
    if (bDeleteBool)
    {
        bAllSuccess = SaveSystem.UDeleteAllBool(CurrentSaveName) && bAllSuccess;
    }



    // VECTOR
    if (bDeleteVect)
    {
        bAllSuccess = SaveSystem.UDeleteAllVect(CurrentSaveName) && bAllSuccess;
    }



    // STRING
    if (bDeleteString)
    {
        bAllSuccess = SaveSystem.UDeleteAllString(CurrentSaveName) && bAllSuccess;
    }



    if (bAllSuccess)
        ActivateOutputLink(0);
    else
        ActivateOutputLink(1);
}


DefaultProperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Int",MinVars=0,MaxVars=1,bWriteable=False)
    VariableLinks(1)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Float",MinVars=0,MaxVars=1,bWriteable=False)
    VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",MinVars=0,MaxVars=1,bWriteable=False)
    VariableLinks(3)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Vector",MinVars=0,MaxVars=1,bWriteable=False)
    VariableLinks(4)=(ExpectedType=class'SeqVar_Bool',LinkDesc="String",MinVars=0,MaxVars=1,bWriteable=False)
    VariableLinks(5)=(ExpectedType=class'SeqVar_Bool',LinkDesc="All",MinVars=0,MaxVars=1,bWriteable=False)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")

    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Delete All Variables"
    ObjCategory = "Save System"
}