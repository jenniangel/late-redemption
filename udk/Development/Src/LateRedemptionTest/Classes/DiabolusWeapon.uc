class DiabolusWeapon extends UTWeap_LinkGun;
 
simulated function PostBeginPlay()
{
Super.PostBeginPlay();
FireInterval[0]=1.00;
DroppedPickupMesh = none;
AimError = 0; 
WeaponProjectiles[0]=class'LateRedemptionTest.DiabolusProjectile';
}