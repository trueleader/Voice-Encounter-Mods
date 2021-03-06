local mod	= VEM:NewMod("d286", "VEM-WorldEvents", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 9856 $"):sub(12, -3))
mod:SetCreatureID(25740)--25740 Ahune, 25755, 25756 the two types of adds
mod:SetModelID(23447)--Frozen Core, ahunes looks pretty bad.
mod:SetZone()

mod:SetReCombatTime(10)
mod:RegisterCombat("combat")
mod:SetMinCombatTime(15)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED"
)

local warnSubmerged				= mod:NewSpellAnnounce(37751, 2, "Interface\\AddOns\\VEM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerged				= mod:NewAnnounce("Emerged", 2, "Interface\\AddOns\\VEM-Core\\textures\\CryptFiendUnBurrow.blp")

local specWarnAttack			= mod:NewSpecialWarning("specWarnAttack")

local timerEmerge				= mod:NewTimer(35.5, "EmergeTimer", "Interface\\AddOns\\VEM-Core\\textures\\CryptFiendUnBurrow.blp")
local timerSubmerge				= mod:NewTimer(92, "SubmergTimer", "Interface\\AddOns\\VEM-Core\\textures\\CryptFiendBurrow.blp")--Variable, 92-96

function mod:OnCombatStart(delay)
	timerSubmerge:Start(95-delay)--first is 95, rest are 92
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 45954 then				-- Ahunes Shield
		warnEmerged:Show()
		timerSubmerge:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 45954 then				-- Ahunes Shield
		warnSubmerged:Show()
		timerEmerge:Start()
		specWarnAttack:Show()
	end
end