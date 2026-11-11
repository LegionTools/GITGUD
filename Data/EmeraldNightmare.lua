-- Map ID 1520, from BigWigs/Loader.lua - NOT Zygor's own mapid=1094 for
-- this guide (that turned out to be a different ID space entirely, see
-- the big comment in Registry.lua). Unlike The Arcway's 1516, this one
-- hasn't been confirmed live via /gitguddebug yet (would need an actual
-- raid run) - treat it as high-confidence, not certain.
local instance = GITGUD.RegisterInstance(1520, "Emerald Nightmare", "raid")

-- Nythendra: real translated content (Normal/Heroic only - LFR/Mythic
-- still placeholder, phase 3 territory), extracted from Zygor's
-- "Emerald Nightmare - Normal/Heroic" guide. bigwigsModule="Nythendra"
-- matches BigWigs_Legion/Nightmare/Nythendra.lua:13's
-- BigWigs:NewBoss("Nythendra", 1520, 1703) exactly, and the spell IDs
-- below (202977, 203552, 203096, 204463) are copied directly from that
-- same file's mod:GetOptions(), not guessed.
local nythendra = GITGUD.AddBoss(instance, "Nythendra", 102672, "Nythendra")

GITGUD.SetBossText(nythendra, "normal_heroic", "everyone",
	"• Периодически кастует <a href=\"spell:202977\">Заразное Дыхание</a> — бьёт конусом по позиции случайного игрока, наносит урон тикающим эффектом. Не стойте в конусе.\n" ..
	"• Когда энергия Нитхендры падает до 0%, начинается фаза <a href=\"spell:203552\">Сердце Роя</a> на 20 секунд — она стягивает к себе все Заражённые Пятна. Не попадайте под это.\n" ..
	"• Во время фазы Сердца Роя призывает жуков по всей комнате — они бьют по площади 3 раза перед смертью. Уворачивайтесь от них и от Заражённых Пятен одновременно.\n" ..
	"• Если на вас дебафф <a href=\"spell:203096\">Гниение</a> — убегайте от других игроков: наносит урон всем в радиусе 8 ярдов каждые 3 секунды в течение 9 секунд.\n" ..
	"• После спадания Гниения под вашими ногами остаётся Заражённая Земля.\n" ..
	"• (только на героике) Любой полученный урон в этом бою стакает дебафф Заражённость — каждый стак наносит увеличивающийся урон каждые 2 секунды; стаки спадают по окончании фазы Сердца Роя.")
GITGUD.SetBossText(nythendra, "normal_heroic", "tank",
	"Меняйтесь танками, когда основной танк получает <a href=\"spell:204463\">Нестабильное Гниение</a>.\n" ..
	"Получив Нестабильное Гниение, бегите в конец комнаты до его истечения — иначе нанесёт урон рейду и оставит несколько Заражённых Пятен.")

for _, difficultyKey in ipairs({ "lfr", "mythic" }) do
	GITGUD.SetBossText(nythendra, difficultyKey, "everyone",
		string.format("ЗАГЛУШКА: общий текст (Nythendra, %s) ещё не переведён.", difficultyKey))
	for _, role in ipairs({ "tank", "healer", "dps" }) do
		GITGUD.SetBossText(nythendra, difficultyKey, role,
			string.format("ЗАГЛУШКА: текст для %s (Nythendra, %s) ещё не переведён.", role, difficultyKey))
	end
end

-- Il'gynoth: still fully placeholder (phase 3). bigwigsModule="Il'gynoth"
-- matches BigWigs_Legion/Nightmare/Ilgynoth.lua:11's own NewBoss call.
local ilgynoth = GITGUD.AddBoss(instance, "Il'gynoth", 105393, "Il'gynoth")
for _, difficultyKey in ipairs({ "lfr", "normal_heroic", "mythic" }) do
	GITGUD.SetBossText(ilgynoth, difficultyKey, "everyone",
		string.format("ЗАГЛУШКА: общий текст (Il'gynoth, %s) ещё не переведён.", difficultyKey))
	for _, role in ipairs({ "tank", "healer", "dps" }) do
		GITGUD.SetBossText(ilgynoth, difficultyKey, role,
			string.format("ЗАГЛУШКА: текст для %s (Il'gynoth, %s) ещё не переведён.", role, difficultyKey))
	end
end
