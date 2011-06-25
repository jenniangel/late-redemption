/**
 * Copyright 2011 Late Redemption, Inc. All Rights Reserved.
 */

class UTAttachment_Glock extends UTWeaponAttachment;

var ParticleSystem BeamTemplate;
var class<UDKExplosionLight> ImpactLightClass;

var int CurrentPath;

var bool bHittingWall;
var UTEmitter HitWallEffect;
var ParticleSystem WallHitTemplate;

/** emitter playing the endpoint effect */
var UTEmitter BeamEndpointEffect;

/** decal for explosion */
var MaterialInterface BeamDecal;
var float DecalWidth, DecalHeight;
/** How long the decal should last before fading out **/
var float DurationOfDecal;
/** MaterialInstance param name for dissolving the decal **/
var name DecalDissolveParamName;
/** Number of ticks between decals */
var() int TicksBetweenDecals;
/** Number of ticks since last decal */
var int TicksSinceLastDecal;

simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local actor HitActor;
	local vector HitNormal, HitLocation;

	if ( End == Vect(0,0,0) )
	{
		if ( !bFirstPerson || (Instigator.Controller == None) )
		{
	    	return;
		}
		// guess using current viewrotation;
		End = Start + vector(Instigator.Controller.Rotation) * class'UTWeap_Glock'.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
		if ( HitActor != None )
		{
			End = HitLocation;
		}
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('ShockBeamEnd', End);
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
	{
		E.SetDepthPriorityGroup(SDPG_Foreground);
	}
	else
	{
		E.SetDepthPriorityGroup(SDPG_World);
	}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	local vector EffectLocation;

	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	if (Instigator.FiringMode == 0 || Instigator.FiringMode == 3)
	{
		EffectLocation = UTWeapon(PawnWeapon).GetEffectLocation();
		SpawnBeam(EffectLocation, HitLocation, true);

		if (!WorldInfo.bDropDetail && Instigator.Controller != None)
		{
			UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ImpactLightClass, HitLocation);
		}
	}
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	if ((Instigator.FiringMode == 0 || Instigator.FiringMode == 3))
	{
		SpawnBeam(GetEffectLocation(), HitLocation, false);
	}
}

simulated function bool AllowImpactEffects(Actor HitActor, vector HitLocation, vector HitNormal)
{
	return (HitActor != None && UTProj_ShockBall(HitActor) == None && Super.AllowImpactEffects(HitActor, HitLocation, HitNormal));
}

simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (Instigator.FiringMode == 0)
	{
		NewPath = Rand(3);
		if (NewPath == CurrentPath)
		{
			NewPath++;
		}
		CurrentPath = NewPath % 3;

		PathValues[CurrentPath % 3] = 1.0;
		PSC.SetFloatParameter('Path1',PathValues[0]);
		PSC.SetFloatParameter('Path2',PathValues[1]);
		PSC.SetFloatParameter('Path3',PathValues[2]);
//			CurrentPath++;
	}
	else if (Instigator.FiringMode == 3)
	{
		PSC.SetFloatParameter('Path1',1.0);
		PSC.SetFloatParameter('Path2',1.0);
		PSC.SetFloatParameter('Path3',1.0);
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}

}

simulated function SetImpactedActor(Actor HitActor, vector HitLocation, vector HitNormal, TraceHitInfo HitInfo)
{
	local MaterialInstanceTimeVarying MITV_Decal;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (HitActor != None)
		{
			if(!bHittingWall)
			{

				bHittingWall = UTPawn(HitActor) == none;
				if(bHittingwall)
				{
					HitWallEffect = Spawn(class'UTEmitter', self,, HitLocation);// WorldInfo.MyEmitterPool.SpawnEmitter(WallHitTemplate, HitLocation, Rotator(HitNormal));
					HitWallEffect.SetTemplate(WallHitTemplate);
				}
			}

			if (BeamEndpointEffect != None)
			{
				BeamEndpointEffect.SetRotation(rotator(HitNormal));
			}
		}
		if(bHittingWall)
		{
			if ( HitActor.bWorldGeometry )
			{ 
				HitStaticMesh = StaticMeshComponent(HitInfo.HitComponent);
				if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
				{
					NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
					if ( NewKActor != None )
					{
						HitActor = NewKActor;
					}
				}
			}
			if(HitWallEffect != none)
			{
				HitWallEffect.SetRotation(rotator(HitNormal));
				HitWallEffect.SetLocation(HitLocation);
			}

			// Apply beam decal
			if (TicksBetweenDecals <= TicksSinceLastDecal)
			{
				if( MaterialInstanceTimeVarying(BeamDecal) != none )
				{
					MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
					MITV_Decal.SetParent( BeamDecal );
					WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, HitLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, FALSE );
					MITV_Decal.SetScalarStartTime( DecalDissolveParamName, DurationOfDecal );
				}
				else
				{
					WorldInfo.MyDecalManager.SpawnDecal( BeamDecal, HitLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, true );
				}
				TicksSinceLastDecal = 0;
			}
			else
			{
				++TicksSinceLastDecal;
			}
		}
		else
		{
			HitWallEffect = none;
		}
	}
}

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'LateRedemptionMarshall.Mesh.glock'
	End Object

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam_Impact_2', Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	ImpactEffects(0)=(MaterialType=Water, ParticleTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_HIT', Sound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue')
	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

	MuzzleFlashSocket=MuzzleFlashSocket
//	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Primary
	//MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	//MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	//MuzzleFlashPSCTemplate=VH_Manta.Effects.PS_Manta_Gun_MuzzleFlash
	MuzzleFlashPSCTemplate=VH_Cicada.Effects.P_VH_Cicada_2ndAltFlash
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	//BeamTemplate=particlesystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam'
	WeaponClass=class'UTWeap_Glock'
	ImpactLightClass=class'UTShockImpactLight'
	WeapAnimType=EWAT_Pistol

        BeamDecal=MaterialInstanceTimeVarying'WP_FlakCannon.Decals.MITV_WP_FlakCannon_Impact_Decal01'
	DecalWidth=32.0
	DecalHeight=32.0
	DecalDissolveParamName="DissolveAmount"
	DurationOfDecal=20.0
	TicksBetweenDecals=0
}