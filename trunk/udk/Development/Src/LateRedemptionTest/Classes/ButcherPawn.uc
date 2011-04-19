class ButcherPawn extends UTPawn
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
const MINGROUNDSPEED=100;
const MAXTICKERCOUNTER=20;
const REDUCESPEEDONTIMEOUT= -350;



var ButcherController myController;  // Classe de IA para o butcher

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

	defaultMesh=SkeletalMesh'CH_Zombie.Mesh.SK_Zombie'
	defaultAnimTree=AnimTree'CH_Zombie.Anims.Zombie_AninTree'
	defaultAnimSet(0)=AnimSet'CH_Zombie.Anims.Zombie_AnimSet'
	defaultPhysicsAsset=PhysicsAsset'CH_Zombie.Mesh.SK_Zombie_Physics'


	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'CH_Zombie.Mesh.SK_Zombie'
        AnimSets(0)=AnimSet'CH_Zombie.Anims.Zombie_AnimSet'
		AnimTreeTemplate=AnimTree'CH_Zombie.Anims.Zombie_AninTree'

		bOwnerNoSee=false
		CastShadow=true

		//CollideActors=TRUE
		BlockRigidBody=true
		BlockActors=true
		BlockZeroExtent=true
		//BlockNonZeroExtent=true

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

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Walking);
	if (myController == none)
	{
		myController = Spawn(class'ButcherController', self);
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