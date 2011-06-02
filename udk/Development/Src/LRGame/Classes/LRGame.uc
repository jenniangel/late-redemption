class LRGame extends UTGame;

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	// Removendo mensagem de morte
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class 'LRGame.LRGame';
}

/*
 * Restaura a vida de todos os inimigos vivos.
 * */
function restoreEnemiesHealth() {
	local ShortiePawn shortie;
	local ScreamerPawn screamer;
	local ButcherPawn butcher;
	local CrusherPawn crusher;
 
	foreach AllActors(class 'LateRedemptionTest.ShortiePawn', shortie)
	{
		if (shortie.Health != shortie.initialHealth) {
			shortie.Health = shortie.initialHealth;
		}
	}

	foreach AllActors(class 'LateRedemptionTest.ScreamerPawn', screamer)
	{
		if (screamer.Health != screamer.initialHealth) {
			screamer.Health = screamer.initialHealth;
		}
	}

	foreach AllActors(class 'LateRedemptionTest.ButcherPawn', butcher)
	{
		if (butcher.Health != butcher.initialHealth) {
			butcher.Health = butcher.initialHealth;
		}
	}

	foreach AllActors(class 'LateRedemptionTest.CrusherPawn', crusher)
	{
		if (crusher.Health != crusher.initialHealth) {
			crusher.Health = crusher.initialHealth;
		}
	}
}

function RestartPlayer(Controller aPlayer) {
	restoreEnemiesHealth();
	super.RestartPlayer(aPlayer);
}

DefaultProperties
{
	//Indentify your GameInfo
	Acronym="LR"

	PlayerControllerClass=class'LRGame.LRPlayerController'
	DefaultPawnClass=class'LRGame.LRPawn'
	DefaultInventory(0)=class'LRGame.UTWeap_Glock'
	
	// Obtém classe LR para o GRI
	GameReplicationInfoClass=class'LRGame.LRGameReplicationInfo'

	HUDType=class'LRGame.LRHUD'

	//This variable was created by Epic Games to allow back compatability with UIScenes
	bUseClassicHUD=true

	// bDelayedStart=false
	// bRestartLevel=true
}