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

/**
 * Método que executa a animação de reload definida no Pawn.
 **/
function PlayPawnReloadAnimation() 
{
	LRPawn(Pawn).SetReload();
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

// Player movement.
// Player Standing, walking, running, falling, stop walking to reload
state PlayerWalking
{
	ignores SeePlayer, HearNoise, Bump;

	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
		}
		else
		{
			DoubleClickDir = DCLICK_None;
		}

		if (Global.NotifyLanded(HitNormal, FloorActor))
		{
			return true;
		}

		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UTPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}

    function PlayerMove( float DeltaTime )
    {
		local UTWeap_Glock mywp;
		mywp = UTWeap_Glock(Pawn.Weapon);
		// Se está em reload, então não se movimenta.
		if (!mywp.bIsReloading) {
			GroundPitch = 0;
			Super.PlayerMove(DeltaTime);
		} else {
			// Garante que a velocidade do Pawn esteja em 0 no reload.
			Pawn.ZeroMovementVariables();
		}
	}
}