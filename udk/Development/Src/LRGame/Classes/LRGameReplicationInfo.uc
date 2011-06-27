
class LRGameReplicationInfo extends GameReplicationInfo
	config(Game);

var bool contaTempo;    // se true, inicia contagem de tempo
var bool mostrarHora;    // se true, inicia contagem de tempo
var bool mostrarPercentualVida; // se true, mostra o percentual de vida no HUD

// controla quais badaladas j� executaram
var bool jaTocouUma;
var bool jaTocouDuas;
var bool jaTocouTres;

// Variavel criada por Cesar em 16/06/11 para guardar muni��o do Marshall
// 1 = muni��o normal
// 2= muni��o especial
var int tipoMunicao;

// Dano da muni��o
var int danoMunicao;

// Quantidade de vida do Marshall
var int vidaMarshall;

var int tocando;    // indica se as badaladas est�o acontecendo
var int delayToque; // usada para saber quanto tempo o toque est� dando

var  (LateRedemption) SoundCue SomBadalada;

// fun��o que faz a contagem do tempo
simulated event Timer()
{
	// s� faz contagem se true
	if (contaTempo==true)
	{
		// quando inicia contagem, tem que dar 12 badaladas
		if (ElapsedTime==0)
			tocando=12;

		// faz o tempo passar 1 segundo por vez
		ElapsedTime=ElapsedTime+1;
	}

	// se � para tocar
	if (tocando>0)
	{
		// se passou 2 segundos do �ltimo toque
		if ((ElapsedTime-delayToque)>1)
		{
			// toca o som
			TocarBadalada();
			tocando--;
			delayToque = ElapsedTime;
		}
	}

	// verifica se j� passou da uma e ainda nao tocou
	if (SegundosJogo()>=3600 && jaTocouUma==false)
	{
		jaTocouUma = true;
		tocando = 1;
	}

	// verifica se j� passou das duas e ainda nao tocou
	if (SegundosJogo()>=7200 && jaTocouDuas==false)
	{
		jaTocouDuas = true;
		tocando = 2;
	}

	// verifica se j� passou das tr�s e ainda nao tocou
	if (SegundosJogo()>=10800 && jaTocouTres==false)
	{
		jaTocouTres = true;
		tocando = 3;
	}
}

// toca o som da badalada
function TocarBadalada()
{
	PlaySound(SomBadalada);
}


simulated function int SegundosJogo()
{
	// converte a quantidade de segundos reais
	// para a quantidade de segundos do jogo
	return ElapsedTime * 10.65;
}


defaultproperties
{

	SomBadalada = SoundCue'LateRedemptionPackageSounds.Sounds.SinoAlto_Cue'
	jaTocouUma = false
	jaTocouDuas = false
	jaTocouTres = false

	tocando = 0;
	delayToque = 0;

	contaTempo = false;
	mostrarHora = false;
	mostrarPercentualVida = false;

	tipoMunicao = 1 // muni��o normal
	danoMunicao = 20.0; // Muni��o normal no Go Easy on Me
	vidaMarshall = 100.00 // vida do Marshall no Go Easy on Me
}

