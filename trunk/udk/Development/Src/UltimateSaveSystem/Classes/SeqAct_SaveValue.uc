//==============================================================================
// This SeqAction saves a plain variable of any type plugged into this under the
// plugged in names in the propriate file.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_SaveValue extends SequenceAction;

var UltimateSaveSystem SaveSystem;

event Activated()
{
    local SequenceVariable SeqVar;
    local array<string> Names;
    local string CurrentSaveName;
    local array<SequenceObject> SaveNames;
    local string CurrentPropertyName;
    local bool bAllSuccess;


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


    // Get all names linked to us.
    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Name")
    {
        if (SeqVar_String(SeqVar).StrValue != "")
            Names[Names.Length] = SeqVar_String(SeqVar).StrValue;
    }

    if (Names.Length <= 0)
    {
        ActivateOutputLink(1);
        return;
    }

    foreach LinkedVariables(class'SequenceVariable', SeqVar, "Value")
    {
        if (SeqVar_Int(SeqVar) != None)
        {
            SaveSystem.ULoadIntList(CurrentSaveName);
            foreach Names(CurrentPropertyName)
            {
                SaveSystem.UImportInt(SeqVar_Int(SeqVar).IntValue, CurrentPropertyName);
            }
            bAllSuccess = SaveSystem.USaveIntList(CurrentSaveName) && bAllSuccess;
        }
        else if (SeqVar_Float(SeqVar) != None)
        {
            SaveSystem.ULoadFloatList(CurrentSaveName);
            foreach Names(CurrentPropertyName)
            {
                SaveSystem.UImportFloat(SeqVar_Float(SeqVar).FloatValue, CurrentPropertyName);
            }
            bAllSuccess = SaveSystem.USaveFloatList(CurrentSaveName) && bAllSuccess;
        }
        else if (SeqVar_Bool(SeqVar) != None)
        {
            SaveSystem.ULoadBoolList(CurrentSaveName);
            foreach Names(CurrentPropertyName)
            {
                SaveSystem.UImportBool(SeqVar_Bool(SeqVar).bValue, CurrentPropertyName);
            }
            bAllSuccess = SaveSystem.USaveBoolList(CurrentSaveName) && bAllSuccess;
        }
        else if (SeqVar_Vector(SeqVar) != None)
        {
            SaveSystem.ULoadVectList(CurrentSaveName);
            foreach Names(CurrentPropertyName)
            {
                SaveSystem.UImportVect(SeqVar_Vector(SeqVar).VectValue, CurrentPropertyName);
            }
            bAllSuccess = SaveSystem.USaveVectList(CurrentSaveName) && bAllSuccess;
        }
        else if (SeqVar_String(SeqVar) != None)
        {
            SaveSystem.ULoadStringList(CurrentSaveName);
            foreach Names(CurrentPropertyName)
            {
                SaveSystem.UImportString(SeqVar_String(SeqVar).StrValue, CurrentPropertyName);
            }
            bAllSuccess = SaveSystem.USaveStringList(CurrentSaveName) && bAllSuccess;
        }
    }

    if (bAllSuccess)
        ActivateOutputLink(0);
    else
        ActivateOutputLink(1);
}


defaultproperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SequenceVariable',LinkDesc="Value",MinVars=1,MaxVars=1,bAllowAnyType=True)
    VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="Name",MinVars=1,MaxVars=999)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")

    bCallHandler = False
    bAutoActivateOutputLinks=True
    ObjName = "Save Value"
    ObjCategory = "Save System"
}