-- Phase 1 placeholder data. Real map ID (1079) and boss creature IDs are
-- taken directly from Zygor's own guide (Guides/Dungeons/ZygorDungeon*LEGION.lua)
-- so the zone-detection and boss-kill-tracking pipeline can be tested live
-- in the real dungeon - only the guidance text itself is a stand-in, to be
-- replaced with real translated content in phase 2.
local instance = GITGUD.RegisterInstance(1079, "The Arcway", "dungeon")

local xakal = GITGUD.AddBoss(instance, "General Xakal", 98206)
GITGUD.SetBossText(xakal, "normal", "tank", "ЗАГЛУШКА: текст для танка (General Xakal) ещё не переведён.")
GITGUD.SetBossText(xakal, "normal", "healer", "ЗАГЛУШКА: текст для хилера (General Xakal) ещё не переведён.")
GITGUD.SetBossText(xakal, "normal", "dps", "ЗАГЛУШКА: текст для ДД (General Xakal) ещё не переведён.")

local naltira = GITGUD.AddBoss(instance, "Nal'tira", 98207)
GITGUD.SetBossText(naltira, "normal", "tank", "ЗАГЛУШКА: текст для танка (Nal'tira) ещё не переведён.")
GITGUD.SetBossText(naltira, "normal", "healer", "ЗАГЛУШКА: текст для хилера (Nal'tira) ещё не переведён.")
GITGUD.SetBossText(naltira, "normal", "dps", "ЗАГЛУШКА: текст для ДД (Nal'tira) ещё не переведён.")

local corstilax = GITGUD.AddBoss(instance, "Corstilax", 98205)
GITGUD.SetBossText(corstilax, "normal", "tank", "ЗАГЛУШКА: текст для танка (Corstilax) ещё не переведён.")
GITGUD.SetBossText(corstilax, "normal", "healer", "ЗАГЛУШКА: текст для хилера (Corstilax) ещё не переведён.")
GITGUD.SetBossText(corstilax, "normal", "dps", "ЗАГЛУШКА: текст для ДД (Corstilax) ещё не переведён.")

local ivanyr = GITGUD.AddBoss(instance, "Ivanyr", 98203)
GITGUD.SetBossText(ivanyr, "normal", "tank", "ЗАГЛУШКА: текст для танка (Ivanyr) ещё не переведён.")
GITGUD.SetBossText(ivanyr, "normal", "healer", "ЗАГЛУШКА: текст для хилера (Ivanyr) ещё не переведён.")
GITGUD.SetBossText(ivanyr, "normal", "dps", "ЗАГЛУШКА: текст для ДД (Ivanyr) ещё не переведён.")

local vandros = GITGUD.AddBoss(instance, "Advisor Vandros", 98208)
GITGUD.SetBossText(vandros, "normal", "tank", "ЗАГЛУШКА: текст для танка (Advisor Vandros) ещё не переведён.")
GITGUD.SetBossText(vandros, "normal", "healer", "ЗАГЛУШКА: текст для хилера (Advisor Vandros) ещё не переведён.")
GITGUD.SetBossText(vandros, "normal", "dps", "ЗАГЛУШКА: текст для ДД (Advisor Vandros) ещё не переведён.")
