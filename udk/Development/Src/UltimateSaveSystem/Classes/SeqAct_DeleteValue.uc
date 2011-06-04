//==============================================================================
// This SeqAction deletes value by their name from the appropriate file.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_DeleteValue extends SequenceAction;

var() enum VariableType {VT_Int, VT_Float, VT_Bool, VT_Vector, VT_String} TargetType;
var UltimateSaveSystem SaveSystem;

event Activated()
{
    local SequenceVariable SeqVar;
    local array<string> Names;
    local string CurrentSaveName;
    local array<SequenceObject> SaveNames;
    local bool bAllSuccess;
    local string CurrentPropertyName;


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


    Switch(TargetType)
    {
        case VT_Int:
            if (SaveSystem.ULoadIntList(CurrentSaveName))
            {
                foreach Names(CurrentPropertyName)
                {
                    bAllSuccess = SaveSystem.UDeleteInt(CurrentPropertyName) && bAllSuccess;
                }

                bAllSuccess = SaveSystem.USaveIntList(CurrentSaveName) && bAllSuccess;

                if (bAllSuccess)
                    ActivateOutputLink(0);
                else
                    ActivateOutputLink(1);
            }
            else
            {
                ActivateOutputLink(1);
            }
            return;

        case VT_Float:
            if (SaveSystem.ULoadFloatList(CurrentSaveName))
            {
                foreach Names(CurrentPropertyName)
                {
                    bAllSuccess = SaveSystem.UDeleteFloat(CurrentPropertyName) && bAllSuccess;
                }

                bAllSuccess = SaveSystem.USaveFloatList(CurrentSaveName) && bAllSuccess;

                if (bAllSuccess)
                    ActivateOutputLink(0);
                else
                    ActivateOutputLink(1);
            }
            else
            {
                ActivateOutputLink(1);
            }
            return;

        case VT_Bool:
            if (SaveSystem.ULoadBoolList(CurrentSaveName))
            {
                foreach Names(CurrentPropertyName)
                {
                    bAllSuccess = SaveSystem.UDeleteBool(CurrentPropertyName) && bAllSuccess;
                }

                bAllSuccess = SaveSystem.USaveBoolList(CurrentSaveName) && bAllSuccess;

                if (bAllSuccess)
                    ActivateOutputLink(0);
                else
                    ActivateOutputLink(1);
            }
            else
            {
                ActivateOutputLink(1);
            }
            return;

        case VT_Vector:
            if (SaveSystem.ULoadVectList(CurrentSaveName))
            {
                foreach Names(CurrentPropertyName)
                {
                    bAllSuccess = SaveSystem.UDeleteVect(CurrentPropertyName) && bAllSuccess;
                }

                bAllSuccess = SaveSystem.USaveVectList(CurrentSaveName) && bAllSuccess;

                if (bAllSuccess)
                    ActivateOutputLink(0);
                else
                    ActivateOutputLink(1);
            }
            else
            {
                ActivateOutputLink(1);
            }
            return;

        case VT_String:
            if (SaveSystem.ULoadStringList(CurrentSaveName))
            {
                foreach Names(CurrentPropertyName)
                {
                    bAllSuccess = SaveSystem.UDeleteString(CurrentPropertyName) && bAllSuccess;
                }

                bAllSuccess = SaveSystem.USaveStringList(CurrentSaveName) && bAllSuccess;

                if (bAllSuccess)
                    ActivateOutputLink(0);
                else
                    ActivateOutputLink(1);
            }
            else
            {
                ActivateOutputLink(1);
            }
            return;
    }

    ActivateOutputLink(1);
}


defaultproperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="Name",MinVars=1,MaxVars=999)

    OutputLinks.Empty
    OutputLinks(0)=(LinkDesc="Success")
    OutputLinks(1)=(LinkDesc="Failure")


    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Delete Value"
    ObjCategory = "Save System"
}