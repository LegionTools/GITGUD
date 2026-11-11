-- GITGUD window: a boss list on the left (one row per encounter), a role
-- switcher and (for raids only) a difficulty switcher along the top, and
-- the selected boss/role/difficulty's guidance text on the right. Built
-- the same way as MountPetLink's disambiguation picker (plain frames,
-- BasicFrameTemplateWithInset with a manual-backdrop fallback, ElvUI skin
-- support) for consistency across this project's addons.

local DIFFICULTY_LABELS = { lfr = "ЛФР", normal_heroic = "ОБ/ГЕР", mythic = "МИФ" }
local DIFFICULTY_ORDER = { "lfr", "normal_heroic", "mythic" }
local ROLE_LABELS = { tank = "Танк", healer = "Хилер", dps = "ДД" }
local ROLE_ORDER = { "tank", "healer", "dps" }

local FRAME_WIDTH, FRAME_HEIGHT = 560, 420
local BOSS_LIST_WIDTH = 160
local BOSS_ROW_HEIGHT = 20

local SELECTED_COLOR = { 1, 0.82, 0 } -- gold, matches Blizzard's own "currently selected" convention
local KILLED_COLOR = { 0.5, 0.5, 0.5 }
local NORMAL_COLOR = { 1, 1, 1 }

GITGUD.currentInstance = nil
GITGUD.currentDifficulty = nil
GITGUD.currentRole = nil
GITGUD.selectedBossIndex = nil

local frame, bossScrollChild, contentText, contentScrollChild
local bossRows = {}
local roleButtons, difficultyButtons = {}, {}

local function SkinForElvUI(mainFrame, scrollFrames, closeButton)
	if not _G.ElvUI then return end
	local ok, E = pcall(unpack, _G.ElvUI)
	if not ok or not E then return end
	local S = E:GetModule("Skins")
	if not S then return end

	if type(mainFrame.StripTextures) == "function" then pcall(mainFrame.StripTextures, mainFrame) end
	if type(mainFrame.SetTemplate) == "function" then pcall(mainFrame.SetTemplate, mainFrame, "Default") end
	for _, scrollFrame in ipairs(scrollFrames) do
		local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
		if scrollBar then pcall(S.HandleScrollBar, S, scrollBar) end
	end
	if closeButton then pcall(S.HandleCloseButton, S, closeButton) end
end

local function CreateToggleButton(parent, label, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(70, 20)
	button:SetText(label)
	button:SetScript("OnClick", onClick)
	return button
end

local function SetButtonSelected(button, selected)
	if selected then
		button:GetFontString():SetTextColor(unpack(SELECTED_COLOR))
	else
		button:GetFontString():SetTextColor(unpack(NORMAL_COLOR))
	end
end

local function RefreshRoleButtons()
	for role, button in pairs(roleButtons) do
		SetButtonSelected(button, role == GITGUD.currentRole)
	end
end

local function RefreshDifficultyButtons()
	for difficultyKey, button in pairs(difficultyButtons) do
		SetButtonSelected(button, difficultyKey == GITGUD.currentDifficulty)
	end
end

local function GetOrCreateBossRow(index)
	if bossRows[index] then return bossRows[index] end
	local row = CreateFrame("Button", nil, bossScrollChild)
	row:SetSize(BOSS_LIST_WIDTH - 16, BOSS_ROW_HEIGHT)
	row:SetPoint("TOP", 0, -(index - 1) * BOSS_ROW_HEIGHT)
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

	row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.text:SetPoint("LEFT", 2, 0)
	row.text:SetPoint("RIGHT", -2, 0)
	row.text:SetJustifyH("LEFT")

	bossRows[index] = row
	return row
end

local function RefreshContent()
	local instance, boss = GITGUD.currentInstance, nil
	if instance then boss = instance.bosses[GITGUD.selectedBossIndex] end

	if not (instance and boss) then
		contentText:SetText("")
	else
		local byDifficulty = boss.difficulties[GITGUD.currentDifficulty]
		local text = byDifficulty and byDifficulty[GITGUD.currentRole]
		contentText:SetText(text or "Нет данных для этой роли/сложности.")
	end

	contentScrollChild:SetHeight(math.max(1, contentText:GetStringHeight()))
end

local function SelectBoss(index)
	GITGUD.selectedBossIndex = index
	for i, row in ipairs(bossRows) do
		local boss = GITGUD.currentInstance.bosses[i]
		if boss then
			local color = GITGUD.IsBossKilled(boss.creatureID) and KILLED_COLOR
				or (i == index and SELECTED_COLOR or NORMAL_COLOR)
			row.text:SetTextColor(color[1], color[2], color[3])
		end
	end
	RefreshContent()
end

-- Called by Core.lua (real kill or /gitgudkill) after marking a boss dead:
-- jumps the selection to the next not-yet-killed boss, same as on first
-- opening the window. No-op if the window isn't currently showing this
-- instance.
function GITGUD.OnBossKilled()
	if not (GITGUD.currentInstance and frame and frame:IsShown()) then return end
	local nextIndex = #GITGUD.currentInstance.bosses
	for i, boss in ipairs(GITGUD.currentInstance.bosses) do
		if not GITGUD.IsBossKilled(boss.creatureID) then
			nextIndex = i
			break
		end
	end
	SelectBoss(nextIndex)
end

local function SelectRole(role)
	GITGUD.currentRole = role
	RefreshRoleButtons()
	RefreshContent()
end

local function SelectDifficulty(difficultyKey)
	GITGUD.currentDifficulty = difficultyKey
	RefreshDifficultyButtons()
	RefreshContent()
end

local function PopulateBossList(instance)
	for i, boss in ipairs(instance.bosses) do
		local row = GetOrCreateBossRow(i)
		row.text:SetText(boss.name)
		row:SetScript("OnClick", function() SelectBoss(i) end)
		row:Show()
	end
	for i = #instance.bosses + 1, #bossRows do
		bossRows[i]:Hide()
	end
	bossScrollChild:SetHeight(#instance.bosses * BOSS_ROW_HEIGHT)
end

local function CreateFrameOnce()
	if frame then return frame end

	local ok, f = pcall(CreateFrame, "Frame", "GITGUDFrame", UIParent, "BasicFrameTemplateWithInset")
	if not ok or not f then
		f = CreateFrame("Frame", "GITGUDFrame", UIParent)
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
		f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
		f.CloseButton:SetPoint("TOPRIGHT", -2, -2)
	end

	f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.title:SetPoint("TOP", 0, -8)
	f.title:SetText("GITGUD")

	-- Difficulty row (top, under the title) - hidden entirely for dungeons.
	f.difficultyRow = CreateFrame("Frame", nil, f)
	f.difficultyRow:SetPoint("TOP", 0, -28)
	f.difficultyRow:SetSize(FRAME_WIDTH - 20, 24)
	local prevDiffButton
	for _, difficultyKey in ipairs(DIFFICULTY_ORDER) do
		local button = CreateToggleButton(f.difficultyRow, DIFFICULTY_LABELS[difficultyKey],
			function() SelectDifficulty(difficultyKey) end)
		if prevDiffButton then
			button:SetPoint("LEFT", prevDiffButton, "RIGHT", 4, 0)
		else
			button:SetPoint("LEFT", 0, 0)
		end
		difficultyButtons[difficultyKey] = button
		prevDiffButton = button
	end

	-- Role row, always shown.
	f.roleRow = CreateFrame("Frame", nil, f)
	f.roleRow:SetPoint("TOP", f.difficultyRow, "BOTTOM", 0, -4)
	f.roleRow:SetSize(FRAME_WIDTH - 20, 24)
	local prevRoleButton
	for _, role in ipairs(ROLE_ORDER) do
		local button = CreateToggleButton(f.roleRow, ROLE_LABELS[role], function() SelectRole(role) end)
		if prevRoleButton then
			button:SetPoint("LEFT", prevRoleButton, "RIGHT", 4, 0)
		else
			button:SetPoint("LEFT", 0, 0)
		end
		roleButtons[role] = button
		prevRoleButton = button
	end

	-- Boss list, left side, below the role row.
	local bossScrollFrame = CreateFrame("ScrollFrame", "GITGUDBossScrollFrame", f, "UIPanelScrollFrameTemplate")
	bossScrollFrame:SetPoint("TOPLEFT", f.roleRow, "BOTTOMLEFT", 0, -8)
	bossScrollFrame:SetPoint("BOTTOMLEFT", 10, 10)
	bossScrollFrame:SetWidth(BOSS_LIST_WIDTH)

	bossScrollChild = CreateFrame("Frame", nil, bossScrollFrame)
	bossScrollChild:SetSize(BOSS_LIST_WIDTH - 16, BOSS_ROW_HEIGHT)
	bossScrollFrame:SetScrollChild(bossScrollChild)

	-- Content pane, right side.
	local contentScrollFrame = CreateFrame("ScrollFrame", "GITGUDContentScrollFrame", f, "UIPanelScrollFrameTemplate")
	contentScrollFrame:SetPoint("TOPLEFT", bossScrollFrame, "TOPRIGHT", 12, 0)
	contentScrollFrame:SetPoint("BOTTOMRIGHT", -28, 10)

	contentScrollChild = CreateFrame("Frame", nil, contentScrollFrame)
	contentScrollChild:SetSize(1, 1) -- resized below once width is known
	contentScrollFrame:SetScrollChild(contentScrollChild)

	contentText = contentScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	-- A few pixels of left padding - flush against the scroll frame's own
	-- edge clipped the first glyph or two of the first line (confirmed
	-- live: "ЗАГЛУШКА" rendered as "ГЛУШКА").
	contentText:SetPoint("TOPLEFT", 6, 0)
	contentText:SetJustifyH("LEFT")
	contentText:SetJustifyV("TOP")
	local contentWidth = FRAME_WIDTH - BOSS_LIST_WIDTH - 66
	contentText:SetWidth(contentWidth)
	contentScrollChild:SetSize(contentWidth, 1)
	-- FontStrings don't support SetScript/OnTextChanged (that's an EditBox
	-- script) - RefreshContent resizes the scroll child by hand instead,
	-- right after every SetText.

	tinsert(UISpecialFrames, "GITGUDFrame")
	f:Hide()
	frame = f

	SkinForElvUI(f, { bossScrollFrame, contentScrollFrame }, f.CloseButton)
	return f
end

function GITGUD.ShowWindow(instance)
	CreateFrameOnce()

	GITGUD.currentInstance = instance
	frame.title:SetText(instance.name)

	local isRaid = instance.kind == "raid"
	frame.difficultyRow:SetShown(isRaid)
	frame.roleRow:ClearAllPoints()
	if isRaid then
		frame.roleRow:SetPoint("TOP", frame.difficultyRow, "BOTTOM", 0, -4)
	else
		frame.roleRow:SetPoint("TOP", frame, "TOP", 0, -28)
	end

	GITGUD.currentDifficulty = GITGUD.DetectDifficultyKey(instance)
	GITGUD.currentRole = GITGUD.DetectRole()
	RefreshDifficultyButtons()
	RefreshRoleButtons()

	PopulateBossList(instance)

	local nextIndex = 1
	for i, boss in ipairs(instance.bosses) do
		if not GITGUD.IsBossKilled(boss.creatureID) then
			nextIndex = i
			break
		end
		nextIndex = i -- all killed: leave it on the last boss
	end
	SelectBoss(nextIndex)

	frame:Show()
end

function GITGUD.ToggleWindow()
	if frame and frame:IsShown() then
		frame:Hide()
	elseif GITGUD.currentInstance then
		GITGUD.ShowWindow(GITGUD.currentInstance)
	else
		print("|cff33ccff[GITGUD]|r нет данных для текущего места - зайди в отслеживаемое подземелье/рейд, или используй /gitgudtest")
	end
end
