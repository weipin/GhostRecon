local CONST_PADDING = 6
local CONST_SIZE = 48
local CONST_COLUMNS = 6

local frm = CreateFrame("Frame", "GhostReconBrowser", UIParent)

local mouseOverMob
local suppressMobClear
local nextId = 1

local LBF = LibStub and LibStub("LibButtonFacade", true)
local GhostCCLBFGroup = nil

if LBF then
	GhostCCLBFGroup = LBF:Group("Ghost: Recon")
end

-- zone handling
local function GetMobsForZone(zone)
	local rc = { }
	local info = GhostReconDB.Instances[zone]
	
	
	if info then
		for i, _ in pairs(info) do
			if i ~= "isInstance" then
				table.insert(rc, i)
			end
		end
	end
	
	return rc
end

local function GetZoneForMob(mob)
	local rc
	local rc2
	local zone
	local info
	local stop
	
	
	if mob then
		local inMob = string.lower(mob)
		
		
		for zone, info in pairs(GhostReconDB.Instances) do
			local curMob
			
			
			for curMob, _ in pairs(info) do
				local compMob = string.lower(curMob)
				
				
				if compMob == inMob then
					rc = zone
					rc2 = curMob
						
					if string.len(zone) > 7 then
						if string.sub(zone, 1, 7) == "Heroic " then
							stop = true
							break
						end
					end
				end
			end
			
			if stop then
				break
			end
		end
	end
		
	return rc, rc2
end

local function SetMobHistory()
	local mobs = GetMobsForZone(frm.Zone:GetText())
	local count = 0
	
	
	frm.Mob:SetHistoryLines(1)
	
	table.sort(mobs)
	
	for _, v in pairs(mobs) do
		count = count + 1
		frm.Mob:SetHistoryLines(count+1)
		frm.Mob:AddHistoryLine(v)
	end
end

-- the category frame
frm:SetWidth(350)
frm:SetHeight(400)
frm:Hide()
frm.name = "Search"
frm.parent = "Ghost: Recon"
frm:SetScript("OnShow", function()
	frm.Zone:SetText(GhostRecon:WhereAmI())
	SetMobHistory()
	frm.Mob:SetText("")
	frm.Mob:SetFocus()
end)

-- helpers
local function ReportCurrentMob(who)
	if frm.spellFrame.spellCount > 0 then
		local i
		local name = frm.Mob:GetText()
		local msg = ""
		local curCount = 0
		

		GhostRecon:Announce(string.format("Ghost: Recon - Spells and Abilities of '%s'...", name), who)
		
		for i = 1, frm.spellFrame.spellCount do
			curCount = curCount + 1
			
			if curCount > 5 then
				curCount = 1			
				GhostRecon:Announce("- "..msg, who)
				msg = ""
			end
			
			if curCount > 1 then
				msg = msg..", "
			end
			
			msg = msg..frm.spellFrame.spellFrames[i].hyperlink
		end
		
		if string.len(msg) > 0 then
			GhostRecon:Announce("- "..msg, who)
		end
		
		
		-- notes
		local notes = GhostRecon:GetNotes(frm.Zone:GetText(), "", frm.Mob:GetText())
		
		
		if notes ~= nil and string.len(notes) > 0 then
			GhostRecon:Announce("Notes: "..notes, who)
		end
	end
end

-- frames
local function CreateSpellFrame(spellId, parent)
    local rc = CreateFrame("Button", "GhostReconSpellSearch"..nextId, parent)
    
    
    rc.altSpellIds = { }
    
    rc.spellImage = rc:CreateTexture(nil, "ARTWORK")
	rc.spellImage:SetAllPoints(rc)

	rc.dispelFrame = rc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rc.dispelFrame:SetAllPoints(rc)
	rc.dispelFrame:SetJustifyV("BOTTOM")
	rc.dispelFrame:SetJustifyH("RIGHT")
	rc.dispelFrame:SetShadowColor(0, 0, 0)
	rc.dispelFrame:SetShadowOffset(-1, 1)
	rc.dispelFrame:SetTextColor(0.3, 1, 0.3)
	rc.dispelFrame:SetText("D")
	rc.dispelFrame:Hide()

    rc:EnableMouse(true)
    rc:RegisterForClicks("LeftButton")
    rc:SetScript("OnMouseDown", function(this)
    	if IsShiftKeyDown() then
	   		if ChatFrameEditBox:IsVisible() then
		    	ChatFrameEditBox:Insert(this.hyperlink)
	    	else
	    		GhostRecon:Announce(this.hyperlink)
	    	end
		end
		
	    if IsAltKeyDown() then
	    	ReportCurrentMob()
	    end
    end)
    rc:SetScript("OnEnter", function(this)
		GameTooltip_SetDefaultAnchor(GameTooltip, this)
    	GameTooltip:SetHyperlink(this.hyperlink)
    	GameTooltip:Show()
    end)
    rc:SetScript("OnLeave", function(this)
    	GameTooltip:FadeOut()
    end)
    
    function rc:SetSize(value)
        rc:SetWidth(value)
        rc:SetHeight(value)
    end
    
    rc.SetSpell = function(this, spellId)
        local _, _, image = GetSpellInfo(spellId)
        
        
        this.spellImage:SetTexture(image)
        this.spellId = spellId
        this.hyperlink = GetSpellLink(spellId)

        if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[spellId] and GhostReconDB.SpellInfo[spellId].removable then
			this.dispelFrame:SetText("D")
	        this.dispelFrame:Show()
	    else
	        this.dispelFrame:Hide()
	    end

        if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[spellId] and GhostReconDB.SpellInfo[spellId].healType ~= nil then
			this.dispelFrame:SetText("H")
	        this.dispelFrame:Show()
	    else
	        this.dispelFrame:Hide()
	    end
    end
    
    rc:SetSize(CONST_SIZE)
    
    if GhostCCLBFGroup then
	    GhostCCLBFGroup:AddButton(rc, { ["Icon"] = rc.spellImage } )
	end
	
	rc.FrameRepresentsSpell = function(this, spellId)
		local retCode
		
		
		if this.spellId == spellId then
			retCode = true
			
		elseif this.altSpellIds then
			retCode = this.altSpellIds[spellId]
			
		end
		
		return retCode
	end
	
    nextId = nextId + 1
    
    return rc
end

local function CreateSpellBar()
    local rc = CreateFrame("Frame", "GhostReconSearchSpellBar", frm)
    
    
    -- preview bar
    rc.spellCount = 0
    rc.spellFrames = { }
    
    rc.LayoutSpells = function(this)
        local curX = 0
        local curY = 0
        local curCol = 1
        local curRow = 1

        
        for i = 1, this.spellCount do
        	local v = this.spellFrames[i]


			curX = (curCol - 1) * (CONST_SIZE + CONST_PADDING)
			curY = (curRow - 1) * (CONST_SIZE + CONST_PADDING)

            v:SetPoint("TOPLEFT", rc, "TOPLEFT", curX, -curY)
            v.spellImage:SetAllPoints(v)
            v:SetSize(CONST_SIZE)
            v:Show()

			curCol = curCol + 1
			
			if curCol > CONST_COLUMNS then
				curCol = 1
				curRow = curRow + 1
			end
        end

		if GhostReconDB.SkinSettings and GhostCCLBFGroup then
			GhostCCLBFGroup.Colors = GhostReconDB.SkinSettings.Colors or GhostCCLBFGroup.Colors
			GhostCCLBFGroup:Skin(GhostReconDB.SkinSettings.SkinID, GhostReconDB.SkinSettings.Gloss, GhostReconDB.SkinSettings.Backdrop)
		end

		local maxCols = math.min(this.spellCount, CONST_COLUMNS)
		local maxRows = math.floor(this.spellCount / maxCols)
		
		
		if (this.spellCount / maxCols) % 1 > 0 then
			maxRows = maxRows + 1
		end
		
		rc:SetWidth(maxCols * CONST_SIZE + (maxCols - 1) * CONST_PADDING)
		rc:SetHeight(maxRows * CONST_SIZE + (maxRows - 1) * CONST_PADDING)
    end
    
    rc.SetSpells = function(this, spells)
        local posn = 1
        local didSomething = false
   		local namesSeen = { }
        	
        	
        if spells then
	        for _, info in pairs(spells) do
	            local curSpellFrame = this.spellFrames[posn]

	            
				if not namesSeen[info.name] then
					namesSeen[info.name] = true
					
		            if not curSpellFrame then
		                curSpellFrame = CreateSpellFrame(info.spellId, this)
		                table.insert(this.spellFrames, curSpellFrame)
		                created = true
		            end
		            
		            curSpellFrame:SetSpell(info.spellId)
		            curSpellFrame:Show()
		            posn = posn + 1
		            
		            didSomething = true
		        else
	      			this.spellFrames[posn-1].altSpellIds[info.spellId] = true
		        end
	        end
	    end

        for j = posn, this.spellCount do
        	if this.spellFrames[j] then
        		this.spellFrames[j]:Hide()
        	end
        end
	        
        this.spellCount = posn - 1
        this:LayoutSpells()
        
		if this.spellCount == 0 then
			this:Hide()
		end
    end

    return rc
end

local function SpellsForMob(mobGuid, mobName, zone)
    local whereInfo = GhostReconDB.Instances[zone] or { }
    local mobInfo = whereInfo[mobName] or { }
	local t = { }
	
	
	if mobInfo.spells then
		for i, _ in pairs(mobInfo.spells) do
			local info = { }
			local name = GetSpellInfo(i)
			
			
			info.spellId = i
			info.name = name
			
			table.insert(t, info)
		end
		
		table.sort(t, function(a, b)
			if a.name < b.name then
				return true
			end
		end)
	end
		
	return t
end

local function ClearPanel(zone, mob)
	if zone then
		frm.Zone:SetText("")
	end
	
	if mob then
		frm.Mob:SetText("")
	end
	
	frm.spellFrame:Hide()
	frm.SpellLabel:Hide()
	frm.MobProxy:Hide()
end

local function InputValid()
	local rc
	
	
	if GhostReconDB.Instances[frm.Zone:GetText()] then
		if GhostReconDB.Instances[frm.Zone:GetText()][frm.Mob:GetText()] then
			rc = true
		end
	end
	
	return rc
end

local function UpdateTooltip()
	if InputValid() then
		if mouseOverMob then
			GameTooltip_SetDefaultAnchor(GameTooltip, this)
			GameTooltip:SetUnit("player")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(frm.Mob:GetText().." ("..frm.Zone:GetText()..")")
			GhostRecon:DecorateTooltip("", frm.Mob:GetText(), false, frm.Zone:GetText(), true)
			GameTooltip:Show()
		else
			if GameTooltip:IsVisible() then
				GameTooltip:FadeOut()
			end
		end
	else
		GameTooltip:FadeOut()
	end
end

local function InfoVisible(value)
	if value then
		if frm.spellFrame.spellCount > 0 then
			frm.spellFrame:Show()
			frm.SpellLabel:Show()
			frm.ReportMob:Enable()
			frm.WhisperMob:Enable()
		else
			frm.spellFrame:Hide()
			frm.SpellLabel:Hide()
			frm.ReportMob:Disable()
			frm.WhisperMob:Disable()
		end
		
		frm.ClearMob:Enable()
		frm.MobProxy:Show()
		frm.Notes:Show()
		frm.NotesLabel:Show()
	else
		frm.ReportMob:Disable()
		frm.WhisperMob:Disable()
		frm.ClearMob:Disable()
		frm.spellFrame:Hide()
		frm.SpellLabel:Hide()
		frm.MobProxy:Hide()
		frm.Notes:Hide()
		frm.NotesLabel:Hide()
	end
	
	UpdateTooltip()
end

local function ZoneHasMobs(zone)
	local rc
	local info = GhostReconDB.Instances[zone]
	
	
	if info then
		for i, _ in pairs(info) do
			if i ~= "isInstance" then
				rc = true
				break
			end
		end
	end
	
	return rc
end

local function GetZoneList()
	local rc = { }
	
	
	for i, _ in pairs(GhostReconDB.Instances) do
		if string.len(i) > 0 then
			if ZoneHasMobs(i) then
				table.insert(rc, i)
			end
		end
	end
	
	return rc
end

local function CreateComboBox(name, parent)
	local rc
	
	
	rc = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
	
	function rc:init()
		if rc.list ~= nil then
			local info = UIDropDownMenu_CreateInfo()			
			local items
			
			
			if type(rc.list) == "function" then
				items = rc.list()
			else
				items = rc.list
			end
			
			table.sort(items)
	
			for i, v in pairs(items) do
				info.text = v
				info.value = i
				info.func = function()
					UIDropDownMenu_SetSelectedValue(self, i)
					
					if self.OnItemClick then
						self.OnItemClick(self, v)
					end
				end
				info.checked = nil
				info.icon = nil
				UIDropDownMenu_AddButton(info, 1)
			end
		end
	end
	
	UIDropDownMenu_Initialize(rc, rc.init)

	return rc
end

-- spell frame
frm.spellFrame = CreateSpellBar()
frm.spellFrame:SetPoint("TOPLEFT", frm, "TOPLEFT", 72, -141)
frm.spellFrame:Hide()
-- spell label
frm.SpellLabel = frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frm.SpellLabel:SetWidth(52)
frm.SpellLabel:SetHeight(20)
frm.SpellLabel:SetPoint("TOPLEFT", 8, -137)
frm.SpellLabel:SetJustifyH("RIGHT")
frm.SpellLabel:SetTextColor(1, 1, 1)
frm.SpellLabel:SetText("Abilities")

-- title
frm.Title = frm:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frm.Title:SetWidth(340)
frm.Title:SetHeight(20)
frm.Title:SetPoint("TOPLEFT", 15, -14)
frm.Title:SetJustifyH("LEFT")
frm.Title:SetText("Ghost: Recon - Mob Search")

-- zone text box
frm.Zone = CreateFrame("EditBox", "GhostReconZone", frm, "InputBoxTemplate")
frm.Zone:SetPoint("TOPLEFT", 72, -48)
frm.Zone:SetTextInsets(0, 0, 0, 0)
frm.Zone:SetWidth(256)
frm.Zone:SetHeight(32)
frm.Zone:SetAutoFocus(false)
frm.Zone:SetScript("OnTextChanged", function()
	local zones = GetZoneList()
	local curText = frm.Zone:GetText()
	local current = nil
	local count = 0
	
	
--	frm.Mob:SetText("")
	
	for _, v in pairs(zones) do
		local curZone = v
		
		
		-- match it up with what we typed
		local l = math.min(string.len(curText), string.len(curZone))
		local comp = string.sub(curText, 1, l)
		

		if string.lower(comp) == string.lower(string.sub(curZone, 1, l)) then
			current = v
			count = count + 1
		end
	end
	
	if count == 1 then
		frm.Zone:SetText(current)
		SetMobHistory()
	end
	
	InfoVisible(InputValid())
end)
frm.Zone:SetScript("OnTabPressed", function()
	frm.Mob:SetFocus()
	frm.Mob:HighlightText()
end)
-- zone label
frm.ZoneLabel = frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frm.ZoneLabel:SetWidth(52)
frm.ZoneLabel:SetHeight(20)
frm.ZoneLabel:SetPoint("TOPLEFT", 8, -54)
frm.ZoneLabel:SetJustifyH("RIGHT")
frm.ZoneLabel:SetTextColor(1, 1, 1)
frm.ZoneLabel:SetText("Zone")

-- mob text box
frm.Mob = CreateFrame("EditBox", "GhostReconMob", frm, "InputBoxTemplate")
frm.Mob:SetPoint("TOPLEFT", 72, -77)
frm.Mob:SetTextInsets(0, 0, 0, 0)
frm.Mob:SetWidth(256)
frm.Mob:SetHeight(32)
frm.Mob:SetAutoFocus(false)
frm.Mob:SetScript("OnTextChanged", function()
	if frm.Zone:GetText() == "" then
		local foundZone, realMobName = GetZoneForMob(frm.Mob:GetText())
		
		
		if foundZone then
			frm.Zone:SetText(foundZone)
			frm.Mob:SetText(realMobName)
		end
	else
		local mobs = GetMobsForZone(frm.Zone:GetText())
		local curText = frm.Mob:GetText()
		local current = nil
		local count = 0
		
		
		for _, v in pairs(mobs) do
			local curMob = v
			
			
			-- match it up with what we typed
			local l = math.min(string.len(curText), string.len(curMob))
			local comp = string.sub(curText, 1, l)
			
	
			if string.lower(comp) == string.lower(string.sub(curMob, 1, l)) then
				current = v
				count = count + 1
			end
		end
		
		if count == 1 then
			frm.Mob:SetText(current)
		end
	end
	
	if InputValid() then
		local spells = SpellsForMob("", frm.Mob:GetText(), frm.Zone:GetText())
		
		
		frm.spellFrame:SetSpells(spells)
		frm.Notes:SetText(GhostRecon:GetNotes(frm.Zone:GetText(), "", frm.Mob:GetText()))
		InfoVisible(true)
	else
		InfoVisible(false)
	end
end)
frm.Mob:SetScript("OnTabPressed", function()
	frm.Zone:SetFocus()
	frm.Zone:HighlightText()
end)
-- mob label
frm.MobLabel = frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frm.MobLabel:SetWidth(52)
frm.MobLabel:SetHeight(20)
frm.MobLabel:SetPoint("TOPLEFT", 8, -83)
frm.MobLabel:SetJustifyH("RIGHT")
frm.MobLabel:SetTextColor(1, 1, 1)
frm.MobLabel:SetText("Mob")

-- mob-icon frame
frm.MobProxy = CreateFrame("Button", "GhostReconMobProxy", frm)
frm.MobProxy:SetPoint("TOPLEFT", frm, "TOPLEFT", 336, -50)
frm.MobProxy:SetWidth(56)
frm.MobProxy:SetHeight(56)
frm.MobProxy.texture = frm.MobProxy:CreateTexture(nil, "ARTWORK")
frm.MobProxy.texture:SetTexture("Interface\\AddOns\\GhostRecon\\Recon.tga")
frm.MobProxy.texture:SetAllPoints(frm.MobProxy)
frm.MobProxy:EnableMouse(true)
--frm.MobProxy:SetScript("OnEnter", function()
--	mouseOverMob = true
--	UpdateTooltip()
--end)
--frm.MobProxy:SetScript("OnLeave", function()
--	mouseOverMob = false
--	UpdateTooltip()
--end)
if GhostCCLBFGroup then
	GhostCCLBFGroup:AddButton(frm.MobProxy, { ["Icon"] = frm.MobProxy.texture } )
end
	

-- notes
frm.Notes = CreateFrame("EditBox", "GhostReconMobNotes", frm, "InputBoxTemplate")
frm.Notes:SetMaxLetters(248)
frm.Notes:SetPoint("TOPLEFT", 72, -106)
frm.Notes:SetTextInsets(0, 0, 0, 0)
frm.Notes:SetWidth(320)
frm.Notes:SetHeight(32)
frm.Notes:SetAutoFocus(false)
frm.Notes:SetScript("OnTextChanged", function()
	if InputValid() then
		GhostRecon:SetNotes(frm.Zone:GetText(), "", frm.Mob:GetText(), frm.Notes:GetText())
	end
end)

-- notes
frm.NotesLabel = frm:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frm.NotesLabel:SetWidth(52)
frm.NotesLabel:SetHeight(20)
frm.NotesLabel:SetPoint("TOPLEFT", 8, -112)
frm.NotesLabel:SetJustifyH("RIGHT")
frm.NotesLabel:SetTextColor(1, 1, 1)
frm.NotesLabel:SetText("Notes")


-- clear mob data
frm.ClearMob = CreateFrame("Button", nil, frm, "UIPanelButtonTemplate")
frm.ClearMob:SetScript("OnClick", function()
	StaticPopup_Show("GhostReconClearMob")
end)
frm.ClearMob:RegisterForClicks("LeftButtonUp")
frm.ClearMob:SetPoint("BOTTOMRIGHT", frm, "BOTTOMRIGHT", -16, 16)
frm.ClearMob:EnableMouse()
frm.ClearMob:SetText("Clear Mob")
frm.ClearMob:SetWidth(112)
frm.ClearMob:SetHeight(24)
frm.ClearMob:Disable()
-- confirmation dialog
StaticPopupDialogs["GhostReconClearMob"] = {
	text = "Do you really want to remove information about this mob from the database?",
	button1 = "Yes",
	button2 = "No",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	OnAccept = function()
		GhostReconDB.Instances[frm.Zone:GetText()][frm.Mob:GetText()] = nil
		frm.spellFrame:Hide()
		ClearPanel(false, true)
		SetMobHistory()
		frm.Mob:SetFocus()
	end,
}

-- whisper mob data
frm.WhisperMob = CreateFrame("Button", nil, frm, "UIPanelButtonTemplate")
frm.WhisperMob:SetScript("OnClick", function()
	StaticPopup_Show("GhostReconWhisper")
end)
frm.WhisperMob:RegisterForClicks("LeftButtonUp")
frm.WhisperMob:SetPoint("BOTTOMLEFT", frm, "BOTTOMLEFT", 136, 16)
frm.WhisperMob:EnableMouse()
frm.WhisperMob:SetText("Whisper")
frm.WhisperMob:SetWidth(112)
frm.WhisperMob:SetHeight(24)
frm.WhisperMob:Disable()
StaticPopupDialogs["GhostReconWhisper"] = {
  name = "GRStaticPopupWhisper",
	text = "Report the spells and abilities to who?",
	button1 = "Okay",
	button2 = "Cancel",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	hasEditBox = 1,
	OnAccept = function(self)
		local who = getglobal(self:GetName().."EditBox"):GetText()
		
		
		if who ~= nil and string.len(who) > 0 then
			ReportCurrentMob(who)
		end
	end,
}

-- report mob data
frm.ReportMob = CreateFrame("Button", nil, frm, "UIPanelButtonTemplate")
frm.ReportMob:SetScript("OnClick", function()
	ReportCurrentMob()
end)
frm.ReportMob:RegisterForClicks("LeftButtonUp")
frm.ReportMob:SetPoint("BOTTOMLEFT", frm, "BOTTOMLEFT", 16, 16)
frm.ReportMob:EnableMouse()
frm.ReportMob:SetText("Report")
frm.ReportMob:SetWidth(112)
frm.ReportMob:SetHeight(24)
frm.ReportMob:Disable()

InterfaceOptions_AddCategory(frm)

GhostRecon.browser = frm
