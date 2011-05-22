class LRPawn extends UTPawn;

var SkeletalMesh defaultMesh;                  // Custom Mesh member
var AnimTree defaultAnimTree;                  // Custom Anim member
var array<AnimSet> defaultAnimSet;             // Custom Anim member
var PhysicsAsset defaultPhysicsAsset;          // Custom Mesh member

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{	
	Mesh.SetSkeletalMesh(defaultMesh);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);
}

DefaultProperties
{

	defaultMesh=SkeletalMesh'LateRedemptionMarshall.Mesh.Marshal3ds-7-4'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	SoundGroupClass=class'UTPawnSoundGroup_Marshall'

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'LateRedemptionMarshall.Mesh.Marshal3ds-7-4'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		Translation=(Z=14.0)
		Scale=1.075
		
		//General Mesh Properties
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		MotionBlurScale=0.0
		bAllowAmbientOcclusion=false
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	mesh = WPawnSkeletalMeshComponent
}