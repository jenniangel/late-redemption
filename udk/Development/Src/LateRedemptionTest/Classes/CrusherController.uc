class CrusherController extends AIController;

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var CrusherPawn myCrusher;         // Crusher controlled by this IA.
var Pawn thePlayer;                // Player - must die...

var int actual_node;              // Used during navigation
var int last_node;                // Used during navigation

var Name AnimSetName;

var bool  followingPath;          // Movement is ongoing
var bool  awake;                  // Whether monster is awaken
var float distanceToPlayer;       // No comments...
var Float IdleInterval;           // Time before start patrol
var Float AngerTime;              // Time to attack.

//------------------------------------------------------------------
// Variables you get directly from the CrusherPawn Class
//------------------------------------------------------------------
var array<NavigationPoint> navigationPointsCrusher;
var float perceptionDistance;     // Myopia factor :)
var float attackDistance;         // Anything within this radio dies



//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
defaultproperties
{
   AnimSetName ="ATTACK"
   followingPath = true
   IdleInterval = 2.5f
   awake = false
   AngerTime = 3
}



//==================================================================
//----------------------Global Functions/Events---------------------
//--------They can be unleashed no matter the state we are----------
//==================================================================

//------------------------------------------------------------------
// This function is only used for debug purpose. It simply unleashes
// internal messages in case the logactive flag is turned on.
//------------------------------------------------------------------
function LogMessage(String texto)
{
   if (myCrusher.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
// Function triggered by the CrusherPawn Class when a new Crusher
// is created (it associates an Pawn object with its controller
// object. Some important variable values are sync at this moment.
//------------------------------------------------------------------
function SetPawn(CrusherPawn NewPawn)
{
   LogMessage("Function CrusherController SetPawn");
   myCrusher = NewPawn;
   Possess(myCrusher, false);
   myCrusher.SetAttacking(false,false);
   perceptionDistance = myCrusher.perceptionDistance;
   navigationPointsCrusher = myCrusher.navigationPointsCrusher;
   attackDistance = myCrusher.attackDistance;
}


//------------------------------------------------------------------
// This function is called when the Pawn being controlled by this
// controller gets alive (it is called from within above function
// which is triggered when the CrusherPawn is Spawned).
//------------------------------------------------------------------
function Possess(Pawn aPawn, bool bVehicleTransition)
{
   LogMessage("Function CrusherController Possess");
   if (aPawn.bDeleteMe)
   {
      LogMessage("Function CrusherController Possess Fail");
      ScriptTrace();
      GotoState('Dead');
   }
   else
   {
      LogMessage("Function CrusherController Possess Success");
      Super.Possess(aPawn, bVehicleTransition);
      Pawn.SetMovementPhysics();
      if (Pawn.Physics == PHYS_Walking)
      {
         Pawn.SetPhysics(PHYS_Falling);
      }
   }
}


//------------------------------------------------------------------
// Whenever the Pawn is hit, it will inform its controller by means
// of this function.
// The action being taken is to lock target on player, send a
// request towards the Pawn Class to increase its speed (revenge
// timer and attack sub-states are triggered here) and change 
// the internal state value.
//------------------------------------------------------------------
function NotifyTakeHit1()
{
   LogMessage("Event CrusherController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   if (awake)
   {
      GotoState('Pursuit');                     // Go after Player
   }
   else
   {
      GotoState('Anger');
   }
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Crusher will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// (To be implemented in phase-2).
// This is the default state - the one triggered after the 
// Crusher is possessed.
//------------------------------------------------------------------
auto state Idle
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event CrusherController SeePLayer Idle");
      thePlayer = seenPlayer;
      if( PlayerController(thePlayer.Controller) != none )
      {
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer < perceptionDistance)
         { 
            if (awake)
            {
               GotoState('Pursuit');
            }
			else
			{
         	   GotoState('Anger');
			}
         }
      }
   }

   Begin:
      LogMessage("State CrusherController Idle");
      Pawn.Acceleration = vect(0,0,0);
      Sleep(IdleInterval);
	  GotoState('FollowPath');
}



//------------------------------------------------------------------
//------------------------------State = Anger-----------------------
// In this state, the Crusher will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// (To be implemented in phase-2).
// This is the default state - the one triggered after the 
// Crusher is possessed.
//------------------------------------------------------------------
state Anger
{
    ignores NotifyTakeHit1;

   Begin:
      LogMessage("State CrusherController Anger");
      awake = true;
      myCrusher.SetAttacking(false,true);
      Sleep(AngerTime);
      myCrusher.SetAttacking(false,false);
      thePlayer = GetALocalPlayerController().Pawn;
      GotoState('Pursuit');                     // Go after Player
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
// Either when the Player is detected or when the Crusher is hit
// by a player projectile, this state will be unleashed.
// The action sequence within this state ensures that wherever the 
// player goes, the Crusher will be following him.
// - If the Crusher loose contact with Player, it will go back to 
//   the idle State.
// - In case player is not reachable (e.g.: protected by a wall),
//   the Crusher will try to reach him by going through some of its 
//   known anchor places (to be implemented in phase-2, as this
//   is part of the patrol mechanism)).
// - If the player is close enough (i.e.: it is within the Attack
//   distance value), the state will be changed to Attack.
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State CrusherController Pursuit");
      Pawn.Acceleration = vect(0,0,1);
      MoveToward(thePlayer, thePlayer, 20.0f, true);

      while (Pawn != none && thePlayer.Health > 0)
      {
         if (ActorReachable(thePlayer))
         {
            distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
            if (distanceToPlayer < attackDistance)
            {
				GotoState('Attack');
				break;
            }
            else
            {
               MoveToward(thePlayer, thePlayer, 20.0f);
               if(Pawn.ReachedDestination(thePlayer))
               {
                  GotoState('Attack');
                  break;
               }
            }
         }
         else
         {
            MoveTarget = FindPathToward(thePlayer);
            if (MoveTarget != none)
            {
               LogMessage("Crusher Controller Moving Towards Player");
               distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
               if (distanceToPlayer < 100)
                  MoveToward(MoveTarget, thePlayer, 80.0f);
               else
                  MoveToward(MoveTarget, MoveTarget, attackDistance);
            }
            else
            {
               GotoState('Idle');
               break;
            }
         }
         Sleep(1);
      }
      GotoState('Idle');
}



//------------------------------------------------------------------
//------------------------------State = Attack---------------------
// If we reached this state (by the way, global state Attack is kept
// when revenge timer is active as well - i.e.: states Revenge and
// insane are in fact Attack Sub-states) it means that poor Player 
// is within the Crusher's cleaver range attack.
// This state is mortal, especially if player is trapped into
// a corner hehehe...
// If the player is able to escape from Crusher attacks (either
// by hiding himself or by fleeing), Crusher state will be moved 
// back to Pursuit.
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State CrusherController Attack");
      myCrusher.SetAttacking(true,false);
      Pawn.Acceleration = vect(0,0,0);

      while(true && thePlayer.Health > 0)
      {   
         if (!ActorReachable(thePlayer))
         {
            myCrusher.SetAttacking(false,false);
            myCrusher.StopFire(0);
            GotoState('Pursuit');
            break;
         }

         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 1.2)
         { 
            myCrusher.SetAttacking(false,false);
            GotoState('Pursuit');
            break;
         }
         Sleep(1);
      }
      myCrusher.SetAttacking(false,false);
      GotoState('Idle');
}


//------------------------------------------------------------------
//------------------------------State = FollowPath------------------
// When the Crusher is hit by a bullet but the Player is too far,
// rather than initiating an offensive against the player, it will
// start a patrol process trying to move towards reference points
// whereas searching for the player.
// This Patrol is also triggered by default after some time without
// action (timer defined by IdleInterval parameter) and as mentioned
// earlier, it will be fully implemented at Demo-2 game version.
// It is important to notice that in this state, the Crusher will
// keep searching for the Player and in case it is visible, it will
// start its hunting sequence by going to Pursuit state.
//------------------------------------------------------------------
state FollowPath
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event CrusherController SeePLayer FollowPath");
      thePlayer = seenPlayer;
      distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
      if (distanceToPlayer < perceptionDistance)
      { 
            if (awake)
            {
               followingPath = false;
               GotoState('Pursuit');
            }
			else
			{
         	   GotoState('Anger');
			}
      }
   }

   Begin:

      LogMessage("State FollowPath");
      followingPath = true;
      thePlayer = GetALocalPlayerController().Pawn;

      while(followingPath)
      {
         MoveTarget = navigationPointsCrusher[actual_node];

         if(Pawn.ReachedDestination(MoveTarget))
         {
            actual_node++;

            if (actual_node >= navigationPointsCrusher.Length)
            {
               actual_node = 0;
            }
            last_node = actual_node;

            MoveTarget = navigationPointsCrusher[actual_node];
         }
         if (ActorReachable(MoveTarget))
         {
            MoveToward(MoveTarget, thePlayer);	
         }
         else
         {
            MoveTarget = FindPathToward(navigationPointsCrusher[actual_node]);
            if (MoveTarget != none)
            {
               //SetRotation(RInterpTo(Rotation,Rotator(MoveTarget.Location),Delta,90000,true));
               MoveToward(MoveTarget, MoveTarget);
            }
         }
         Sleep(2);
      }
}
