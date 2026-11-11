-- GITGUD: zone/role/difficulty detection, boss-kill progression tracking,
-- minimap button and slash commands. The window itself lives in UI.lua;
-- this file only tracks game state and decides when to show it.

GITGUD.killedBosses = {} -- keyed by creatureID, reset on entering a (new) tracked instance

function GITGUD.IsBossKilled(creatureID)
	return GITGUD.killedBosses[creatureID] or false
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

local function OnEnterWorld()
	local ok, isInInstance = pcall(IsInInstance)
	if not ok or not isInInstance then return end

	local ok2, _, _, _, _, _, _, _, instanceMapID = pcall(GetInstanceInfo)
	if not ok2 or not instanceMapID then return end

	local instance = GITGUD.instances[instanceMapID]
	if not instance then return end -- no GITGUD data for this place yet

	if GITGUD.currentInstance ~= instance then
		wipe(GITGUD.killedBosses)
	end
	GITGUD.ShowWindow(instance)
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

	button:SetScript("OnClick", function() GITGUD.ToggleWindow() end)

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
			wipe(GITGUD.killedBosses)
			GITGUD.ShowWindow(instance)
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
