class ButcherController extends AIController;

//------------------------------------------------------------------
//-----------------------------Variables----------------------------
//------------------------------------------------------------------
var ButcherPawn myButcher1Pawn;    // Butcher controlled by this IA.
var Pawn thePlayer;                // Player - must die...

var () array<NavigationPoint> MyNavigationPoints;

var int actual_node;
var int last_node;

var float perceptionDistance;     // Myopia factor :)
var float attackDistance;         // Anything within this radio will die
var float distanceToPlayer;       // No comments.

var Name AnimSetName;

var bool  followingPath;          // Moviment is ongoing
var Float IdleInterval;
const ADDSPEEDONHIT=350;          // Increase in speed at hit.


defaultproperties
{
   attackDistance = 50
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
   if (myButcher1Pawn.logactive)
   {
      Worldinfo.Game.Broadcast(self, texto);
   }
}


//------------------------------------------------------------------
function SetPawn(ButcherPawn NewPawn)
{
   LogMessage("Function ButcherController SetPawn");
   myButcher1Pawn = NewPawn;
   Possess(myButcher1Pawn, false);
   MyNavigationPoints = myButcher1Pawn.MyNavigationPoints;
}


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
function NotifyTakeHit1()
{
   LogMessage("Event ButcherController NotifyTakeHit");
   thePlayer = GetALocalPlayerController().Pawn;
   myButcher1Pawn.ChangeSpeed(ADDSPEEDONHIT);
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
      myButcher1Pawn.SetAttacking(false);
      Sleep(IdleInterval);

      followingPath = true;
      actual_node = last_node;
      GotoState('FollowPath');
}



//------------------------------------------------------------------
//------------------------------State = Pursuit---------------------
//------------------------------------------------------------------
state Pursuit
{
   Begin:
      LogMessage("State ButcherController Pursuit");
      myButcher1Pawn.SetAttacking(false);
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
            else //if(distanceToPlayer < 300)
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
            MoveTarget = FindPathToward(thePlayer,,perceptionDistance + (perceptionDistance/2));
            if (MoveTarget != none)
            {
               Worldinfo.Game.Broadcast(self, "Moving toward Player");
               distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
               if (distanceToPlayer < 100)
                  MoveToward(MoveTarget, thePlayer, 20.0f);
               else
                  MoveToward(MoveTarget, MoveTarget, 20.0f);
            }
            else
            {
               GotoState('Idle');
               break;
            }
         }
         Sleep(1);
      }
}





//------------------------------------------------------------------
//------------------------------State = Attack---------------------
//------------------------------------------------------------------
state Attack
{
   Begin:
      LogMessage("State ButcherController Attack");
      Pawn.Acceleration = vect(0,0,0);
      myButcher1Pawn.SetAttacking(true);
      while(true && thePlayer.Health > 0)
      {   
         distanceToPlayer = VSize(thePlayer.Location - Pawn.Location);
         if (distanceToPlayer > attackDistance * 2)
         { 
            myButcher1Pawn.SetAttacking(false);
            GotoState('Pursuit');
            break;
         }
         Sleep(1);
      }
      myButcher1Pawn.SetAttacking(false);
}





//------------------------------------------------------------------
//------------------------------State = FollowPath------------------
//------------------------------------------------------------------
state FollowPath
{
   event SeePlayer(Pawn seenPlayer)
   {
      LogMessage("Event ButcherController SeePLayer FollowPath");
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
            //distanceToPlayer = VSize(MoveTarget.Location - Pawn.Location);
            //if (distanceToPlayer < perceptionDistance / 3)
            //MoveToward(MoveTarget, MyNavigationPoints[actual_node + 1]);
            //else
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