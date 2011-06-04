//==============================================================================
// This SeqAction allows to specify the file name under which the variables are
// saved and where they are loaded from. There is always only one file name
// active at a time, so you can use these to switch between them.
//
// IMPORTANT: You need to have at least one of these in your Kismet window in
// order to save or load variables at all!
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//==============================================================================
class SeqAct_SetCurrentSaveName extends SequenceAction;

var string GlobalKismetSaveFileName;

event Activated()
{
    local SeqVar_String StringVar;
    local array<SequenceObject> OtherSaveNames;
    local int i;

    foreach LinkedVariables(class'SeqVar_String', StringVar, "File Name")
    {
        GlobalKismetSaveFileName = StringVar.StrValue;

        // Update the File Name in all our brother classes.
        ParentSequence.FindSeqObjectsByClass(Class, true, OtherSaveNames);
        for (i = 0; i < OtherSaveNames.length; i++)
        {
            if (SeqAct_SetCurrentSaveName(OtherSaveNames[i]) != self)
            {
                SeqAct_SetCurrentSaveName(OtherSaveNames[i]).GlobalKismetSaveFileName = GlobalKismetSaveFileName;
            }
        }

        break;
    }

    ActivateOutputLink(0);
}


DefaultProperties
{
    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="File Name")

    bCallHandler = False
    bAutoActivateOutputLinks=False
    ObjName = "Set Save File Name"
    ObjCategory = "Save System"
}