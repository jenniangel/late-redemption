class ShortiePawn extends UTPawn
placeable;                           // Available in Content Browser

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var SkeletalMesh defaultMesh;                  // Custom Mesh member
var AnimTree defaultAnimTree;                  // Custom Anim member
var array<AnimSet> defaultAnimSet;             // Custom Anim member
var PhysicsAsset defaultPhysicsAsset;          // Custom Mesh member
var MaterialInterface defaultMaterial0;        // Custom Mesh member
var Pawn thePlayer;                            // Player - must die...
var Name AnimSetName;

const DEFAULTMAXGROUNDSPEED=800;
const DEFAULTMINGROUNDSPEED=500;

var ShortieController myController;         // Shortie IA Controller
var float tickCounter;                      // Timing variable
var int reduceSpeedTimer;                   // Timing variable
var int changeSpeed;                        // Change fury states
var bool AttAcking;                         // Flag to indicate state
var bool playerVisible;                     // I can see the Player
var bool groupAttack;                       // Join forces??

//------------------------------------------------------------------
// Variables to be used by the Controller Class
// All of these variables can be edited from within the UDK editor
// just by pressing F4 over a ShortiePawn monster.
//------------------------------------------------------------------
var (LateRedemption) bool logactive;        // Turn debug on-off
var (LateRedemption) float perceptionDistance; // Myopia factor :)
var (LateRedemption) float attackDistance;     // Distance do drain Life.
var (LateRedemption) int revengeTimer;         // Fury time in seconds
var (LateRedemption) int minGroundSpeed;       // Min Chase Marshall Speed
var (LateRedemption) int maxGroundSpeed;       // Max Chase Marshall Speed
var (LateRedemption) int initialHealth;        // Shortie Initial Health
var (LateRedemption) SoundCue shortieAwake;    // Sound: see Marshall
var (LateRedemption) SoundCue shortieAttack;   // Sound: attack Marshall



defaultproperties
//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
{
   minGroundSpeed = 500;
   maxGroundSpeed = 800;
   AnimSetName = "ATTACK"
   AttAcking = false
   logactive = false;
   perceptionDistance = 4000
   attackDistance = 20
   revengeTimer = 5
   initialHealth = 100
   bCanPickupInventory = false
   defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
   defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
   defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
   defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
   shortieAwake=SoundCue'A_Effort_EnigmaMean_LandHeavy_Cue'
   shortieAttack=SoundCue'A_Effort_EnigmaMean_PainMedium_Cue'

   Begin Object Name=WPawnSkeletalMeshComponent
      SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'


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
      CollisionRadius=+0015.000000
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
// In addition to that, this function initiates some important 
// properties, based on the values eventually changed by the user
// directly on the editable variables.
//------------------------------------------------------------------
simulated function PostBeginPlay()
{
   super.PostBeginPlay();
   SetPhysics(PHYS_Walking);
   if (maxGroundSpeed > minGroundSpeed)
   {
      groundSpeed = minGroundSpeed;
   }
   else
   {
      groundSpeed = DEFAULTMINGROUNDSPEED;
      maxGroundSpeed = DEFAULTMAXGROUNDSPEED;
   }

   if (initialHealth > 0)
   {
      health = initialHealth;
   }

   changeSpeed = (maxGroundSpeed - minGroundSpeed);

   groupAttack = false;

   if (myController == none)
   {
      myController = Spawn(class'ShortieController', self);
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

function HandleEvent(String event)
{
   LogMessage("Event ShortieController HandleEvent Hit-1");
   if (event == "HIT")
   {
      LogMessage("Event ShortieController HandleEvent Hit-2");
      myController.NotifyTakeHit1(false);
   }
}


//------------------------------------------------------------------
// Whenever the Attack State is changed within the Controller class,
// (i.e.: either entering or leaving the Attack state) this function 
// is called so that the Attacking variable can be properly updated.
// This variable is useful in order to be used by the Anime editor
// (so that the attack sequence can be unleashed.
//------------------------------------------------------------------
function SetAttacking(bool atacar)
{
	AttAcking = atacar;
}

function SetPlayerVisible(bool visible)
{
    if (playerVisible != visible)
    {
       self.PlaySound(shortieAwake, false, true);
    }
	playerVisible = visible;
}



//------------------------------------------------------------------
// This function is linked to the revenge timer and with the Attack
// substate Revenge.
// It will be called by the Controller class whenever it receives
// the notification that the Shortie has been hit requesting to
// increase its speed velocity.
// Before changing the speed, the Shortie must check whether the
// new requested value is within acceptable limits.
// On the opposite direction, when revenge timer runs out, this 
// function is internally called in order to decrease the Shortie
// speed, changing in this way its Attack sub-state
// It means that in case the ChangePawnSpeed succeeds in changing the
// Shortie speed, it is going from Attack to Revenge or from Revenge
// to Insane states.
// If the ChangeSpeed succeeds in decreasing its speed, it changes
// its state on the opposite direction Insane -> Revenge or 
// Revenge -> Attack.
//------------------------------------------------------------------
function ChangePawnSpeed(int speed)
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
// This event is notified whenever the Shortie is hit. It has been
// overwritten here just to send a notification for the controller
// class by calling the NotifyTakeHit1 function.
//------------------------------------------------------------------
event TakeDamage (int Damage, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
   LogMessage("Event Pawn TakeDamage");
   ChangePawnSpeed(changeSpeed);
   super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
   myController.NotifyTakeHit1(true);
   thePlayer = GetALocalPlayerController().Pawn;
}



//------------------------------------------------------------------
// This event is from utmost importance to every Pawn.
// At some pre-determined intervals (usually between 0.05 and 0.1 
// seconds) this event will be triggered and for instance, the Pawn
// can use these notifications in order to take timing based actions.
// In this case, a function to drain the Player life is implemented
// in order to reduce the Player health whereas he is in contact
// with the Shortie.
// Here, revenge timer is also implemented, with the aid of
// reduceSpeedTimer variable so that when a predetermined timeout
// (equal to 100 Ticks) is reached, a request to reduce the 
// Shortie speed will be carried out by calling the ChangeSpeed
// function with a negative value (in this case, if the Attack 
// sub-state is Revenge, it will be set back to Normal Attack).
//------------------------------------------------------------------
simulated event Tick(float DeltaTime)
{
   local UTPawn seenPawn;
   super.Tick(DeltaTime);
   LogMessage("Event ShortieController HandleEvent Hit-!!");

   if (tickCounter < 1)
   {
      tickCounter +=DeltaTime;
//	  teste = string(tickCounter);

   }
   else                            // Wait one second
   {
      if (groupAttack == true)
      {
         LogMessage("Event ShortieController HandleEvent Hit-0");
         HandleEvent("HIT");
      }
      else
      {
         LogMessage("Event ShortieController HandleEvent Hit-?");
      }

      reduceSpeedtimer += 1;
      tickCounter = 0;
      foreach VisibleCollidingActors(class'UTPawn', seenPawn, 100)
      {
         if(AttAcking && seenPawn == GetALocalPlayerController().Pawn)
         {
            if(seenPawn.Health > 5)      // Contact will kill player.
            {
               seenPawn.health -= 5;
			   self.PlaySound(shortieAttack, false, true);
            }
			else
			{
			   self.PlaySound(shortieAttack, false, true);
               seenPawn.destroy();
			}
         }
      }
   }

   if (reduceSpeedTimer == revengeTimer)     // Wait "n" seconds
   {
      reduceSpeedTimer = 0;
      ChangePawnSpeed(-changeSpeed);
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
