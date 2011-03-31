/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class MobileGame extends FrameworkGame;

defaultproperties
{
	PlayerControllerClass=class'MobileGame.MobilePC'
	DefaultPawnClass=class'MobileGame.MobilePawn'
	HUDType=class'GameFramework.MobileHUD'
	bRestartLevel=false
	bWaitingToStartMatch=true
	bDelayedStart=false
}



