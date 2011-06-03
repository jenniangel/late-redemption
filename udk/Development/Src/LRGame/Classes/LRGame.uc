class LRGame extends UTGame;

var bool showingTime;

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	// Removendo mensagem de morte
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class 'LRGame.LRGame';
}

/*
 * Fun��o utilizada para reduzir o tempo do jogo em 10 minutos 
 * (considerando 3h33) a cada vez que o jogador morre.
 * */
function AdjustTimeAfterDeath() {
	local LRGameReplicationInfo GRI;
	GRI = LRGameReplicationInfo(GameReplicationInfo);
	if (GRI.contaTempo) {
		GRI.ElapsedTime += 56;
		GRI.mostrarHora = true;
		showingTime = true;
		SetTimer(5, false);
	}
}

/*
 * Esconde o tempo mostrado no HUD.
 * */
function Timer()
{
	local LRGameReplicationInfo GRI;
	if (showingTime) {
		GRI = LRGameReplicationInfo(GameReplicationInfo);
		GRI.mostrarHora = false;
		showingTime = false;
	}
}

/*
 * Restaura a vida de todos os inimigos vivos.
 * */
function RestoreEnemiesHealth() {
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
	RestoreEnemiesHealth();
	super.RestartPlayer(aPlayer);
	AdjustTimeAfterDeath();
}

DefaultProperties
{
	//Indentify your GameInfo
	Acronym="LR"

	PlayerControllerClass=class'LRGame.LRPlayerController'
	DefaultPawnClass=class'LRGame.LRPawn'
	DefaultInventory(0)=class'LRGame.UTWeap_Glock'
	
	// Obt�m classe LR para o GRI
	GameReplicationInfoClass=class'LRGame.LRGameReplicationInfo'

	HUDType=class'LRGame.LRHUD'

	//This variable was created by Epic Games to allow back compatability with UIScenes
	bUseClassicHUD=true

	// bDelayedStart=false
	// bRestartLevel=true
}