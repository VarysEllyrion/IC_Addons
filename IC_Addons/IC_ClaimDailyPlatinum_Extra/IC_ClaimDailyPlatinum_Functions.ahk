class IC_ClaimDailyPlatinum_Functions
{
	
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
	
	IsGameClosed()
	{
		if(g_SF.Memory.ReadCurrentZone() == "" && Not WinExist( "ahk_exe " . g_userSettings[ "ExeName"] ))
			return true
		return false
	}
	
}