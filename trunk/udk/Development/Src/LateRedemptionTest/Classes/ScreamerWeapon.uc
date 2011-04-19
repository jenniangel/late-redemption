class ScreamerWeapon extends UTWeap_LinkGun;

	var color myBeamColor;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Super.ChangeVisibility(false);
	myBeamColor.A = 255;
	myBeamColor.R = 255;
	myBeamColor.G = 255;
	myBeamColor.B = 255;
	FireInterval[0]=1.00;
	Mesh.SetHIdden(true);
	BeamEmitter[0].SetColorParameter('Link_Beam_Color', myBeamColor);
	BeamEmitter[1].SetColorParameter('Link_Beam_Color', myBeamColor);
	Mesh = none;	
	SetSkin(none);
	ChangeVisibility(false);
//	FirstPersonMesh.destroy();
//	PickupMesh.destroy();

}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	Super.UpdateBeamEmitter(FlashLocation, HitNormal, HitActor);
	myBeamColor.A = 255;
	myBeamColor.R = 255;
	myBeamColor.G = 255;
	myBeamColor.B = 255;
	BeamEmitter[0].SetColorParameter('Link_Beam_Color', myBeamColor);
	BeamEmitter[1].SetColorParameter('Link_Beam_Color', myBeamColor);
	Mesh.SetHidden(true);
	Mesh = none;	
	SetSkin(none);
	ChangeVisibility(false);
}

defaultproperties
{
    FireInterval(0)=+1.00
	FireInterval(1)=+0.35
	// Weapon SkeletalMesh
	Begin Object class=SkeletalMeshComponent Name=ScreamerMesh
	   SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3'
	   HiddenGame=TRUE
	   HiddenEditor=TRUE
	End Object
	Mesh=ScreamerMesh
	Components.Add(ScreamerMesh)
}

