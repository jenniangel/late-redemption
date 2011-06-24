class LRGFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

var bool bGammaCorrection;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject Hora;
var GFxObject qtdMunicaoArma, qtdMunicaoPenteAtivo, qtdMunicaoPenteReserva, imagemPenteReserva, mensagemCarregando, percentualVida;
var GFxObject penteNormal, penteEspecial;

var LRGameReplicationInfo GRI;
var WorldInfo ThisWorld;
var GFxObject     CenterTextMC, CenterTextTF;

var GFxObject     HudVida100, HudVida5, HudVida10, HudVida15, HudVida20, 
				  HudVida25, HudVida30, HudVida35, HudVida40, HudVida45, 
				  HudVida50, HudVida55, HudVida60, HudVida65, HudVida70, 
				  HudVida75, HudVida80, HudVida85, HudVida90, HudVida95;

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
	
	penteNormal = GetVariableObject("_root.PenteNormal");
	penteEspecial = GetVariableObject("_root.PenteEspecial");
	
	
	HudVida5 = GetVariableObject("_root.vida5");
	HudVida10 = GetVariableObject("_root.vida10");
	HudVida15 = GetVariableObject("_root.vida15");
	HudVida20 = GetVariableObject("_root.vida20");
	HudVida25 = GetVariableObject("_root.vida25");
	HudVida30 = GetVariableObject("_root.vida30");
	HudVida35 = GetVariableObject("_root.vida35");
	HudVida40 = GetVariableObject("_root.vida40");
	HudVida45 = GetVariableObject("_root.vida45");
	HudVida50 = GetVariableObject("_root.vida50");
	HudVida55 = GetVariableObject("_root.vida55");
	HudVida60 = GetVariableObject("_root.vida60");
	HudVida65 = GetVariableObject("_root.vida65");
	HudVida70 = GetVariableObject("_root.vida70");
	HudVida75 = GetVariableObject("_root.vida75");
	HudVida80 = GetVariableObject("_root.vida80");
	HudVida85 = GetVariableObject("_root.vida85");
	HudVida90 = GetVariableObject("_root.vida90");
	HudVida95 = GetVariableObject("_root.vida95");
	HudVida100 = GetVariableObject("_root.vida100");

	EsconderTodasCamadasVida();
	
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

function EsconderTodasCamadasVida()
{
	
	HudVida5.SetVisible(false);
	HudVida10.SetVisible(false);
	HudVida15.SetVisible(false);
	HudVida20.SetVisible(false);
	HudVida25.SetVisible(false);
	HudVida30.SetVisible(false);
	HudVida35.SetVisible(false);
	HudVida40.SetVisible(false);
	HudVida45.SetVisible(false);
	HudVida50.SetVisible(false);
	HudVida55.SetVisible(false);
	HudVida60.SetVisible(false);
	HudVida65.SetVisible(false);
	HudVida70.SetVisible(false);
	HudVida75.SetVisible(false);
	HudVida80.SetVisible(false);
	HudVida85.SetVisible(false);
	HudVida90.SetVisible(false);
	HudVida95.SetVisible(false);
	HudVida100.SetVisible(false);
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


		// QUando o GRI manda, tem que mostrar a hora!
		if (GRI.mostrarHora==true)
		{
			Hora.SetString("text", FormatTime(GRI.SegundosJogo()));
		}
		else
		{
			if (escondeHora==false)
			{
				Hora.SetString("text", "");
			}
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

		// No final do tempo, mostra hora em tempo real
		if (GRI.SegundosJogo()>=11000)
		{
			Hora.SetString("text",  FormatTime(GRI.SegundosJogo()));
		}


	} 
	else
	{
		// esconde a hora
		Hora.SetString("text", "");
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
		
		
		// Mostrar a imagem do pente segundo o tipo de munição
		if (GRI.tipoMunicao==1)
		{
			penteNormal.SetVisible(true);
			penteEspecial.SetVisible(false);
		}
		else
		{
			penteNormal.SetVisible(false);
			penteEspecial.SetVisible(true);
		}

		
		
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
	EsconderTodasCamadasVida();
}


//Called every update Tick
function TickHUD() {
	local UTPawn UTP;
	local UTVehicle UTV;
	local UTWeaponPawn UWP;
	local PlayerController PC;
	local int healthPercent;
	
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
	
			healthPercent = (UTP.Health * 100) / UTP.HealthMax;

			percentualVida.SetString("text",healthPercent$"%");
			
			// Esconde todos as camadas vermelhas
			EsconderTodasCamadasVida();

			// mostra a que tem o alfa correspondente a vida
			if (healthPercent>=95)
				HudVida100.SetVisible(true);
			else if (healthPercent>=90)
				HudVida95.SetVisible(true);
			else if (healthPercent>=85)
				HudVida90.SetVisible(true);
			else if (healthPercent>=80)
				HudVida85.SetVisible(true);
			else if (healthPercent>=75)
				HudVida80.SetVisible(true);
			else if (healthPercent>=70)
				HudVida75.SetVisible(true);
			else if (healthPercent>=65)
				HudVida70.SetVisible(true);
			else if (healthPercent>=60)
				HudVida65.SetVisible(true);
			else if (healthPercent>=55)
				HudVida60.SetVisible(true);
			else if (healthPercent>=50)
				HudVida55.SetVisible(true);
			else if (healthPercent>=45)
				HudVida50.SetVisible(true);
			else if (healthPercent>=40)
				HudVida45.SetVisible(true);
			else if (healthPercent>=35) 
				HudVida40.SetVisible(true);
			else if (healthPercent>=30) 
				HudVida35.SetVisible(true);
			else if (healthPercent>=25) 
				HudVida30.SetVisible(true);
			else if (healthPercent>=20) 
				HudVida25.SetVisible(true);
			else if (healthPercent>=15) 
				HudVida20.SetVisible(true);
			else if (healthPercent>=10)
				HudVida15.SetVisible(true);
			else if (healthPercent>=5) 
				HudVida10.SetVisible(true);
			else
				HudVida5.SetVisible(true);

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