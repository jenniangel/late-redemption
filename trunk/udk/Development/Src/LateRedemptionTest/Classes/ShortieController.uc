class ShortieController extends AIController;

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var ShortiePawn myShortie;         // Shortie controlled by this IA.
var Pawn thePlayer;                // Player - must die...

var Name AnimSetName;

var bool  followingPath;          // Movement is ongoing
var float distanceToPlayer;       // No comments...
var Float IdleInterval;

//------------------------------------------------------------------
// Variables you get directly from the ShortiePawn Class
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
   if (myShortie.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
// Function triggered by the ShortiePawn Class when a new Shortie
// is created (it associates an Pawn object with its controller
// object. Some important variable values are sync at this moment.
//------------------------------------------------------------------
function SetPawn(ShortiePawn NewPawn)
{
   LogMessage("Function ShortieController SetPawn");
   myShortie = NewPawn;
   Possess(myShortie, false);
   myShortie.SetAttacking(false);
   perceptionDistance = myShortie.perceptionDistance;
   attackDistance = myShortie.attackDistance;
}


//------------------------------------------------------------------
// This function is called when the Pawn being controlled by this
// controller gets alive (it is called from within above function
// which is triggered when the ShortiePawn is Spawned).
//------------------------------------------------------------------
function Possess(Pawn aPawn, bool bVehicleTransition)
{
   LogMessage("Function ShortieController Possess");
   if (aPawn.bDeleteMe)
   {
      LogMessage("Function ShortieController Possess Fail");
      ScriptTrace();
      GotoState('Dead');
   }
   else
   {
      LogMessage("Function ShortieController Possess Success");
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
function NotifyTakeHit1(bool hitFromPLayer)
{
   LogMessage("Event ShortieController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;

   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
   GotoState('Pursuit');                      // Go after Player
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Shortie will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// (To be implemented in phase-2).
// This is the default state - the one triggered after the 
// Shortie is possessed.
//------------------------------------------------------------------
auto state Idle
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event ShortieController SeePLayer Idle");
      thePlayer = seenPlayer;
      if( PlayerController(thePlayer.Controller) != none )
      {
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer < perceptionDistance)
         { 
            myShortie.SetPlayerVisible(true);
            GotoState('Pursuit');
         }
      }
   }

   Begin:
      LogMessage("State ShortieController Idle");
      Pawn.Acceleration = vect(0,0,0);
      Sleep(IdleInterval);
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
// Either when the Player is detected or when the Shortie is hit
// by a player projectile, this state will be unleashed.
// The action sequence within this state ensures that wherever the 
// player goes, the Shortie will be following him.
// - If the Shortie loose contact with Player, it will go back to 
//   the idle State.
// - In case player is not reachable (e.g.: protected by a wall),
//   the Shortie will try to reach him by going through some of its 
//   known anchor places (to be implemented in phase-2, as this
//   is part of the patrol mechanism)).
// - If the player is close enough (i.e.: it is within the Attack
//   distance value), the state will be changed to Attack.
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State ShortieController Pursuit");
      Pawn.Acceleration = vect(0,0,1);
      MoveToward(thePlayer, thePlayer, , true);

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
               MoveToward(thePlayer, thePlayer);
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
               LogMessage("Shortie Controller Moving Towards Player");
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
// is within the Shortie's cleaver range attack.
// This state is mortal, especially if player is trapped into
// a corner hehehe...
// If the player is able to escape from Shortie attacks (either
// by hiding himself or by fleeing), Shortie state will be moved 
// back to Pursuit.
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State ShortieController Attack");
      myShortie.SetAttacking(true);
  //  Pawn.Acceleration = vect(0,0,0);

      while(true && thePlayer.Health > 0)
      {   
         if (!ActorReachable(thePlayer))
         {
            myShortie.SetAttacking(false);
            GotoState('Pursuit');
            break;
         }

         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 2)
         { 
            myShortie.SetAttacking(false);
            GotoState('Pursuit');
            break;
         }
         Sleep(1);
      }
      myShortie.SetAttacking(false);
      GotoState('Idle');
}
