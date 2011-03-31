/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class SeqCond_SwitchPlatform extends SequenceCondition
	native(Sequence);

cpptext
{
	virtual void Activated();
};


defaultproperties
{
	ObjName="Platform"
	ObjCategory="Switch Platform"

	OutputLinks(0)=(LinkDesc="Windows")
	OutputLinks(1)=(LinkDesc="Xbox360")
	OutputLinks(2)=(LinkDesc="PS3")
	OutputLinks(3)=(LinkDesc="iPhone")
	OutputLinks(4)=(LinkDesc="Android")
	OutputLinks(5)=(LinkDesc="Linux")
	OutputLinks(6)=(LinkDesc="MacOS")
	OutputLinks(7)=(LinkDesc="Desktop")
	OutputLinks(8)=(LinkDesc="Console (non-mobile)")
	OutputLinks(9)=(LinkDesc="Mobile")
	OutputLinks(10)=(LinkDesc="Default")

	VariableLinks.Empty
}
