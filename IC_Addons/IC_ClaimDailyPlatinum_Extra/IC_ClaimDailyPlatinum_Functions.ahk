class IC_ClaimDailyPlatinum_Functions
{

	static LogFile := A_LineFile . "\..\logs.json"
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	UpdateSharedSettings()
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.CDP_UpdateSettingsFromFile(IC_ClaimDailyPlatinum_Component.SettingsPath)
		}
	}
	
	SetClaimables(CDP_boilerplate, CDP_claimables, CDP_freebieIDs)
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			for k,v in CDP_claimables
			{
				if (!v)
					continue
				CDP_GetClaimedState := SharedRunData.CDP_GetClaimedState(k)
				if (CDP_GetClaimedState == 0)
					SharedRunData.CDP_SetClaimable(k, CDP_boilerplate)
			}
			for k,v in CDP_freebieIDs
			{
				SharedRunData.CDP_AddFreebieOfferIDs(v)
			}
		}
	}
	
	GetClaimedState(CDP_key)
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			return SharedRunData.CDP_GetClaimedState(CDP_key)
		}
		return ""
	}
	
	ClearClaimedState(CDP_key)
	{
		try {
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
			SharedRunData.CDP_ClearClaimedState(CDP_key)
		}
	}
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" && Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
}