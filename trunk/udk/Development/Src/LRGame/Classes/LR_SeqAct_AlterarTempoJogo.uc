class LR_SeqAct_AlterarTempoJogo extends SequenceAction;
var(ObjectiveRunParams) int NovoTempoJogo;	

// Here we set the default values of the variables //
defaultproperties
{
  // This is the name that will apear in the Kismet Editor
   ObjName="Alterar Tempo Jogo"
	ObjCategory="LateRedemption"

	NovoTempoJogo=0

  // This is the name of the event that will be triggered when this action is called //
   //HandlerName="AlterarTempoJogo"
	bCallHandler=false
}

event Activated()
{
	local WorldInfo WI;
	local LRGameReplicationInfo GRI;

	WI = GetWorldInfo();
	GRI = LRGameReplicationInfo(WI.GRI);

	GRI.mostrarHora = true;
	GRI.ElapsedTime = self.NovoTempoJogo;

	SetTimer(2.0, false, 'EsconderHora');

}

function EsconderHora()
{
		local WorldInfo WI;
	local LRGameReplicationInfo GRI;

	WI = GetWorldInfo();
	GRI = LRGameReplicationInfo(WI.GRI);

	GRI.mostrarHora = false;
}