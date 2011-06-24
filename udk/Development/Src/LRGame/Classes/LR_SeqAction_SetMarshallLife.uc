// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class LR_SeqAction_SetMarshallLife extends SequenceAction;

var float HealthMax;

event Activated()
{
	local WorldInfo WI;
	local LRGameReplicationInfo GRI;
	local Controller c;

	WI = GetWorldInfo();
	GRI = LRGameReplicationInfo(WI.GRI);
	GRI.vidaMarshall = HealthMax;
	
	c = Controller(Targets[0]);
	c.Pawn.HealthMax = HealthMax;
	if (c.Pawn.Health > HealthMax) {
		c.Pawn.Health = HealthMax;
	}
}

defaultproperties
{
	ObjName="Alterar máximo de vida do Marshall"
	ObjCategory="LateRedemption"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Vida",PropertyName=HealthMax)
}
