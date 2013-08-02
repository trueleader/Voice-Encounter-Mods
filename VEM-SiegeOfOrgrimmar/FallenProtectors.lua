﻿local mod	= VEM:NewMod(849, "VEM-SiegeOfOrgrimmar", nil, 369)
local L		= mod:GetLocalizedStrings()
local sndWOP	= mod:NewSound(nil, "SoundWOP", true)

mod:SetRevision(("$Revision: 10086 $"):sub(12, -3))
mod:SetCreatureID(71479, 71475, 71480)--He-Softfoot, Rook Stonetoe, Sun Tenderheart
--mod:SetQuestID(32744)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"UNIT_SPELLCAST_SUCCEEDED boss1 boss2 boss3"
)


--All
local warnBondGoldenLotus			= mod:NewCastAnnounce(143497, 4)
--Rook Stonetoe
local warnVengefulStrikes			= mod:NewSpellAnnounce(144396, 3, nil, mod:IsTank())
local warnCorruptedBrew				= mod:NewTargetAnnounce(143019, 2)--I do believe target scanning WILL work here, i just need more time to mess with it next round of testing
local warnClash						= mod:NewSpellAnnounce(143027, 3)--No target scanning, no emote, no warning of any kind that gave me a target :\
----Rook Stonetoe's Desperate Measures (66% and 33%)
local warnMiserySorrowGloom			= mod:NewSpellAnnounce(143955, 2)--Activation
local warnCorruptionShock			= mod:NewSpellAnnounce(143958, 3)--Embodied Gloom (spammy if you do it wrong, but very important everyone sees. SOMEONE needs to interrupt it if it keeps going off)
local warnDefiledGround				= mod:NewSpellAnnounce(143961, 3, nil, mod:IsTank())--Embodied Misery
local warnInfernoStrike				= mod:NewTargetAnnounce(143962, 3)
--He Softfoot
local warnGouge						= mod:NewCastAnnounce(143330, 4, nil, nil, mod:IsTank())--The cast, so you can react and turn back to it and avoid stun.
local warnGougeStun					= mod:NewTargetAnnounce(143301, 4, nil, mod:IsTank())--Failed, stunned. the success ID is 143331 (knockback)
local warnGarrote					= mod:NewTargetAnnounce(143198, 3, nil, mod:IsHealer())
----He Softfoot's Desperate Measures
local warnMarkOfAnguish				= mod:NewSpellAnnounce(143812, 2)--Activation
local warnMarked					= mod:NewTargetAnnounce(143840, 3)--Embodied Anguish			
--Sun Tenderheart
local warnShaShear					= mod:NewCastAnnounce(143423, 3, 5)
local warnBane						= mod:NewCastAnnounce(143446, 4, nil, nil, mod:IsHealer())
local warnCalamity					= mod:NewSpellAnnounce(143491, 4)
----Sun Tenderheart's Desperate Measures
local warnDarkMeditation			= mod:NewSpellAnnounce(143546, 2)--Activation

--Rook Stonetoe
local specWarnVengefulStrikes		= mod:NewSpecialWarningSpell(144396, mod:IsTank())
local specWarnClash					= mod:NewSpecialWarningYou(143027)
local specWarnCorruptedBrew			= mod:NewSpecialWarningYou(143019)
local yellCorruptedBrew				= mod:NewYell(143019)
local specWarnCorruptedBrewNear		= mod:NewSpecialWarningClose(143019)
local specWarnClashMove				= mod:NewSpecialWarningMove(143010)
----Rook Stonetoe's Desperate Measures
local specWarnMiserySorrowGloom		= mod:NewSpecialWarningSpell(143955)
local specWarnCorruptionShock		= mod:NewSpecialWarningInterrupt(143958, mod:IsMelee())
local specWarnDefiledGround			= mod:NewSpecialWarningMove(143959)
local specWarnInfernoStrike			= mod:NewSpecialWarningYou(143962)
local yellInfernoStrike				= mod:NewYell(143962)
--He Softfoot
local specWarnGouge					= mod:NewSpecialWarningMove(143330, mod:IsTank())--Maybe localize it as a "turn away" warning.
local specWarnGougeStunOther		= mod:NewSpecialWarningTarget(143301, mod:IsTank())--Tank is stunned, other tank must taunt or he'll start killing people
local specWarnNoxiousPoison			= mod:NewSpecialWarningMove(144367)
----He Softfoot's Desperate measures
local specWarnMarkOfAnquish			= mod:NewSpecialWarningSpell(143812)
local specWarnMarked				= mod:NewSpecialWarningYou(143840)
local yellMarked					= mod:NewYell(143840, nil, false)
--Sun Tenderheart
local specWarnShaShear				= mod:NewSpecialWarningInterrupt(143423, mod:IsMelee())
local specWarnBane					= mod:NewSpecialWarningSpell(143446, mod:IsHealer())
local specWarnCalamity				= mod:NewSpecialWarningSpell(143491, nil, nil, nil, 2)
----Sun Tenderheart's Desperate Measures
local specWarnDarkMeditation		= mod:NewSpecialWarningSpell(143546)

--Rook Stonetoe
local timerVengefulStrikesCD		= mod:NewCDTimer(43, 144396)--(heroic 28)
local timerCorruptedBrewCD			= mod:NewCDTimer(11, 143019)--11-27
local timerClashCD					= mod:NewCDTimer(49.5, 143027)--Seems changed to a next timer
----Rook Stonetoe's Desperate Measures
local timerDefiledGroundCD			= mod:NewCDTimer(10.5, 143961, nil, mod:IsTank())
local timerInfernoStrikeCD			= mod:NewNextTimer(10, 143962)
--He Softfoot
local timerGougeCD					= mod:NewCDTimer(30, 143330, nil, mod:IsTank())--30-41
local timerGarroteCD				= mod:NewCDTimer(30, 143198, nil, mod:IsHealer())--30-36 (heroic 20-26)
--Sun Tenderheart
local timerBaneCD					= mod:NewCDTimer(25, 143446, nil, mod:IsHealer())--25-30 (heroic 13-20)
local timerCalamityCD				= mod:NewCDTimer(39, 143491)--39-43

--local berserkTimer					= mod:NewBerserkTimer(490)

local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitDetailedThreatSituation = UnitDetailedThreatSituation

local DeadTime = {}

function mod:BrewTarget(targetname, uId)
	if not targetname then return end
	warnCorruptedBrew:Show(targetname)
	if targetname == UnitName("player") then
		specWarnCorruptedBrew:Show()
		yellCorruptedBrew:Yell()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
	end
	if uId then
		local x, y = GetPlayerMapPosition(uId)
		if x == 0 and y == 0 then
			SetMapToCurrentZone()
			x, y = GetPlayerMapPosition(uId)
		end
		local inRange = VEM.RangeCheck:GetDistance("player", x, y)
		if inRange and inRange < 6 then
			specWarnCorruptedBrewNear:Show(targetname)
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
		end
	end
end

function mod:InfernoStrikeTarget(targetname, uId)
	if not targetname then return end
	warnInfernoStrike:Show(targetname)
	if targetname == UnitName("player") then
		specWarnInfernoStrike:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_lydj.mp3") --煉獄打擊
		sndWOP:Schedule(5.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\countfour.mp3")
		sndWOP:Schedule(6.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(7.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(8.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		yellInfernoStrike:Yell()
	end
end

function mod:OnCombatStart(delay)
	timerVengefulStrikesCD:Start(8-delay)
	timerGarroteCD:Start(9-delay)
	timerBaneCD:Start(15-delay)
	timerCorruptedBrewCD:Start(18-delay)
	timerGougeCD:Start(25-delay)
	timerCalamityCD:Start(31-delay)
	timerClashCD:Start(-delay)
	table.wipe(DeadTime)
--	berserkTimer:Start(-delay)
	VEM.InfoFrame:SetHeader(EJ_GetSectionInfo(8017))
	VEM.InfoFrame:Show(3, "FPHealth", DeadTime)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 143958 then
		local source = args.sourceName
		warnCorruptionShock:Show()
		if source == UnitName("target") or source == UnitName("focus") then 
			specWarnCorruptionShock:Show(source)
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3") --快打斷
		end
	elseif args.spellId == 143330 then
		warnGouge:Show()
		timerGougeCD:Start()
		for i = 1, 3 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and UnitDetailedThreatSituation("player", bossUnitID) then--We are highest threat target
				specWarnGouge:Show()--So show tank warning
				sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\turnaway.mp3") --快轉身
			end
		end
	elseif args.spellId == 143446 then
		warnBane:Show()
		specWarnBane:Show()
		if mod:IsHealer() then
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_ays.mp3") --暗言術準備
			sndWOP:Schedule(3, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\dispelnow.mp3")
		end
		if self:IsDifficulty("heroic10", "heroic25") then
			timerBaneCD:Start(13)--TODO, verify normal to see if it was changed too
		else
			timerBaneCD:Start()
		end
	elseif args.spellId == 143491 then
		warnCalamity:Show()
		specWarnCalamity:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_zxzb.mp3") --災星準備
		sndWOP:Schedule(2.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\countthree.mp3")
		sndWOP:Schedule(3.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\counttwo.mp3")
		sndWOP:Schedule(4.5, "Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\countone.mp3")
		timerCalamityCD:Start()
	elseif args.spellId == 143961 then
		warnDefiledGround:Show()
		timerDefiledGroundCD:Start()
	elseif args.spellId == 143962 then
		self:BossTargetScanner(71481, "InfernoStrikeTarget", 0.025)
		timerInfernoStrikeCD:Start()
	elseif args.spellId == 143497 then
		warnBondGoldenLotus:Show()
		if args:GetSrcCreatureID() == 71479 and not DeadTime["dz"] then
			DeadTime["dz"] = GetTime()
		elseif args:GetSrcCreatureID() == 71475 and not DeadTime["ws"] then
			DeadTime["ws"] = GetTime()
		elseif args:GetSrcCreatureID() == 71480 and not DeadTime["ms"] then
			DeadTime["ms"] = GetTime()
		end
		VEM.InfoFrame:SetHeader(EJ_GetSectionInfo(8017))
		VEM.InfoFrame:Show(3, "FPHealth", DeadTime)
	elseif args.spellId == 144396 then
		warnVengefulStrikes:Show()
		if mod:IsHealer() and self:AntiSpam(2, 3) then
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_fcdj.mp3") --復仇打擊
		end
		if self:IsDifficulty("heroic10", "heroic25") then
			timerVengefulStrikesCD:Start(28)--TODO, verify normal to see if it was changed too
		else
			timerVengefulStrikesCD:Start()
		end
		for i = 1, 3 do
			local bossUnitID = "boss"..i
			if UnitExists(bossUnitID) and UnitGUID(bossUnitID) == args.sourceGUID and UnitDetailedThreatSituation("player", bossUnitID) then--We are highest threat target
				specWarnVengefulStrikes:Show()--So show tank warning
				if self:AntiSpam(2, 3) then
					sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_fcdj.mp3")--復仇打擊
				end
			end
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 143027 then
		warnClash:Show()
		timerClashCD:Start()
		if args:IsPlayer() then
			specWarnClash:Show()
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_dc.mp3") --對沖快躲
		end
	elseif args.spellId == 143423 then
		local source = args.sourceName
		if source == UnitName("target") or source == UnitName("focus") then--Only warn if your target or focus, period, because if you aren't actually dpsing her, you just stay out of melee range and ignore this
			warnShaShear:Show()
			specWarnShaShear:Show(source)
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\kickcast.mp3") --快打斷
		end
	elseif args.spellId == 143497 then
		if args:GetSrcCreatureID() == 71479 then
			DeadTime["dz"] = nil
		elseif args:GetSrcCreatureID() == 71475 then
			DeadTime["ws"] = nil
		elseif args:GetSrcCreatureID() == 71480 then
			DeadTime["ms"] = nil
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 143959 and args:IsPlayer() and self:AntiSpam(1.5, 2) then
		specWarnDefiledGround:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
	elseif args.spellId == 143301 then--Stun debuff spellid
		warnGougeStun:Show(args.destName)
		if not args:IsPlayer() then
			specWarnGougeStunOther:Show(args.destName)
			if mod:IsTank() then
				sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\tauntboss.mp3") --嘲諷BOSS
			end
		end
	elseif args.spellId == 143198 then
		warnGarrote:Show(args.destName)
		if self:IsDifficulty("heroic10", "heroic25") then
			timerGarroteCD:Start(20)--TODO, see if it's cast more often on heroic only, or if normal was also changed to 20
		else
			timerGarroteCD:Start()
		end
	elseif args.spellId == 143840 then
		warnMarked:Show(args.destName)
		if args:IsPlayer() then
			specWarnMarked:Show(args.destName)
			sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_zyyj.mp3")--注意印記
			yellMarked:Yell()
		end
	--Special phases
	elseif args.spellId == 143546 then--Dark Meditation
		warnDarkMeditation:Show()
		specWarnDarkMeditation:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_amqh.mp3")--暗牧強化
		timerBaneCD:Cancel()
		timerCalamityCD:Cancel()
	elseif args.spellId == 143955 then--Misery, Sorrow, and Gloom
		warnMiserySorrowGloom:Show()
		specWarnMiserySorrowGloom:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_wsqh.mp3")--武僧強化
		timerVengefulStrikesCD:Cancel()
		timerClashCD:Cancel()
		timerCorruptedBrewCD:Cancel()
		timerInfernoStrikeCD:Start(7)
		timerDefiledGroundCD:Start(9)
	elseif args.spellId == 143812 then--Mark of Anguish
		warnMarkOfAnguish:Show()
		specWarnMarkOfAnquish:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\ex_so_dzqh.mp3")--盜賊強化
		timerGougeCD:Cancel()
		timerGarroteCD:Cancel()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	--Special phases
	if args.spellId == 143546 then--Dark Meditation
		timerBaneCD:Start(10)
--		timerCalamityCD:Start()--Seems cast almost right away now?
	elseif args.spellId == 143955 then--Misery, Sorrow, and Gloom
		timerDefiledGroundCD:Cancel()
		timerInfernoStrikeCD:Cancel()
		timerVengefulStrikesCD:Start(7.5)
		timerCorruptedBrewCD:Start(17)
		timerClashCD:Start(42)--Seems highly variable after his special, 42-49. but is a next timer rest of fight
	elseif args.spellId == 143812 then--Mark of Anguish
		timerGarroteCD:Start(8)--TODO, compare normal logs with heroic logs 
		timerGougeCD:Start(23)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 144357 and destGUID == UnitGUID("player") and self:AntiSpam(1.5, 3) then
		specWarnDefiledGround:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
	elseif spellId == 144367 and destGUID == UnitGUID("player") and self:AntiSpam(1.5, 4) then
		specWarnNoxiousPoison:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
	elseif spellId == 143009 and destGUID == UnitGUID("player") and self:AntiSpam(2, 5) then
		specWarnClashMove:Show()
		sndWOP:Play("Interface\\AddOns\\VEM-Core\\extrasounds\\"..VEM.Options.CountdownVoice.."\\runaway.mp3") --快躲開
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if spellId == 143019 then--Does not show in combat log on normal
		self:BossTargetScanner(71475, "BrewTarget", 0.025)
		timerCorruptedBrewCD:Start()
	end
end
