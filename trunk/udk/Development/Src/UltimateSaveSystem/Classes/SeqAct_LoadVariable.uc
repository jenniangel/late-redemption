//==============================================================================
// This SeqAction loads all variables that are plugged into it from a file,
// using the File Name specified by the SeqAct_SetCurrentSaveName.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_LoadVariable extends SequenceAction;

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
        if (SaveSystem.ULoadIntList(CurrentSaveName))
        {
            foreach LinkedVariables(class'SequenceVariable', SeqVar, "Int")
            {
                IntVar = SeqVar_Int(SeqVar);
                if (IntVar.VarName != '')
                {
                    bAllSuccess = SaveSystem.UExportInt(IntVar.VarName, IntVar.IntValue) && bAllSuccess;
                }
                else
                {
                    `log("Could not load Int variable: No variable name");
                }
            }
        }
        else
            bAllSuccess = False;
    }



    // FLOAT
    if (bHasFloatLinks)
    {
        if (SaveSystem.ULoadFloatList(CurrentSaveName))
        {
            foreach LinkedVariables(class'SequenceVariable', SeqVar, "Float")
            {
                FloatVar = SeqVar_Float(SeqVar);
                if (FloatVar.VarName != '')
                {
                    bAllSuccess = SaveSystem.UExportFloat(FloatVar.VarName, FloatVar.FloatValue) && bAllSuccess;
                }
                else
                {
                    `log("Could not load Float variable: No variable name");
                }
            }
        }
        else
        {
            bAllSuccess = False;
        }
    }



    // BOOL
    if (bHasBoolLinks)
    {
        if (SaveSystem.ULoadBoolList(CurrentSaveName))
        {
            foreach LinkedVariables(class'SequenceVariable', SeqVar, "Bool")
            {
                BoolVar = SeqVar_Bool(SeqVar);
                if (BoolVar.VarName != '')
                {
                    bAllSuccess = SaveSystem.UExportBool(BoolVar.VarName, BoolVar.bValue) && bAllSuccess;
                }
                else
                {
                    `log("Could not load Bool variable: No variable name");
                }
            }
        }
        else
        {
            bAllSuccess = False;
        }
    }



    // VECTOR
    if (bHasVectLinks)
    {
        if (SaveSystem.ULoadVectList(CurrentSaveName))
        {
            foreach LinkedVariables(class'SequenceVariable', SeqVar, "Vector")
            {
                VectorVar = SeqVar_Vector(SeqVar);
                if (VectorVar.VarName != '')
                {
                    bAllSuccess = SaveSystem.UExportVect(VectorVar.VarName, VectorVar.VectValue) && bAllSuccess;
                }
                else
                {
                    `log("Could not load Vector variable: No variable name");
                }
            }
        }
        else
        {
            bAllSuccess = False;
        }
    }



    // STRING
    if (bHasStringLinks)
    {
        if (SaveSystem.ULoadStringList(CurrentSaveName))
        {
            foreach LinkedVariables(class'SequenceVariable', SeqVar, "String")
            {
                StringVar = SeqVar_String(SeqVar);
                if (StringVar.VarName != '')
                {
                     bAllSuccess = SaveSystem.UExportString(StringVar.VarName, StringVar.StrValue) && bAllSuccess;
                }
                else
                {
                    `log("Could not load String variable: No variable name");
                }
            }
        }
        else
        {
            bAllSuccess = False;
        }
    }



    if (bAllSuccess)
        ActivateOutputLink(0);
    else
        ActivateOutputLink(1);
}


DefaultProperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Int",bWriteable=True,MinVars=0,MaxVars=999)
    VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Float",bWriteable=True,MinVars=0,MaxVars=999)
    VariableLinks(2)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",bWriteable=True,MinVars=0,MaxVars=999)
    VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Vector",bWriteable=True,MinVars=0,MaxVars=999)
    VariableLinks(4)=(ExpectedType=class'SeqVar_String',LinkDesc="String",bWriteable=True,MinVars=0,MaxVars=999)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")

    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Load Variable"
    ObjCategory = "Save System"
}