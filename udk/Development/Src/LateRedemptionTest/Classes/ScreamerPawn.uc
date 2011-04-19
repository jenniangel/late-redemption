class ScreamerPawn extends UTPawn
	placeable;                      // Pode ser pego a partir do Content Browser

// members for the custom mesh
var SkeletalMesh defaultMesh;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var PhysicsAsset defaultPhysicsAsset;
var MaterialInterface defaultMaterial0;
var AnimNodeSequence defaultAnimSeq;
var Pawn hitPawn; // variable to hold the pawn we bump into
var () bool logactive;
const MAXGROUNDSPEED=800;
const MINGROUNDSPEED=300;
const MAXTICKERCOUNTER=20;
const REDUCESPEEDONTIMEOUT= -350;



var ScreamerController myController;  // Classe de IA para o Screamer

var float tickCounter;
var int reduceSpeedTimer;

var SkeletalMeshComponent MyMesh;
var bool bplayed;
var Name AnimSetName;
var AnimNodeSequence MyAnimPlayControl;

var bool AttAcking;

var () array<NavigationPoint> MyNavigationPoints;

defaultproperties
{
    GroundSpeed = MINGROUNDSPEED
	AnimSetName="ATTACK"
	AttAcking=false
logactive = true;

	// Soldado
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	// Zumbi
	//defaultMesh=SkeletalMesh'CH_Zombie.Mesh.SK_Zombie'


	Begin Object Name=WPawnSkeletalMeshComponent
//		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		SkeletalMesh=SkeletalMesh'CH_Zombie.Mesh.SK_Zombie'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'

		bOwnerNoSee=false
		CastShadow=true

		//CollideActors=TRUE
		BlockRigidBody=true
		BlockActors=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true

		bAllowApproximateOcclusion=true
		bForceDirectLightMap=true
		bUsePrecomputedShadows=false
		LightEnvironment=MyLightEnvironment
		//Scale=0.5
	End Object

	mesh = WPawnSkeletalMeshComponent

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0041.000000
		CollisionHeight=+0044.000000
		BlockZeroExtent=false
	End Object

	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder

	
	bCollideActors=true
	bPushesRigidBodies=true
	bStatic=False
	bMovable=True

	bAvoidLedges=true
	bStopAtLedges=true

	LedgeCheckThreshold=0.5f
	
}

function AddDefaultInventory()
{
    InvManager.CreateInventory(class'ScreamerWeapon');
    //For those in the back who don't follow, SandboxPaintballGun is a custom weapon
    //I've made in an earlier article, don't look for it in your UDK build.
}



simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Walking);
    AddDefaultInventory(); //GameInfo calls it only for players, so we have to do it ourselves for AI.
	if (myController == none)
	{
		myController = Spawn(class'ScreamerController', self);
		myController.SetPawn(self);		
	}

    //I am not using this
	MyAnimPlayControl = AnimNodeSequence(MyMesh.Animations.FindAnimNode('AnimAttack'));
}


function LogMessage(String texto)
{
    if (logactive)
    {
       Worldinfo.Game.Broadcast(self, texto);
	}
}

function SetAttacking(bool atacar)
{
	AttAcking = atacar;
}

function ChangeSpeed(int speed)
{
   reduceSpeedTimer = 0;
   groundspeed = groundspeed + speed;
   if (groundspeed > MAXGROUNDSPEED)
   {
      groundspeed = MAXGROUNDSPEED;
   }
   if (groundspeed < MINGROUNDSPEED)
   {
      groundspeed = MINGROUNDSPEED;
   }
}

event TakeDamage (int Damage, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
   	   LogMessage("Event Pawn TakeDamage");
	   super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	   myController.NotifyTakeHit1();
	}


simulated event Tick(float DeltaTime)
{
	local UTPawn gv;          // saida para a funcao abaixo  ... tem que ver se o player eh utpawn

	super.Tick(DeltaTime);

	if (tickCounter < MAXTICKERCOUNTER)
	{
	   tickCounter +=1;
	}
	else
	{
	   reduceSpeedtimer = reduceSpeedtimer + 1;
       tickCounter = 0;
	   foreach VisibleCollidingActors(class'UTPawn', gv, 100)
	   {
          if(AttAcking && gv != none)
		   {
//			  if(gv.Name == 'MyPawn_0' && gv.Health > 10)
			  if(gv.Health > 10)
			  {
				//Worldinfo.Game.Broadcast(self, "Colliding with player : " @ gv.Name);
				gv.Health -= 1;
				gv.IsInPain();
			  }
		   }
	   }
   }
   
   if (reduceSpeedTimer == 10)
   {
      reduceSpeedTimer = 0;
      ChangeSpeed(REDUCESPEEDONTIMEOUT);
   }

   }

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	Mesh.SetSkeletalMesh(defaultMesh);
	Mesh.SetMaterial(0,defaultMaterial0);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);

}