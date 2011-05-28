class LRGFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

var bool bGammaCorrection;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject Hora;
var GFxObject qtdMunicaoArma, qtdMunicaoPenteAtivo, qtdMunicaoPenteReserva, imagemPenteReserva, mensagemCarregando, percentualVida;

var LRGameReplicationInfo GRI;
var WorldInfo ThisWorld;
var GFxObject     CenterTextMC, CenterTextTF;

var array<MessageRow>   Messages, FreeMessages;
var float               MessageHeight;
var int                 NumMessages;

var bool    badaladaMeiaNoite;
var bool    badaladaUma;
var bool    badaladaDuas;
var bool    badaladaTres;

var bool    escondeHora;
var int     delayHora;

function SetCenterText(string text)
{
	CenterTextTF.SetText(text);
	CenterTextMC.GotoAndPlay("on");
}

function AddMessage(string type, string msg)
{
	local MessageRow mrow;
	local GFxObject.ASDisplayInfo DI;
	local int j;

	if (Len(msg) == 0)
		return;

	if (FreeMessages.Length > 0)
	{
		mrow = FreeMessages[FreeMessages.Length-1];
		FreeMessages.Remove(FreeMessages.Length-1,1);
	}
	else
	{
		mrow = Messages[Messages.Length-1];
		Messages.Remove(Messages.Length-1,1);
	}

	mrow.TF.SetString(type, msg);
	mrow.Y = 0;
	DI.hasY = true;
	DI.Y = 0;
	mrow.MC.SetDisplayInfo(DI);
	mrow.MC.GotoAndPlay("show");
	for (j = 0; j < Messages.Length; j++)
	{
		Messages[j].Y -= MessageHeight;
		DI.Y = Messages[j].Y;
		Messages[j].MC.SetDisplayInfo(DI);
	}
	Messages.InsertItem(0,mrow);
}


//  Function to round a float value to an int
function int roundNum(float NumIn) {
	local int iNum;
	local float fNum;

	fNum = NumIn;
	iNum = int(fNum);
	fNum -= iNum;
	if (fNum >= 0.5f)
	{
		return (iNum + 1);
	}
	else
	{
		return iNum;
	}
}

//  Function to return a percentage from a value and a maximum
function int getpercent(int val, int max) {
	return roundNum((float(val) / float(max)) * 100.0f);
}



//Called from STHUD'd PostBeginPlay()
function Init(optional LocalPlayer LocPlay)
{

	ThisWorld = GetPC().WorldInfo;
	GRI = LRGameReplicationInfo(ThisWorld.GRI);
	

	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	//Load the references with pointers to the movieClips and text fields in the .swf
	
	percentualVida = GetVariableObject("_root.percentualVida");
	Hora = GetVariableObject("_root.hora");
	qtdMunicaoArma = GetVariableObject("_root.qtdMunicaoArma");
	qtdMunicaoPenteAtivo = GetVariableObject("_root.qtdMunicaoPenteAtivo");
	
	CenterTextTF = GetVariableObject("_root.centerTextMC.centerText.textField");
	CenterTextMC = GetVariableObject("_root.centerTextMC");
	
	qtdMunicaoPenteReserva = GetVariableObject("_root.qtdMunicaoPenteReserva");
	imagemPenteReserva = GetVariableObject("_root.imagemPenteReserva");
	mensagemCarregando = GetVariableObject("_root.mensagemCarregando");


	// esconde os pentes reservas, hora e mensagem de reload
	qtdMunicaoPenteReserva.SetVisible(false);
	imagemPenteReserva.SetVisible(false);
	//Hora.SetVisible(false);
	mensagemCarregando.SetVisible(false);
	
}

static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;

	NewTimeString = ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins));

	return NewTimeString;
}

function AtualizarHora()
{
	if ( GRI != None )
	{

		//SetCenterText(FormatTime(GRI.SegundosJogo())$" - "$GRI.ElapsedTime$", "$GRI.SegundosJogo());

		// Quando identifica o início do tempo, mostra 00:00
		if (badaladaMeiaNoite==false && GRI.contaTempo==true)
		{
			Hora.SetString("text", "00:00");
			badaladaMeiaNoite=true;
			escondeHora=true;
			delayHora = GRI.ElapsedTime;
		}

		// Quando identifica uma da manhã, mostra 01:00
		if (GRI.SegundosJogo()>=3600 && badaladaUma==false)
		{
			Hora.SetString("text", "01:00");
			badaladaUma=true;
			escondeHora=true;
			delayHora = GRI.ElapsedTime;
		}

		// Quando identifica duas da manhã, mostra 02:00
		if (GRI.SegundosJogo()>=7200 && badaladaDuas==false)
		{
			Hora.SetString("text", "02:00");
			badaladaDuas=true;
			escondeHora=true;
			delayHora = GRI.ElapsedTime;
		}

		// Quando identifica três da manhã, mostra 03:00
		if (GRI.SegundosJogo()>=10800 && badaladaTres==false)
		{
			Hora.SetString("text",  "03:00");
			badaladaTres=true;
			escondeHora=true;
			delayHora = GRI.ElapsedTime;
		}

		// No final do tempo, mostra hora em tempo real
		if (GRI.SegundosJogo()>=11000)
		{
			Hora.SetString("text",  FormatTime(GRI.SegundosJogo()));
		}

		// Quando indicar que é para esconder a hora
		if (escondeHora==true)
		{
			// verifica se ficou 15 segundos aparecendo
			if ((GRI.ElapsedTime-delayHora)>15)
			{
				// esconde a hora
				Hora.SetString("text", "");
				escondeHora=false;
			}
		}
	} 
	else
	{
		Hora.SetVisible(false);
	}
}

function AtualizarMunicao(UTPawn UTP)
{

	local int i;
	local int clips;
	local UTWeap_Glock Weapon;
	
	Weapon = UTWeap_Glock(UTP.Weapon);
	if (Weapon != none)
	{
		
		i = Weapon.GetAmmoCount();
		clips = Weapon.GetClipsCount();
		qtdMunicaoArma.SetString("text",i$"");
		qtdMunicaoPenteAtivo.SetString("text",clips$"");
		
		mensagemCarregando.SetVisible(Weapon.bIsReloading);

	}
}

function EsconderTudo()
{
	Hora.SetString("text","");
	qtdMunicaoArma.SetString("text","");
	qtdMunicaoPenteAtivo.SetString("text","");
	qtdMunicaoPenteReserva.SetString("text","");
	imagemPenteReserva.SetVisible(false);
	mensagemCarregando.SetVisible(false);
	percentualVida.SetString("text","");
}


//Called every update Tick
function TickHUD() {
	local UTPawn UTP;
	local UTVehicle UTV;
	local UTWeaponPawn UWP;
	local PlayerController PC;
	
	//GRI.ElapsedTime = 0;

	PC = GetPC();
	
	UTP = UTPawn(PC.Pawn);
	
	if (UTP == None)
	{
		UTV = UTVehicle(PC.Pawn);
		if ( UTV == None )
		{
			UWP = UTWeaponPawn(PC.Pawn);
			if ( UWP != None )
			{
				UTV = UTVehicle(UWP.MyVehicle);
				UTP = UTPawn(UWP.Driver);
			}
		}
		else
		{
			UTP = UTPawn(UTV.Driver);
		}

		if (UTV == None)
		{
			EsconderTudo();
			return;
		}
		else if (UTVehicle_Hoverboard(UTV) != none)
		{
			UTV = none;
		}
	}

	if (UTP != None)
	{
	
		if (!UTP.bPlayedDeath)
		{
			AtualizarHora();
	
			AtualizarMunicao(UTP);
	
			percentualVida.SetString("text",UTP.Health$"%");
		}
		else
		{
			EsconderTudo();
		}

	}
	else
	{
		EsconderTudo();
	}

}

function AddDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Killed, class<UTDamageType> Dmg)
{
	EsconderTudo();
}


DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	bDisplayWithHudOff=false
	
	//The path to the swf asset we will create later
	MovieInfo=SwfMovie'LRHUD.Flash.LRHUD'
	
	//Just put it in...
	bGammaCorrection = false

	badaladaMeiaNoite = false
	badaladaUma = false
	badaladaDuas = false
	badaladaTres = false

	escondeHora = false
	delayHora = 0;
}