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

global g_CDP_cbDist := 25
global g_CDP_infoDist := 15
global g_CDP_infoGap := 5
global g_CDP_col1w := 130
global g_CDP_col2x := g_CDP_col1w + 20
global g_CDP_col2w := 200
global g_CDP_groupboxHeight := 100
global g_CDP_infoOffy := -13

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 y+10 Section w500 h%g_CDP_groupboxHeight%, Claim Daily Platinum
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, xs15 ys+%g_CDP_cbDist% vg_CDP_ClaimPlatinum, Claim Daily Platinum?
Gui, ICScriptHub:Add, Text, xs15 y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Platinum Days Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumDaysCount xs%g_CDP_col2x% y+%g_CDP_infoOffy% w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs15 y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_PlatinumTimer xs%g_CDP_col2x% y+%g_CDP_infoOffy% w%g_CDP_col2w%, 

Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, GroupBox, x15 ys+%g_CDP_groupboxHeight%+5 Section w500 h%g_CDP_groupboxHeight% vg_CDP_InfoGroupBox, Claim Free Weekly Shop Offers
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Checkbox, xs15 ys+%g_CDP_cbDist% vg_CDP_ClaimFreeOffer, Claim Free Weekly Shop Offers?
Gui, ICScriptHub:Add, Text, xs15 y+%g_CDP_infoDist% w%g_CDP_col1w% +Right, Free Offers Claimed:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOffersCount xs%g_CDP_col2x% y+%g_CDP_infoOffy%  w%g_CDP_col2w%, 
Gui, ICScriptHub:Add, Text, xs15 y+%g_CDP_infoGap% w%g_CDP_col1w% +Right, Time Until Next Check:
Gui, ICScriptHub:Add, Text, vg_CDP_FreeOfferTimer xs%g_CDP_col2x% y+%g_CDP_infoOffy% w%g_CDP_col2w%, 

if(IsObject(IC_BrivGemFarm_Component))
{
	g_ClaimDailyPlatinum.InjectAddon()
}

g_ClaimDailyPlatinum.Init()

Class IC_ClaimDailyPlatinum_Component
{
	static SettingsPath := A_LineFile . "\..\ClaimDailyPlatinum_Settings.json"
	static WaitingMessage := "Waiting for BrivGemFarm to Start."
	static OfflineMessage := "Waiting for the next offline progress."
	
	Injected := false
	Running := false
	TimerFunctions := {}
	DefaultSettings := {"Platinum":true,"FreeOffer":false}
	Settings := {}
	; The timer for MainLoop:
	MainLoopCD := 60 ; in seconds = 1 minute.
	; The timer for OfflineCheck:
	OfflineCheckCD := 1000 ; 1000 in milliseconds = 1 second.
	; The starting cooldown for each type:
	StartingCD := 60 ; in seconds = 10 minutes.
	; The cooldown period between checks for each type (if value can't be pulled from calls):
	;     Platinum:   28,800 in seconds is  8 hours (3 times per day)
	;     FreeOffer: 201,600 in seconds is 56 hours (3 times per week)
	BaseCD := {"Platinum":28800,"FreeOffer":201600}
	; The current cooldown for each type:
	CurrentCD := {"Platinum":0,"FreeOffer":0}
	; The amount of times each type has been claimed:
	Claimed := {"Platinum":0,"FreeOffer":0}
	; The flags to tell the timers to pause if the script is waiting for the game to go offline.
	Claimable := {"Platinum":false,"FreeOffer":false}
	FreeOfferIDs := []
	
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
		
		g_SF.WriteObjectToJSON(IC_ClaimDailyPlatinum_Component.SettingsPath, this.Settings)
		IC_ClaimDailyPlatinum_Functions.UpdateSharedSettings()
		;if (!sanityChecked)
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
		CDP_newCurrent := ""
		CDP_AnyClaimable := false
		CDP_ChangesInClaimable := false
		CDP_ApplyNewCurrentCD := true
		; Decrement cooldown and if the timer is <= 0 check if anything can be claimed
		for k,v in this.CurrentCD
		{
			if (!this.Settings[k])
				continue
			CDP_newCurrent := this.CurrentCD[k]
			if (CDP_newCurrent > 0)
				CDP_newCurrent -= this.MainLoopCD
			if (CDP_newCurrent <= 0)
			{
				CDP_newCurrent := 0
				CDP_CurrClaimedState := IC_ClaimDailyPlatinum_Functions.GetClaimedState(k)
				; If it has been claimed:
				if (CDP_CurrClaimedState == 2)
				{
					this.Claimed[k] += 1 ; Increment counter
					this.Claimable[k] := false ; Set it not claimable
					this.CurrentCD[k] = 0 ; Set current CD to 0
					IC_ClaimDailyPlatinum_Functions.ClearClaimedState() ; Clear claimed state for StackRestart
					CDP_CurrClaimedState := IC_ClaimDailyPlatinum_Functions.GetClaimedState(k) ; Clear claimed state here too
				}
				; If it isn't claimable:
				if (!this.Claimable[k])
				{
					CDP_CheckedClaimable := this.CheckClaimable(k) ; Check if it is claimable (and when if not)
					this.Claimable[k] := CDP_CheckedClaimable[1] ; Claimable
					this.CurrentCD[k] := CDP_CheckedClaimable[2] ; Claimable Cooldown
					CDP_ApplyNewCurrentCD := false ; Don't change current cooldown from detected
				}
				; If it is claimable and the claim state is 0:
				if (CDP_CurrClaimedState == 0 && this.Claimable[k])
				{
					; Set claimables:
					IC_ClaimDailyPlatinum_Functions.SetClaimables(this.GetBoilerplate(), this.Claimable, this.FreeOfferIDs)
					CDP_AnyClaimable := true ; And allow the main status to change
				}
			}
			if (CDP_ApplyNewCurrentCD)
				this.CurrentCD[k] := CDP_newCurrent
		}
		if (CDP_AnyClaimable)
			this.UpdateMainStatus(this.OfflineMessage)
		this.UpdateGUI()
	}
	
	CheckClaimable(CDP_key)
	{
		CDP_returnArr := []
		if (CDP_key=="FreeOffer")
		{
			this.FreeOfferIDs := []
			params := this.GetBoilerplate()
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
					CDP_returnArr := [true, 0]
				else
					CDP_returnArr := [false, response.offers.time_remaining + 30]
			}
		}
		else ; Platinum
		{
			params := this.GetBoilerplate()
			response := g_ServerCalls.ServerCall("getdailyloginrewards",params)
			if (IsObject(response) && response.success)
			{
				if (response.daily_login_details.next_claim_seconds == 0)
					CDP_returnArr := [true, 0]
				else
					CDP_returnArr := [false, response.daily_login_details.next_claim_seconds + 30]
			}
		}
		if (this.ArrSize(CDP_returnArr) == 0)
			CDP_returnArr := [false, this.BaseCD[CDP_key]]
		return CDP_returnArr
	}
	
	; =======================
	; ===== TIMER STUFF =====
	; =======================
	
	; Adds timed functions (typically to be started when briv gem farm is started)
	CreateTimedFunctions()
	{
		this.TimerFunctions := {}
		fncToCallOnTimer := ObjBindMethod(this, "MainLoop")
		this.TimerFunctions[fncToCallOnTimer] := this.MainLoopCD * 1000
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
		{
			SetTimer, %k%, %v%, 0
		}
		for k,v in this.CurrentCD
		{
			this.CurrentCD[k] := this.StartingCD
		}
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
		GuiControl, ICScriptHub:, g_CDP_PlatinumDaysCount, % this.ProduceGUIClaimedMessage("Platinum")
		GuiControl, ICScriptHub:, g_CDP_FreeOffersCount, % this.ProduceGUIClaimedMessage("FreeOffer")
		Gui, Submit, NoHide
	}
	
	ProduceGUITimerMessage(CDP_key)
	{
		if (this.Running && !this.Settings[CDP_key])
			return "Disabled."
		if (this.Claimable[CDP_key])
			return "Claiming on next offline stack."
		return this.FmtSecs(this.CurrentCD[CDP_key])
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
		fmtTime := RegExReplace(fmtTime, "m)0d ", "")
		fmtTime := RegExReplace(fmtTime, "m)^0h ", "")
		fmtTime := Trim(fmtTime)
		return fmtTime
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