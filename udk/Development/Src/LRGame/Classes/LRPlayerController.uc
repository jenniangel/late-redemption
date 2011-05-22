class LRPlayerController extends UTPlayerController;

reliable client function PlayStartupMessage(byte StartupStage) 
{
	// Evitando tocar an�ncio do in�cio da partida
}

simulated function GetPlayerViewPoint(out vector POVLocation, out rotator POVRotation)
{
	bBehindView = true; // start in behindview by default
	super.GetPlayerViewPoint(POVLocation,POVRotation);
}

reliable client function ClientSetBehindView(bool B)
{} // override so it wont reset

function SetBehindView(bool bNewBehindView)
{} // override so it wont reset

function PrevWeapon() {
}

function NextWeapon() {
}
