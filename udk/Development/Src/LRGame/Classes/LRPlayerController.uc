class LRPlayerController extends UTPlayerController;

exec function RequestReload()
{
	local UTWeap_Glock mywp;
	local int clips;
	mywp = UTWeap_Glock(Pawn.Weapon);

	if(mywp != none)
	{
		clips = mywp.clips;

		if(clips > 0 && !mywp.bIsReloading && mywp.AmmoCount != mywp.MaxAmmoCount)
		{
			mywp.bIsReloading = true;
			mywp.AcionarReload();
		}
	}
}

reliable client function PlayStartupMessage(byte StartupStage) 
{
	// Evitando tocar anúncio do início da partida
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
