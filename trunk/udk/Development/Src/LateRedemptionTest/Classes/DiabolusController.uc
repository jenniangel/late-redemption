class DiabolusController extends AIController;

//==================================================================
//-----------------------------Variables----------------------------
//==================================================================
var DiabolusPawn myDiabolus;      // Diabolus controlled by this IA.
var Pawn thePlayer;               // Player - must die...

var int actual_node;              // Used during navigation
var int last_node;                // Used during navigation

var Name AnimSetName;             // Just overwrite parent value.

var float distanceToPlayer;       // No comments...
var Float IdleInterval;
var Float heartTime;
var int initialHealth;            // Initial Health
var int shotsOnHeartCount;        // Counter of Number of Shots on Heart
var int maxShotsOnHeart;          // Number of Shots on Heart to kill

//------------------------------------------------------------------
// Variables you get directly from the DiabolusPawn Class
//------------------------------------------------------------------
var int heartHealth;              // My real vital force...
var int handAttackDistance;       // Anything within this radio dies
                                  // by my clawns. Outside, by fire!


//==================================================================
//-----------Just in case they are not initialized,-----------------
//---------------let's give them a default value--------------------
//==================================================================
defaultproperties
{
   AnimSetName ="ATTACK";
   heartHealth = 200;
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
   if (myDiabolus.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
// Function triggered by the DiabolusPawn Class when a new Diabolus
// is created (it associates an Pawn object with its controller
// object). Some important variable values are sync at this moment.
//------------------------------------------------------------------
function SetPawn(DiabolusPawn NewPawn)
{
   LogMessage("Function DiabolusController SetPawn");
   myDiabolus = NewPawn;
   Possess(myDiabolus, false);
   myDiabolus.SetFireAttacking(false);
   myDiabolus.SetHandAttacking(false);
   handAttackDistance = myDiabolus.handAttackDistance;
   heartHealth = myDiabolus.heartHealth;
   IdleInterval = myDiabolus.idleTime;
   heartTime = myDiabolus.heartTime;
   initialHealth = myDiabolus.initialHealth;
}


//------------------------------------------------------------------
// This function is called when the Pawn being controlled by this
// controller gets alive (it is called from within above function
// which is triggered when the DiabolusPawn is Spawned).
//------------------------------------------------------------------
function Possess(Pawn aPawn, bool bVehicleTransition)
{
   LogMessage("Function DiabolusController Possess");
   if (aPawn.bDeleteMe)
   {
      LogMessage("Function DiabolusController Possess Fail");
      ScriptTrace();
      GotoState('Dead');
   }
   else
   {
      LogMessage("Function DiabolusController Possess Success");
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
// If the player is too far from the Diabolus, the Diabolus will 
// start a cover routine, trying to go to a safe place or try to
// close the distance towards the player.
// Also this is the momment to stop attacking (if attack is ongoing)
// in order to restart it latter on (eventually in the fury mode).
//------------------------------------------------------------------
function NotifyTakeHit1(int damage)
{
   LogMessage("Event DiabolusController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;

   if (myDiabolus.Health < (initialHealth/5))  // 10% of initial health.
      GotoState('HealMe');
   else
   {

   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);

   if (distanceToPlayer < handAttackDistance)
   { 
      GotoState('AttackHand');
   }
   else
   {
      if (!self.IsinState('AttackFire'))
      	myDiabolus.SetFireAttacking(false);    // Set to false to enable fury state
      GotoState('AttackFire');
   }
   }
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Diabolus will wait for a while (IdleInterval)
// and in case Player is not visible, it will start a patrol.
// This is the default state - the one triggered after the 
// Diabolus is possessed.
// If when in this state, the player enters the vision radio, a
// pursuit will start.
//------------------------------------------------------------------
auto state Idle
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event DiabolusController SeePLayer Idle");
      thePlayer = seenPlayer;
      if( PlayerController(thePlayer.Controller) != none )
      {
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer < handAttackDistance)
         { 
            GotoState('AttackHand');
         }
         else
         {
            GotoState('AttackFire');
         }
      }
   }

   Begin:
//      ignores SeePlayer;
      LogMessage("State DiabolusController Idle");
      Sleep(IdleInterval);
//      enables(SeePlayer);  
}



//------------------------------------------------------------------
//------------------------------State = AttackFire------------------
// If we reached this state (by the way, global state Attack is kept
// when revenge timer is active as well - i.e.: state Revenge is
// in fact a Attack Sub-state) it means that Player is under 
// Diabolus's fireballs range. Hunting season has just begun...
// If the player is able to escape from Diabolus's fire sight (either
// by hiding himself or by fleeing)... Ops, in the library, there is
// No way to escape from Diabolus fire sight huahaha...
//------------------------------------------------------------------
state AttackFire
{
   Begin:
      LogMessage("State DiabolusController AttackFire");
      myDiabolus.SetHandAttacking(false);
      myDiabolus.ZeroMovementVariables();
      MoveToward(thePlayer, thePlayer, 10000);
      myDiabolus.SetFireAttacking(true);

      while(true && thePlayer.Health > 0)
      {   
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer < handAttackDistance)
         { 
            GotoState('AttackHand');
            break;
         }
         Sleep(1.0);

      }
      myDiabolus.SetFireAttacking(false);
      Sleep(1.0);
      GotoState('Idle');

}


//------------------------------------------------------------------
//------------------------------State = AttackHand------------------
// If we reached this state (by the way, global state Attack is kept
// when revenge timer is active as well - i.e.: state Revenge is
// in fact a Attack Sub-state) it means that Player is under 
// Diabolus's fireballs range. Hunting season has just begun...
// If the player is able to escape from Diabolus's fire sight (either
// by hiding himself or by fleeing), Diabolus state will be moved 
// back to Pursuit.
//------------------------------------------------------------------
state AttackHand
{
   Begin:
      LogMessage("State DiabolusController AttackHand");
      myDiabolus.SetFireAttacking(false);
      myDiabolus.ZeroMovementVariables();
      MoveToward(thePlayer, thePlayer, 10000);
      myDiabolus.SetHandAttacking(true);
      while(true && thePlayer.Health > 0)
      {   
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > handAttackDistance)
         { 
            myDiabolus.SetHandAttacking(false);
            GotoState('AttackFire');
            break;
         }
         Sleep(1.0);
      }
      myDiabolus.SetHandAttacking(false);
      Sleep(1.0);
      GotoState('Idle');

}


//------------------------------------------------------------------
//------------------------------State = AttackHand------------------
state HealMe
{
   function NotifyTakeHit1(int damage)
   {
      heartHealth = heartHealth - damage;
      if (heartHealth <= 0)
         GotoState('Dying');
   }


   Begin:
      myDiabolus.SetFireAttacking(false);
      myDiabolus.SetHeartTime(true);
      Sleep(heartTime);
      myDiabolus.SetHeartTime(false);
      myDiabolus.Health = myDiabolus.initialHealth;
      GotoState('Idle');
   
}