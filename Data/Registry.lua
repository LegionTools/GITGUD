-- GITGUD's data schema. One instance (dungeon or raid) is registered per
-- data file (Data/<InstanceName>.lua), keyed by its REAL map ID - the one
-- GetInstanceInfo()'s instanceMapID return value reports at runtime.
--
-- IMPORTANT: Zygor's own "mapid" field (in its RegisterGuide() extra table)
-- is NOT this ID - confirmed live (a /gitguddebug dump inside The Arcway
-- showed instanceMapID=1516, while Zygor's guide entry for the same
-- dungeon has mapid=1079). Zygor's mapid is some other ID space of its
-- own (likely tied to its path/map-overlay rendering), so it must never be
-- used for instance registration here even though it's tempting to reuse
-- while reading Zygor's data for boss names/creatureIDs/text.
--
-- The real IDs instead come from BigWigs/Loader.lua, which keys its
-- addon-loading table by the same instanceMapID GetInstanceInfo() returns.
-- Confirmed-correct values as of this writing (Legion, from that file):
--   Dungeons: 1544 Assault on Violet Hold, 1677 Cathedral of Eternal Night,
--     1571 Court of Stars, 1651 Return to Karazhan, 1501 Black Rook Hold,
--     1516 The Arcway, 1466 Darkheart Thicket, 1458 Neltharion's Lair,
--     1456 Eye of Azshara, 1492 Maw of Souls, 1477 Halls of Valor,
--     1493 Vault of the Wardens, 1753 Seat of the Triumvirate.
--   Raids: 1520 The Emerald Nightmare, 1648 Trial of Valor, 1530 The
--     Nighthold, 1676 Tomb of Sargeras, 1712 Antorus the Burning Throne.
-- Treat these as high-confidence but not certain for THIS server - if a
-- future instance's auto-open doesn't fire, /gitguddebug while standing
-- inside it is the way to confirm/correct it, same as how 1516 got
-- confirmed for The Arcway.
--
-- Dungeons only ever use the "normal" difficulty bucket (Zygor doesn't
-- carry separate heroic/mythic 5-man text); raids use "lfr" /
-- "normal_heroic" / "mythic", matching how Zygor itself splits raid guide
-- text by difficulty.
--
-- This file defines the registration API only - it holds no actual
-- instance/boss data itself. Phase 1 shipped two real instances (one
-- dungeon, one raid) with placeholder guidance text so the whole pipeline
-- (zone detection, boss-kill tracking, difficulty/role switching) could be
-- tested live before any real translated content existed. Phase 2 is now
-- filling in real content one dungeon at a time, same file-per-instance
-- pattern; phase 3 will do the same for raids.

GITGUD = GITGUD or {}
GITGUD.instances = {} -- keyed by mapid
GITGUD.instancesByOrder = {} -- insertion order, for listing

function GITGUD.RegisterInstance(mapid, name, kind)
	local instance = { mapid = mapid, name = name, kind = kind, bosses = {} }
	GITGUD.instances[mapid] = instance
	tinsert(GITGUD.instancesByOrder, instance)
	return instance
end

-- bigwigsModule (optional) is BigWigs' own internal module name for this
-- boss - the exact first argument passed to BigWigs:NewBoss(...) in that
-- boss's file (confirmed by reading the installed BigWigs_Legion source;
-- e.g. Nightmare/Nythendra.lua:13 is
-- `BigWigs:NewBoss("Nythendra", 1520, 1703)`, so bigwigsModule="Nythendra"
-- here deep-links correctly). Only set it when a real BigWigs module for
-- this exact boss is actually installed - leave it nil otherwise (e.g. no
-- LittleWigs zone content is installed for any Legion dungeon on this
-- client at all, confirmed by checking the AddOns folder, so no dungeon
-- boss should ever get one right now). When nil, clicking a spell link
-- for this boss just opens BigWigs' general config instead of deep-linking.
function GITGUD.AddBoss(instance, name, creatureID, bigwigsModule)
	local boss = { name = name, creatureID = creatureID, difficulties = {}, bigwigsModule = bigwigsModule }
	tinsert(instance.bosses, boss)
	return boss
end

-- role is "tank" / "healer" / "dps" for a role-specific addition, or the
-- pseudo-role "everyone" for Zygor's "_EVERYONE:_" common tip - the UI
-- shows "everyone" once, above whichever role is currently selected,
-- rather than it being duplicated into all three role strings. A boss
-- with no addition for a given role simply gets no SetBossText call for
-- it; the UI falls back to "no extra tip for this role".
--
-- text is now a small HTML subset (rendered via a SimpleHTML widget, not
-- a plain FontString) so spell names can be tagged as clickable links:
-- write `<a href="spell:12345">Spell Name</a>` inline wherever a spell is
-- mentioned - hovering shows its real tooltip (GameTooltip:SetHyperlink),
-- clicking tries to deep-link into that boss's BigWigs options (see
-- Core.lua's GITGUD.OpenBigWigsConfigFor). "\n" is still used for line
-- breaks within a role's text (converted to <br/> at render time) -
-- don't write raw <br/> in these strings directly.
function GITGUD.SetBossText(boss, difficultyKey, role, text)
	boss.difficulties[difficultyKey] = boss.difficulties[difficultyKey] or {}
	boss.difficulties[difficultyKey][role] = text
end
