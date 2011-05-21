class UTGameInfo extends UTGame;
function AddDefaultInventory( pawn PlayerPawn )
{
	local int i;
	//-may give the physics gun to non-bots
	if(PlayerPawn.IsHumanControlled() )
	{
		PlayerPawn.CreateInventory(class'UTWeap_Glock',true);
	}

	for (i=0; i<DefaultInventory.Length; i++)
	{
		//-Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			//-Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}
	}
	`Log("Adding inventory");
	PlayerPawn.AddDefaultInventory();

}

DefaultProperties
{
 //Indentify your GameInfo
 Acronym="LR"

 //The class for your playerController (created later)
 PlayerControllerClass=class'LRGame.LRPlayerController'

 //The class for your GFx HUD Wrapper (created later)
 HUDType=class'LRGame.LRHUD'

 //This variable was created by Epic Games to allow back compatability with UIScenes
 bUseClassicHUD=true

 //Required values
 bDelayedStart=false
 bRestartLevel=false
 Name="Default__UTGameInfo"
}
