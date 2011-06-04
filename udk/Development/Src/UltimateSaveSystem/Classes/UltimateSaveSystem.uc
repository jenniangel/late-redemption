//==============================================================================
// This class implements an easy to use system to save any Int, Float, Bool,
// Vector or String into a DLL with a unique name and load it from there again.
//
// Copyright 2010 by Dennis Iffländer
// MappingCrocodile@googlemail.com
//
// Many thanks to Andre "[WuTz]!" Taulien, for helping me a lot with the C++ part
// of this, and Renan "Ayalaskin" Lopes, for creating the DLLBind Save System on
// which this system is basing.
//
//------------------------------------------------------------------------------
// CC(by-sa) License
//
// This class, the Kismet-related classes in this package and the
// UltimateSaveSystem-DLL, including their source code, are provided under the
// Creative Commons Attribution-ShareAlike 2.0 license.
//
// That means you may do whatever you want with the contents of this package if
// you give credits to Dennis Iffländer, Andre Taulien and Renan Lopes where all
// the credit is given in your project or another propriate way.
// And you have to make any modifications to this code available under the same
// terms I stated here. If you don't apply changes, it is enough to point people
// who would like to use this to the page on the Unreal Wiki.
//
// This comment block has to remain unchanged.
//==============================================================================
class UltimateSaveSystem extends Actor DLLBind(UltimateSaveSystem)
    notplaceable;

// The max number of characters in one string
var const int MAX_STRING_LENGHT;
var const string FILE_EXTENSION;


/* Here we declare the functions we want to retrieve from the DLL.
 * Keep in mind that "Import" and "Export" describe how it looks from the DLL's point of view!!!
 */
dllimport final function ImportFloat(float Value, string PropertyName);
dllimport final function bool SaveFloatList(string SaveName);
dllimport final function bool LoadFloatList(string SaveName);
dllimport final function bool ExportFloat(string PropertyName, out float OutValue);
dllimport final function bool DeleteFloat(string PropertyName);

dllimport final function ImportInt(int Value, string PropertyName);
dllimport final function bool SaveIntList(string SaveName);
dllimport final function bool LoadIntList(string SaveName);
dllimport final function bool ExportInt(string PropertyName, out int OutValue);
dllimport final function bool DeleteInt(string PropertyName);

dllimport final function ImportBool(int Value, string PropertyName);
dllimport final function bool SaveBoolList(string SaveName);
dllimport final function bool LoadBoolList(string SaveName);
dllimport final function bool ExportBool(string PropertyName, out int OutValue);
dllimport final function bool DeleteBool(string PropertyName);

dllimport final function ImportVect(vector Value, string PropertyName);
dllimport final function bool SaveVectList(string SaveName);
dllimport final function bool LoadVectList(string SaveName);
dllimport final function bool ExportVect(string PropertyName, out vector OutValue);
dllimport final function bool DeleteVect(string PropertyName);

dllimport final function ImportString(string Value, string PropertyName, int StringSplitNum);
dllimport final function bool SaveStringList(string SaveName);
dllimport final function bool LoadStringList(string SaveName);
dllimport final function bool ExportString(string PropertyName, out string OutValue, out int StringSplitNum, int SkipEntries);
dllimport final function bool DeleteString(string PropertyName);

dllimport final function bool DeleteSaveFile(string SaveName);


/* @DLL functions:
 * -Import*X* will load a name-value pair of type X into a dynamic array inside the DLL.
 *  The entry is in the array now, but it's not yet saved.
 *  If an entry with the given name already exists in that array, only it's
 *  value will be changed.
 *
 * -Save*X*List will save the whole array into a file with the specified name.
 *  The different files are independent per datatype and list, so if you add
 *  entries to a bool and int list, you have to save both lists manually.
 *  True is returned if the file could be saved/created successfully.
 *
 * -Load*X*List will load an array from the file with the matching name.
 *  A loaded list will stay valid until a new map is loaded or you load a list
 *  of the same type from another file.
 *  True is returned if a file with the save name was found.
 *
 * -Export*X* will look for an entry with the matching property name and returns
 *  the associated value as out parameter.
 *  True is returned if an entry with the specified name was found (you can also
 *  use this as test to see if a certain name-value pair already exists).
 *
 * -Delete*X* will look for an entry with the matching property name and remove
 * it from the array.
 * True is returned if an entry was found.
 *
 * -DeleteAll*X* will delete the whole file that holds this datatype.
 * A new one will be created as soon as something needs to be saved again.
 * Returns True if the file was deleted successfully.
 */


// A way to let other classes get a reference to us.
static function UltimateSaveSystem GetSaveSystem()
{
    local UltimateSaveSystem USS;

    foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'UltimateSaveSystem', USS){break;} // Out-parameter magic!

    if (USS == None) // Still none? Then be the first to spawn one!
        USS = class'WorldInfo'.static.GetWorldInfo().Spawn(class'UltimateSaveSystem');

    return USS;
}

// Get rid of all files that belong to the SaveFile with the given name.
function bool UDeleteCompleteSave(coerce string SaveName)
{
    local bool bAllSuccess;

    bAllSuccess = False;

    bAllSuccess = UDeleteAllInt(SaveName) || bAllSuccess;
    bAllSuccess = UDeleteAllFloat(SaveName) || bAllSuccess;
    bAllSuccess = UDeleteAllBool(SaveName) || bAllSuccess;
    bAllSuccess = UDeleteAllVect(SaveName) || bAllSuccess;
    bAllSuccess = UDeleteAllString(SaveName) || bAllSuccess;

    return bAllSuccess;
}


function UImportInt(int Value, coerce string PropertyName)
{
    ImportInt(Value, PropertyName);
}

function UImportIntArray(array<int> Values, coerce string ArrayName)
{
    local int i;

    for (i = 0; i < Values.Length; i++)
    {
        UImportInt(Values[i], Mid(ArrayName, 0) $ i);
    }
}

function bool USaveIntList(coerce string SaveName)
{
    return SaveIntList(Mid(SaveName, 0) $ "_i" $ FILE_EXTENSION);
}

function bool ULoadIntList(coerce string SaveName)
{
    return LoadIntList(Mid(SaveName, 0) $ "_i" $ FILE_EXTENSION);
}

function bool UExportInt(coerce string PropertyName, out int OutValue)
{
    return ExportInt(PropertyName, OutValue);
}

function bool UExportIntArray(coerce string ArrayName, out array<int> OutValues)
{
    local bool bSuccess;
    local int Temp;
    OutValues.Length = 0;

    while (UExportInt(Mid(ArrayName, 0) $ OutValues.Length, Temp))
    {
        OutValues[OutValues.Length] = Temp;
        bSuccess = True;
    }

    return bSuccess;
}

function bool UDeleteInt(coerce string PropertyName)
{
    return DeleteInt(PropertyName);
}

function bool UDeleteIntArray(coerce string ArrayName)
{
    local bool bFoundValue, bFoundOne;
    local int i;
    bFoundValue = True;

    for (i = 0; bFoundValue; i++)
    {
        if (UDeleteInt(Mid(ArrayName, 0) $ i))
        {
            bFoundOne = True;
        }
        else
        {
            bFoundValue = False;
        }
    }

    return bFoundOne;
}

function bool UDeleteAllInt(coerce string SaveName)
{
    return DeleteSaveFile(Mid(SaveName, 0) $ "_i" $ FILE_EXTENSION);
}



function UImportFloat(float Value, coerce string PropertyName)
{
    ImportFloat(Value, PropertyName);
}

function UImportFloatArray(array<float> Values, coerce string ArrayName)
{
    local int i;

    for (i = 0; i < Values.Length; i++)
    {
        UImportFloat(Values[i], Mid(ArrayName, 0) $ i);
    }
}

function bool USaveFloatList(coerce string SaveName)
{
    // We need to do the Mid-stuff in order to create a copy of the string.
    // Otherwise the DLL would modify (corrupt) our original string because it's only passed by reference.
    return SaveFloatList(Mid(SaveName, 0) $ "_f" $ FILE_EXTENSION);
}

function bool ULoadFloatList(coerce string SaveName)
{
    return LoadFloatList(Mid(SaveName, 0) $ "_f" $ FILE_EXTENSION);
}

function bool UExportFloat(coerce string PropertyName, out float OutValue)
{
    return ExportFloat(PropertyName, OutValue);
}

function bool UExportFloatArray(coerce string ArrayName, out array<float> OutValues)
{
    local bool bSuccess;
    local float Temp;
    OutValues.Length = 0;

    while (UExportFloat(Mid(ArrayName, 0) $ OutValues.Length, Temp))
    {
        OutValues[OutValues.Length] = Temp;
        bSuccess = True;
    }

    return bSuccess;
}

function bool UDeleteFloat(coerce string PropertyName)
{
    return DeleteFloat(PropertyName);
}

function bool UDeleteFloatArray(coerce string ArrayName)
{
    local bool bFoundValue, bFoundOne;
    local int i;
    bFoundValue = True;

    for (i = 0; bFoundValue; i++)
    {
        if (UDeleteFloat(Mid(ArrayName, 0) $ i))
        {
            bFoundOne = True;
        }
        else
        {
            bFoundValue = False;
        }
    }

    return bFoundOne;
}

function bool UDeleteAllFloat(coerce string SaveName)
{
    return DeleteSaveFile(Mid(SaveName, 0) $ "_f" $ FILE_EXTENSION);
}



// Attention! The for consistency reasons is the first parameter an Int.
function UImportBool(int Value, coerce string PropertyName)
{
        ImportBool(Value, PropertyName);
}

function UImportBoolArray(array<int> Values, coerce string ArrayName)
{
    local int i;

    for (i = 0; i < Values.Length; i++)
    {
        UImportBool(Values[i], Mid(ArrayName, 0) $ i);
    }
}

function bool USaveBoolList(coerce string SaveName)
{
    return SaveBoolList(Mid(SaveName, 0) $ "_b" $ FILE_EXTENSION);
}

function bool ULoadBoolList(coerce string SaveName)
{
    return LoadBoolList(Mid(SaveName, 0) $ "_b" $ FILE_EXTENSION);
}

// Attention! The out value can not be a bool, so it has to be an Int.
function bool UExportBool(coerce string PropertyName, out int OutValue)
{
    return ExportBool(PropertyName, OutValue);
}

function bool UExportBoolArray(coerce string ArrayName, out array<int> OutValues)
{
    local bool bSuccess;
    local int Temp;
    OutValues.Length = 0;

    while (UExportBool(Mid(ArrayName, 0) $ OutValues.Length, Temp))
    {
        OutValues[OutValues.Length] = Temp;
        bSuccess = True;
    }

    return bSuccess;
}

function bool UDeleteBool(coerce string PropertyName)
{
    return DeleteBool(PropertyName);
}

function bool UDeleteBoolArray(coerce string ArrayName)
{
    local bool bFoundValue, bFoundOne;
    local int i;
    bFoundValue = True;

    for (i = 0; bFoundValue; i++)
    {
        if (UDeleteBool(Mid(ArrayName, 0) $ i))
        {
            bFoundOne = True;
        }
        else
        {
            bFoundValue = False;
        }
    }

    return bFoundOne;
}

function bool UDeleteAllBool(coerce string SaveName)
{
    return DeleteSaveFile(Mid(SaveName, 0) $ "_b" $ FILE_EXTENSION);
}



function UImportVect(vector Value, coerce string PropertyName)
{
    ImportVect(Value, PropertyName);
}

function UImportVectArray(array<vector> Values, coerce string ArrayName)
{
    local int i;

    for (i = 0; i < Values.Length; i++)
    {
        UImportVect(Values[i], Mid(ArrayName, 0) $ i);
    }
}

function bool USaveVectList(coerce string SaveName)
{
    return SaveVectList(Mid(SaveName, 0) $ "_v" $ FILE_EXTENSION);
}

function bool ULoadVectList(coerce string SaveName)
{
    return LoadVectList(Mid(SaveName, 0) $ "_v" $ FILE_EXTENSION);
}

function bool UExportVect(coerce string PropertyName, out vector OutValue)
{
    return ExportVect(PropertyName, OutValue);
}

function bool UExportVectArray(coerce string ArrayName, out array<vector> OutValues)
{
    local bool bSuccess;
    local vector Temp;
    OutValues.Length = 0;

    while (UExportVect(Mid(ArrayName, 0) $ OutValues.Length, Temp))
    {
        OutValues[OutValues.Length] = Temp;
        bSuccess = True;
    }

    return bSuccess;
}

function bool UDeleteVect(coerce string PropertyName)
{
    return DeleteVect(PropertyName);
}

function bool UDeleteVectArray(coerce string ArrayName)
{
    local bool bFoundValue, bFoundOne;
    local int i;
    bFoundValue = True;

    for (i = 0; bFoundValue; i++)
    {
        if (UDeleteVect(Mid(ArrayName, 0) $ i))
        {
            bFoundOne = True;
        }
        else
        {
            bFoundValue = False;
        }
    }

    return bFoundOne;
}

function bool UDeleteAllVect(coerce string SaveName)
{
    return DeleteSaveFile(Mid(SaveName, 0) $ "_v" $ FILE_EXTENSION);
}



// This has to be a singular function to assure that the strings are consecutive in the file!
// Keep it in mind when you use this.
singular function UImportString(string Value, coerce string PropertyName)
{
    // We split the UScript string into sub-strings with a fixed lenght and
    // import them in row. The third parameter of the C++ string import tells
    // how many sub-strings after the imported one still belong to that string.

    local array<string> Splits;
    local int i, j;

    for (i = 0; i <= Len(Value) / MAX_STRING_LENGHT; i++)
    {
        Splits[i] = Mid(Value, i*MAX_STRING_LENGHT, MAX_STRING_LENGHT);
    }

    // Strings should be deleted with all their parts instead of being overwritten.
    // It's otherwise hard to keep track of the other parts if the length of the string changes drastically.
    // We also omit thereby the check for existing entries in the DLL, speeding it up a bit.
    UDeleteString(PropertyName);

    for (j = 0; j < Splits.Length; j++)
    {
        ImportString(Splits[j], PropertyName, Splits.Length - 1 - j);
    }
}

function UImportStringArray(array<string> Values, coerce string ArrayName)
{
    local int i;

    for (i = 0; i < Values.Length; i++)
    {
        UImportString(Values[i], Mid(ArrayName, 0) $ i);
    }
}

function bool USaveStringList(coerce string SaveName)
{
    return SaveStringList(Mid(SaveName, 0) $ "_s" $ FILE_EXTENSION);
}

function bool ULoadStringList(coerce string SaveName)
{
    return LoadStringList(Mid(SaveName, 0) $ "_s" $ FILE_EXTENSION);
}

// Lots of magic behind the scenes.
function bool UExportString(coerce string PropertyName, out string OutValue)
{
    local array<string> Splits;
    local string CurrentSplit;
    local int i, RemainingSplits;
    RemainingSplits = 1;

    while (RemainingSplits > 0) // RemainingSplits is read from each DLL array entry.
    {

        CurrentSplit = "        ";
        for (i = 0; i < (MAX_STRING_LENGHT/8); i++) // This reduces the number of iterations.
        {
            CurrentSplit @= "        ";
        }
        if (!ExportString(PropertyName, CurrentSplit, RemainingSplits, Splits.Length))
            return false;

        Splits[Splits.Length] = CurrentSplit;
    }
    OutValue = "";
    for (i = 0; i < Splits.Length; i++)
        OutValue $= Splits[i];
    return true;
}

function bool UExportStringArray(coerce string ArrayName, out array<string> OutValues)
{
    local bool bSuccess;
    local string Temp;
    OutValues.Length = 0;

    while (UExportString(Mid(ArrayName, 0) $ OutValues.Length, Temp))
    {
        OutValues[OutValues.Length] = Temp;
        bSuccess = True;
    }

    return bSuccess;
}

function bool UDeleteString(coerce string PropertyName)
{
    return DeleteString(PropertyName);
}

function bool UDeleteStringArray(coerce string ArrayName)
{
    local bool bFoundValue, bFoundOne;
    local int i;
    bFoundValue = True;

    for (i = 0; bFoundValue; i++)
    {
        if (UDeleteString(Mid(ArrayName, 0) $ i))
        {
            bFoundOne = True;
        }
        else
        {
            bFoundValue = False;
        }
    }

    return bFoundOne;
}

function bool UDeleteAllString(coerce string SaveName)
{
    return DeleteSaveFile(Mid(SaveName, 0) $ "_s" $ FILE_EXTENSION);
}


DefaultProperties
{
    MAX_STRING_LENGHT = 256
    FILE_EXTENSION = ".sav"
    bHidden = True
}