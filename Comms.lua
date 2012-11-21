local CONST_ADDON = "GHOSTRECON"
local CONST_CHAT_PREFIX_COLOR = { ["r"] = 1, ["g"] = 1, ["b"] = 0 }
local CONST_CHAT_PREFIX = "Ghost: Recon - "

GhostRecon.knownUsers = { }

local outboundMessages = { }
local nextSendTime = nil

local queries = { }
local inCombat
local versionWarningIssued


local function CsvDecode(text, sep)
    local rc = { }
    local curText


	if sep == nil then
		sep = ","
	end
	
    curText = text..sep

    while true do
        local posn = string.find(curText, "%"..sep)


        if posn then
            local curElement = string.sub(curText, 1, posn-1)


            table.insert(rc, curElement)
            curText = string.sub(curText, posn+1, string.len(curText))
        else
            break
        end
    end

    return unpack(rc)
end

function GhostRecon:TellUser(msg, r, g, b, force)
	if r ~= nil and g == nil and b == nil and force == nil then
		force = r
	end
		
--	if not inCombat or force then
	    if GhostReconDB.Settings.ShowMessages or force then
	        local out = string.format("%s%s", self:ColoredText(CONST_CHAT_PREFIX, CONST_CHAT_PREFIX_COLOR), msg)
	        
	        
	        DEFAULT_CHAT_FRAME:AddMessage(out, r, g, b)
	    end
--	end
end

function GhostRecon:SendSpellInfoNotification(spellId, spellName, zone, isRemovable)
    if IsInGuild() and GhostRecon.useComms and GhostReconDB.Settings.GuildSync then
    	if spellId ~= nil and
    	   spellName ~= nil and
    	   zone ~= nil then
    	
    		local msg
    		

	        msg = string.format("SPELLINFO,%d,%s,%s", spellId, spellName, zone)
	    
	        if isRemovable then
	            msg = msg..",1"
	        else
	            msg = msg..",0"
	        end
	        
	        outboundMessages[msg] = true
	        
	        if nextSendTime == nil then
	            nextSendTime = GetTime()
	        end
    	end
	end
end

function GhostRecon:SendHealInfoNotification(spellId, spellName, zone, healType)
    if IsInGuild() and GhostRecon.useComms and GhostReconDB.Settings.GuildSync then
    	if spellId ~= nil and
    	   spellName ~= nil and
    	   zone ~= nil then
    	
    		local msg
    		

	        msg = string.format("HEALINFO,%d,%s,%s,%d", spellId, spellName, zone, healType)
	    
	        outboundMessages[msg] = true
	        
	        if nextSendTime == nil then
	            nextSendTime = GetTime()
	        end
    	end
	end
end

function GhostRecon:SendNotification(notifyType, mobGuid, mobName, spellId, spellName, zone, success, inInstance)
    if IsInGuild() and GhostRecon.useComms and GhostReconDB.Settings.GuildSync then
    	if notifyType ~= nil and
    	   mobGuid ~= nil and
    	   mobName ~= nil and
    	   spellId ~= nil and
    	   spellName ~= nil and
    	   zone ~= nil then
    	   
	        local msg
	        

	        msg = string.format("%s,%s,%s,%d,%s,%s", string.upper(notifyType), mobGuid, mobName, spellId, spellName, zone)
	    
	        if success then
	            msg = msg..",1"
	        else
	            msg = msg..",0"
	        end
	        
	        if inInstance then
	            msg = msg..",1"
	        else
	            msg = msg..",0"
	        end
	        
	        outboundMessages[msg] = true
	        
	        if nextSendTime == nil then
	            nextSendTime = GetTime()
	        end
	    end
    end
end

function GhostRecon:SendQuery(mobGuid, mobName, zone)
    if IsInGuild() and GhostRecon.useComms and GhostReconDB.Settings.GuildSync then
        local info = { }
        
        
        info.mobGuid = mobGuid
        info.mobName = mobName
        info.zone = zone
        info.spellCount = 0
        info.respondants = { }
        info.askTime = GetTime()
        
        queries[mobGuid] = info
        
        -- send the query
        local msg = string.format("QUERY,%s,%s,%s", mobGuid, mobName, zone)
    
    	
        outboundMessages[msg] = true
        
        if nextSendTime == nil then
            nextSendTime = GetTime()
        end
    end	
end

function GhostRecon:SendHello()
	if IsInGuild() then
		SendAddonMessage(CONST_ADDON, "HELLO", "GUILD")
	end
end

function GhostRecon:SendWelcome()
	if IsInGuild() then
		SendAddonMessage(CONST_ADDON, "WELCOME", "GUILD")
	end
end

function GhostRecon:SendVersion()
	if IsInGuild() then
		SendAddonMessage(CONST_ADDON, "VERSION,"..GetAddOnMetadata("GhostRecon", "Version"), "GUILD")
	end
end

local function ReceiveControlNotification(sender, mobGuid, mobName, spellId, spellName, zone, success, inInstance)
    spellId = tonumber(spellId)
    success = tonumber(success)
	inInstance = tonumber(inInstance)
	
	if inInstance == 1 then	
    	GhostReconDB.Instances[zone] = GhostReconDB.Instances[zone] or { }
		GhostReconDB.Instances[zone].isInstance = true
	end
	
	if success == 0 then
		success = nil
	else
		success = true
	end
	
	if inInstance == 1 or not GhostReconDB.Settings.InstancesOnly then
	    if GhostRecon:AddControl(zone, mobGuid, mobName, spellId, success) then
	    	local link = GetSpellLink(spellId)
	    	

			if link then	    	
		        if success then
		            GhostRecon:TellUser(string.format("Received control information: %s works on %s (%s).  Sent by %s.", link, mobName, zone, sender), 0.3, 1, 0.3)
		        else
		            GhostRecon:TellUser(string.format("Received control information: %s fails on %s (%s).  Sent by %s.", link, mobName, zone, sender), 1, 0.3, 0.3)
		        end
			end
	    end
	end
end

local function ReceiveAbilityNotification(sender, mobGuid, mobName, spellId, spellName, zone, inInstance)
    spellId = tonumber(spellId)
	inInstance = tonumber(inInstance)

	if spellId ~= nil and mobGuid ~= nil then
		if not GhostRecon.IgnoredAbilities[spellId] then
			if inInstance == 1 then	
		    	GhostReconDB.Instances[zone] = GhostReconDB.Instances[zone] or { }
				GhostReconDB.Instances[zone].isInstance = true
			end
			
			if inInstance == 1 or not GhostReconDB.Settings.InstancesOnly then
			    if GhostRecon:AddAbility(zone, mobGuid, mobName, spellId) then
			    	local link = GetSpellLink(spellId)
		    	
		    	
			        GhostRecon:TellUser(string.format("Received spell/ability information: %s has a spell/ability called %s (%s).  Sent by %s.", mobName, link, zone, sender), 0.3, 0.3, 1)
			        
			        if GhostRecon.abilityBar:IsVisible() then
			        	if GhostRecon.abilityBar.mobName == mobName then
			        		GhostRecon:RefreshSpells("target")
			        	end
			        end
			    end
			end
		end
	end
end

local function ReceiveQueryRequest(sender, mobGuid, mobName, zone)
	local spellCount = 0
    local whereInfo = GhostReconDB.Instances[zone] or { }
    local mobInfo = whereInfo[mobName] or { }


	if mobInfo.spells then
		for i, _ in pairs(mobInfo.spells) do
			spellCount = spellCount + 1
		end
	end
	
	if spellCount > 0 then
		local msg = string.format("RESPONSE,%s,%s,%s,%d", mobGuid, mobName, zone, spellCount)

		
        outboundMessages[msg] = true
        
        if nextSendTime == nil then
            nextSendTime = GetTime()
        end        
	end
end

local function ReceiveQueryResponse(sender, mobGuid, mobName, zone, spellCount)
	local info = queries[mobGuid]
	
	
	if info then
		info.respondants[sender] = tonumber(spellCount)
	end
end

local function ReceiveSpellInfoNotification(sender, spellId, spellName, zone, removable)
	if spellId ~= nil and spellName ~= nil then
	   	spellId = tonumber(spellId)
		inInstance = tonumber(inInstance)
		removable = tonumber(removable)
		
		local link = GetSpellLink(spellId)
			
			
		if link then
			GhostReconDB.SpellInfo = GhostReconDB.SpellInfo or { }
			GhostReconDB.SpellInfo[spellId] = GhostReconDB.SpellInfo[spellId] or { }
			
			if not GhostReconDB.SpellInfo[spellId].removable then
				GhostRecon:TellUser(string.format("Received spell information: %s is removable.  Sent by %s.", link, sender), 0.3, 1, 0.3)
			end
			
			if removable == 1 then
				GhostReconDB.SpellInfo[spellId].removable = true
			else
				GhostReconDB.SpellInfo[spellId].removable = false
			end
		end
	end
end

local function ReceiveHealInfoNotification(sender, spellId, spellName, zone, healType)
	if spellId ~= nil and spellName ~= nil then
	   	spellId = tonumber(spellId)
		inInstance = tonumber(inInstance)
		healType = tonumber(healType)
		
		local link = GetSpellLink(spellId)
			
			
		if link then
			GhostReconDB.SpellInfo = GhostReconDB.SpellInfo or { }
			GhostReconDB.SpellInfo[spellId] = GhostReconDB.SpellInfo[spellId] or { }
			
			if GhostReconDB.SpellInfo[spellId].healType == nil then
				if healType == GhostRecon.CONST_HEAL_SELF then
					GhostRecon:TellUser(string.format("Received heal information: %s is a self-healing spell.  Sent by %s.", link, sender), 0.3, 1, 0.3)
					
				elseif healType == GhostRecon.CONST_HEAL_OTHERS then
					GhostRecon:TellUser(string.format("Received heal information: %s is a general healing spell.  Sent by %s.", link, sender), 0.3, 1, 0.3)
				end
				
				GhostReconDB.SpellInfo[spellId].healType = healType
			
			elseif GhostReconDB.SpellInfo[spellId].healType == GhostRecon.CONST_HEAL_SELF then
				if healType == GhostRecon.CONST_HEAL_OTHERS then
					GhostReconDB.SpellInfo[spellId].healType = GhostRecon.CONST_HEAL_OTHERS
					GhostRecon:TellUser(string.format("Received heal information: %s is a general healing spell.  Sent by %s.", link, sender), 0.3, 1, 0.3)
				end
			end
		end
	end
end

local function ReceiveSendRequest(sender, whoShouldSend, mobGuid, mobName, zone)
	if whoShouldSend == UnitName("player") then
	    local whereInfo = GhostReconDB.Instances[zone] or { }
	    local mobInfo = whereInfo[mobName] or { }
	
	
		-- mob CC effects
		for ccType, spellList in pairs(GhostRecon.ccList) do
			local value = mobInfo[ccType] and mobInfo[ccType].value
			local chosenSpellId = 0
			local spellName = ""
						
			
			for spellId, _ in pairs(spellList) do
				chosenSpellId = spellId
				break
			end
			
			if value ~= nil and chosenSpellId ~= nil then
				spellName = GetSpellInfo(chosenSpellId)
				
				if value == GhostRecon.CC_NO then
					GhostRecon:SendNotification("CONTROL", moGuid, mobName, chosenSpellId, spellName, zone, false, whereInfo.isInstance or false)
				
				elseif value == GhostRecon.CC_YES then
					GhostRecon:SendNotification("CONTROL", moGuid, mobName, chosenSpellId, spellName, zone, true, whereInfo.isInstance or false)
	
				elseif value == GhostRecon.CC_SOMETIMES then
					GhostRecon:SendNotification("CONTROL", moGuid, mobName, chosenSpellId, spellName, zone, false, whereInfo.isInstance or false)
					GhostRecon:SendNotification("CONTROL", moGuid, mobName, chosenSpellId, spellName, zone, true, whereInfo.isInstance or false)
	
				end
			end
		end
		
		-- mob abilities
		local spellsFound = { }
		
		
		if mobInfo.spells then
			for i, _ in pairs(mobInfo.spells) do
				local name = GetSpellInfo(i)
				
				
				GhostRecon:SendNotification("ABILITY", mobGuid, mobName, i, name, zone, true, whereInfo.isInstance or false)
				
				
				-- additional spell information
				if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[i] then
					GhostRecon:SendSpellInfoNotification(i, name, zone, GhostReconDB.SpellInfo[i].removable)
				end
			end
		end
	end
end


local function ReceiveVersionCheck(sender, versionString)
	local major, minor, revision = CsvDecode(versionString, ".")
	local myMajor, myMinor, myRevision = CsvDecode(GetAddOnMetadata("GhostRecon", "Version"), ".")
	
	local total = tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(revision)
	local myTotal = tonumber(myMajor) * 10000 + tonumber(myMinor) * 100 + tonumber(myRevision)
	
	
   	GhostRecon.knownUsers[sender] = versionString

	if not versionWarningIssued and myTotal < total then
		GhostRecon:TellUser(string.format("%s has version %s of Ghost: Recon - time for you to update!", sender, versionString), 1, 0, 0, true)
		versionWarningIssued = true
	end
end

function GhostRecon:RequestVersion(sender)
	if IsInGuild() then
		SendAddonMessage(CONST_ADDON, "SENDVERSION", "GUILD")
	end
end

local notifyHandlers = {
    ["CONTROL"] = ReceiveControlNotification,
    ["ABILITY"] = ReceiveAbilityNotification,
	["SPELLINFO"] = ReceiveSpellInfoNotification,
	["HEALINFO"] = ReceiveHealInfoNotification,
	["QUERY"] = ReceiveQueryRequest,
	["RESPONSE"] = ReceiveQueryResponse,
	["SEND"] = ReceiveSendRequest,
	["VERSION"] = ReceiveVersionCheck,
	["SENDVERSION"] = function()
		GhostRecon:SendVersion()
	end,
	["HELLO"] = function()
		GhostRecon:SendWelcome()		
		GhostRecon.useComms = true
	end,
	["WELCOME"] = function()
		GhostRecon:TellUser("Switching communications on - other guild members are using Ghost: Recon.")
		GhostRecon.useComms = true
	end,
}

local function OnReceiveNotification(f, event, addOn, msg, distribution, sender)
	if GhostReconDB.Settings.Active then
	    if addOn == CONST_ADDON and sender ~= UnitName("player") then
	    	if not GhostRecon.knownUsers[sender] then
		    	GhostRecon.knownUsers[sender] = true
	    	end
	    	
			if GhostReconDB.Settings.GuildSync then
		        local notifyType = CsvDecode(msg)
		        local func = notifyHandlers[notifyType]
		        
		        
		        if func then
		            func(sender, select(2, CsvDecode(msg)))
		        end
			end
		end
	end
end

local function OnEvent(f, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
		
	elseif event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
		
	elseif event == "CHAT_MSG_ADDON" then
		OnReceiveNotification(f, event, ...)
		
	elseif event == "ZONE_CHANGED" or
		   event == "ZONE_CHANGED_INDOORS" or
		   event == "ZONE_CHANGED_NEW_AREA" then
		GhostRecon:SendVersion()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		GhostRecon:SendHello()
	end
end

local function OnUpdate()
    -- send pending outgoing messages to keep spam under
    -- control in order to avoid disconnections
    if nextSendTime ~= nil then
        local curTime = GetTime()
        local msgSent
        
        
        if curTime >= nextSendTime then
            for msg, _ in pairs(outboundMessages) do
                if msgSent then
                    nextSendTime = curTime + 0.3333333333
                    break
                else
                    SendAddonMessage(CONST_ADDON, msg, "GUILD")
                    outboundMessages[msg] = nil
                    nextSendTime = nil
                    msgSent = true
                end
            end
        end
    end
    
    -- check query responses
   	for key, info in pairs(queries) do
   		local diff = GetTime() - info.askTime
   		
   		
   		if diff >= 5 then
   			-- find a sender and get them to tell us
   			local chosenSender
   			local highCount = 0
   			
   			
   			for who, count in pairs(info.respondants) do
   				if count > highCount then
   					highCount = count
   					chosenSender = who
   				end
   			end
   			
   			if chosenSender then
   				-- format a message to tell them to send the info
   				local msg = string.format("SEND,%s,%s,%s,%s", chosenSender, info.mobGuid, info.mobName, info.zone)
   				
   				
		        outboundMessages[msg] = true
		        
		        if nextSendTime == nil then
		            nextSendTime = GetTime()
		        end
   			end
   			
   			-- remove the entry - if we didn't get any responses
   			-- by this time, we'll assume we won't get any at all
			queries[key] = nil
   		end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", OnEvent)
frame:SetScript("OnUpdate", OnUpdate)
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_INDOORS")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
