class LRGame extends UTGame;

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	// Removendo mensagem de morte
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class 'LRGame.LRGame';
}

DefaultProperties
{
	//Indentify your GameInfo
	Acronym="LR"

	PlayerControllerClass=class'LRGame.LRPlayerController'
	DefaultPawnClass=class'LRGame.LRPawn'
	DefaultInventory(0)=class'LRGame.UTWeap_Glock'

	HUDType=class'LRGame.LRHUD'

	//This variable was created by Epic Games to allow back compatability with UIScenes
	bUseClassicHUD=true

	// bDelayedStart=false
	// bRestartLevel=true
}