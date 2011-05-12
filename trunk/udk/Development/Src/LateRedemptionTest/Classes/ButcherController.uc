class ButcherController extends AIController;

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var ButcherPawn myButcher;         // Butcher controlled by this IA.
var Pawn thePlayer;                // Player - must die...

var Name AnimSetName;

var bool  followingPath;          // Movement is ongoing
var float distanceToPlayer;       // No comments...
var Float IdleInterval;

//------------------------------------------------------------------
// Variables you get directly from the ButcherPawn Class
//------------------------------------------------------------------
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
   if (myButcher.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
// Function triggered by the ButcherPawn Class when a new butcher
// is created (it associates an Pawn object with its controller
// object. Some important variable values are sync at this moment.
//------------------------------------------------------------------
function SetPawn(ButcherPawn NewPawn)
{
   LogMessage("Function ButcherController SetPawn");
   myButcher = NewPawn;
   Possess(myButcher, false);
   myButcher.SetAttacking(false);
   perceptionDistance = myButcher.perceptionDistance;
   attackDistance = myButcher.attackDistance;
}


//------------------------------------------------------------------
// This function is called when the Pawn being controlled by this
// controller gets alive (it is called from within above function
// which is triggered when the ButcherPawn is Spawned).
//------------------------------------------------------------------
function Possess(Pawn aPawn, bool bVehicleTransition)
{
   LogMessage("Function ButcherController Possess");
   if (aPawn.bDeleteMe)
   {
      LogMessage("Function ButcherController Possess Fail");
      ScriptTrace();
      GotoState('Dead');
   }
   else
   {
      LogMessage("Function ButcherController Possess Success");
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
   LogMessage("Event ButcherController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
   GotoState('Pursuit');                        // Go after Player
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Butcher will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// (To be implemented in phase-2).
// This is the default state - the one triggered after the 
// Butcher is possessed.
//------------------------------------------------------------------
auto state Idle
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event ButcherController SeePLayer Idle");
      thePlayer = seenPlayer;
      if( PlayerController(thePlayer.Controller) != none )
      {
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer < perceptionDistance)
         { 
            GotoState('Pursuit');
         }
      }
   }

   Begin:
      LogMessage("State ButcherController Idle");
      Pawn.Acceleration = vect(0,0,0);
      Sleep(IdleInterval);
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
// Either when the Player is detected or when the Butcher is hit
// by a player projectile, this state will be unleashed.
// The action sequence within this state ensures that wherever the 
// player goes, the Butcher will be following him.
// - If the Butcher loose contact with Player, it will go back to 
//   the idle State.
// - In case player is not reachable (e.g.: protected by a wall),
//   the Butcher will try to reach him by going through some of its 
//   known anchor places (to be implemented in phase-2, as this
//   is part of the patrol mechanism)).
// - If the player is close enough (i.e.: it is within the Attack
//   distance value), the state will be changed to Attack.
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State ButcherController Pursuit");
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
               LogMessage("Butcher Controller Moving Towards Player");
               distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
               MoveToward(MoveTarget, thePlayer, attackDistance);
//             if (distanceToPlayer < 100)
//                MoveToward(MoveTarget, thePlayer, 80.0f);
//             else
//                MoveToward(MoveTarget, thePlayer, attackDistance);
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
// is within the Butcher's cleaver range attack.
// This state is mortal, especially if player is trapped into
// a corner hehehe...
// If the player is able to escape from Butcher attacks (either
// by hiding himself or by fleeing), Butcher state will be moved 
// back to Pursuit.
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State ButcherController Attack");
      myButcher.SetAttacking(true);
      Pawn.Acceleration = vect(0,0,0);

      while(true && thePlayer.Health > 0)
      {   
         if (!ActorReachable(thePlayer))
         {
            myButcher.SetAttacking(false);
            myButcher.StopFire(0);
            GotoState('Pursuit');
            break;
         }

         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 2)
         { 
            myButcher.SetAttacking(false);
            GotoState('Pursuit');
            break;
         }
         Sleep(1);
      }
      myButcher.SetAttacking(false);
      GotoState('Idle');
}
