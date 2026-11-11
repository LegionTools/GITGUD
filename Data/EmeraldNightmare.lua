-- Phase 1 placeholder data for the first raid stub, used to exercise the
-- difficulty selector (dungeons only ever have one difficulty bucket, so
-- this is the only way to test that UI path before phase 3 fills in real
-- raid content). Real map ID (1094) and boss creature IDs are taken from
-- Zygor's own guide, same as TheArcway.lua.
local instance = GITGUD.RegisterInstance(1094, "Emerald Nightmare", "raid")

local function StubAllDifficulties(boss, label)
	for _, difficultyKey in ipairs({ "lfr", "normal_heroic", "mythic" }) do
		GITGUD.SetBossText(boss, difficultyKey, "everyone",
			string.format("ЗАГЛУШКА: общий текст (%s, %s) ещё не переведён.", label, difficultyKey))
		for _, role in ipairs({ "tank", "healer", "dps" }) do
			GITGUD.SetBossText(boss, difficultyKey, role,
				string.format("ЗАГЛУШКА: текст для %s (%s, %s) ещё не переведён.", role, label, difficultyKey))
		end
	end
end

local nythendra = GITGUD.AddBoss(instance, "Nythendra", 102672)
StubAllDifficulties(nythendra, "Nythendra")

local ilgynoth = GITGUD.AddBoss(instance, "Il'gynoth", 105393)
StubAllDifficulties(ilgynoth, "Il'gynoth")
