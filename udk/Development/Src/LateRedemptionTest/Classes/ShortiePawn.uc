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
var (LateRedemption) bool logactive;           // Turn debug on-off
var (LateRedemption) float perceptionDistance; // Myopia factor :)
var (LateRedemption) float attackDistance;     // Distance do drain Life.
var (LateRedemption) int revengeTimer;         // Fury time in seconds
var (LateRedemption) int damageValue;          // Health to drain on touch
var (LateRedemption) int minGroundSpeed;       // Min Chase Marshall Speed
var (LateRedemption) int maxGroundSpeed;       // Max Chase Marshall Speed
var (LateRedemption) int initialHealth;        // Shortie Initial Health
var (LateRedemption) array<ShortiePawn> attackGroupMembers; //My team...
var (LateRedemption) SoundCue shortieAwake;    // Sound: see Marshall
var (LateRedemption) SoundCue shortieAttack;   // Sound: attack Marshall
var (LateRedemption) SoundCue shortiePain;     // Sound: I'm bleeding



defaultproperties
//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
{
   minGroundSpeed = 400;
   maxGroundSpeed = 600;
   AnimSetName = "ATTACK"
   AttAcking = false
   logactive = false;
   perceptionDistance = 1000
   attackDistance = 25
   revengeTimer = 5
   initialHealth = 120
   damageValue = 7
   bCanPickupInventory = false
   collisiontype = COLLIDE_BlockAll
   BlockRigidBody=true

   defaultMesh=SkeletalMesh'CH_Shortie.Mesh.SK_Shortie'
   defaultAnimTree=AnimTree'CH_Shortie.Anims.Shortie_AnimTree'
   defaultAnimSet(0)=AnimSet'CH_Shortie.Anims.SK_Shortie_Anims'
   defaultPhysicsAsset=PhysicsAsset'CH_Shortie.Mesh.SK_Shortie_Physics'
   shortieAwake=SoundCue'LateRedemptionPackageSounds.ShortieAttack2_Cue'
   shortieAttack=SoundCue'LateRedemptionMonsterSounds.Shortie_Attack'
   shortiePain=SoundCue'LateRedemptionMonsterSounds.Shortie_Pain'

   Begin Object Name=WPawnSkeletalMeshComponent
      SkeletalMesh=SkeletalMesh'CH_Shortie.Mesh.SK_Shortie'
      AnimSets(0)=AnimSet'CH_Shortie.Anims.SK_Shortie_Anims'
      AnimTreeTemplate=AnimTree'CH_Shortie.Anims.Shortie_AnimTree'


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
      BlockZeroExtent=true
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



//------------------------------------------------------------------
// This function is the one which triggers the group attack.
// It is internally called from within the Tick function whenever
// this shortie is informed towards SetPlayerVisible that at least 
// one shortie of this group has been awake.
// By default, a call to the Controller NotifyTakeHit function is
// carried out but without indication to go to the Revenge State
// (in other words, this function will call the controller function
// pushing this Shortie to go to the Pursuit or Attack Normal states.
// This also indicates to the controller that this NotifyTakeHit
// is being broadcasted by one of the members of this Shortie Group
// (i.e.: the shortie directly controlled by this controller was
// not hurt at this momment...)
//------------------------------------------------------------------

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
// (so that the attack sequence can be unleashed).
//------------------------------------------------------------------
function SetAttacking(bool atacar)
{
	AttAcking = atacar;
}


//------------------------------------------------------------------
// This function is from utmost importance for the shortie group
// attack coordination.
// Whenever the controller class notices the presence of the Player
// (i.e.: whenever the player is seen), this function is called in order
// to set the playerVisible variable, and at the same time, a broadcast
// message is sent  towards the other shorties of this group (using
// the list presented in the attackGroupMembers variable) so that they
// can be awaken as well.
// This proccess is complemented with the setting of groupAttack variable
// so that when this variable is checked by the other Shorties of this
// group, they can unleash their attack sequence as well.
// This is particularly effective in the first time the player is seen
// as the Awake function (the one which unleashes the Group Attack) is 
// triggered only once in the Shortie life or when the first Shortie
// member of this group is Shot (because there is a calling to 
// SetPlayerVisible function as well from within the Shortie 
// Controller class in this sittuation as well.
// In parallel to the Awaking proccess, a sound (recorded from my Dog
// voice) is played.
//------------------------------------------------------------------
function SetPlayerVisible(bool visible, bool ownWarning)
{
   local bool warnTeam;
   local ShortiePawn tempShortie;
   local int shortieIndex;

   if (playerVisible != visible)
   {
      playerVisible = visible;
      self.PlaySound(shortieAwake, false, true);
      shortieIndex = 0;
      warnTeam = true;
	  
	  if (ownWarning == false)
      {
	     groupattack = true;
	  }
      while (warnTeam)
      {
         tempShortie = attackGroupMembers[shortieIndex];

         if (shortieIndex >= attackGroupMembers.Length)
         {
            warnTeam = false;
         }
         else
         {
            if (tempShortie != none)
			{
               tempShortie.SetPlayerVisible(visible,false);
			}
            shortieIndex++;
         }
      }
   }
}



//------------------------------------------------------------------
// This function is linked to the revenge timer and with the Attack
// substate Revenge.
// It will be called by the Pawn class whenever it receives
// the notification that the Shortie has been hit requesting to
// increase its speed velocity.
// Before changing the speed, the Shortie must check whether the
// new requested value is within acceptable limits.
// On the opposite direction, when revenge timer runs out, this 
// function is internally called in order to decrease the Shortie
// speed, changing in this way its Attack sub-state
// It means that in case the ChangePawnSpeed succeeds in changing the
// Shortie speed, it is going from Attack to Revenge state.
// If the ChangeSpeed succeeds in decreasing its speed, it changes
// its state on the opposite direction: Revenge -> Attack.
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
// class by calling the NotifyTakeHit1 function and in order to
// call the function which modifies the Shortie Attack/Pursuit sub
// state.
//------------------------------------------------------------------
event TakeDamage (int Damage, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
   LogMessage("Event Pawn TakeDamage");
   ChangePawnSpeed(changeSpeed);
   super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
   myController.NotifyTakeHit1(true);
   self.PlaySound(shortiePain, false, true);
}



//------------------------------------------------------------------
// This event is from utmost importance to every Pawn.
// At some pre-determined intervals (usually between 0.05 and 0.1 
// seconds - it depends on the computer capacity) this event will 
// be triggered and the Pawn can use these notifications 
// in order to take timing based actions (basically, the primarily
// intervals, determined by the DeltaTime will be added till 
// completion of 1 second).
// Here, revenge timer is also implemented, with the aid of
// reduceSpeedTimer variable so that when a predetermined timeout
// (defined by configurable variable revengeTimer) is reached, 
// a request to reduce the Shortie speed will be carried out by 
// calling the ChangeSpeed function with a negative value (in 
// this case, if the Attack sub-state is Revenge, it will be 
// set back to Normal Attack).
// It is also important to highlight that two other very important
// tasks are carried out for the Shorties by this function:
// - Set Damage to the Player:
//   In this case, a function to drain the Player life is implemented
//   in order to reduce the Player health whereas he is in contact
//   with the Shortie. Basically a call towards the TakeDamage function
//   aiming the player is carried out so that the damage is inflicted 
//   towards the player.
// - Coordination of group attacks:
//   At every second, the variable groupAttack, which is manipulated
//   towards SetPlayerVisible function whenever one of the shorties 
//   from this group is awaken, is checked. When this variable value 
//   is set (meaning that Marshall either has been seen or has hit 
//   one Shortie member, a call to HandleEvent will wake up this 
//   Shortie as well.
//------------------------------------------------------------------
simulated event Tick(float DeltaTime)
{
   local UTPawn seenPawn;
   super.Tick(DeltaTime);
   LogMessage("Event ShortieController HandleEvent Hit-!!");

   if (tickCounter < 1)
   {
      tickCounter +=DeltaTime;

   }
   else                            // Wait one second
   {
      if (groupAttack == true)
      {
         LogMessage("Event ShortieController HandleEvent Hit-0");
		 groupAttack = false;
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
            self.PlaySound(shortieAttack, false, true);
            if(seenPawn.Health > damageValue)      // Contact will kill player.
            {
               seenPawn.TakeDamage(damageValue, none, seenPawn.Location, vect(0,0,0) , class'UTDmgType_RanOver');
            }
            else
            {
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

