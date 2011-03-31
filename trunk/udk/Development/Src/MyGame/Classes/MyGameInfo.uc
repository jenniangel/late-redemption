class MyGameInfo extends UTDeathmatch;

defaultproperties
{
	Acronym="MG"	

	MapPrefixes.Empty
	MapPrefixes(0)="MG"

	DefaultMapPrefixes.Empty
	DefaultMapPrefixes(0)=(Prefix="MG",GameType="MyGame.MyGameInfo")

	PlayerControllerClass=class'MyPlayerController'
	DefaultPawnClass=class'MyPawn'

	Name="Default__MyGameInfo"
}