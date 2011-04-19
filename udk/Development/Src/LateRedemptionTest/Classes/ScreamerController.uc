class ScreamerController extends AIController;

//------------------------------------------------------------------
//-----------------------------Variables----------------------------
//------------------------------------------------------------------
var ScreamerPawn myScreamer1Pawn;    // Screamer controlled by this IA.
var Pawn thePlayer;                  // Player - must die...

var () array<NavigationPoint> MyNavigationPoints;

var int actual_node;
var int last_node;

var float perceptionDistance;     // Myopia factor :)
var () float attackDistance;      // Anything within this radio will die
var float distanceToPlayer;       // No comments.

var Name AnimSetName;

var bool  followingPath;          // Moviment is ongoing
var Float IdleInterval;
const ADDSPEEDONHIT=350;          // Increase in speed at hit.


defaultproperties
{
   attackDistance = 300.0f
   perceptionDistance = 10000
   AnimSetName ="ATTACK"
   actual_node = 0
   last_node = 0
   followingPath = true
   IdleInterval = 2.5f
}



//------------------------------------------------------------------
//----------------------Global Functions/Events---------------------
//------------------------------------------------------------------
function LogMessage(String texto)
{
   if (myScreamer1Pawn.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
function SetPawn(ScreamerPawn NewPawn)
{
   LogMessage("Function ScreamerController SetPawn");
   myScreamer1Pawn = NewPawn;
   Possess(myScreamer1Pawn, false);
   MyNavigationPoints = myScreamer1Pawn.MyNavigationPoints;
}


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
      if (Pawn.Physics == PHYS_Walking)
      {
         Pawn.SetPhysics(PHYS_Falling);
      }
   }
}


//------------------------------------------------------------------
function NotifyTakeHit1()
{
   LogMessage("Event ScreamerController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   myScreamer1Pawn.ChangeSpeed(ADDSPEEDONHIT);
   distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
   if (distanceToPlayer < perceptionDistance)
   { 
      GotoState('Pursuit');
   }
   else
   {
      GotoState('FollowPath');
   }
}



//------------------------------------------------------------------
//------------------------------State = IDLE------------------------
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
      GotoState('FollowPath');
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State ScreamerController Pursuit");
      Pawn.Acceleration = vect(0,0,1);

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
            MoveTarget = FindPathToward(thePlayer,,perceptionDistance);
            if (MoveTarget != none)
            {
               Worldinfo.Game.Broadcast(self, "Moving toward Player");
               distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
               if (distanceToPlayer < attackDistance)
                  MoveToward(MoveTarget, thePlayer, attackDistance);
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
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State ScreamerController Attack");
	  myScreamer1Pawn.ZeroMovementVariables();
      myScreamer1Pawn.SetAttacking(true);
      myScreamer1Pawn.StartFire(0);
      MoveToward(thePlayer, thePlayer, attackDistance);

	while(true && thePlayer.Health > 0)
      {   
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 2)
         { 
            myScreamer1Pawn.SetAttacking(false);
            myScreamer1Pawn.StopFire(0);
            GotoState('Pursuit');
            break;
         }
         if (distanceToPlayer < attackDistance / 2)
		 {
  //        MoveTo(FindRandomDest().Location);
		 }
         Sleep(1);
      }
      myScreamer1Pawn.StopFire(0);
      myScreamer1Pawn.SetAttacking(false);
	  GotoState('Idle');

}





//------------------------------------------------------------------
//------------------------------State = FollowPath------------------
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

      while(followingPath)
      {
         MoveTarget = MyNavigationPoints[actual_node];

         if(Pawn.ReachedDestination(MoveTarget))
         {
            //WorldInfo.Game.Broadcast(self, "Encontrei o node");
            actual_node++;

            if (actual_node >= MyNavigationPoints.Length)
            {
               actual_node = 0;
            }
            last_node = actual_node;

            MoveTarget = MyNavigationPoints[actual_node];
         }
         if (ActorReachable(MoveTarget))
         {
            MoveToward(MoveTarget, MoveTarget);	
         }
         else
         {
            MoveTarget = FindPathToward(MyNavigationPoints[actual_node]);
            if (MoveTarget != none)
            {
               //SetRotation(RInterpTo(Rotation,Rotator(MoveTarget.Location),Delta,90000,true));
               MoveToward(MoveTarget, MoveTarget);
            }
         }
         Sleep(1);
      }
}