class ButcherPawn extends UTPawn
placeable;                           // Available in Content Browser

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var SkeletalMesh defaultMesh;                  // Custom Mesh member
var AnimTree defaultAnimTree;                  // Custom Anim member
var array<AnimSet> defaultAnimSet;             // Custom Anim member
var PhysicsAsset defaultPhysicsAsset;          // Custom Mesh member
var MaterialInterface defaultMaterial0;        // Custom Mesh member
var Name AnimSetName;

const MAXGROUNDSPEED=800;
const MINGROUNDSPEED=100;
const MAXTICKERCOUNTER=20;
const REDUCESPEEDONTIMEOUT= -350;

var ButcherController myController;        // Butcher IA Controller
var float tickCounter;                      // Timing variable
var int reduceSpeedTimer;                   // Timing variable
var bool AttAcking;                         // Flag to indicate state
var () bool logactive;                      // Turn debug on-off

//------------------------------------------------------------------
// Variables to be used by the Controller Class
//------------------------------------------------------------------
var () float perceptionDistance;            // Myopia factor :)
var () float attackDistance;                // Death distance.
var () array<NavigationPoint> navigationPointsButcher;



//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
defaultproperties
{
   GroundSpeed = MINGROUNDSPEED
   AnimSetName="ATTACK"
   AttAcking=false
   logactive = false;
   perceptionDistance = 10000
   attackDistance = 50

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
      BlockRigidBody=true
      BlockActors=true
      BlockZeroExtent=true
      BlockNonZeroExtent=true
      bAllowApproximateOcclusion=true
      bForceDirectLightMap=true
      bUsePrecomputedShadows=false
      LightEnvironment=MyLightEnvironment
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




//==================================================================
//------------------------- Functions/Events------------------------
//==================================================================

//------------------------------------------------------------------
// The main purpose of this function is to establish the link
// between this Pawn and its controller Class.
//------------------------------------------------------------------
simulated function PostBeginPlay()
{
   super.PostBeginPlay();
   SetPhysics(PHYS_Walking);
   if (myController == none)
   {
      myController = Spawn(class'ButcherController', self);
      myController.SetPawn(self);
   }
}



//------------------------------------------------------------------
// This function is only used for debug purpose. It simply unleashes
// internal messages in case the logactive flag is turned on.
//------------------------------------------------------------------
function LogMessage(String texto)
{
   if (logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}



//------------------------------------------------------------------
// Whenever the Attack State is changed within the Controller class,
// (i.e.: either entering or leaving the Attack state) this function 
// is called so that the Attacking variable can be properly updated.
// This variable can be useful to trigger future Kismet Sequences.
//------------------------------------------------------------------
function SetAttacking(bool atacar)
{
   AttAcking = atacar;
}



//------------------------------------------------------------------
// This function is linked to the revenge timer and with the Attack
// substate Revenge.
// It will be called by the Controller class whenever it receives
// the notification that the Butcher has been hit requesting to
// increase its speed velocity.
// Before changing the speed, the Butcher must check whether the
// new requested value is within acceptable limits.
// On the opposite direction, when revenge timer runs out, this 
// function is internally called in order to decrease the Butcher
// speed, changing in this way its Attack sub-state
// It means that in case the ChangeSpeed succeeds in changing the
// Butcher speed, it is going from Attack to Revenge or from Revenge
// to Insane states.
// If the ChangeSpeed succeeds in decreasing its speed, it changes
// its state on the opposite direction Insane -> Revenge or 
// Revenge -> Attack.
//------------------------------------------------------------------
function ChangeSpeed(int speed)
{
   reduceSpeedTimer = 0;                   // Reset revenge timer
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



//------------------------------------------------------------------
// This event is notified whenever the Butcher is hit. It has been
// overwritten here just to send a notification for the controller
// class by calling the NotifyTakeHit1 function.
//------------------------------------------------------------------
event TakeDamage (int Damage, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
   LogMessage("Event Pawn TakeDamage");
   super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
   myController.NotifyTakeHit1();
}



//------------------------------------------------------------------
// This event is from utmost importance to every Pawn.
// At some pre-determined intervals (usually between 0.05 and 0.1 
// seconds) this event will be triggered and for instance, the Pawn
// can use these notifications in order to take timing based actions.
// In this case, a function to drain the Player life is implemented
// in order to reduce the Player health whereas he is in contact
// with the Butcher.
// Here, revenge timer is also implemented, with the aid of
// reduceSpeedTimer variable so that when a predetermined timeout
// (equal to 100 Ticks) is reached, a request to reduce the 
// Butcher speed will be carried out by calling the ChangeSpeed
// function with a negative value (in this case, if the Attack 
// sub-state is Revenge, it will be set back to Normal Attack).
//------------------------------------------------------------------
simulated event Tick(float DeltaTime)
{
   local UTPawn gv;
   super.Tick(DeltaTime);
   if (tickCounter < MAXTICKERCOUNTER)
   {
      tickCounter +=1;
   }
   else                            // Wait 10 primary timer intervals
   {
      reduceSpeedtimer = reduceSpeedtimer + 1;
      tickCounter = 0;
      foreach VisibleCollidingActors(class'UTPawn', gv, 100)
      {
         if(AttAcking && gv != none)
         {
            if(gv.Health > 10)     // Contact will not kill player.
            {
               gv.Health -= 1;
               gv.IsInPain();
            }
         }
      }
   }
   
   if (reduceSpeedTimer == 10)     // Wait 100 primary timer intervals
   {
      reduceSpeedTimer = 0;
      ChangeSpeed(REDUCESPEEDONTIMEOUT);
   }

}



//------------------------------------------------------------------
// This is the function responsible for changing the character when
// new version of the Mesh, AnimSet or Physical Asset are available.
//------------------------------------------------------------------
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
   Mesh.SetSkeletalMesh(defaultMesh);
   Mesh.SetMaterial(0,defaultMaterial0);
   Mesh.SetPhysicsAsset(defaultPhysicsAsset);
   Mesh.AnimSets=defaultAnimSet;
   Mesh.SetAnimTreeTemplate(defaultAnimTree);

}
