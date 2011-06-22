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
// request towards the Pawn Class to increase its firint-speed (if in
// attackfire state) and revenge timer and attack sub-states will be
// Also this is the momment to stop firing-attacking (if attack is 
// ongoing) in order to restart it latter on (eventually in the fury 
// mode), where the firing rate is increased.
// Also, the most important transition from Diabolus State Machine
// occurs from within this Function: When receiving damage and
// it is noticed that the current health is 20% lower than initial
// healt, the HealMe state (a State where Diabolus will expose his
// weakness) will be called.
//------------------------------------------------------------------
function NotifyTakeHit1(int damage)
{
   LogMessage("Event DiabolusController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);

   if (myDiabolus.Health < (initialHealth/5))  // 10% of initial health.
   {	   
      if (!self.IsinState('HealMe'))
      {
         GotoState('HealMe');
      }
   }
   else
   {
      if (distanceToPlayer < handAttackDistance)
      { 
         GotoState('AttackHand');
      }
      else
      {
         if (!self.IsinState('AttackFire'))
         {
      	    myDiabolus.SetFireAttacking(false);    // Set to false to enable fury state
         }
         GotoState('AttackFire');
      }
   }
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
// In this state, the Diabolus will wait for Marshall to be visible
// in order to start its attack routine.
// This is the default state - the one triggered after the 
// Diabolus is possessed.
// Once attack is triggered (as described below), it never stops...
// So, be carefull when deciding to enter in the Library...
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
         if (distanceToPlayer < 1000)
         {
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
   }

   Begin:
      LogMessage("State DiabolusController Idle");
}



//------------------------------------------------------------------
//------------------------------State = AttackFire------------------
// If we reached this state (by the way, global state Attack is kept
// when revenge timer is active as well - i.e.: state Revenge is
// in fact a Attack Sub-state) it means that Player is under 
// Diabolus's fireballs range (in fact, unfortunatelly this is true
// in the majority of places within the Library). Hunting season has 
// just begun... If the player is able to escape from Diabolus's fire 
// sight (either by hiding himself or by fleeing)... Ops, in the 
// library, there is No way to escape from Diabolus fire sight, unless
// Marshall enters the Diabolus Claw attack range huahaha...
//------------------------------------------------------------------
state AttackFire
{
   Begin:
      LogMessage("State DiabolusController AttackFire");
      myDiabolus.SetHandAttacking(false);
      myDiabolus.ZeroMovementVariables();
      MoveToward(thePlayer, thePlayer, 1000);
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
// If we reached this state it means that Player is under 
// Diabolus's claws range. Sorry to say that Marshall will not last
// long if kept in this radio.
// If the player is able to escape from Diabolus's claws attack range
// Diabolus state will be moved back to AttackFire (i.e.: whereas not
// dying, Diabolus will be in constant attack).
//------------------------------------------------------------------
state AttackHand
{
   Begin:
      LogMessage("State DiabolusController AttackHand");
      myDiabolus.SetFireAttacking(false);
      myDiabolus.ZeroMovementVariables();
      MoveToward(thePlayer, thePlayer, 1000);
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
//------------------------------State = HealMe----------------------
// This state is reached when Diabolus suffers a heavy ammount of
// damage, towards NotifyTakeHit1 function.
// In this state, a new NotifyTakeHit function is declared in order
// to allow a special transition from current state to Dying state,
// where a special Dying annimation can be put in place.
// Basically in this state, the Spawn points (i.e.: points where
// Diabolus can spawn Shorties and Screamers) are signallized towards
// Kismet and the annimation to expose the Diabolus Heart is shown.
// During a pre-determined time (defined by heartTime), it will be
// kept exposed and the Shots fired during this time will reduce the
// heartHEalth. When it reaches 0, Diabolus will go to dead state.
// When heartTime runs out and Diabolus is still alive, an Evil 
// laught will be heard and its Strenght will be restored.
//------------------------------------------------------------------
state HealMe
{
   function NotifyTakeHit1(int damage)
   {
      heartHealth = heartHealth - damage;
      if (heartHealth <= 0)
         {
         myDiabolus.SetHeartTime(false);
		 myDiabolus.ending = true;
         GotoState('Dying');
         }
   }


   Begin:
      myDiabolus.SetFireAttacking(false);
      myDiabolus.SetHandAttacking(false);
      myDiabolus.dizzy = true;            // Enable light in the spawn points via kismet
      Sleep(2);                               // before spawning the enemies
      myDiabolus.dizzy = false;
      myDiabolus.SetHeartTime(true);
      Sleep(heartTime-2);
      myDiabolus.SetHeartTime(false);
      myDiabolus.Health = myDiabolus.initialHealth;
      GotoState('Idle');
   
}