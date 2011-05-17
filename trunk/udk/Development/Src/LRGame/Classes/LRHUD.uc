class LRHUD extends UTHUDBase;

//Reference the actual SWF container (LRGFxHUD created later)
var LRGFxHUD HudMovie;

//Called when this is destroyed
singular event Destroyed() {
	if (HudMovie != none) {
		//Get rid of the memory usage of HudMovie
		HudMovie.Close(true);
		HudMovie = none;
	}
	Super.Destroyed();
}

//Called after game loaded - initialise things
simulated function PostBeginPlay() {
	super.PostBeginPlay();
	HudMovie = new class'LRGFxHUD';	//Create a LRGFxHUD for HudMovie
	HudMovie.SetTimingMode(TM_Real); //Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.Init(); //Call HudMovie's Initialise function
}

//Called every tick the HUD should be updated
event PostRender() {
	HudMovie.TickHUD();
}

function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	PlayerReplicationInfo	RelatedPRI_2,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)
{
	local class<UTLocalMessage> UTMessageClass;

	UTMessageClass = class<UTLocalMessage>(InMessageClass);
/*
	if (InMessageClass == class'UTMultiKillMessage')
		HudMovie.ShowMultiKill(Switch, "Kill Streak!");
	else if (ClassIsChildOf (InMessageClass, class'UTDeathMessage'))
		HudMovie.AddDeathMessage (RelatedPRI_1, RelatedPRI_2, class<UTDamageType>(OptionalObject));
	else  if ( (UTMessageClass == None) || UTMessageClass.default.MessageArea > 6 )
	{
		HudMovie.AddMessage("text", InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}
	else 
	*/
	if ( (UTMessageClass.default.MessageArea < 4) || (UTMessageClass.default.MessageArea == 6) )
	{
		HudMovie.SetCenterText(InMessageClass.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
	}

	// Skip message area 4,5 for now (pickup and weapon switch messages)
}

DefaultProperties
{
}