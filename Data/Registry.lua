-- GITGUD's data schema. One instance (dungeon or raid) is registered per
-- data file (Data/<InstanceName>.lua), keyed by its map ID (same mapid
-- Zygor's own guide files use, since that's what GetInstanceInfo() reports
-- back at runtime too). Dungeons only ever use the "normal" difficulty
-- bucket (Zygor doesn't carry separate heroic/mythic 5-man text); raids use
-- "lfr" / "normal_heroic" / "mythic", matching how Zygor itself splits raid
-- guide text by difficulty.
--
-- This file defines the registration API only - it holds no actual
-- instance/boss data itself. Phase 1 ships two real instances (one dungeon,
-- one raid) with placeholder guidance text, wired to their real map IDs and
-- boss creature IDs, so the whole pipeline (zone detection, boss-kill
-- tracking, difficulty/role switching) can be tested live before any real
-- translated content exists. Phases 2/3 fill in more Data/<Name>.lua files
-- the same way, one instance at a time.

GITGUD = GITGUD or {}
GITGUD.instances = {} -- keyed by mapid
GITGUD.instancesByOrder = {} -- insertion order, for listing

function GITGUD.RegisterInstance(mapid, name, kind)
	local instance = { mapid = mapid, name = name, kind = kind, bosses = {} }
	GITGUD.instances[mapid] = instance
	tinsert(GITGUD.instancesByOrder, instance)
	return instance
end

function GITGUD.AddBoss(instance, name, creatureID)
	local boss = { name = name, creatureID = creatureID, difficulties = {} }
	tinsert(instance.bosses, boss)
	return boss
end

-- role is "tank" / "healer" / "dps" for a role-specific addition, or the
-- pseudo-role "everyone" for Zygor's "_EVERYONE:_" common tip - the UI
-- shows "everyone" once, above whichever role is currently selected,
-- rather than it being duplicated into all three role strings. A boss
-- with no addition for a given role simply gets no SetBossText call for
-- it; the UI falls back to "no extra tip for this role".
function GITGUD.SetBossText(boss, difficultyKey, role, text)
	boss.difficulties[difficultyKey] = boss.difficulties[difficultyKey] or {}
	boss.difficulties[difficultyKey][role] = text
end
