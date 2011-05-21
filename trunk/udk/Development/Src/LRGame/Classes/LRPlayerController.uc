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

defaultproperties
{

}