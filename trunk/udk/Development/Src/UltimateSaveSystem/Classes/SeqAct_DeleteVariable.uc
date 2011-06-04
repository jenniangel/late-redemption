//==============================================================================
// This SeqAction deletes all variables that are plugged into it if they exist
// in the file using the File Name specified by the SeqAct_SetCurrentSaveName.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_DeleteVariable extends SequenceAction;

var UltimateSaveSystem SaveSystem;

event Activated()
{
    local SequenceVariable SeqVar;
    local SeqVar_Int IntVar;
    local SeqVar_Float FloatVar;
    local SeqVar_Bool BoolVar;
    local SeqVar_Vector VectorVar;
    local SeqVar_String StringVar;
    local string CurrentSaveName;
    local array<SequenceObject> SaveNames;
    local bool bAllSuccess, bHasIntLinks, bHasFloatLinks, bHasBoolLinks, bHasVectLinks, bHasStringLinks;

    if (SaveSystem == None)
    {
        SaveSystem = class'UltimateSaveSystem'.static.GetSaveSystem();
    }


    bAllSuccess = True;

    ParentSequence.FindSeqObjectsByClass(class'SeqAct_SetCurrentSaveName', true, SaveNames);
    if (SaveNames.Length == 0)
    {
        `log("Tried to save variable, but could not find any SeqAct_SetCurrentSaveName");
        return;
    }
    else
        CurrentSaveName = SeqAct_SetCurrentSaveName(SaveNames[0]).GlobalKismetSaveFileName;


    // Check which links actually exist so that we don't load the lists that we won't need.
    // They would give us errors otherwise and cause us to activate always the Failure link.
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Int")
    {
        bHasIntLinks = True;
        break;
    }
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Float")
    {
        bHasFloatLinks = True;
        break;
    }
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Bool")
    {
        bHasBoolLinks = True;
        break;
    }
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Vector")
    {
        bHasVectLinks = True;
        break;
    }
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "String")
    {
        bHasStringLinks = True;
        break;
    }


    // INT
    if (bHasIntLinks)
    {
        bAllSuccess = SaveSystem.ULoadIntList(CurrentSaveName) && bAllSuccess;
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Int")
        {
            IntVar = SeqVar_Int(SeqVar);
            if (IntVar.VarName != '')
            {
                bAllSuccess = SaveSystem.UDeleteInt(IntVar.VarName) && bAllSuccess;
            }
            else
            {
                `log("Could not delete Int variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveIntList(CurrentSaveName) && bAllSuccess;
    }



    // FLOAT
    if (bHasFloatLinks)
    {
        bAllSuccess = SaveSystem.ULoadFloatList(CurrentSaveName) && bAllSuccess;
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Float")
        {
            FloatVar = SeqVar_Float(SeqVar);
            if (FloatVar.VarName != '')
            {
                bAllSuccess = SaveSystem.UDeleteFloat(FloatVar.VarName) && bAllSuccess;
            }
            else
            {
                `log("Could not delete Float variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveFloatList(CurrentSaveName) && bAllSuccess;
    }



    // BOOL
    if (bHasBoolLinks)
    {
        bAllSuccess = SaveSystem.ULoadBoolList(CurrentSaveName) && bAllSuccess;
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Bool")
        {
            BoolVar = SeqVar_Bool(SeqVar);
            if (BoolVar.VarName != '')
            {
                bAllSuccess = SaveSystem.UDeleteBool(BoolVar.VarName) && bAllSuccess;
            }
            else
            {
                `log("Could not delete Bool variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveBoolList(CurrentSaveName) && bAllSuccess;
    }



    // VECTOR
    if (bHasVectLinks)
    {
        bAllSuccess = SaveSystem.ULoadVectList(CurrentSaveName) && bAllSuccess;
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Vector")
        {
            VectorVar = SeqVar_Vector(SeqVar);
            if (VectorVar.VarName != '')
            {
                bAllSuccess = SaveSystem.UDeleteVect(VectorVar.VarName) && bAllSuccess;
            }
            else
            {
                `log("Could not delete Vector variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveVectList(CurrentSaveName) && bAllSuccess;
    }



    // STRING
    if (bHasStringLinks)
    {
        bAllSuccess = SaveSystem.ULoadStringList(CurrentSaveName) && bAllSuccess;
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "String")
        {
            StringVar = SeqVar_String(SeqVar);
            if (StringVar.VarName != '')
            {
                bAllSuccess = SaveSystem.UDeleteString(StringVar.VarName) && bAllSuccess;
            }
            else
            {
                `log("Could not delete String variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveStringList(CurrentSaveName) && bAllSuccess;
    }



    if (bAllSuccess)
        ActivateOutputLink(0);
    else
        ActivateOutputLink(1);
}


DefaultProperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Int",MinVars=0,MaxVars=999)
    VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Float",MinVars=0,MaxVars=999)
    VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",MinVars=0,MaxVars=999)
    VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Vector",MinVars=0,MaxVars=999)
    VariableLinks(4)=(ExpectedType=class'SeqVar_String',LinkDesc="String",MinVars=0,MaxVars=999)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")

    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Delete Variable"
    ObjCategory = "Save System"
}