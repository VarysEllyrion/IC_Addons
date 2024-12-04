global CDP_ClaimableParams := {"Platinum":"","FreeOffer":"","BonusChests":""}
; Claimed States:
;   0 = Idle - doing nothing.
;   1 = Waiting for offline progress in order to send call.
;   2 = Call has been sent.
global CDP_ClaimedState := {"Platinum":0,"FreeOffer":0,"BonusChests":0,"Celebrations":0}
global CDP_FreeOfferIDs := []
global CDP_BonusChestIDs := []
global CDP_CelebrityCodes := []
; global CDP_LogFile := A_LineFile . "\..\logs.json"

class IC_ClaimDailyPlatinum_SharedData_Class extends IC_SharedData_Class
{

	CDP_UpdateSettingsFromFile(fileName := "")
	{
		if (fileName == "")
			fileName := IC_ClaimDailyPlatinum_Component.SettingsPath
		settings := g_SF.LoadObjectFromJSON(fileName)
		if (!IsObject(settings))
			return false
		for k,v in settings
		{
			g_BrivUserSettingsFromAddons[ "CDP_" k ] := v
		}
	}
	
	CDP_SetClaimable(CDP_key, CDP_value)
	{
		CDP_ClaimableParams[CDP_key] := CDP_value
		CDP_ClaimedState[CDP_key] := 1
	}
	
	CDP_GetClaimedState(CDP_key)
	{
		return CDP_ClaimedState[CDP_key]
	}
	
	CDP_ClearClaimedState(CDP_key)
	{
		CDP_ClaimableParams[CDP_key] := ""
		CDP_ClaimedState[CDP_key] := 0
	}
	
	CDP_AddFreebieOfferIDs(CDP_fbID)
	{
		if (!this.HasValue(CDP_FreeOfferIDs,CDP_fbID))
			CDP_FreeOfferIDs.Push(CDP_fbID)
	}
	
	CDP_AddBonusChestIDs(CDP_bcID)
	{
		if (!this.HasValue(CDP_BonusChestIDs,CDP_bcID))
			CDP_BonusChestIDs.Push(CDP_bcID)
	}
	
	CDP_AddCelebrationCodes(CDP_ccID)
	{
		if (!this.HasValue(CDP_CelebrityCodes,CDP_ccID))
			CDP_CelebrityCodes.Push(CDP_ccID)
	}
	
	HasValue(obj,val)
	{
		for k,v in obj
			if (v == val)
				return true
		return false
	}
	
}

; Overrides Stack Restart
class IC_ClaimDailyPlatinum_BrivGemFarm_Class extends IC_BrivSharedFunctions_Class
{

	StackRestart()
	{
		lastStacks := stacks := g_BrivUserSettings[ "AutoCalculateBrivStacks" ] ? g_SF.Memory.ReadSBStacks() : this.GetNumStacksFarmed()
		targetStacks := g_BrivUserSettings[ "AutoCalculateBrivStacks" ] ? (this.TargetStacks - this.LeftoverStacks) : g_BrivUserSettings[ "TargetStacks" ]
		if (stacks >= targetStacks)
			return
		numSilverChests := g_SF.Memory.ReadChestCountByID(1)
		numGoldChests := g_SF.Memory.ReadChestCountByID(2)
		retryAttempt := 0
		maxRetries := 2
		if (this.LastStackSuccessArea == 0)
			maxRetries := 1
		while ( stacks < targetStacks AND retryAttempt <= maxRetries )
		{
			this.StackFailRetryAttempt++ ; per run
			retryAttempt++			   ; pre stackfarm call
			this.StackFarmSetup()
			g_SF.CurrentZone := g_SF.Memory.ReadCurrentZone() ; record current zone before saving for bad progression checks
			modronResetZone := g_SF.Memory.GetModronResetArea()
			if (modronResetZone != "" AND g_SF.CurrentZone > modronResetZone)
			{
				g_SharedData.LoopString := "Attempted to offline stack after modron reset - verify settings"
				break
			}
			g_SF.CloseIC( "StackRestart" . (this.StackFailRetryAttempt > 1 ? (" - Warning: Retry #" . this.StackFailRetryAttempt - 1 . ". Check Stack Settings."): "") )
			g_SharedData.LoopString := "Stack Sleep: "
			chestsCompletedString := ""
			StartTime := A_TickCount
			ElapsedTime := 0
			; START ClaimDailyPlatinum Code Insert
			if (CDP_ClaimedState["Platinum"] == 1)
				this.ClaimDailyPlatinum()
			if (CDP_ClaimedState["FreeOffer"] == 1)
				this.ClaimFreeWeeklyOffers()
			if (CDP_ClaimedState["BonusChests"] == 1)
				this.ClaimBonusChests()
			if (CDP_ClaimedState["Celebrations"] == 1)
				this.ClaimCelebrationCodes()
			ElapsedTime := A_TickCount - StartTime
			; END ClaimDailyPlatinum Code Insert
			chestsCompletedString := " " . this.DoChests(numSilverChests, numGoldChests)
			while ( ElapsedTime < g_BrivUserSettings[ "RestartStackTime" ] )
			{
				g_SharedData.LoopString := "Stack Sleep: " . g_BrivUserSettings[ "RestartStackTime" ] - ElapsedTime . chestsCompletedString
				Sleep, 62
				ElapsedTime := A_TickCount - StartTime
			}
			g_SF.SafetyCheck()
			stacks := g_BrivUserSettings[ "AutoCalculateBrivStacks" ] ? g_SF.Memory.ReadSBStacks() : this.GetNumStacksFarmed()
			;check if save reverted back to below stacking conditions
			if (g_SF.Memory.ReadCurrentZone() < g_BrivUserSettings[ "MinStackZone" ])
			{
				g_SharedData.LoopString := "Stack Sleep: Failed (zone < min)"
				Break  ; "Bad Save? Loaded below stack zone, see value."
			}
			g_SharedData.PreviousStacksFromOffline := stacks - lastStacks
			lastStacks := stacks
		}
		if (retryAttempt >= maxRetries)
		{
			Loop, 4 ; add next 4 areas to failed stacks so next attempt would be CurrentZone + 4
			{
				this.StackFailAreasTally[g_SF.CurrentZone + A_Index - 1] := (this.StackFailAreasTally[g_SF.CurrentZone + A_Index - 1] == "") ? 1 : (this.StackFailAreasTally[g_SF.CurrentZone + A_Index - 1] + 1)
				; debugStackFailAreasTallyString := ArrFnc.GetDecFormattedAssocArrayString(this.StackFailAreasTally)
				this.StackFailAreasThisRunTally[g_SF.CurrentZone + A_Index - 1] := 1
				; debugStackStackFailAreasThisRunTallyString := ArrFnc.GetDecFormattedAssocArrayString(this.StackFailAreasThisRunTally)
				this.LastStackSuccessArea := 0
			}
		}
		else if (retryAttempt == 1)
		{
			this.StackFailAreasTally[g_SF.CurrentZone] := 0
			this.LastStackSuccessArea := g_SF.CurrentZone
		}
		else
		{
			this.LastStackSuccessArea := g_SF.CurrentZone
		}
		g_PreviousZoneStartTime := A_TickCount
		return 
	}
	
	ClaimDailyPlatinum(CDP_key := "Platinum")
	{
		params := CDP_ClaimableParams[CDP_key]
		if (params == "")
		{
			CDP_ClaimedState[CDP_key] := 0
			return
		}
		extraParams := "&is_boost=0" . params
		response := g_ServerCall.ServerCall("claimdailyloginreward",extraParams)
		if (IsObject(response) && response.success)
		{
			if (response.daily_login_details.premium_active)
			{
				extraParams := "&is_boost=1" . params
				response := g_ServerCall.ServerCall("claimdailyloginreward",extraParams)
			}
		}
		else
		{
			; server call failed
			CDP_ClaimableParams[CDP_key] := ""
			CDP_ClaimedState[CDP_key] := 0
			return
		}
		
		CDP_ClaimableParams[CDP_key] := ""
		CDP_ClaimedState[CDP_key] := 2
	}
	
	ClaimFreeWeeklyOffers(CDP_key := "FreeOffer")
	{
		params := CDP_ClaimableParams[CDP_key]
		if (params == "")
		{
			CDP_ClaimedState[CDP_key] := 0
			return
		}
		for k,v in CDP_FreeOfferIDs
		{
			extraParams := "&offer_id=" . v . params
			response := g_ServerCall.ServerCall("PurchaseALaCarteOffer",extraParams)
			if (!IsObject(response) || !response.success)
			{
				; server call failed
				CDP_ClaimableParams[CDP_key] := ""
				CDP_ClaimedState[CDP_key] := 0
				CDP_FreeOfferIDs := []
				return
			}
		}
		
		CDP_ClaimableParams[CDP_key] := ""
		CDP_ClaimedState[CDP_key] := 2
		CDP_FreeOfferIDs := []
	}
	
	ClaimBonusChests(CDP_key := "BonusChests")
	{
		params := CDP_ClaimableParams[CDP_key]
		if (params == "")
		{
			CDP_ClaimedState[CDP_key] := 0
			return
		}
		for k,v in CDP_BonusChestIDs
		{
			extraParams := "&premium_item_id=" . v . params
			response := g_ServerCall.ServerCall("claimsalebonus",extraParams)
			if (!IsObject(response) || !response.success)
			{
				; server call failed
				CDP_ClaimableParams[CDP_key] := ""
				CDP_ClaimedState[CDP_key] := 0
				CDP_BonusChestIDs := []
				return
			}
		}
		
		CDP_ClaimableParams[CDP_key] := ""
		CDP_ClaimedState[CDP_key] := 2
		CDP_BonusChestIDs := []
	}
	
	ClaimCelebrationCodes(CDP_key := "Celebrations")
	{
		params := CDP_ClaimableParams[CDP_key]
		if (params == "")
		{
			CDP_ClaimedState[CDP_key] := 0
			return
		}
		for k,v in CDP_CelebrityCodes
		{
			extraParams := "&code=" . v . params
			response := g_ServerCall.ServerCall("redeemcoupon",extraParams)
			if (!IsObject(response) || !response.success)
			{
				; server call failed
				CDP_ClaimableParams[CDP_key] := ""
				CDP_ClaimedState[CDP_key] := 0
				CDP_CelebrityCodes := []
				return
			}
		}
		
		CDP_ClaimableParams[CDP_key] := ""
		CDP_ClaimedState[CDP_key] := 2
		CDP_CelebrityCodes := []
	}

}