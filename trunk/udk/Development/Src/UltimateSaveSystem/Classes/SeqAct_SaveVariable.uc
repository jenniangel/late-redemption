//==============================================================================
// This SeqAction saves all variables that are plugged into it into a file,
// using the File Name specified by the SeqAct_SetCurrentSaveName.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_SaveVariable extends SequenceAction;

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
    {
        CurrentSaveName = SeqAct_SetCurrentSaveName(SaveNames[0]).GlobalKismetSaveFileName;
    }


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
        SaveSystem.ULoadIntList(CurrentSaveName);
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Int")
        {
            IntVar = SeqVar_Int(SeqVar);
            if (IntVar == None)
                continue;

            if (IntVar.VarName != '')
            {
                SaveSystem.UImportInt(IntVar.IntValue, IntVar.VarName);
            }
            else
            {
                `log("Could not save Int variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveIntList(CurrentSaveName) && bAllSuccess;
    }



    // FLOAT
    if (bHasFloatLinks)
    {
        SaveSystem.ULoadFloatList(CurrentSaveName);
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Float")
        {
            FloatVar = SeqVar_Float(SeqVar);
            if (FloatVar == None)
                continue;

            if (FloatVar.VarName != '')
            {
                SaveSystem.UImportFloat(FloatVar.FloatValue, FloatVar.VarName);
            }
            else
            {
                `log("Could not save Float variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveFloatList(CurrentSaveName) && bAllSuccess;
    }



    // BOOL
    if (bHasBoolLinks)
    {
        SaveSystem.ULoadBoolList(CurrentSaveName);
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Bool")
        {
            BoolVar = SeqVar_Bool(SeqVar);
            if (BoolVar == None)
                continue;

            if (BoolVar.VarName != '')
            {
                SaveSystem.UImportBool(BoolVar.bValue, BoolVar.VarName);
            }
            else
            {
                `log("Could not save Bool variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveBoolList(CurrentSaveName) && bAllSuccess;
    }



    // VECTOR
    if (bHasVectLinks)
    {
        SaveSystem.ULoadVectList(CurrentSaveName);
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "Vector")
        {
            VectorVar = SeqVar_Vector(SeqVar);
            if (VectorVar == None)
                continue;

            if (VectorVar.VarName != '')
            {
                SaveSystem.UImportVect(VectorVar.VectValue, VectorVar.VarName);
            }
            else
            {
                `log("Could not save Vector variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveVectList(CurrentSaveName) && bAllSuccess;
    }



    // STRING
    if (bHasStringLinks)
    {
        SaveSystem.ULoadStringList(CurrentSaveName);
        foreach LinkedVariables(class'SequenceVariable', SeqVar, "String")
        {
            StringVar = SeqVar_String(SeqVar);
            if (StringVar == None)
                continue;

            if (StringVar.VarName != '')
            {
                SaveSystem.UImportString(StringVar.StrValue, StringVar.VarName);
            }
            else
            {
                `log("Could not save String variable: No variable name");
            }
        }
        bAllSuccess = SaveSystem.USaveStringList(CurrentSaveName) && bAllSuccess;
    }



    if (bAllSuccess)
        ActivateOutputLink(0);
    else
        ActivateOutputLink(1);
}


defaultproperties
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
    ObjName = "Save Variable"
    ObjCategory = "Save System"
}