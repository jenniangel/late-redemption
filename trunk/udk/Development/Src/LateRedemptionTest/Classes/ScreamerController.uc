class ScreamerController extends AIController;

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var ScreamerPawn myScreamer;      // Screamer controlled by this IA.
var Pawn thePlayer;               // Player - must die...

var int actual_node;              // Used during navigation
var int last_node;                // Used during navigation

var Name AnimSetName;             // Just overwrite parent value.

var bool  followingPath;          // Movement is ongoing
var float distanceToPlayer;       // No comments...
var Float IdleInterval;

//------------------------------------------------------------------
// Variables you get directly from the ScreamerPawn Class
//------------------------------------------------------------------
var array<NavigationPoint> navigationPointsScreamer;
var float perceptionDistance;     // Myopia factor :)
var float attackDistance;         // Anything within this radio dies



//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
defaultproperties
{
   actual_node = 0
   last_node = 0
   AnimSetName ="ATTACK"
   followingPath = true
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
   if (myScreamer.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
// Function triggered by the ScreamerPawn Class when a new Screamer
// is created (it associates an Pawn object with its controller
// object). Some important variable values are sync at this moment.
//------------------------------------------------------------------
function SetPawn(ScreamerPawn NewPawn)
{
   LogMessage("Function ScreamerController SetPawn");
   myScreamer = NewPawn;
   Possess(myScreamer, false);
   myScreamer.SetAttacking(false);
   navigationPointsScreamer = myScreamer.navigationPointsScreamer;
   perceptionDistance = myScreamer.perceptionDistance;
   attackDistance = myScreamer.attackDistance;
   IdleInterval = myScreamer.idleTime;
}


//------------------------------------------------------------------
// This function is called when the Pawn being controlled by this
// controller gets alive (it is called from within above function
// which is triggered when the ScreamerPawn is Spawned).
//------------------------------------------------------------------
function Possess(Pawn aPawn, bool bVehicleTransition)
{
   LogMessage("Function ScreamerController Possess");
   if (aPawn.bDeleteMe)
   {
      LogMessage("Function ScreamerController Possess Fail");
      ScriptTrace();
      GotoState('Dead');
   }
   else
   {
      LogMessage("Function ScreamerController Possess Success");
      Super.Possess(aPawn, bVehicleTransition);
      Pawn.SetMovementPhysics();
   }
}


//------------------------------------------------------------------
// Whenever the Pawn is hit, it will inform its controller by means
// of this function.
// The action being taken is to lock target on player, send a
// request towards the Pawn Class to increase its speed (revenge
// timer and attack sub-states are triggered here) and change 
// the internal state value.
// If the player is too far from the Screamer, the Screamer will 
// start a cover routine, trying to go to a safe place or try to
// close the distance towards the player.
// Also this is the momment to stop attacking (if attack is ongoing)
// in order to restart it latter on (eventually in the fury mode).
//------------------------------------------------------------------
function NotifyTakeHit1()
{
   LogMessage("Event ScreamerController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
   if (myScreamer.AttAcking == true)
   {
      myScreamer.SetAttacking(false);
      myScreamer.StopFire(0);
   }

   if (distanceToPlayer < perceptionDistance)
   { 
      GotoState('Pursuit');                 // Go after Player
   }
   else
   {
      GotoState('FollowPath');              // Run from the Player
   }
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Screamer will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// This is the default state - the one triggered after the 
// Screamer is possessed.
// If when in this state, the player enters the vision radio, a
// pursuit will start.
//------------------------------------------------------------------
auto state Idle
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event ScreamerController SeePLayer Idle");
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
      LogMessage("State ScreamerController Idle");

      Pawn.Acceleration = vect(0,0,0);
      Sleep(IdleInterval);

      actual_node = last_node;
      GotoState('FollowPath');                   // Start Patrol
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
// Either when the Player is detected or when the Screamer is hit
// by a player projectile and the distance between the player and the
// Screamer is within the perception distance limit, this state 
// will be unleashed. The action sequence within this state ensures
// that wherever the player goes, the Screamer will be following him.
// - If the Screamer loose contact with Player, it will go back to 
//   the idle State (and in sequence, will restart the Patrol 
//   mechanism).
// - In case player is not reachable (e.g.: protected by a wall),
//   the Screamer will try to reach him by going through some of its 
//   known anchor places.
// - If the player is close enough (i.e.: it is within the Attack
//   distance value), the state will be changed to Attack.
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State ScreamerController Pursuit");
      Pawn.Acceleration = vect(0,0,1);
      MoveToward(thePlayer, thePlayer, attackDistance);

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
               MoveToward(thePlayer, thePlayer, attackDistance);
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
               LogMessage("ScreamerController Moving Towards Player");
               distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
               MoveToward(MoveTarget, thePlayer, attackDistance);
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
// when revenge timer is active as well - i.e.: state Revenge is
// in fact a Attack Sub-state) it means that Player is under 
// Screamer's fireballs range. Hunting season has just begun...
// If the player is able to escape from Screamer's fire sight (either
// by hiding himself or by fleeing), Screamer state will be moved 
// back to Pursuit.
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State ScreamerController Attack");
      Sleep(0.1);
      myScreamer.ZeroMovementVariables();
      myScreamer.SetAttacking(true);
      myScreamer.StartFire(0);

      while(true && thePlayer.Health > 0)
      {   
         if (!ActorReachable(thePlayer))
         {
            myScreamer.SetAttacking(false);
            myScreamer.StopFire(0);
            GotoState('Pursuit');
            break;
         }

         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 2)
         { 
            myScreamer.SetAttacking(false);
            myScreamer.StopFire(0);
            GotoState('Pursuit');
            break;
         }
         Sleep(1);

      }
      myScreamer.StopFire(0);
      myScreamer.SetAttacking(false);
      GotoState('Idle');

}





//------------------------------------------------------------------
//------------------------------State = FollowPath------------------
// When the Screamer is hit by a bullet but the Player is too far,
// rather than initiating an offensive against the player, it will
// start a movement process trying to move towards reference points
// whereas searching for the player or trying to hide from the 
// player bullets.
// This patrol is also triggered by default after some time without
// action (timer defined by IdleInterval parameter).
// It is important to notice that in this state, the Screamer will
// keep an eye opened searching for the Player and in case it is 
// visible, it will start its hunting sequence by going to Pursuit 
// state.
//------------------------------------------------------------------
state FollowPath
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event ScreamerController SeePLayer FollowPath");
      thePlayer = seenPlayer;
      distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
      if (distanceToPlayer < perceptionDistance)
      { 
         followingPath = false;
         GotoState('Pursuit');
      }
   }

   Begin:

      LogMessage("State FollowPath");
      followingPath = true;
      thePlayer = GetALocalPlayerController().Pawn;

      while(followingPath)
      {
         MoveTarget = navigationPointsScreamer[actual_node];

         if(Pawn.ReachedDestination(MoveTarget))
         {
            actual_node++;

            if (actual_node >= navigationPointsScreamer.Length)
            {
               actual_node = 0;
            }
            last_node = actual_node;

            MoveTarget = navigationPointsScreamer[actual_node];
         }
         if (ActorReachable(MoveTarget))
         {
            MoveToward(MoveTarget, thePlayer);	
         }
         else
         {
            MoveTarget = FindPathToward(navigationPointsScreamer[actual_node]);
            if (MoveTarget != none)
            {
               MoveToward(MoveTarget, thePlayer);
            }
         }
         Sleep(1);
      }
}
