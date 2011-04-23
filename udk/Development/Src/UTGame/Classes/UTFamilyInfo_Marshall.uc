Class UTFamilyInfo_Marshall extends UTFamilyInfo
   abstract;

defaultproperties
{
	CharacterMesh=SkeletalMesh'LateRedemptionMarshall.Mesh.Marshal3ds-7-4'
	
	PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	ArmMeshPackageName="CH_Corrupt_Arms"
	ArmMesh=CH_Corrupt_Arms.Mesh.SK_CH_Corrupt_Arms_MaleA_1P
	ArmSkinPackageName="CH_Corrupt_Arms"

	DefaultMeshScale=1.075
	BaseTranslationOffset=14.0

	SoundGroupClass=class'UTPawnSoundGroup_Marshall'

}
