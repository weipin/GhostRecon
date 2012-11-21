function GhostRecon:CurBuild()
    local v, b = GetBuildInfo()
    
    
    return v.."."..b
end

function GhostRecon:GetMobInfo(zone, mobGuid, mobName)
	return GhostReconDB.Instances[zone] and GhostReconDB.Instances[zone][mobName] or { }
end

function GhostRecon:SetMobInfo(zone, mobGuid, mobName, info)
	GhostReconDB.Instances[zone] = GhostReconDB.Instances[zone] or { }
	GhostReconDB.Instances[zone][mobName] = info
	GhostReconDB.Instances[zone][mobName].cooldowns = nil
end

function GhostRecon:GetNotes(zone, mobGuid, mobName)
	return self:GetMobInfo(zone, mobGuid, mobName).notes or ""
end

function GhostRecon:SetNotes(zone, mobGuid, mobName, notes)
	local info = self:GetMobInfo(zone, mobGuid, mobName)
	
	
	info.notes = notes
	self:SetMobInfo(zone, mobGuid, mobName, info)
end

function GhostRecon:ValidateRange(shortestTime, longestTime)
	local rc = true
	
	
	if shortestTime < 15 or longestTime < 20 then
		rc = nil
	else
		local period = longestTime - shortestTime
		
		
		if period >= 20 then
			rc = nil
			
		else
			local ppc = period / longestTime
			
			
			if ppc >= 0.2 then
				rc = nil
			end
		end
		
	end
	
	return rc
end

function GhostRecon:AddAbility(zone, mobGuid, mobName, spellId)
	-- returns true if we didn't already know about the spell/ability
	local rc


	if GhostReconDB.Settings.Active then
		local info = self:GetMobInfo(zone, mobGuid, mobName)
		
		
		info.spells = info.spells or { }
		
		if not info.spells[spellId] then
			info.spells[spellId] = true
			rc = true
			
			self:SetMobInfo(zone, mobGuid, mobName, info)
		end
	end
		
	return rc
end

function GhostRecon:RemoveAbility(zone, mobGuid, mobName, spellId)
	-- returns true if we already knew about the spell/ability
	local rc


	if GhostReconDB.Settings.Active then
		local info = self:GetMobInfo(zone, mobGuid, mobName)
		
		
		info.spells = info.spells or { }
		
		if info.spells[spellId] then
			info.spells[spellId] = nil
			rc = true
			
			self:SetMobInfo(zone, mobGuid, mobName, info)
		end
	end
		
	return rc
end

function GhostRecon:AddControl(zone, mobGuid, mobName, spellId, success)
	-- returns true if we changed what we thought about this effect on this mob
	local rc


	if GhostReconDB.Settings.Active then
		local info = self:GetMobInfo(zone, mobGuid, mobName)
		local cType = GhostRecon:ControlTypeForSpellId(spellId)
		
	
		if cType then
			local info = GhostRecon:GetMobInfo(zone, mobGuid, mobName)
			local curBuildVersion = self:CurBuild()
			
			
			info[cType] = info[cType] or { ["recordedBuild"] = curBuildVersion, ["value"] = self.CC_UNKNOWN }
			
			if info[cType].recordedBuild == curBuildVersion then
				if info[cType].value == self.CC_UNKNOWN or info[cType].value == nil then
					if success then
						info[cType].value = self.CC_YES
					else
						info[cType].value = self.CC_NO
					end
					
					rc = true
				else
					if info[cType].value == self.CC_NO and success then
						info[cType].value = self.CC_SOMETIMES
						rc = true
						
					elseif info[cType].value == self.CC_YES and not success then
						info[cType].value = self.CC_SOMETIMES
						rc = true
						
					end
				end
			else
				info[cType].recordedBuild = curBuildVersion
				
				if success then
					info[cType].value = self.CC_YES
				else
					info[cType].value = self.CC_NO
				end
				
				rc = true
			end
			
			self:SetMobInfo(zone, mobGuid, mobName, info)
		end
	end
		
	return rc
end
