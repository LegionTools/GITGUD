-- GITGUD: zone/role/difficulty detection, boss-kill progression tracking,
-- minimap button and slash commands. The window itself lives in UI.lua;
-- this file only tracks game state and decides when to show it.

GITGUD.killedBosses = {} -- keyed by creatureID, reset on entering a (new) tracked instance

function GITGUD.IsBossKilled(creatureID)
	return GITGUD.killedBosses[creatureID] or false
end

-- Clicking a spell link in the guidance text tries to deep-link straight
-- into BigWigs' own config for that boss. BigWigs_Options is its own
-- load-on-demand addon (the global BigWigsOptions doesn't exist until it's
-- loaded), and BigWigs' options UI has no public API for opening to a
-- specific module/spell - this walks the same AceGUI widget chain
-- BigWigsOptions:OpenConfig() itself builds (Frame -> TabGroup -> on
-- selecting "bigwigs"/"littlewigs", a TreeGroup -> on selecting the zone,
-- a DropdownGroup listing that zone's boss modules), using each widget's
-- own public AceGUI methods (:SelectTab/:SelectByValue/:SetGroup) rather
-- than any BigWigs-private function. Confirmed by reading
-- BigWigs_Options/Options.lua directly (OpenConfig, onTabGroupSelected,
-- onZoneShow) - this client's BigWigs version is frozen (private server,
-- never updates), so there's no ongoing breakage risk from relying on
-- this internal structure, only the risk of having read it wrong the
-- first time; hence the pcall and the fallback to just opening the
-- general config window if any step doesn't find what it expects.
local function GetBigWigsOptions()
	if not BigWigsOptions then
		pcall(UIParentLoadAddOn, "BigWigs_Options")
	end
	return BigWigsOptions
end

function GITGUD.OpenBigWigsConfigFor(instance, boss)
	local bwOptions = GetBigWigsOptions()
	if not bwOptions then
		print("|cff33ccff[GITGUD]|r BigWigs_Options isn't available on this client.")
		return
	end

	local moduleName = boss and boss.bigwigsModule
	local isRaid = instance.kind == "raid"

	local ok, err = pcall(function()
		local bw = bwOptions:IsOpen()
		if not bw then
			bwOptions:OpenConfig()
			bw = bwOptions:IsOpen()
		end
		if not bw then error("BigWigs config frame did not open") end
		if not moduleName then return end -- no installed module for this boss - general config is all we can offer

		local tabs
		for _, child in ipairs(bw.children or {}) do
			if child.SetTabs then
				tabs = child
				break
			end
		end
		if not tabs then error("could not find BigWigs' tab group widget") end

		tabs:SelectTab(isRaid and "bigwigs" or "littlewigs")

		local tree = tabs.children and tabs.children[1]
		if not tree or not tree.SetTree then error("could not find BigWigs' zone tree widget") end

		local headerValue = (isRaid and "BigWigs_" or "LittleWigs_") .. "Legion"
		tree:SelectByValue(("%s\001%d"):format(headerValue, instance.mapid))

		local outerContainer = tree.children and tree.children[1]
		local innerContainer = outerContainer and outerContainer.children and outerContainer.children[1]
		if innerContainer and innerContainer.SetGroup then
			innerContainer:SetGroup(moduleName)
		end
	end)

	if not ok then
		print("|cff33ccff[GITGUD]|r BigWigs deep-link failed (" .. tostring(err) .. "); opened the general config instead.")
	end
end

-- GetSpecializationRole-style APIs have been unreliable on this server for
-- other addons in this set (MountPetLink hit several missing/placeholder
-- APIs) - defensive pcalls throughout, defaulting to "dps" whenever
-- detection fails rather than erroring.
function GITGUD.DetectRole()
	local ok, specIndex = pcall(GetSpecialization)
	if ok and specIndex then
		local ok2, role = pcall(GetSpecializationRole, specIndex)
		if ok2 and role == "TANK" then return "tank" end
		if ok2 and role == "HEALER" then return "healer" end
	end
	return "dps"
end

-- Dungeons only ever have one difficulty bucket in Zygor's data (no
-- separate heroic/mythic 5-man text), so difficulty switching is only
-- meaningful - and only shown - for raids. difficultyID numbers below are
-- retail's: 14/15 share Normal/Heroic guide text in Zygor, 16 is Mythic,
-- 17 is LFR. Falls back to normal_heroic if detection fails or returns
-- something unrecognized.
function GITGUD.DetectDifficultyKey(instance)
	if instance.kind ~= "raid" then return "normal" end

	local ok, _, _, difficultyID = pcall(GetInstanceInfo)
	if ok and difficultyID then
		if difficultyID == 17 then return "lfr" end
		if difficultyID == 16 then return "mythic" end
		if difficultyID == 14 or difficultyID == 15 then return "normal_heroic" end
	end
	return "normal_heroic"
end

-- Shared by auto-open-on-zone-entry, /gitgudtest, and the minimap
-- right-click menu: wipes progression only when actually switching to a
-- different instance than whatever was last shown, so manually reopening
-- the instance you're already in doesn't lose track of killed bosses.
function GITGUD.OpenInstance(instance)
	if GITGUD.currentInstance ~= instance then
		wipe(GITGUD.killedBosses)
	end
	GITGUD.ShowWindow(instance)
end

local function OnEnterWorld()
	local ok, isInInstance = pcall(IsInInstance)
	if not ok or not isInInstance then return end

	local ok2, _, _, _, _, _, _, _, instanceMapID = pcall(GetInstanceInfo)
	if not ok2 or not instanceMapID then return end

	local instance = GITGUD.instances[instanceMapID]
	if not instance then return end -- no GITGUD data for this place yet

	GITGUD.OpenInstance(instance)
end

local function OnUnitDied(unitTarget)
	if not GITGUD.currentInstance then return end

	local guid = UnitGUID(unitTarget)
	if not guid then return end
	local _, _, _, _, _, npcID = strsplit("-", guid)
	npcID = tonumber(npcID)
	if not npcID then return end

	for _, boss in ipairs(GITGUD.currentInstance.bosses) do
		if boss.creatureID == npcID then
			GITGUD.killedBosses[npcID] = true
			GITGUD.OnBossKilled()
			break
		end
	end
end

local trackerFrame = CreateFrame("Frame")
trackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
trackerFrame:RegisterEvent("UNIT_DIED")
trackerFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		OnEnterWorld()
	elseif event == "UNIT_DIED" then
		OnUnitDied(...)
	end
end)

-- Right-click menu on the minimap button: two submenus ("Подземелья" /
-- "Рейды"), listing every registered instance of that kind - lets you jump
-- straight to any instance's guide without having to be there, same as
-- /gitgudtest but as a proper in-game menu. Standard Blizzard
-- UIDropDownMenu nested-menu pattern (level 1 = the two categories, level
-- 2 = the instances in whichever category was hovered).
local instanceMenuFrame

local function InstanceMenu_OnClick(_, instance)
	CloseDropDownMenus()
	GITGUD.OpenInstance(instance)
end

local function InstanceMenu_Initialize(_, level, menuList)
	if level == 1 then
		for _, entry in ipairs({ { text = "Подземелья", kind = "dungeon" }, { text = "Рейды", kind = "raid" } }) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = entry.text
			info.hasArrow = true
			info.menuList = entry.kind
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end
	elseif level == 2 and (menuList == "dungeon" or menuList == "raid") then
		local any = false
		for _, instance in ipairs(GITGUD.instancesByOrder) do
			if instance.kind == menuList then
				any = true
				local info = UIDropDownMenu_CreateInfo()
				info.text = instance.name
				info.notCheckable = true
				info.func = InstanceMenu_OnClick
				info.arg1 = instance
				UIDropDownMenu_AddButton(info, level)
			end
		end
		if not any then
			local info = UIDropDownMenu_CreateInfo()
			info.text = "(пока нет данных)"
			info.notCheckable = true
			info.disabled = true
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

local function ShowInstanceMenu(anchorFrame)
	local ok, err = pcall(function()
		if not instanceMenuFrame then
			instanceMenuFrame = CreateFrame("Frame", "GITGUDInstanceMenu", UIParent, "UIDropDownMenuTemplate")
			UIDropDownMenu_Initialize(instanceMenuFrame, InstanceMenu_Initialize, "MENU")
		end
		ToggleDropDownMenu(1, nil, instanceMenuFrame, anchorFrame, 0, 0)
	end)
	if not ok then
		print("|cff33ccff[GITGUD]|r instance menu failed: " .. tostring(err))
	end
end

-- Minimap button: a plain draggable button orbiting the minimap, same
-- pattern as APUser's, rather than pulling in a full LibDBIcon dependency
-- for one button.
local function CreateMinimapButton()
	local button = CreateFrame("Button", "GITGUDMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetTexture("Interface\\Icons\\INV_Misc_Book_16")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetAllPoints()

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(54, 54)
	border:SetPoint("TOPLEFT")

	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	button:SetPoint("CENTER", Minimap, "CENTER", 80, 0)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "RightButton" then
			ShowInstanceMenu(self)
		else
			GITGUD.ToggleWindow()
		end
	end)

	button:SetMovable(true)
	button:EnableMouse(true)
	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", function(self) self.dragging = true end)
	button:SetScript("OnDragStop", function(self) self.dragging = false end)
	button:SetScript("OnUpdate", function(self)
		if not self.dragging then return end
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		local dx, dy = px - mx, py - my
		local dist = math.sqrt(dx * dx + dy * dy)
		local radius = 80
		if dist > 0 then
			dx, dy = dx / dist * radius, dy / dist * radius
		end
		self:ClearAllPoints()
		self:SetPoint("CENTER", Minimap, "CENTER", dx, dy)
	end)
end
CreateMinimapButton()

SLASH_GITGUD1 = "/gitgud"
SlashCmdList["GITGUD"] = function()
	GITGUD.ToggleWindow()
end

-- /gitgudtest [substring] - force-opens a registered (possibly still
-- placeholder) instance by name without needing to travel there, so the
-- window itself can be reviewed/iterated on immediately after install.
SLASH_GITGUDTEST1 = "/gitgudtest"
SlashCmdList["GITGUDTEST"] = function(msg)
	local needle = (msg or ""):lower()
	for _, instance in ipairs(GITGUD.instancesByOrder) do
		if needle == "" or instance.name:lower():find(needle, 1, true) then
			GITGUD.OpenInstance(instance)
			return
		end
	end
	local names = {}
	for _, instance in ipairs(GITGUD.instancesByOrder) do tinsert(names, instance.name) end
	print("|cff33ccff[GITGUD]|r no matching stub instance. Available: " .. table.concat(names, ", "))
end

-- /gitgudkill <creatureID> - marks a boss dead without actually killing it,
-- so progression tracking (next-boss auto-select, grey-out) can be tested
-- without running the instance.
SLASH_GITGUDKILL1 = "/gitgudkill"
SlashCmdList["GITGUDKILL"] = function(msg)
	local creatureID = tonumber(msg)
	if not creatureID then
		print("|cff33ccff[GITGUD]|r usage: /gitgudkill <creatureID>")
		return
	end
	GITGUD.killedBosses[creatureID] = true
	GITGUD.OnBossKilled()
	print("|cff33ccff[GITGUD]|r marked creatureID " .. creatureID .. " as killed.")
end

-- /gitguddebug - the auto-open window in The Arcway didn't fire; this
-- dumps exactly what IsInInstance()/GetInstanceInfo() return on this
-- client so the mismatch can be diagnosed from evidence instead of
-- guessed at (this server's build may not return instanceMapID in the
-- same position retail does, or at all).
SLASH_GITGUDDEBUG1 = "/gitguddebug"
SlashCmdList["GITGUDDEBUG"] = function()
	local ok, isInInstance, instanceType = pcall(IsInInstance)
	print(string.format("|cff33ccff[GITGUD]|r IsInInstance() ok=%s isInInstance=%s instanceType=%s",
		tostring(ok), tostring(isInInstance), tostring(instanceType)))

	local results = { pcall(GetInstanceInfo) }
	print("|cff33ccff[GITGUD]|r GetInstanceInfo() ok=" .. tostring(results[1]))
	if results[1] then
		local labels = { "name", "instanceType", "difficultyID", "difficultyName", "maxPlayers",
			"dynamicDifficulty", "isDynamic", "instanceMapID", "instanceGroupSize", "LfgDungeonID" }
		for i = 2, #results do
			print(string.format("  [%d] %s = %s", i - 1, labels[i - 1] or "?", tostring(results[i])))
		end
	end

	print("|cff33ccff[GITGUD]|r registered mapids: " .. table.concat((function()
		local ids = {}
		for mapid in pairs(GITGUD.instances) do tinsert(ids, tostring(mapid)) end
		return ids
	end)(), ", "))
end
