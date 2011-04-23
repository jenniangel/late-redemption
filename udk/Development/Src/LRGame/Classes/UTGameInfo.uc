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
defaultproperties
{
}