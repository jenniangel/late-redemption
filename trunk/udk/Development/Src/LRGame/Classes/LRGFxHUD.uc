class LRGFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

var bool bGammaCorrection;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject Hora;
var GFxObject qtdMunicaoArma, qtdMunicaoPenteAtivo, qtdMunicaoPenteReserva, imagemPenteReserva, mensagemCarregando;

var UTGameReplicationInfo GRI;
var WorldInfo ThisWorld;
var GFxObject     CenterTextMC, CenterTextTF;

var array<MessageRow>   Messages, FreeMessages;
var float               MessageHeight;
var int                 NumMessages;

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
//function Init(PlayerController PC)
{
	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	//Set the cahce value so that it will get updated on the first Tick
	LastHealthpc = -1337;

	//Load the references with pointers to the movieClips and text fields in the .swf
	/*
	HealthMC = GetVariableObject("_root.healthbar_mc");
	HealthBarMC = GetVariableObject("_root.healthbar_mc.bar_mc");
	HealthTF = GetVariableObject("_root.healthbar_mc.health_txt");
	
	LogMC = GetVariableObject("_root.log");
	*/
	
	ThisWorld = GetPC().WorldInfo;
	GRI = UTGameReplicationInfo(ThisWorld.GRI);
	
	Hora = GetVariableObject("_root.hora");
	qtdMunicaoArma = GetVariableObject("_root.qtdMunicaoArma");
	qtdMunicaoPenteAtivo = GetVariableObject("_root.qtdMunicaoPenteAtivo");
	
	CenterTextTF = GetVariableObject("_root.centerTextMC.centerText.textField");
	CenterTextMC = GetVariableObject("_root.centerTextMC");
	
	qtdMunicaoPenteReserva = GetVariableObject("_root.qtdMunicaoPenteReserva");
	imagemPenteReserva = GetVariableObject("_root.imagemPenteReserva");
	mensagemCarregando = GetVariableObject("_root.mensagemCarregando");

	hora.SetVisible(false);
	
	// esconde os pentes reservas
	qtdMunicaoPenteReserva.SetVisible(false);
	imagemPenteReserva.SetVisible(false);
	
}

function LogMessage(String texto)
{
    //`log(texto);
	//GetPC().Worldinfo.Game.Broadcast(self, "ate aqui ok");
	//log.SetString("text", texto);
}


static function string FormatTime(int Seconds)
{
	local int Hours, Mins;
	local string NewTimeString;

	Hours = Seconds / 3600;
	Seconds -= Hours * 3600;
	Mins = Seconds / 60;
	Seconds -= Mins * 60;
	if (Hours > 0)
		NewTimeString = ( Hours > 9 ? String(Hours) : "0"$String(Hours)) $ ":";
	NewTimeString = NewTimeString $ ( Mins > 9 ? String(Mins) : "0"$String(Mins)) $ ":";
	NewTimeString = NewTimeString $ ( Seconds > 9 ? String(Seconds) : "0"$String(Seconds));

	return NewTimeString;
}

function AtualizarHora()
{
	if ( GRI != None )
	{
		Hora.SetString("text", FormatTime(GRI.TimeLimit != 0 ? GRI.RemainingTime : GRI.ElapsedTime));
	} 
	else
	{
		Hora.SetString("text", "GRI � NONE");
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


//Called every update Tick
function TickHUD() {
	local UTPawn UTP;
	local UTVehicle UTV;
	local UTWeaponPawn UWP;
	local PlayerController PC;
	
	GRI.ElapsedTime = 0;

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
			return;
		}
		else if (UTVehicle_Hoverboard(UTV) != none)
		{
			UTV = none;
		}
	}


	//AtualizarHora();
	
	AtualizarMunicao(UTP);

}


DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	bDisplayWithHudOff=false
	
	//The path to the swf asset we will create later
	MovieInfo=SwfMovie'LRHUD.Flash.LRHUD'
	
	//Just put it in...
	bGammaCorrection = false
}