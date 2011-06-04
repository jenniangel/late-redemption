//==============================================================================
// This SeqAction loads a value into a plain variable from the appropriate file.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_LoadValue extends SequenceAction;

var UltimateSaveSystem SaveSystem;

event Activated()
{
    local SequenceVariable SeqVar;
    local string PropName;
    local string CurrentSaveName;
    local array<SequenceObject> SaveNames;


    if (SaveSystem == None)
    {
        SaveSystem = class'UltimateSaveSystem'.static.GetSaveSystem();
    }


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


    // Get all names linked to us.
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Name")
    {
        PropName = SeqVar_String(SeqVar).StrValue;
        break;
    }

    if (PropName == "")
    {
        ActivateOutputLink(1);
        return;
    }

    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Value")
    {
        if (SeqVar_Int(SeqVar) != None)
        {
            if (SaveSystem.ULoadIntList(CurrentSaveName) && SaveSystem.UExportInt(PropName, SeqVar_Int(SeqVar).IntValue))
                ActivateOutputLink(0);
            else
                ActivateOutputLink(1);
        }
        else if (SeqVar_Float(SeqVar) != None)
        {
            if (SaveSystem.ULoadFloatList(CurrentSaveName) && SaveSystem.UExportFloat(PropName, SeqVar_Float(SeqVar).FloatValue))
                ActivateOutputLink(0);
            else
                ActivateOutputLink(1);
        }
        else if (SeqVar_Bool(SeqVar) != None)
        {
            if (SaveSystem.ULoadBoolList(CurrentSaveName) && SaveSystem.UExportBool(PropName, SeqVar_Bool(SeqVar).bValue))
                ActivateOutputLink(0);
            else
                ActivateOutputLink(1);
        }
        else if (SeqVar_Vector(SeqVar) != None)
        {
            if (SaveSystem.ULoadVectList(CurrentSaveName) && SaveSystem.UExportVect(PropName, SeqVar_Vector(SeqVar).VectValue))
                ActivateOutputLink(0);
            else
                ActivateOutputLink(1);
        }
        else if (SeqVar_String(SeqVar) != None)
        {
            if (SaveSystem.ULoadStringList(CurrentSaveName) && SaveSystem.UExportString(PropName, SeqVar_String(SeqVar).StrValue))
                ActivateOutputLink(0);
            else
                ActivateOutputLink(1);
        }
    }

    ActivateOutputLink(1);
}


defaultproperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SequenceVariable',LinkDesc="Value",MinVars=1,MaxVars=1,bAllowAnyType=True,bWriteable=True)
    VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="Name",MinVars=1,MaxVars=1)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")


    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Load Value"
    ObjCategory = "Save System"
}