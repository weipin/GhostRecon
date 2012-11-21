-- enums
GhostRecon.CC_UNKNOWN = 0
GhostRecon.CC_NO = 1
GhostRecon.CC_YES = 2
GhostRecon.CC_SOMETIMES = 3

GhostRecon.CONST_HEAL_SELF = 1
GhostRecon.CONST_HEAL_OTHERS = 2

local CCTYPE_SHEEP = "sheep"
local CCTYPE_SLEEP = "sleep"
local CCTYPE_SAP = "sap"
local CCTYPE_BLIND = "blind"
local CCTYPE_KIDNEYSHOT = "kidney"
local CCTYPE_GOUGE = "gouge"
local CCTYPE_BANISH = "banish"
local CCTYPE_ENSLAVE = "enslave"
local CCTYPE_FEAR = "fear"
local CCTYPE_DEATHCOIL = "dc"
local CCTYPE_TRAP = "trap"
local CCTYPE_HEX = "hex"
local CCTYPE_SHACKLE = "shackle"
local CCTYPE_MINDCONTROL = "MC"
local CCTYPE_TURNEVIL = "turnevil"
local CCTYPE_CYCLONE = "cyclone"
local CCTYPE_ROOTS = "roots"
local CCTYPE_SCAREBEAST = "scare"
local CCTYPE_DEATHGRIP = "grip"
local CCTYPE_SLOW = "slow"
local CCTYPE_INFWOUNDS = "infwounds"
local CCTYPE_TONGUES = "tongues"
local CCTYPE_EXHAUSTION = "exhaust"
local CCTYPE_GROWL = "growl"
local CCTYPE_TAUNT = "taunt"
local CCTYPE_RD = "rd"  -- righteous defense
local CCTYPE_MAIM = "maim"
local CCTYPE_BASH = "bash"
local CCTYPE_DARKCMD = "darkcmd"
local CCTYPE_REPENTANCE = "repent"
local CCTYPE_PSYCHIC_SCREAM = "scream"
local CCTYPE_PSYCHIC_HORROR = "horror"
local CCTYPE_HOJ = "hoj" -- Hammer of Justice
local CCTYPE_HOLYWRATH = "holywrath"


local enumNames = {
    [GhostRecon.CC_UNKNOWN] = "Unknown",
    [GhostRecon.CC_NO] = "No",
    [GhostRecon.CC_YES] = "Yes",
    [GhostRecon.CC_SOMETIMES] = "Sometimes"
}

GhostRecon.ccCreatures = {
    [CCTYPE_SHEEP] = { ["Beast"] = true, ["Humanoid"] = true, ["Critter"] = true },
    [CCTYPE_SLEEP] = { ["Beast"] = true, ["Dragonkin"] = true },
    [CCTYPE_SAP] = { ["Beast"] = true, ["Dragonkin"] = true, ["Humanoid"] = true, ["Demon"] = true },
    [CCTYPE_BANISH] = { ["Elemental"] = true, ["Demon"] = true },
    [CCTYPE_ENSLAVE] = { ["Demon"] = true },
    [CCTYPE_HEX] = { ["Beast"] = true, ["Humanoid"] = true },
    [CCTYPE_SHACKLE] = { ["Undead"] = true },
    [CCTYPE_MINDCONTROL] = { ["Humanoid"] = true },
    [CCTYPE_TURNEVIL] = { ["Demon"] = true, ["Undead"] = true },
    [CCTYPE_SCAREBEAST] = { ["Beast"] = true },
	[CCTYPE_REPENTANCE] = { ["Demon"] = true, ["Dragonkin"] = true, ["Giant"] = true, ["Humanoid"] = true, ["Undead"] = true },
  [CCTYPE_HOLYWRATH] = { ["Demon"] = true, ["Undead"] = true, ["Dragonkin"] = true, ["Elemental"] = true }
}

local ccClasses = {
    ["DEATHKNIGHT"] = { [CCTYPE_DEATHGRIP] = true, [CCTYPE_DARKCMD] = true },
    ["DRUID"] = { [CCTYPE_SLEEP] = true, [CCTYPE_CYCLONE] = true, [CCTYPE_ROOTS] = true, [CCTYPE_INFWOUNDS] = true, [CCTYPE_GROWL] = true, [CCTYPE_MAIM] = true, [CCTYPE_BASH] = true },
    ["HUNTER"] = { [CCTYPE_TRAP] = true, [CCTYPE_SCAREBEAST] = true, [CCTYPE_ROOTS] = true, [CCTYPE_SLEEP] = true, [CCTYPE_TAUNT] = true },
    ["MAGE"] = { [CCTYPE_SHEEP] = true, [CCTYPE_SLOW] = true },
    ["PALADIN"] = { [CCTYPE_TURNEVIL] = true, [CCTYPE_REPENTANCE] = true, [CCTYPE_RD] = true, [CCTYPE_HOLYWRATH] = true, [CCTYPE_HOJ] = true },
    ["PRIEST"] = { [CCTYPE_SHACKLE] = true, [CCTYPE_MINDCONTROL] = true, [CCTYPE_PSYCHIC_SCREAM] = true, [CCTYPE_PSYCHIC_HORROR] = true },
    ["ROGUE"] = { [CCTYPE_SAP] = true, [CCTYPE_GOUGE] = true, [CCTYPE_BLIND] = true, [CCTYPE_KIDNEYSHOT] = true },
    ["SHAMAN"] = { [CCTYPE_HEX] = true, [CCTYPE_BANISH] = true },
    ["WARLOCK"] = { [CCTYPE_BANISH] = true, [CCTYPE_ENSLAVE] = true, [CCTYPE_FEAR] = true, [CCTYPE_TONGUES] = true, [CCTYPE_EXHAUSTION] = true, [CCTYPE_DEATHCOIL] = true },
    ["WARRIOR"] = { [CCTYPE_TAUNT] = true, [CCTYPE_FEAR] = true }
}

GhostRecon.ccList = {
    [CCTYPE_SHEEP] = { [118] = true, [61305] = true, [28272] = true, [61721] = true, [61780] = true, [28271] = true },
    [CCTYPE_SLOW] = { [31589] = true },
    [CCTYPE_SLEEP] = { [2637] = true, [19386] = true },
    [CCTYPE_CYCLONE] = { [33786] = true },
    [CCTYPE_ROOTS] = { [339] = true, [90327] = true, [50245] = true, [54706] = true, [4167] = true },
    [CCTYPE_SAP] = { [6770] = true },
	[CCTYPE_KIDNEYSHOT] = { [408] = true, [14174] = true, [14175] = true, [14176] = true },
	[CCTYPE_BLIND] = { [2094] = true },
	[CCTYPE_GOUGE] = { [1776] = true },
    [CCTYPE_BANISH] = { [710] = true, [76780] = true },
    [CCTYPE_ENSLAVE] = { [1098] = true, [18822] = true },
    [CCTYPE_FEAR] = { [5782] = true, [53754] = true, [53759] = true, [5484] = true, [5246] = true },
    [CCTYPE_DEATHCOIL] = { [6789] = true },
    [CCTYPE_TRAP] = { [1499] = true, [60192] = true, [3355] = true },
    [CCTYPE_HEX] = { [51514] = true },
    [CCTYPE_SHACKLE] = { [9484] = true },
    [CCTYPE_MINDCONTROL] = { [605] = true },
    [CCTYPE_TURNEVIL] = { [10326] = true },
    [CCTYPE_DEATHGRIP] = { [49560] = true, [49575] = true, [49576] = true },
    [CCTYPE_DARKCMD] = { [56222] = true },
    [CCTYPE_SCAREBEAST] = { [1513] = true },
    [CCTYPE_INFWOUNDS] = { [48483] = true, [48484] = true },
    [CCTYPE_TONGUES] = { [1714] = true },
    [CCTYPE_EXHAUSTION] = { [18223] = true },
    [CCTYPE_GROWL] = { [6795] = true },
    [CCTYPE_TAUNT] = { [355] = true, [53477] = true },
	[CCTYPE_RD] = { [31789] = true },
    [CCTYPE_MAIM] = { [22570] = true },
    [CCTYPE_BASH] = { [5211] = true },
	[CCTYPE_REPENTANCE] = { [20066] = true },
  [CCTYPE_PSYCHIC_HORROR] = { [64044] = true },
	[CCTYPE_PSYCHIC_SCREAM] = { [8122] = true },
  [CCTYPE_HOLYWRATH] = { [2812] = true },
  [CCTYPE_HOJ] = { [853] = true }
}

local taunts = {
    [CCTYPE_TAUNT] = true,
    [CCTYPE_GROWL] = true,
    [CCTYPE_DARKCMD] = true,
	[CCTYPE_RD] = true
}

local stuns = {
    [CCTYPE_KIDNEYSHOT] = true,
    [CCTYPE_GOUGE] = true,
    [CCTYPE_MAIM] = true,
    [CCTYPE_BASH] = true,
    [CCTYPE_HOJ] = true
}

local realNames = {
}

local function LocalizeCCTypeNames()
	local i
	
	
	for i, _ in pairs(GhostRecon.ccList) do
		local j
		
		
		for j, _ in pairs(GhostRecon.ccList[i]) do
			local name = GetSpellInfo(j)
			
			realNames[i] = name
			break
		end
	end
end

local function GetClassForCCType(ccType)
    local rc = ""


    for i, v in pairs(ccClasses) do
        if v[ccType] then
            rc = i
            break
        end
    end

    return rc
end

local function DecToHex(num)
    local b, k, rc, i, d = 16, "0123456789ABCDEF", "", 0


    while num > 0 do
        i = i + 1
        num, d = math.floor(num / b), num % b + 1
        rc = string.sub(k, d, d)..rc
    end
    
    return rc
end

local function FractionToHex(num)
    local rc = DecToHex(num * 255)


    if string.len(rc) == 1 then
        rc = "0"..rc
    elseif string.len(rc) == 0 then
    	rc = "00"
    end
    
    return rc
end

local function ColorToHex(col)
    return "FF"..FractionToHex(col.r)..FractionToHex(col.g)..FractionToHex(col.b)
end

function GhostRecon:ColoredText(text, color)
    return "|c"..ColorToHex(color)..text.."|r"
end


local function IsStunnable(mobInfo)
	local rc = nil
	local i, v
	
	
	for i, v in pairs(mobInfo) do
		if stuns[i] then
			if v.value == GhostRecon.CC_YES or v.value == GhostRecon.CC_SOMETIMES then
				rc = true
				break
				
			elseif v.value == GhostRecon.CC_NO then
				rc = false
			end
		end
	end
	
	return rc
end

local function IsTauntable(mobInfo)
	local rc = nil
	local i, v
	
	
	for i, v in pairs(mobInfo) do
		if taunts[i] then
			if v.value == GhostRecon.CC_YES then
				rc = true
				break
			elseif v.value == GhostRecon.CC_NO then
				rc = false
			end
		end
	end
	
	return rc
end

local function ClassInGroup(class)
    local rc = false


    if select(2, UnitClass("player")) == class then
        rc = true
    else
        local prefix = "party"
        local limit = 5


        if GetNumGroupMembers() > 5 then
            prefix = "raid"
            limit = 40
        elseif GetNumGroupMembers() == 0 then
            prefix = nil
            limit = nil
        end

        if prefix then
            for i = 1, limit do
                local curUnitId = prefix..i


                if UnitExists(curUnitId) then
                    if select(2, UnitClass(curUnitId)) == class then
                        rc = true
                        break
                    end
                end
            end
        end
    end
    
    return rc
end

function GhostRecon:ControlTypeForSpellId(spellId)
	local rc
	
	
	for i, v in pairs(self.ccList) do
		if v[spellId] then
			rc = i
			break
		end
	end
	
	return rc
end

local function ShouldAddTooltipInfo(mobGuid, mobName)
	local rc = true
	
	
	if not GhostReconDB.Settings.TooltipEnabled then
		rc = nil
	end
	
	return rc
end

function GhostRecon:DecorateTooltip(mobGuid, mobName, showSpells, overrideWhere, overrideParty)
	if ShouldAddTooltipInfo() then
	    local where = overrideWhere or GhostRecon:WhereAmI()
	    local whereInfo = GhostReconDB.Instances[where] or { }
	    local mobInfo = whereInfo[mobName] or { }
	    local added = false
	    local report = ""
	    local affected = "Affected by: "
	    local sometimes = "Sometimes works: "
	    local immunes = "Immune: "
	    local cc = ""
		local red = { ["r"] = 0.9, ["g"] = 0, ["b"] = 0 }
		local green = { ["r"] = 0, ["g"] = 0.9, ["b"] = 0 }
	    local tauntString = ""
	    local stunString = ""
		local tauntColor
		local stunColor
		local addedSomething = false
		local reshow = GameTooltip:IsVisible()
		

	    -- tauntable?
	    local tauntable = IsTauntable(mobInfo)
	    
	    
	    if tauntable == true then
	        tauntString = "Tauntable"
			tauntColor = green
	    elseif tauntable == false then
	        tauntString = "Not tauntable"
			tauntColor = red
	    end
	    
	    if tauntColor and string.len(tauntString) > 0 then
	    	tauntString = self:ColoredText(tauntString, tauntColor)
	    end
	    
		-- stunnable?    
	    local stunnable = IsStunnable(mobInfo)


	    if stunnable == true then
	        stunString = "Stunnable"
			stunColor = green
	    elseif stunnable == false then
	        stunString = "Not stunnable"
			stunColor = red
	    end
	    
	    if stunColor and string.len(stunString) > 0 then
	    	stunString = self:ColoredText(stunString, stunColor)
	    end
	    
		if string.len(tauntString) > 0 or string.len(stunString) > 0 then
			local effString = ""
			
			
			if string.len(tauntString) > 0 then
				effString = tauntString
			end
			
			if string.len(stunString) > 0 then
				if string.len(effString) == 0 then
					effString = stunString
				else
					effString = effString..", "..stunString
				end
			end
			
		    GameTooltip:AddLine(effString, 0.5, 0.5, 0.5, 1)       
			addedSomething = true
		end
		
	    -- find yes
	    for i, v in pairs(mobInfo) do
	        -- check to see if this is a general CC entry (i.e. not special info about the mob)
	        if self.ccList[i] then
	        	if not stuns[i] and not taunts[i] then
		            local owningClass = GetClassForCCType(i)


		            if v.value == GhostRecon.CC_YES then
			            if ClassInGroup(owningClass) or overrideParty then
			                if cc ~= "" then
			                    cc = cc..", "
			                end
			                
                      --local foo = realNames;
			                cc = cc..self:ColoredText(realNames[i], RAID_CLASS_COLORS[owningClass])            
			                added = true
			            end
					end
				end
	        end
	    end
	    
	    if added then
	        report = affected..cc
	        GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
	    end

	    -- find sometimes
	    added = false
	    report = ""
	    cc = ""
	    
   	    for i, v in pairs(mobInfo) do
	        -- check to see if this is a general CC entry (i.e. not special info about the mob)
	        if self.ccList[i] then
	        	if not stuns[i] and not taunts[i] then
		            local owningClass = GetClassForCCType(i)

		
		            if v.value == GhostRecon.CC_SOMETIMES then
			            if ClassInGroup(owningClass) or overrideParty then
			                if cc ~= "" then
			                    cc = cc..", "
			                end
			                
			                cc = cc..self:ColoredText(realNames[i], RAID_CLASS_COLORS[owningClass])            
			                added = true
			            end
					end
				end
	        end
	    end
	    
	    if added then
	        report = sometimes..cc
	        GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
	    end

	    -- find no
	    added = false
	    report = ""
	    cc = ""
	    
   	    for i, v in pairs(mobInfo) do
	        -- check to see if this is a general CC entry (i.e. not special info about the mob)
	        if self.ccList[i] then
	        	if not stuns[i] and not taunts[i] then
		            local owningClass = GetClassForCCType(i)

		
		            if v.value == GhostRecon.CC_NO then
			            if ClassInGroup(owningClass) or overrideParty then
			                if cc ~= "" then
			                    cc = cc..", "
			                end
			                
			                cc = cc..self:ColoredText(realNames[i], { ["r"] = 1, ["g"] = 0, ["b"] = 0 })
			                added = true
			            end
					end
				end
	        end
	    end
	    
	    if added then
	        report = immunes..cc
	        GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
	    end
		
		if showSpells then
			-- spells
			local spellList = ""
			
			
			if mobInfo.spells then
				local spells = { }
				local namesSeen = { }
				
				
				for i, v in pairs(mobInfo.spells) do
					local info = { }
					
					
					info.spellId = i
					info.name = GetSpellInfo(i)
					
					table.insert(spells, info)
				end
				
				table.sort(spells, function(a, b)
					if a == nil and b == nil then
						return nil
					
					elseif a.name == nil and b.name == nil then
						return nil
						
					elseif a.name == nil then
						return nil
					
					elseif b.name == nil then
						return true
						
					elseif a.name < b.name then
						return true
					end
				end)
				
				for _, i in pairs(spells) do	
					local name, _, texture, _, _, _, castTime, minRange, maxRange = GetSpellInfo(i.spellId)
					local right = ""
					local v = mobInfo.spells[i.spellId]
					local leftR = 0.3
					local leftG = 0.3
					local leftB = 1
					
					
					if name then
						if namesSeen[name] == nil then
							namesSeen[name] = true
							addedSomething = true
							
							if castTime == 0 then
								right = "Instant"
							else
								right = string.format("%0.1f sec", castTime / 1000)
							end
							
							if maxRange > 0 then
								if minRange == 0 then
									right = right..string.format(" (%d yds)", maxRange)
								else
									right = right..string.format(" (%d-%d yds)", minRange, maxRange)
								end
							end
							
							if v == 1 then
								right = "|cffff0000"..right.."|r"
							end
							
							if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[i.spellId] then
								if GhostReconDB.SpellInfo[i.spellId].removable then
									leftR = 1
									leftG = 0.3
									leftB = 1
								end
	
								if GhostReconDB.SpellInfo[i.spellId].healType ~= nil then
									leftR = 0.3
									leftG = 1
									leftB = 0.3
								end
							end
							
							-- texture
							local textureString = ""
							
							
							if GhostReconDB.Settings.TooltipIconsEnabled then
								textureString = "|T"..texture..":16|t "
							end
							
							-- add it to the tooltip
							GameTooltip:AddDoubleLine(textureString..name, right, leftR, leftG, leftB, 1, 1, 1)
							addedSomething = true
						end
					end
				end
			end
		end
				
		if addedSomething and reshow then
	        GameTooltip:Show()
		end
	end
end

LocalizeCCTypeNames()
