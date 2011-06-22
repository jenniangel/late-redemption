class DiabolusPawn extends UTPawn
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

var DiabolusController myController;        // Diabolus IA Controller
var float tickCounter;                      // Timing variable
var int reduceFuryTimer;                    // Timing variable
var int changeSpeed;                        // Change fury states
var bool FireAttAcking;                     // Flag to indicate state
var bool HandAttAcking;                     // Flag to indicate state
var bool knockDown;                         // Flag to indicate state
var bool dizzy;                             // Flag to indicate state
var bool ending;                            // Flag to indicate state
var bool AttAcking;                         // Flag to indicate state
var DiabolusWeapon weaponDiab;

//------------------------------------------------------------------
// Variables to be used by the Controller Class
// All of these variables can be edited from within the UDK editor
// just by pressing F4 over a DiabolusPawn monster.
//------------------------------------------------------------------
var (LateRedemption) bool logactive;           // Turn debug on-off
var (LateRedemption) int handAttackDistance;   // Distance to start punches.
var (LateRedemption) int heartHealth;          // Health from the Heart.
var (LateRedemption) int revengeTimer;         // Fury time in seconds
var (LateRedemption) int initialHealth;        // Initial Health
var (LateRedemption) int idleTime;             // Time to Start Move
var (LateRedemption) int heartTime;            // Time to Start Move
var (LateRedemption) float firingRate;         // Time till next fire
var (LateRedemption) SoundCue diabolusFireAttack;  // Sound when attack by Fire
var (LateRedemption) SoundCue diabolusHandAttack;  // Sound when attack by Hand
var (LateRedemption) SoundCue diabolusPain;        // Sound: I'm bleeding
var (LateRedemption) SoundCue diabolusRindo;       // Sound: I'm back
var (LateRedemption) SoundCue diabolusKnocked;     // Sound: I'm really hurted
var (LateRedemption) NavigationPoint spawnPoint1;
var (LateRedemption) NavigationPoint spawnPoint2;
var (LateRedemption) NavigationPoint spawnPoint3;
var (LateRedemption) NavigationPoint spawnPoint4;

defaultproperties
//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
{
   AnimSetName = "ATTACK"
   FireAttAcking = false
   HandAttAcking = false
   KnockDown = false
   dizzy = false
   ending = false
   AttAcking = false
   groundSpeed = 0
   logactive = false;
   initialHealth = 200
   handAttackDistance = 600
   revengeTimer = 5
   heartHealth = 400
   idleTime = 5
   heartTime = 3
   firingRate = 1.0
   bCanPickupInventory = false
   DrawScale = 1.0
   collisiontype = COLLIDE_BlockAll
   BlockRigidBody=true
   Physics = PHYS_Walking

   defaultMesh=SkeletalMesh'CH_Diabolus.Mesh.SK_Diabolus'
   defaultAnimTree=AnimTree'CH_Diabolus.Anims.Diabolus_AnimTree'
   defaultAnimSet(0)=AnimSet'CH_Diabolus.Anims.SK_Diabolus_Anims'
   defaultPhysicsAsset=PhysicsAsset'CH_Diabolus.Mesh.SK_Diabolus_Physics'
   diabolusFireAttack=SoundCue'LateRedemptionMonsterSounds.Diabolus_1_Cue'
   diabolusHandAttack=SoundCue'LateRedemptionMonsterSounds.Screamer_Attack_Cue'
   diabolusPain=SoundCue'LateRedemptionMonsterSounds.Marshall_Pain_2'
   diabolusRindo=SoundCue'LateRedemptionMonsterSounds.DiabolusRindo_Cue'
   diabolusKnocked=SoundCue'LateRedemptionMonsterSounds.DiabolusKnocked_Cue'

   Begin Object Name=WPawnSkeletalMeshComponent
      SkeletalMesh=SkeletalMesh'CH_Diabolus.Mesh.SK_Diabolus'
      AnimSets(0)=AnimSet'CH_Diabolus.Anims.SK_Diabolus_Anims'
      AnimTreeTemplate=AnimTree'CH_Diabolus.Anims.Diabolus_AnimTree'
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
   bAvoidLedges=true
   bStopAtLedges=true
   LedgeCheckThreshold=0.5f
}




//==================================================================
//------------------------- Functions/Events------------------------
//==================================================================

//------------------------------------------------------------------
// This function is only used to add the weapon, defined within
// internal messages in case the logactive flag is turned on.
// This weapon represents the mechanism used to toss fireballs.
//------------------------------------------------------------------
function AddDefaultInventory()
{
    InvManager.CreateInventory(class'DiabolusWeapon');
    weaponDiab = DiabolusWeapon(InvManager.GetBestWeapon());
    weaponDiab.FireInterval[0] = firingRate;
}


//------------------------------------------------------------------
// The main purpose of this function is to establish the link
// between this Pawn and its controller Class.
// In addition to that, this function initiates some important 
// properties, based on the values eventually changed by the user
// directly on the editable variables and also adds the Diabolus
// weapon (fireball emmiter).
//------------------------------------------------------------------
simulated function PostBeginPlay()
{
   super.PostBeginPlay();
   SetPhysics(PHYS_Walking);

   if (initialHealth > 0)
   {
      health = initialHealth;
   }

   AddDefaultInventory();            //Attach the weapon

   if (myController == none)
   {
      myController = Spawn(class'DiabolusController', self);
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
// This variable is useful in order to be used by the Anime editor
// (so that the attack sequence can be unleashed.
//------------------------------------------------------------------
function SetFireAttacking(bool atacar)
{
   if (FireAttAcking != atacar)
   {
      FireAttAcking = atacar;
      if (atacar)
      {
         StartFire(0);
         weaponDiab.WeaponPlaySound(DiabolusFireAttack);
      }
      else
      {
         StopFire(0);
      }
   }
}


//------------------------------------------------------------------
// Whenever the Attack State is changed within the Controller class,
// (i.e.: either entering or leaving the Attack state) this function 
// is called so that the Attacking variable can be properly updated.
// This variable is useful in order to be used by the Anime editor
// (so that the attack sequence can be unleashed.
//------------------------------------------------------------------
function SetHandAttacking(bool atacar)
{
   if (HandAttAcking != atacar)
   {
      HandAttAcking = atacar;
      AttAcking = atacar;
      if (atacar)
      {
         weaponDiab.WeaponPlaySound(DiabolusHandAttack);
      }
   }
}
//------------------------------------------------------------------
//------------------------------------------------------------------
function SetHeartTime(bool knockout)
{
   local NavigationPoint spawnPoint;
   local float result;

   dizzy = false;

   if (KnockDown != knockout)
   {
      knockDown = knockout;
      if (knockout)
      {
         self.PlaySound(diabolusKnocked, false, true);
         result = RandRange(0,4);
      	 if (result < 1.0)
         {
            spawnPoint = spawnPoint1;
         }
         else
         {
         	if (result < 2)
            {
               spawnPoint = spawnPoint2;
            }
            else
            {
               if (result < 3)
               {
                  spawnPoint = spawnPoint3;
               }
               else
               {
                  spawnPoint = spawnPoint4;
               }
            }
         }

         if (RandRange(1,2) > 1.5)
         {
            Spawn(class'ShortiePawn',,,spawnPoint.Location,spawnPoint.Rotation );
         }
         else
         {
            Spawn(class'ScreamerPawn',,,spawnPoint.Location,spawnPoint.Rotation );
         }
      }
      else
      {
         self.PlaySound(diabolusRindo, false, true);
      }
   }
}



//------------------------------------------------------------------
// This function is linked to the revenge timer and with the Attack
// substate Revenge.
// It will be called by the Controller class whenever it receives
// the notification that the Diabolus has been hit requesting to
// increase its speed to toss fireballs.
// On the opposite direction, when revenge timer runs out, this 
// function is internally called in order to decrease these values
// to their original ones.
//------------------------------------------------------------------
function ChangeFuryState(bool fury)
{
   reduceFuryTimer = 0;                   // Reset revenge timer

   if (fury)
   {
      if (weaponDiab.FireInterval[0] == firingRate)
      {
         weaponDiab.FireInterval[0] = (firingRate/2);
      }
   }
   else
   {
      if (weaponDiab.FireInterval[0] < firingRate)
      {
         weaponDiab.FireInterval[0] = firingRate;
      }
   }
}



//------------------------------------------------------------------
// This event is notified whenever the Diabolus is hit. It has been
// overwritten here just to send a notification to the controller
// class by calling the NotifyTakeHit1 function.
//------------------------------------------------------------------
event TakeDamage (int Damage, Controller EventInstigator, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
   LogMessage("Event Pawn TakeDamage");

   if (!KnockDown)
      if (!dizzy)
      {
         super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum/100,DamageType,HitInfo,DamageCauser);
         ChangeFuryState(true);
         self.PlaySound(diabolusPain, false, true);
      }
   myController.NotifyTakeHit1(Damage);
}



//------------------------------------------------------------------
// This event is from utmost importance to every Pawn.
// At some pre-determined intervals (usually between 0.05 and 0.1 
// seconds - it depends on the computer capacity) this event will 
// be triggered and for instance, the Pawn can use these notifications 
// in order to take timing based actions (basically, the primarily
// intervals, determined by the DeltaTime will be added till 
// completion of 1 second).
// Here, revenge timer is also implemented, with the aid of
// reduceFuryTimer variable so that when a predetermined timeout
// (defined by configurable variable revengeTimer) is reached, 
// a request to reduce the Diabolus speed will be carried out by 
// calling the ChangeFuryState function with a negative value 
// (in this case, if the Attack sub-state is Revenge, it will be 
// set back to Normal Attack).
//------------------------------------------------------------------
simulated event Tick(float DeltaTime)
{
   
   super.Tick(DeltaTime);
   if (tickCounter < 1)
   {
      tickCounter +=DeltaTime;
   }
   else                                      // Wait one second
   {
      reduceFuryTimer += 1;
      tickCounter = 0;
   }
   
   if (reduceFuryTimer == revengeTimer)     // Wait "n" seconds
   {
      reduceFuryTimer = 0;
      ChangeFuryState(false);
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