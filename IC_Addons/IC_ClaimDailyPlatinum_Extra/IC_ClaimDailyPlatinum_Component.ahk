#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Functions.ahk
#include %A_LineFile%\..\IC_ClaimDailyPlatinum_Overrides.ahk
#include %A_LineFile%\..\..\..\ServerCalls\IC_ServerCalls_Class.ahk

GUIFunctions.AddTab("Claim Daily Platinum")
global g_ClaimDailyPlatinum := new IC_ClaimDailyPlatinum_Component
global g_ServerCalls := new IC_ServerCalls_Class

Gui, ICScriptHub:Tab, Claim Daily Platinum
GUIFunctions.UseThemeTextColor("HeaderTextColor")
Gui, ICScriptHub:Add, Text, x15 y+15, Claim Daily Platinum:
GUIFunctions.UseThemeTextColor("DefaultTextColor")
Gui, ICScriptHub:Add, Button, x145 y+-15 w100 vg_ClaimDailyPlatinumSave_Clicked, `Save Settings
buttonFunc := ObjBindMethod(g_ClaimDailyPlatinum, "SaveSettings")
GuiControl,ICScriptHub: +g, g_ClaimDailyPlatinumSave_Clicked, % buttonFunc
Gui, ICScriptHub:Add, Text, x5 y+10 w130 +Right, Status:
Gui, ICScriptHub:Add, Text, x145 y+-13 w400 vg_CDP_StatusText, % IC_ClaimDailyPlatinum_Component.WaitingMessage

GuiControlGet, pos, ICScriptHub:Pos, g_CDP_StatusText
g_CDP_groupboxHeight := 100
g_CDP_lineHeight := posH
g_CDP_cbDist := 25
g_CDP_infoDist := 15
g_CDP_infoGap := 5
g_CDP_col1x := 15
g_CDP_col1w := 130
g_CDP_col2x := g_CDP_col1x + g_CDP_col1w + 5
g_CDP_col2w := 260
g_CDP_col3x := g_CDP_col2x + g_CDP_col2w + 5 - 200
g_CDP_col3w := g_CDP_col1w
g_CDP_col4x := g_CDP_col3x + g_CDP_col3w + 5
g_CDP_col4w := g_CDP_col2w - 130

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h%g_CDP_groupboxHeight%, Claim Daily Platinum
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimPlatinum xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Daily Platinum?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Platinum Days Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumDaysCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, vg_CDP_DailyBoostHeader xs%g_CDP_col3x% y+-%g_CDP_lineHeight% w%g_CDP_col3w% +Right, 
Gui, ICScriptHub:Add, Text, vg_CDP_DailyBoostExpires xs%g_CDP_col4x% y+-%g_CDP_lineHeight% w%g_CDP_col4w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+%g_CDP_groupboxHeight%+5 Section w500 h%g_CDP_groupboxHeight%, Claim Free Weekly Shop Offers
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimFreeOffer xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Free Weekly Shop Offers?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Free Offers Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOffersCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOfferTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+%g_CDP_groupboxHeight%+5 Section w500 h%g_CDP_groupboxHeight%, Claim Free Premium Pack Bonus Chests
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimBonusChests xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Free Premium Pack Bonus Chests?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Bonus Chests Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_BonusChestsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_BonusChestsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+%g_CDP_groupboxHeight%+5 Section w500 h%g_CDP_groupboxHeight%, Claim Celebration Rewards
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, vg_CDP_ClaimCelebrations xs%g_CDP_col1x% ys+%g_CDP_cbDist%, Claim Celebration Rewards?
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Rewards Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_CelebrationRewardsCount xs%g_CDP_col2x% y+-%g_CDP_lineHeight%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs%g_CDP_col1x% y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_CelebrationsTimer xs%g_CDP_col2x% y+-%g_CDP_lineHeight% w%g_CDP_col2w%, 

if(IsObject(IC_BrivGemFarm_Component))
{
	g_ClaimDailyPlatinum.InjectAddon()
}

g_ClaimDailyPlatinum.Init()

Class IC_ClaimDailyPlatinum_Component
{
	static SettingsPath := A_LineFile . "\..\ClaimDailyPlatinum_Settings.json"
	static WaitingMessage := "Waiting for BrivGemFarm to Start."
	static OfflineMessage := "Waiting for the next offline stack restart."
	
	Injected := false
	Running := false
	TimerFunctions := {}
	DefaultSettings := {"Platinum":true,"FreeOffer":true,"BonusChests":true,"Celebrations":true}
	Settings := {}
	; The timer for MainLoop:
	MainLoopCD := 60000 ; in milliseconds = 1 minute.
	; The starting cooldown for each type:
	StartingCD := 60000 ; in milliseconds = 1 minutes.
	; The delay between when the server says a timer resets and when to check (for safety):
	SafetyDelay := 30000 ; in milliseconds = 30 seconds.
	; No Timer Delay (for when I can't find a timer in the data)
	NoTimerDelay := 28800000 ; in milliseconds = 8 hours.
	; The current cooldown for each type:
	CurrentCD := {"Platinum":0,"FreeOffer":0,"BonusChests":0,"Celebrations":0}
	; The amount of times each type has been claimed:
	Claimed := {"Platinum":0,"FreeOffer":0,"BonusChests":0,"Celebrations":0}
	; The flags to tell the timers to pause if the script is waiting for the game to go offline.
	Claimable := {"Platinum":false,"FreeOffer":false,"BonusChests":false,"Celebrations":false}
	FreeOfferIDs := []
	BonusChestIDs := []
	CelebrationCodes := []
	DailyBoostExpires := 0
	StaggeredChecks := {"Platinum":1,"FreeOffer":2,"BonusChests":3,"Celebrations":4}
	CheckCelebrationsAgain := false
	
	UserID := ""
	UserHash := ""
	InstanceID := ""
	GameVersion := ""
	Platform := ""

	; ================================
	; ===== LOADING AND SETTINGS =====
	; ================================

	InjectAddon()
	{
		local splitStr := StrSplit(A_LineFile, "\")
		local addonDirLoc := splitStr[(splitStr.Count()-1)]
		local addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_ClaimDailyPlatinum_Addon.ahk`n"
		FileAppend, %addonLoc%, %g_BrivFarmModLoc%
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "CreateTimedFunctions"))
		g_BrivFarmAddonStartFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StartTimedFunctions"))
		g_BrivFarmAddonStopFunctions.Push(ObjBindMethod(g_ClaimDailyPlatinum, "StopTimedFunctions"))
		this.Injected := true
	}
	
	Init()
	{
		Global
		if (!this.Injected)
			return
		this.LoadSettings()
	}
	
	LoadSettings()
	{
		Global
		Gui, Submit, NoHide
		writeSettings := false
		this.Settings := g_SF.LoadObjectFromJSON(IC_ClaimDailyPlatinum_Component.SettingsPath)
		if(!IsObject(this.Settings))
		{
			this.SetDefaultSettings()
			writeSettings := true
		}
		if (this.CheckMissingOrExtraSettings())
			writeSettings := true
		if(writeSettings)
			g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Component.SettingsPath, this.Settings)
		GuiControl, ICScriptHub:, g_CDP_ClaimPlatinum, % this.Settings["Platinum"]
		GuiControl, ICScriptHub:, g_CDP_ClaimFreeOffer, % this.Settings["FreeOffer"]
		GuiControl, ICScriptHub:, g_CDP_ClaimBonusChests, % this.Settings["BonusChests"]
		GuiControl, ICScriptHub:, g_CDP_ClaimCelebrations, % this.Settings["Celebrations"]
		for k,v in this.Settings
			if (!v)
				this.CurrentCD[k] := -1
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		this.UpdateGUI()
	}
	
	SaveSettings()
	{
		Global
		Gui, Submit, NoHide
		;local sanityChecked := this.SanityCheckSettings()
		this.CheckMissingOrExtraSettings()
		
		this.Settings["Platinum"] := g_CDP_ClaimPlatinum
		this.Settings["FreeOffer"] := g_CDP_ClaimFreeOffer
		this.Settings["BonusChests"] := g_CDP_ClaimBonusChests
		this.Settings["Celebrations"] := g_CDP_ClaimCelebrations
		
		g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Component.SettingsPath, this.Settings)
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		;if (!sanityChecked)
		CDP_LoopCounter := 1
		for k,v in this.Settings
		{
			if (v && this.CurrentCD[k] <= 0)
			{
				this.CurrentCD[k] := A_TickCount + (this.MainLoopCD*CDP_LoopCounter)
				CDP_LoopCounter += 1
			}
			if (!v)
				this.CurrentCD[k] := -1
		}
		this.UpdateMainStatus("Saved settings.")
		this.UpdateGUI()
	}
	
	SetDefaultSettings()
	{
		this.Settings := {}
		for k,v in this.DefaultSettings
			this.Settings[k] := v
	}
	
	CheckMissingOrExtraSettings()
	{
		local madeEdit := false
		for k,v in this.DefaultSettings
		{
			if (this.Settings[k] == "") {
				this.Settings[k] := v
				madeEdit := true
			}
		}
		for k,v in this.Settings
		{
			if (!this.DefaultSettings.HasKey(k)) {
				this.Settings.Delete(k)
				madeEdit := true
			}
		}
		return madeEdit
	}
	
	; ======================
	; ===== MAIN STUFF =====
	; ======================
	
	; This loop gets called once per MainLoopCD.
	MainLoop()
	{
		this.UpdateMainStatus("Idle.")
		if (!IC_ClaimDailyPlatinum_Functions.IsGameClosed())
		{
			this.InstanceID := g_SF.Memory.ReadInstanceID()
			if (this.UserID == "")
				this.UserID := g_SF.Memory.ReadUserID()
			if (this.UserHash == "")
				this.UserHash := g_SF.Memory.ReadUserHash()
			if (this.Platform == "")
				this.Platform := g_SF.Memory.ReadPlatform()
			if (this.GameVersion == "")
				this.GameVersion := g_SF.Memory.ReadBaseGameVersion()
		}
		else
			return
		CDP_AnyClaimable := false
		SharedRunData := ""
		try
		{
			SharedRunData := ComObjActive(g_BrivFarm.GemFarmGUID)
		}
		catch
		{
			this.UpdateMainStatus("Could not connect to the Gem Farm script.")
			return
		}
		; Decrement cooldown and if the timer is <= 0 check if anything can be claimed
		for k,v in this.CurrentCD
		{
			if (!this.Settings[k])
				continue
			if (k == "Celebrations" && this.CheckCelebrationsAgain) {
				CDP_CurrClaimedState := SharedRunData.CDP_GetClaimedState(k)
				if (CDP_CurrClaimedState == 2)
					this.CurrentCD[k] := 0
			}
			if (this.CurrentCD[k] <= A_TickCount)
			{
				CDP_CurrClaimedState := SharedRunData.CDP_GetClaimedState(k)
				; If it has been claimed:
				if (CDP_CurrClaimedState == 2)
				{
					; Increment claimed counter:
					if (k == "FreeOffer")
						this.Claimed[k] += this.ArrSize(this.FreeOfferIDs)
					else if (k == "BonusChests")
						this.Claimed[k] += this.ArrSize(this.BonusChestIDs)
					else if (k == "Celebrations")
						this.Claimed[k] += this.ArrSize(this.CelebrationCodes)
					else
						this.Claimed[k] += 1
					this.Claimable[k] := false ; Set it not claimable
					this.CurrentCD[k] := 0 ; Set current CD to 0
					SharedRunData.CDP_ClearClaimedState(k) ; Clear claimed state for StackRestart
					CDP_CurrClaimedState := SharedRunData.CDP_GetClaimedState(k) ; Clear claimed state here too
				}
				; If it isn't claimable:
				if (!this.Claimable[k])
					this.CallCheckClaimable(k)
				; If it is claimable and the claim state is 0:
				if (CDP_CurrClaimedState == 0 && this.Claimable[k])
				{
					; Set claimables:
					SharedRunData.CDP_SetClaimable(k, this.GetBoilerplate())
					if (k == "FreeOffer")
						for l,b in this.FreeOfferIDs
							SharedRunData.CDP_AddFreebieOfferIDs(b)
					if (k == "BonusChests")
						for l,b in this.BonusChestIDs
							SharedRunData.CDP_AddBonusChestIDs(b)
					if (k == "Celebrations")
						for l,b in this.CelebrationCodes
							SharedRunData.CDP_AddCelebrationCodes(b)
					CDP_AnyClaimable := true ; And allow the main status to change
				}
			}
		}
		if (CDP_AnyClaimable)
			this.UpdateMainStatus(this.OfflineMessage)
		this.UpdateGUI()
	}
	
	CallCheckClaimable(CDP_key)
	{
		CDP_CheckedClaimable := this.CheckClaimable(CDP_key) ; Check if it is claimable (and when if not)
		this.Claimable[CDP_key] := CDP_CheckedClaimable[1] ; Claimable
		this.CurrentCD[CDP_key] := CDP_CheckedClaimable[2] ; Claimable Cooldown
	}
	
	CheckClaimable(CDP_key)
	{
		if (CDP_key == "Platinum")
		{
			params := this.GetBoilerplate()
			response := g_ServerCalls.ServerCall("getdailyloginrewards",params)
			if (IsObject(response) && response.success)
			{
				CDP_num := 1 << (response.daily_login_details.today_index)
				if (response.daily_login_details.premium_active && response.daily_login_details.premium_expire_seconds > 0)
					this.DailyBoostExpires := A_TickCount + (response.daily_login_details.premium_expire_seconds * 1000)
				else
					this.DailyBoostExpires := 0
				if ((response.daily_login_details.rewards_claimed & CDP_num) > 0)
				{
					CDP_nextClaimSeconds := response.daily_login_details.next_claim_seconds
					if (CDP_nextClaimSeconds == 0)
						CDP_nextClaimSeconds := Mod(response.daily_login_details.next_reset_seconds, 86400)
					return [false, A_TickCount + (CDP_nextClaimSeconds * 1000) + this.SafetyDelay]
				}
				return [true, 0]
			}
		}
		else if (CDP_key == "FreeOffer")
		{
			this.FreeOfferIDs := []
			params := this.GetBoilerplate()
			g_ServerCalls.ServerCall("revealalacarteoffers",params)
			response := g_ServerCalls.ServerCall("getalacarteoffers",params)
			if (IsObject(response) && response.success)
			{
				for k,v in response.offers.offers
				{
					if (v.type != "free" || v.cost > 0)
						continue
					if (!v.purchased)
						this.FreeOfferIDs.Push(v.offer_id)
				}
				if (this.ArrSize(this.FreeOfferIDs) > 0)
					return [true, 0]
				return [false, A_TickCount + (response.offers.time_remaining * 1000) + this.SafetyDelay]
			}
		}
		else if (CDP_key == "BonusChests")
		{
			this.BonusChestIDs := []
			params := this.GetBoilerplate()
			extraParams := params . "&return_all_items_live=1&return_all_items_ever=0&show_hard_currency=1&prioritize_item_category=recommend"
			response := g_ServerCalls.ServerCall("getshop",extraParams)
			if (IsObject(response) && response.success)
			{
				for k,v in response.package_deals
					if (v.bonus_status == "0")
						this.BonusChestIDs.Push(v.item_id)
				if (this.ArrSize(this.BonusChestIDs) > 0)
					return [true, 0]
			}
			return [false, A_TickCount + this.NoTimerDelay]
		}
		else if (CDP_key == "Celebrations")
		{
			this.CelebrationCodes := []
			this.CheckCelebrationsAgain := false
			wrlLoc := g_SF.Memory.GetWebRequestLogLocation()
			if (wrlLoc == "")
				return [false, A_TickCount + this.NoTimerDelay]
			webRequestLog := ""
			FileRead, webRequestLog, %wrlLoc%
			containsOneToGo := false
			CDP_nextClaimSeconds := 9999999
			if (InStr(webRequestLog, """dialog"":"))
			{
				currMatches := IC_ClaimDailyPlatinum_Functions.GetAllRegexMatches(webRequestLog, """dialog"": ?""([^""]+)""")
				for k,v in currMatches
				{
					params := this.GetBoilerplate()
					extraParams := params . "&dialog=" . v . "&ui_type=standard"
					response := g_ServerCalls.ServerCall("getdynamicdialog",extraParams)
					if (IsObject(response) && response.success)
					{
						for l,b in response.dialog_data.elements
						{
							if (b.timer != "" && b.timer < CDP_nextClaimSeconds)
								CDP_nextClaimSeconds := b.timer
							if (b.type == "button" && InStr(b.text, "claim"))
							{
								for j,c in b.actions
								{
									if (c.action != "redeem_code")
										continue
									this.CelebrationCodes.Push(c.params.code)
									break
								}
							}
							if (InStr(b.text, "1 to go"))
								containsOneToGo := true
						}
					}
				}
			}
			webRequestLog := ""
			if (this.ArrSize(this.CelebrationCodes) > 0) {
				if (containsOneToGo)
					this.CheckCelebrationsAgain := true
				return [true, 0]
			}
			if (CDP_nextClaimSeconds < 9999999)
				return [false, A_TickCount + (CDP_nextClaimSeconds * 1000) + this.SafetyDelay]
			else
				return [false, A_TickCount + this.NoTimerDelay]
		}
		return [false, A_TickCount + this.StartingCD]
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "MainLoop")
		this.TimerFunctions[fncToCallOnTimer] := this.MainLoopCD
	}

	; Starts the saved timed functions (typically to be started when briv gem farm is started)
	StartTimedFunctions()
	{
		this.Running := true
		this.UpdateMainStatus("Idle.")
		this.UserID := g_SF.Memory.ReadUserID()
		this.UserHash := g_SF.Memory.ReadUserHash()
		this.Platform := g_SF.Memory.ReadPlatform()
		this.GameVersion := g_SF.Memory.ReadBaseGameVersion()
		for k,v in this.TimerFunctions
			SetTimer, %k%, %v%, 0
		for k,v in this.CurrentCD
			this.CurrentCD[k] := A_TickCount + (this.StartingCD * this.StaggeredChecks[k])
		this.UpdateGUI()
	}

	; Stops the saved timed functions (typically to be stopped when briv gem farm is stopped)
	StopTimedFunctions()
	{
		this.Running := false
		this.UpdateMainStatus(this.WaitingMessage)
		for k,v in this.TimerFunctions
		{
			SetTimer, %k%, Off
			SetTimer, %k%, Delete
		}
		for k,v in this.CurrentCD
		{
			this.CurrentCD[k] := 0
			this.Claimable[k] := false
		}
		this.UpdateGUI()
	}
	
	; =====================
	; ===== GUI STUFF =====
	; =====================
	
	UpdateMainStatus(status)
	{
		GuiControl, ICScriptHub:Text, g_CDP_StatusText, % status
		Gui, Submit, NoHide
	}
	
	UpdateGUI()
	{
		GuiControl, ICScriptHub:, g_CDP_PlatinumTimer, % this.ProduceGUITimerMessage("Platinum")
		GuiControl, ICScriptHub:, g_CDP_FreeOfferTimer, % this.ProduceGUITimerMessage("FreeOffer")
		GuiControl, ICScriptHub:, g_CDP_BonusChestsTimer, % this.ProduceGUITimerMessage("BonusChests")
		GuiControl, ICScriptHub:, g_CDP_CelebrationsTimer, % this.ProduceGUITimerMessage("Celebrations")
		GuiControl, ICScriptHub:, g_CDP_PlatinumDaysCount, % this.ProduceGUIClaimedMessage("Platinum")
		GuiControl, ICScriptHub:, g_CDP_FreeOffersCount, % this.ProduceGUIClaimedMessage("FreeOffer")
		GuiControl, ICScriptHub:, g_CDP_BonusChestsCount, % this.ProduceGUIClaimedMessage("BonusChests")
		GuiControl, ICScriptHub:, g_CDP_CelebrationRewardsCount, % this.ProduceGUIClaimedMessage("Celebrations")
		GuiControl, ICScriptHub:, g_CDP_DailyBoostHeader, % (this.DailyBoostExpires > 0 ? "Daily Boost Expires:" : "")
		GuiControl, ICScriptHub:, g_CDP_DailyBoostExpires, % (this.DailyBoostExpires > 0 ? this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.DailyBoostExpires)) : "")
		Gui, Submit, NoHide
	}
	
	ProduceGUITimerMessage(CDP_key)
	{
		if (this.Running)
		{
			if (!this.Settings[CDP_key])
				return "Disabled."
			if (this.Claimable[CDP_key])
				return "Claiming on next offline stack."
			; Ceil the remaining milliseconds to the nearest MainLoopCD so it never shows 00m.
			; Then turn it into seconds to format.
			return this.FmtSecs(this.CeilMillisecondsToNearestMainLoopCDSeconds(this.CurrentCD[CDP_key]))
		}
		return ""
	}
	
	ProduceGUIClaimedMessage(CDP_key)
	{
		if (this.Running)
			return this.Claimed[CDP_key]
		return ""
	}
	
	; ======================
	; ===== MISC STUFF =====
	; ======================
	
	FmtSecs(T, Fmt:="{:}d {:01}h {:02}m") { ; v0.50 by SKAN on D36G/H @ tiny.cc/fmtsecs
		local D, H, M, HH, Q:=60, R:=3600, S:=86400
		T := Round(T)
		fmtTime := Format(Fmt, D:=T//S, H:=(T:=T-D*S)//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=D*24+H, HH*Q+M)
		fmtTime := RegExReplace(fmtTime, "m)^0d ", "")
		fmtTime := RegExReplace(fmtTime, "m)^0h ", "")
		fmtTime := Trim(fmtTime)
		return fmtTime
	}
	
	CeilMillisecondsToNearestMainLoopCDSeconds(CDP_timer)
	{
		return (Ceil((CDP_timer - A_TickCount) / this.MainLoopCD) * this.MainLoopCD) / 1000
	}
	
	ArrSize(arr)
	{
		if (IsObject(arr))
		{
			CDP_currArrSize := arr.MaxIndex()
			if (CDP_currArrSize == "")
				return 0
			return CDP_currArrSize
		}
		return 0
	}
	
	GetBoilerplate()
	{
		return "&user_id=" . (this.UserID) . "&hash=" . (this.UserHash) . "&instance_id=" . (this.InstanceID) . "&language_id=1&timestamp=0&request_id=0&network_id=" . (this.Platform) . "&mobile_client_version=" . (this.GameVersion) . "&instance_key=1&offline_v2_build=1&localization_aware=true"
	}
	
}