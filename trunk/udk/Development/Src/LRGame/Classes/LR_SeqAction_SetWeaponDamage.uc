// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class LR_SeqAction_SetWeaponDamage extends SequenceAction;

var() float	Damage;

event Activated()
{
	local WorldInfo WI;
	local LRGameReplicationInfo GRI;
	local Controller c;

	WI = GetWorldInfo();
	GRI = LRGameReplicationInfo(WI.GRI);
	GRI.danoMunicao = Damage;
	
	c = Controller(Targets[0]);
	c.Pawn.Weapon.InstantHitDamage[0] = Damage;
}

defaultproperties
{
	ObjName="Configura dano da arma do Marshall"
	ObjCategory="LateRedemption"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Dano",PropertyName=Damage)
}
